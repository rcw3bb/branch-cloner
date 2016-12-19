require_relative 'cl_args_parser'
require_relative 'config'
require 'open3'
require 'fileutils'

options = BranchCloner::Parser.parse ARGV
cfg = BranchCloner::Config.new options.config

cfg.repositories.each do |repo|
  code = repo[BranchCloner::Config::ATTR_CODE]
  description = repo[BranchCloner::Config::ATTR_DESCRIPTION]

  if options.clean
    work_dir = cfg.getRepoAttributeConf(code, BranchCloner::Config::ATTR_WORKING_DIR)

    if options.group
      work_dir = Pathname.new(work_dir).join(code)
    end

    work_dir = %Q(#{work_dir})

    if work_dir!=nil && !work_dir.empty? && Dir.exist?(work_dir)
      puts "Deleting: #{work_dir}"
      FileUtils.rm_rf(work_dir)
    end
  end

  cmd = cfg.getCommand code, options.mode, options.group
  puts "Processing <<< #{description} >>>"
  puts cmd

  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    while line = stdout.gets
      puts line
    end
    exit_status = wait_thr.value
    unless exit_status.success?
      puts "FAILED #{cmd}"
    end
  end
  puts '-----'
end

puts "Done"
