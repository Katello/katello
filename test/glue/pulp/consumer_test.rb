require 'katello_test_helper'
require 'support/pulp/repository_support'

# rubocop:disable Style/AccessorMethodName
module Katello
  class GluePulpConsumerTestBase < ActiveSupport::TestCase
    include RepositorySupport
    def setup
      set_user
      configure_runcible
      @simple_server = katello_systems(:simple_server)
      @simple_server.foreman_host = @host
      @simple_server.save!
    end

    def teardown
      VCR.eject_cassette
    end

    def self.set_pulp_consumer(uuid)
      # TODO: this tests should move to actions tests once we
      # have more actions in Dynflow. For now just peform the
      # things that system.set_pulp_consumer did before.
      ForemanTasks.sync_task(::Actions::Pulp::Consumer::Create,
                             uuid: uuid, name: uuid)
    end

    def set_pulp_consumer(uuid)
      self.class.set_pulp_consumer(uuid)
    end
  end

  class GluePulpConsumerTestCreateDestroy < GluePulpConsumerTestBase
    def setup
      super
      VCR.insert_cassette('pulp/consumer/create')
    end

    def teardown
      @simple_server.del_pulp_consumer
    ensure
      VCR.eject_cassette
    end

    def test_set_pulp_consumer
      assert set_pulp_consumer(@simple_server.uuid)
    end
  end

  class GluePulpConsumerDeleteTest < GluePulpConsumerTestBase
    def setup
      super
      VCR.insert_cassette('pulp/consumer/delete')
      set_pulp_consumer(@simple_server.uuid)
    end

    def teardown
      super
    end

    def test_del_pulp_consumer
      assert @simple_server.del_pulp_consumer
    end
  end

  class GluePulpConsumerTest < GluePulpConsumerTestBase
    def setup
      super
      VCR.insert_cassette('pulp/consumer/consumer')
      set_pulp_consumer(@simple_server.uuid)
    end

    def teardown
      @simple_server.del_pulp_consumer
    ensure
      VCR.eject_cassette
    end

    def test_update_pulp_consumer
      @simple_server.name = "Not So Simple Server"

      assert_equal @simple_server.update_pulp_consumer['display_name'], "Not So Simple Server"
    end

    def test_katello_agent_installed
      package = Katello::Pulp::SimplePackage.new(:name => "katello-agent")
      @simple_server.stubs(:simple_packages).returns([package])
      assert @simple_server.katello_agent_installed?

      package.name = "not-katello-agent"
      @simple_server.stubs(:simple_packages).returns([package])
      refute @simple_server.katello_agent_installed?
    end
  end

  class GluePulpConsumerBindTest < GluePulpConsumerTestBase
    @simple_server = nil

    def setup
      super
      VCR.insert_cassette('pulp/consumer/bind')

      RepositorySupport.create_and_sync_repo(FIXTURES['katello_repositories']['fedora_17_x86_64']['id'])
      set_pulp_consumer(@simple_server.uuid)
    end

    def teardown
      RepositorySupport.destroy_repo
      @simple_server.del_pulp_consumer
    ensure
      VCR.eject_cassette
    end
  end

  class GluePulpConsumerRequiresBoundRepoTest < GluePulpConsumerTestBase
    @simple_server = nil

    def setup
      super
      VCR.insert_cassette('pulp/consumer/content')

      RepositorySupport.create_and_sync_repo(FIXTURES['katello_repositories']['fedora_17_x86_64']['id'])
      @simple_server = System.find(FIXTURES['katello_systems']['simple_server']['id'])
      set_pulp_consumer(@simple_server.uuid)
      @host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @simple_server.content_view, :lifecycle_environment => @simple_server.environment)
      @host.content_facet.uuid = @simple_server.uuid
      @host.content_facet.bound_repositories << RepositorySupport.repo
      @host.content_facet.propagate_yum_repos
    end

    def teardown
      RepositorySupport.destroy_repo
      @simple_server.del_pulp_consumer if defined? @simple_server
    ensure
      VCR.eject_cassette
    end

    def test_install_package
      tasks = @simple_server.install_package(['elephant'])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_uninstall_package
      tasks = @simple_server.uninstall_package(['cheetah'])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_update_package
      tasks = @simple_server.update_package(['cheetah'])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_update_all_packages
      tasks = @simple_server.update_package([])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_install_package_group
      tasks = @simple_server.install_package_group(['mammls'])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_uninstall_package_group
      tasks = @simple_server.uninstall_package_group(['mammals'])

      assert tasks[:spawned_tasks].first['task_id']
    end

    def test_install_consumer_errata
      erratum_id = RepositorySupport.repo.errata_json.select { |errata| errata['id'] == 'RHEA-2010:0002' }.first['id']
      profile = [{"vendor" => "FedoraHosted", "name" => "elephant",
                  "version" => "0.3", "release" => "0.8",
                  "arch" => "noarch", :epoch => ""}]
      ForemanTasks.sync_task(::Actions::Katello::Host::UploadPackageProfile, @host, profile)
      tasks = @simple_server.install_consumer_errata([erratum_id])

      assert tasks[:spawned_tasks].first['task_id']
    end
  end
end
