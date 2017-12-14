require_relative 'config'
require 'optparse'

module BranchCloner
  Options = Struct.new(:commands, :repositories, :mode, :group, :clean)

  class Parser

    ATTR_COMMAND_OPTIONS = 'command-options'
    ATTR_COMMANDS = 'commands'
    ATTR_REPOSITORIES = 'repositories'
    ATTR_MODE = 'mode'
    ATTR_GROUP = 'group'
    ATTR_CLEAN = 'clean'

    @@CONF_DIR = 'conf'

    @version = '0.3.1'
    @program_name = 'Branch Cloner'
    @basename = Pathname.new($0).basename

    def self.loadDefault
      BranchCloner::Config.loadFile 'default.json' do |content|
        conf = JSON.parse(content)
        @default_options = conf[ATTR_COMMAND_OPTIONS]
      end
    end

    def self.parse(options)
      puts "#{@program_name} v#{@version}\n\n"

      args = Options.new()

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{@basename} [options]"

        opts.on("-cCOMMANDS", "--commands COMMANDS", 'String', "The configuration file for commands.") do |cmd|
          args.commands = cmd
        end

        opts.on("-rREPOSITORIES", "--repositories REPOSITORIES", 'String', "The configuration file for repositories.") do |repo|
          args.repositories = repo
        end

        opts.on("-mMODE", "--mode=MODE", 'String', "Accepts update or checkout.") do |mode|
          args.mode = BranchCloner::Config::MODES[mode]
        end

        opts.on("-u", "--ungroup", "Do not group the checkout by the code of the repository.") do
          args.group = false
        end

        opts.on("-C", "--clean", "Cleans work directory before processing.") do
          args.clean = true
        end

        opts.on("-h", "--help", "Prints this help.") do
          puts opts
          exit
        end
      end

      opt_parser.parse!(options)

      loadDefault

      args.commands = @default_options[ATTR_COMMANDS]           if args.commands==nil
      args.repositories = @default_options[ATTR_REPOSITORIES]   if args.repositories==nil
      args.mode = @default_options[ATTR_MODE]                   if args.mode==nil
      args.group = @default_options[ATTR_GROUP]                 if args.group==nil
      args.clean = @default_options[ATTR_CLEAN]                 if (args.clean==nil || args.mode==BranchCloner::Config::CMD_UPDATE)

      return args
    end
  end
end