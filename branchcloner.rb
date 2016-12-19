require_relative 'cl_args_parser'
require_relative 'config'

options = BranchCloner::Parser.parse ARGV
cfg = BranchCloner::Config.new options.config
cfg.repositories.each do |repo|
  code = repo[BranchCloner::Config::ATTR_CODE]
  cmd = cfg.getCommand code, options.mode, options.group
  puts cmd
  stat = %x(#{cmd})
  puts stat
end
