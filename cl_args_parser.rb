require_relative 'config'

module BranchCloner
  Options = Struct.new(:config, :mode, :group)

  class Parser
    require 'optparse'

    def self.parse(options)
      args = Options.new()

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options]"

        opts.on("-cCONFIG", "--config CONFIG", 'String', "The configuration file to use.") do |cfg|
          args.config = cfg
        end

        opts.on("-mMODE", "--mode=MODE", 'String', "Accepts update or checkout.") do |mode|
          args.mode = BranchCloner::Config::MODES[mode]
        end

        opts.on("-u", "--ungroup", "Do not group the checkout by the code of the repository.") do
          args.group = false
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

      return args
    end
  end
end