require_relative 'lib/cl_args_parser'
require_relative 'lib/config'

require 'concurrent'

require 'open3'
require 'fileutils'
require 'log4r'
require 'log4r/MDC'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

LOG_CONFIG = Log4r::YamlConfigurator
LOG_CONFIG['HOME'] = '.'
LOG_CONFIG.load_yaml_file(Pathname.new('conf/log4r.yaml'))

LOG = Log4r::Logger['branchcloner']

options = BranchCloner::Parser.parse ARGV
cfg = BranchCloner::Config.new options

THREAD_POOL_EXECUTOR = Concurrent::ThreadPoolExecutor.new({
    :min_threads=>cfg.thread_pool[BranchCloner::Config::ATTR_MIN_THREADS],
    :max_threads=>cfg.thread_pool[BranchCloner::Config::ATTR_MAX_THREADS],
    :max_queue=>cfg.thread_pool[BranchCloner::Config::ATTR_MAX_QUEUE],
    :idletime=>cfg.thread_pool[BranchCloner::Config::ATTR_THREAD_IDLETIME],
    :fallback_policy=>:caller_runs
})

def self.processRepo(cfg, options, repo)
  code = repo[BranchCloner::Config::ATTR_CODE]
  description = repo[BranchCloner::Config::ATTR_DESCRIPTION]

  Log4r::MDC.put(:code, code)

  if options.clean
    work_dir = cfg.getRepoAttributeConf(code, BranchCloner::Config::ATTR_WORKING_DIR)

    if options.group
      work_dir = Pathname.new(work_dir).join(code)
    end

    work_dir = %Q(#{work_dir})

    if work_dir!=nil && !work_dir.empty? && Dir.exist?(work_dir)
      LOG.info "Deleting: #{work_dir}"
      FileUtils.rm_rf(work_dir)
    end
  end

  cmd = cfg.getCommand code, options.mode, options.group
  LOG.info "Processing <<< #{description} >>>"
  LOG.info cmd

  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    while line = stdout.gets
      LOG.debug line.chomp
    end
    exit_status = wait_thr.value
    unless exit_status.success?
      LOG.error "FAILED #{cmd}"
    end
  end

  LOG.info "-- #{code} --"
  Log4r::MDC.put(:code, nil)
end

cfg.repositories.each do |repo|

  THREAD_POOL_EXECUTOR.post {
    self.processRepo(cfg, options, repo)
  }

end

THREAD_POOL_EXECUTOR.shutdown
THREAD_POOL_EXECUTOR.wait_for_termination

LOG.info "Done"
