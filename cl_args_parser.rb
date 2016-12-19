require_relative 'config'
require 'optparse'

module BranchCloner
  Options = Struct.new(:config, :mode, :group, :clean)

  class Parser
    @version = '0.1a'
    @program_name = 'Branch Cloner'
    @basename = Pathname.new($0).basename

    def self.parse(options)
      puts "#{@program_name} v#{@version}\n\n"

      args = Options.new()

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{@basename} [options]"

        opts.on("-cCONFIG", "--config CONFIG", 'String', "The configuration file to use.") do |cfg|
          args.config = cfg
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

      args.config = 'config.json' if args.config==nil
      args.mode = BranchCloner::Config::CMD_UPDATE if args.mode==nil
      args.group = true if args.group==nil
      args.clean = false if (args.clean==nil || args.mode==BranchCloner::Config::CMD_UPDATE)

      return args
    end
  end
end