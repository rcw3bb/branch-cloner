require 'test/unit'
require_relative '../lib/config'
require_relative '../lib/cl_args_parser'

class ConfigTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  Options = BranchCloner::Options

  def getConfig(options = Options.new('svnserver.json', 'repository.json', 'update', true, false))
    BranchCloner::Config.new options
  end

  def getRepository(repository)
    assert_not_nil repository
    repository
  end

  def getConf(repository)
    conf = repository[BranchCloner::Config::ATTR_CONF]
    assert_not_nil conf
    conf
  end

  def test_repository_config_base
    repository = getRepository getConfig.repositories[0]
    assert_equal repository[BranchCloner::Config::ATTR_CODE], 'test_repository'
    assert_equal repository[BranchCloner::Config::ATTR_DESCRIPTION], 'Test Repository'
  end

  def test_repository_config_conf
    conf = getConf getRepository getConfig.repositories[0]
    assert_equal conf[BranchCloner::Config::ATTR_URL], 'url'
    assert_equal conf[BranchCloner::Config::ATTR_USERNAME], 'username'
    assert_equal conf[BranchCloner::Config::ATTR_PASSWORD], 'password'
  end

  def test_get_attr
    assert_equal getConfig.getRepoAttribute('test_repository', BranchCloner::Config::ATTR_CODE), 'test_repository'
    assert_equal getConfig.getRepoAttribute('test_repository', BranchCloner::Config::ATTR_DESCRIPTION), 'Test Repository'
  end

  def test_get_attr_conf
    assert_equal getConfig.getRepoAttributeConf('test_repository', BranchCloner::Config::ATTR_URL), 'url'
    assert_equal getConfig.getRepoAttributeConf('test_repository', BranchCloner::Config::ATTR_USERNAME), 'username'
    assert_equal getConfig.getRepoAttributeConf('test_repository', BranchCloner::Config::ATTR_PASSWORD), 'password'
  end

  def test_get_attr_default_conf
    config = Options.new('svnserver.json', 'repository-default.json', 'update', true, false)
    assert_equal getConfig(config).getRepoAttributeConf('test_repository', BranchCloner::Config::ATTR_URL), 'default_url'
    assert_equal getConfig(config).getRepoAttributeConf('test_repository', BranchCloner::Config::ATTR_USERNAME), 'default_username'
    assert_equal getConfig(config).getRepoAttributeConf('test_repository', BranchCloner::Config::ATTR_PASSWORD), 'default_password'
  end

  def test_get_attr_default_no_conf
    config = Options.new('svnserver.json', 'repository-no-conf.json', 'update', true, false)
    assert_equal getConfig(config).getRepoAttributeConf('test_repository', BranchCloner::Config::ATTR_URL), 'no_conf_url'
    assert_equal getConfig(config).getRepoAttributeConf('test_repository', BranchCloner::Config::ATTR_USERNAME), 'no_conf_username'
    assert_equal getConfig(config).getRepoAttributeConf('test_repository', BranchCloner::Config::ATTR_PASSWORD), 'no_conf_password'
  end

  def test_get_attr_def_no_conf_over
    config = Options.new('svnserver.json', 'repository-no-conf.json', 'update', true, false)
    assert_equal getConfig(config).getRepoAttributeConf('test_repository2', BranchCloner::Config::ATTR_URL), 'with_url'
    assert_equal getConfig(config).getRepoAttributeConf('test_repository2', BranchCloner::Config::ATTR_USERNAME), 'no_conf_username'
    assert_equal getConfig(config).getRepoAttributeConf('test_repository2', BranchCloner::Config::ATTR_PASSWORD), 'no_conf_password'
    assert_equal getConfig(config).getRepoAttributeConf('test_repository2', BranchCloner::Config::ATTR_WORKING_DIR), '.\repositories'
  end

  def test_command
    assert_equal '"C:/Program Files (x86)/Subversion/bin/svn.exe" co "url" "./repositories"',
                 getConfig.getCommand('test_repository', BranchCloner::Config::CMD_CHECKOUT)
  end

  def test_command_group
    assert_equal '"C:/Program Files (x86)/Subversion/bin/svn.exe" co "url" "./repositories/test_repository"',
                 getConfig.getCommand('test_repository', BranchCloner::Config::CMD_CHECKOUT, true)
  end

end