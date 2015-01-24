#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'
require 'support/pulp/repository_support'

# rubocop:disable Style/AccessorMethodName
module Katello
  class GluePulpConsumerTestBase < ActiveSupport::TestCase
    include RepositorySupport

    def self.before_suite
      services  = ['Candlepin', 'ElasticSearch', 'Foreman']
      models    = ['System', 'Repository', 'User']
      disable_glue_layers(services, models)
      configure_runcible
      super
    end

    def self.set_pulp_consumer(system)
      # TODO: this tests should move to actions tests once we
      # have more actions in Dynflow. For now just peform the
      # things that system.set_pulp_consumer did before.
      ForemanTasks.sync_task(::Actions::Pulp::Consumer::Create,
                             uuid: system.uuid, name: system.name)
    end

    def set_pulp_consumer(system)
      self.class.set_pulp_consumer(system)
    end
  end

  class GluePulpConsumerTestCreateDestroy < GluePulpConsumerTestBase
    def setup
      VCR.insert_cassette('pulp/consumer/create')
      @simple_server = System.find(katello_systems(:simple_server).id)
    end

    def teardown
      VCR.eject_cassette
    end

    def test_set_pulp_consumer
      assert set_pulp_consumer(@simple_server)
      @simple_server.del_pulp_consumer
    end
  end

  class GluePulpConsumerDeleteTest < GluePulpConsumerTestBase
    def setup
      VCR.insert_cassette('pulp/consumer/delete')
      @simple_server = System.find(katello_systems(:simple_server).id)
      set_pulp_consumer(@simple_server)
    end

    def teardown
      VCR.eject_cassette
    end

    def test_del_pulp_consumer
      assert @simple_server.del_pulp_consumer
    end
  end

  class GluePulpConsumerTest < GluePulpConsumerTestBase
    def setup
      VCR.insert_cassette('pulp/consumer/consumer')
      @simple_server = System.find(katello_systems(:simple_server).id)
      set_pulp_consumer(@simple_server)
    end

    def teardown
      @simple_server.del_pulp_consumer
      VCR.eject_cassette
    end

    def test_update_pulp_consumer
      @simple_server.name = "Not So Simple Server"

      assert_equal @simple_server.update_pulp_consumer['display_name'], "Not So Simple Server"
    end

    def test_upload_package_profile
      profile = [{"vendor" => "FedoraHosted", "name" => "elephant",
                  "version" => "0.3", "release" => "0.8",
                  "arch" => "noarch", :epoch => ""}]

      assert @simple_server.upload_package_profile(profile)
    end

    def test_katello_agent_installed
      package = Glue::Pulp::SimplePackage.new(:name => "katello-agent")
      @simple_server.stubs(:simple_packages).returns([package])
      assert @simple_server.katello_agent_installed?

      package.name = "not-katello-agent"
      @simple_server.stubs(:simple_packages).returns([package])
      refute @simple_server.katello_agent_installed?
    end
  end

  class GluePulpConsumerBindTest < GluePulpConsumerTestBase
    @@simple_server = nil

    def self.before_suite
      super
      VCR.insert_cassette('pulp/consumer/bind')

      RepositorySupport.create_and_sync_repo(@loaded_fixtures['katello_repositories']['fedora_17_x86_64']['id'])

      @@simple_server = System.find(@loaded_fixtures['katello_systems']['simple_server']['id'])
      set_pulp_consumer(@@simple_server)
    end

    def self.after_suite
      RepositorySupport.destroy_repo
      @@simple_server.del_pulp_consumer
      VCR.eject_cassette
    end

    def test_enable_repos
      @@simple_server.bound_repositories << RepositorySupport.repo
      @@simple_server.save!

      error_ids = @@simple_server.propagate_yum_repos

      refute_includes error_ids, RepositorySupport.repo.pulp_id
    end
  end

  class GluePulpConsumerRequiresBoundRepoTest < GluePulpConsumerTestBase
    @@simple_server = nil

    def self.before_suite
      super
      VCR.insert_cassette('pulp/consumer/content')

      RepositorySupport.create_and_sync_repo(@loaded_fixtures['katello_repositories']['fedora_17_x86_64']['id'])
      @@simple_server = System.find(@loaded_fixtures['katello_systems']['simple_server']['id'])
      set_pulp_consumer(@@simple_server)
      @@simple_server.bound_repositories << RepositorySupport.repo
      @@simple_server.propagate_yum_repos
    end

    def self.after_suite
      RepositorySupport.destroy_repo
      @@simple_server.del_pulp_consumer if defined? @@simple_server
      VCR.eject_cassette
    end

    def test_install_package
      tasks = @@simple_server.install_package(['elephant'])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_uninstall_package
      tasks = @@simple_server.uninstall_package(['cheetah'])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_update_package
      tasks = @@simple_server.update_package(['cheetah'])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_update_all_packages
      tasks = @@simple_server.update_package([])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_install_package_group
      tasks = @@simple_server.install_package_group(['mammls'])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_uninstall_package_group
      tasks = @@simple_server.uninstall_package_group(['mammals'])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_install_consumer_errata
      erratum_id = RepositorySupport.repo.errata_json.select { |errata| errata['id'] == 'RHEA-2010:0002' }.first['id']
      tasks = @@simple_server.install_consumer_errata([erratum_id])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_import_applicability
      erratum = Erratum.first
      @@simple_server.expects(:errata_ids).returns([erratum.uuid])
      @@simple_server.import_applicability
      assert_equal [erratum], @@simple_server.reload.applicable_errata
    end
  end
end
