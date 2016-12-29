require 'json'
require 'pathname'
require_relative 'cl_args_parser'

module BranchCloner

  class Config
    attr_reader :config_filename
    attr_reader :config
    attr_reader :repositories

    CMD_CHECKOUT = 'checkout'
    CMD_UPDATE = 'update'

    MODES = {'checkout' => CMD_CHECKOUT,
             'update' => CMD_UPDATE
    }

    ATTR_REPO_CONFIG = 'repository_config'
    ATTR_REPO_TOOL_CONFIG = 'repository_tool_config'
    ATTR_CODE = 'code'
    ATTR_DESCRIPTION = 'description'
    ATTR_USERNAME = 'username'
    ATTR_PASSWORD = 'password'
    ATTR_URL = 'url'
    ATTR_CONF = 'conf'
    ATTR_WORKING_DIR = 'work_dir'

    @@CONF_DIR = 'conf'
    @@ATTR_DEFAULT_REPO_CONF = 'default_repository_conf'
    @@ATTR_REPOSITORIES = 'repositories'

    def loadRepositories
      filename = File.join(Dir.pwd,@@CONF_DIR,@repositories_file)
      if File.exist?(filename)
        File.open(filename, 'r') do |file|
          content = file.read

          #TODO: capture error.
          #TODO: possible to DRY.

          repos = JSON.parse(content)

          @default_repo = repos[@@ATTR_DEFAULT_REPO_CONF]
          @repositories = repos[@@ATTR_REPOSITORIES]
        end
      end
    end
    private :loadRepositories

    def loadCommands
      filename = File.join(Dir.pwd,@@CONF_DIR,@commands_file)
      if File.exist?(filename)
        File.open(filename, 'r') do |file|
          content = file.read

          #TODO: capture error.
          #TODO: possible to DRY.

          @command = JSON.parse(content)
        end
      end
    end
    private :loadCommands

    def initialize(options)
      @commands_file = options[BranchCloner::Parser::ATTR_COMMANDS]
      @repositories_file = options[BranchCloner::Parser::ATTR_REPOSITORIES]

      loadCommands
      loadRepositories
    end

    def getRepoAttribute(code, attrName)
      repos = @repositories.select {|repo| repo[ATTR_CODE]==code}
      repos.count==1 ? repos.first[attrName] : nil
    end

    def getRepoAttributeConf(code, attrName)
      config = getRepoAttribute(code, ATTR_CONF)
      default_conf = lambda {@default_repo[attrName]}
      ret_val = config[attrName] || default_conf.call if config
      ret_val || default_conf.call
    end

    def finalizeCommand(code, cmd, grp)
      mapper = {
          'url' => lambda {getRepoAttributeConf(code, ATTR_URL)},
          'work_dir' => lambda {
            directory = Pathname.new(%Q(#{getRepoAttributeConf(code, ATTR_WORKING_DIR)}))
            directory=directory.join(code) if grp
            directory.to_s
          },
          'username' => lambda {getRepoAttributeConf(code, ATTR_USERNAME)},
          'password' => lambda {getRepoAttributeConf(code, ATTR_PASSWORD)}
      }

      delim = '%'
      pad = lambda {|str| delim + str + delim}

      mapper.keys.each do |key|
        cmd.gsub! pad.call(key), mapper[key].call
      end

      cmd
    end

    def getCommand(code, cmd, grp = false)
      attr_root = 'command'
      attr_cmd = 'cmd'
      attr_args = 'args'
      attrs = @command[attr_root][cmd]
      executable = @command[attrs[attr_cmd]]
      whole_command = %Q("#{executable}").concat(" #{attrs[attr_args]}")
      finalizeCommand(code, whole_command, grp)
    end
  end
end
