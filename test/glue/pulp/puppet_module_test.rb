#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'
require './test/support/repository_support'

class GluePulpPuppetModuleTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  def setup
    configure_runcible

    services  = ['Candlepin', 'ElasticSearch', 'Foreman']
    models    = ['Repository', 'PuppetModule']
    disable_glue_layers(services, models)

    User.current = User.find(users(:admin))
    @repository = Repository.find(repositories(:p_forge))
    RepositorySupport.create_and_sync_repo(@repository)

    @names = ["cron", "httpd", "pureftpd", "samba"]

    VCR.insert_cassette('glue_pulp_puppet_module', :match_requests_on => [:path, :params, :method, :body_json])
  end

  def teardown
    RepositorySupport.destroy_repo
    VCR.eject_cassette
  end

  def test_repo_puppet_modules
    assert_equal 4, @repository.puppet_modules.length
    assert_equal @names, @repository.puppet_modules.map(&:name).sort
  end

  def test_puppet_module_attributes
    puppet_module = @repository.puppet_modules.sort_by(&:name).first
    assert_equal "cron", puppet_module.name
    assert_equal "5UbZ3r0", puppet_module.author # very 1337
    assert_equal "0.0.1", puppet_module.version
  end

  def test_cloned_puppet_modules
    @dev_repo = Repository.find(repositories(:dev_p_forge))
    @dev_repo.relative_path = "/test_path/"
    @dev_repo.create_pulp_repo

    Katello.pulp_server.extensions.puppet_module.expects(:copy).
      with(@repository.pulp_id, @dev_repo.pulp_id)
    tasks = @repository.clone_contents(@dev_repo)
    TaskSupport.wait_on_tasks(tasks)

    assert_equal 4, @repository.puppet_modules.length
    assert_equal @names, @repository.puppet_modules.map(&:name).sort
  ensure
    @dev_repo.destroy
  end
end
