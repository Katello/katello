# encoding: utf-8

require 'katello_test_helper'
require 'support/host_support'

module Katello
  class HostManagedExtensionsTestBase < ActiveSupport::TestCase
    def setup
      disable_orchestration # disable foreman orchestration
      @dev = KTEnvironment.find(katello_environments(:dev).id)
      @library = KTEnvironment.find(katello_environments(:library).id)
      @view = ContentView.find(katello_content_views(:library_dev_staging_view).id)
      @library_view = ContentView.find(katello_content_views(:library_view).id)

      @foreman_host = FactoryBot.create(:host)
      @foreman_host.puppetclasses = []
      @foreman_host.save!

      new_puppet_environment = Environment.find(environments(:testing).id)

      @foreman_host.environment = new_puppet_environment
    end
  end

  class HostManagedExtensionsTest < HostManagedExtensionsTestBase
    def test_destroy_host
      assert @foreman_host.destroy
    end

    def test_full_text_search
      other_host = FactoryBot.create(:host)
      found = ::Host.search_for(@foreman_host.name)

      assert_includes found, @foreman_host
      refute_includes found, other_host
    end

    def test_smart_proxy_ids_with_katello
      content_source = FactoryBot.create(:smart_proxy,
                                          :features => [Feature.where(:name => "Pulp Node").first_or_create])
      Support::HostSupport.attach_content_facet(@foreman_host, @view, @library)
      @foreman_host.content_facet.content_source = content_source
      assert @foreman_host.smart_proxy_ids.include?(@foreman_host.content_source_id)
    end

    def test_info_with_katello
      assert_nil @foreman_host.info['parameters']['content_view']
      assert_nil @foreman_host.info['parameters']['lifecycle_environment']
      assert_equal @foreman_host.info['parameters']['foreman_host_collections'], []

      Support::HostSupport.attach_content_facet(@foreman_host, @view, @library)
      host_collection = katello_host_collections(:simple_host_collection)
      host_collection.hosts << @foreman_host

      assert_equal @foreman_host.info['parameters']['content_view'], @foreman_host.content_view.label
      assert_equal @foreman_host.info['parameters']['lifecycle_environment'], @foreman_host.lifecycle_environment.label
      assert_includes @foreman_host.info['parameters']['foreman_host_collections'], host_collection.name
    end

    def test_info_with_katello_deprecated
      assert_nil @foreman_host.info['parameters']['kt_cv']
      assert_nil @foreman_host.info['parameters']['kt_env']

      Support::HostSupport.attach_content_facet(@foreman_host, @view, @library)

      assert_equal @foreman_host.info['parameters']['kt_cv'], @foreman_host.content_view.label
      assert_equal @foreman_host.info['parameters']['kt_env'], @foreman_host.lifecycle_environment.label
    end

    def test_update_with_cv_env
      host = FactoryBot.create(:host, :with_content, :content_view => @library_view, :lifecycle_environment => @library)
      host.content_facet.content_view = @library_view
      host.content_facet.lifecycle_environment = @library
      assert host.content_facet.save!
    end

    def test_update_with_invalid_cv_env_combo
      host = FactoryBot.create(:host, :with_content, :content_view => @library_view, :lifecycle_environment => @library)
      host.content_facet.content_view = @library_view
      host.content_facet.lifecycle_environment = @dev
      assert_raises(ActiveRecord::RecordInvalid) do
        host.content_facet.save!
      end
    end
  end

  class HostManagedPuppetTest < HostManagedExtensionsTestBase
    def setup
      super
      @library_dev_staging_view = katello_content_views(:library_dev_staging_view)
      @library_cvpe = katello_content_view_puppet_environments(:library_dev_staging_view_library_puppet_env)
      @dev_cvpe = katello_content_view_puppet_environments(:dev_dev_staging_view_library_puppet_env)

      @library_puppet_env = ::Environment.create!(:name => 'library_env')
      @dev_puppet_env = ::Environment.create!(:name => 'dev_env')

      @library_cvpe.puppet_environment = @library_puppet_env
      @library_cvpe.save!

      @dev_cvpe.puppet_environment = @dev_puppet_env
      @dev_cvpe.save!

      @foreman_host = FactoryBot.create(:host, :with_content, :content_view => @library_dev_staging_view,
                                     :lifecycle_environment => @library, :organization => @library.organization, :environment => @library_puppet_env)
    end

    def test_correct_puppet_environment
      assert_equal @library_puppet_env, @foreman_host.environment

      @foreman_host.content_facet.lifecycle_environment = @dev
      @foreman_host.save!

      assert_equal @dev_puppet_env, @foreman_host.environment
    end

    def test_non_matching_puppet_environment
      third_party_env = ::Environment.create!(:name => 'someotherenv',
                                              :organizations => [@foreman_host.organization],
                                              :locations => [@foreman_host.location])
      @foreman_host.environment = third_party_env
      @foreman_host.save!

      @foreman_host.content_facet.lifecycle_environment = @dev
      @foreman_host.save!

      assert_equal third_party_env, @foreman_host.environment
    end
  end
  class HostInstalledPackagesTest < HostManagedExtensionsTestBase
    def setup
      super
      package_json = {:name => "foo", :version => "1", :release => "1.el7", :arch => "x86_64"}
      @foreman_host.import_package_profile([::Katello::Pulp::SimplePackage.new(package_json)])
      @nvra = 'foo-1-1.el7.x86_64'
      @foreman_host.reload
    end

    def test_installed_packages
      assert_equal 1, @foreman_host.installed_packages.count
      assert_equal 'foo', @foreman_host.installed_packages.first.name
      assert_equal @nvra, @foreman_host.installed_packages.first.nvra
    end

    def test_import_package_profile_adds_removes_bulk
      packages = [::Katello::Pulp::SimplePackage.new(:name => "betterfoo", :version => "1", :release => "1.el7", :arch => "x86_64")]
      @foreman_host.import_package_profile(packages)
      assert_equal 1, @foreman_host.installed_packages.count
      assert_equal 'betterfoo', @foreman_host.installed_packages.first.name

      @foreman_host.reload
      packages << ::Katello::Pulp::SimplePackage.new(:name => "alphabeta", :version => "1", :release => "2", :arch => "x86_64")
      @foreman_host.import_package_profile(packages)
      assert_equal 2, @foreman_host.installed_packages.count
    end

    def test_search_installed_package
      assert_includes ::Host::Managed.search_for("installed_package = #{@nvra}"), @foreman_host
      assert_includes ::Host::Managed.search_for("installed_package_name = foo"), @foreman_host
    end
  end

  class HostEnabledReposTest < HostManagedExtensionsTestBase
    def test_import_repos
      repos_json = [{"repositoryid" => "good", "baseurl" => ["https://foo.com/pulp/repos/foo"]},
                    {"repositoryid" => "bad", "baseurl" => []}]
      Support::HostSupport.attach_content_facet(@foreman_host, @view, @library)
      @foreman_host.content_facet.expects(:update_repositories_by_paths).with(["/pulp/repos/foo"])
      @foreman_host.import_enabled_repositories(repos_json)
    end
  end

  class HostAvailableModulesTest < HostManagedExtensionsTestBase
    def make_module_json(name = "foo", status = "unknown", installed_profiles = [])
      {
        "name" => name,
        "stream" => "8",
        "version" => "20180308143646",
        "context" => "c2c572ec",
        "arch" => "x86_64",
        "profiles" => [
          "development",
          "minimal",
          "default"
        ],
        "installed_profiles" => installed_profiles,
        "status" => status
      }
    end

    def test_import_modules
      modules_json = [
        make_module_json("enabled-installed", "enabled", ["default"]),
        make_module_json("enabled2", "enabled"),
        make_module_json("disabled", "disabled"),
        make_module_json("unknown", "unknown")
      ]
      @foreman_host.import_module_streams(modules_json)
      assert_equal 1, @foreman_host.host_available_module_streams.installed.size
      assert_equal 2, @foreman_host.host_available_module_streams.enabled.size
      assert_equal 1, @foreman_host.host_available_module_streams.disabled.size
      assert_equal 1, @foreman_host.host_available_module_streams.unknown.size

      installed_params = modules_json.first

      installed = @foreman_host.host_available_module_streams.installed.first
      assert_equal installed_params["name"], installed.available_module_stream.name
      assert_equal installed_params["stream"], installed.available_module_stream.stream
      assert_equal installed_params["installed_profiles"], installed.installed_profiles
      assert_equal "enabled", installed.status
      refute_empty installed.installed_profiles
    end

    def test_import_modules_with_update
      modules_json = [make_module_json("enabled21111", "enabled")]
      prior_count = HostAvailableModuleStream.count
      @foreman_host.import_module_streams(modules_json)
      assert_equal prior_count + 1, HostAvailableModuleStream.count
      assert_equal "enabled", @foreman_host.reload.host_available_module_streams.first.status

      modules_json.first["status"] = "unknown"

      @foreman_host.import_module_streams(modules_json)
      assert_equal "unknown", @foreman_host.reload.host_available_module_streams.first.status
      assert_equal prior_count + 1, HostAvailableModuleStream.count

      @foreman_host.import_module_streams([])
      assert_empty @foreman_host.reload.host_available_module_streams
      assert_equal prior_count, HostAvailableModuleStream.count

      @foreman_host.import_module_streams([make_module_json("xxxx", "enabled", ["default"])])
      assert_equal "enabled", @foreman_host.reload.host_available_module_streams.first.status
      assert_equal ["default"], @foreman_host.reload.host_available_module_streams.first.installed_profiles

      @foreman_host.import_module_streams([make_module_json("xxxx", "enabled", [])])
      assert_equal "enabled", @foreman_host.reload.host_available_module_streams.first.status
      assert_empty @foreman_host.reload.host_available_module_streams.first.installed_profiles
    end
  end

  class HostTracerTest < HostManagedExtensionsTestBase
    def setup
      super
      tracer_json = {"sshd": {"type": "daemon", "helper": "sudo systemctl restart sshd"}}
      @foreman_host.import_tracer_profile(tracer_json)
    end

    def test_known_traces
      assert_equal 1, @foreman_host.host_traces.count
      assert_equal 'sshd', @foreman_host.host_traces.first.application
    end

    def test_search_known_traces
      assert_includes ::Host::Managed.search_for("trace_app_type =  daemon"), @foreman_host
      assert_includes ::Host::Managed.search_for("trace_app = sshd"), @foreman_host
      assert_includes ::Host::Managed.search_for("trace_helper = \"sudo systemctl restart sshd\""), @foreman_host
    end
  end

  class HostManagedExtensionsKickstartTest < ActiveSupport::TestCase
    def setup
      disable_orchestration # disable foreman orchestration
      @distro = katello_repositories(:fedora_17_x86_64)
      @os = ::Redhat.create_operating_system('RedHat', '17', '0')
      @os.stubs(:kickstart_repos).returns([@distro])
      @arch = architectures(:x86_64)
      @distro_cv = @distro.content_view
      @distro_env = @distro.environment
      @content_source = FactoryBot.create(:smart_proxy,
                                          name: "foobar",
                                          url: "http://example.com/",
                                          lifecycle_environments: [@distro_env])
      @medium = FactoryBot.create(:medium, operatingsystems: [@os])

      @host = FactoryBot.create(:host, operatingsystem: @os, arch: @arch)
      Support::HostSupport.attach_content_facet(@host, @distro_cv, @distro_env)
      @host.content_facet.content_source = @content_source
      @host.save!
    end

    def test_set_medium
      @host.medium = @medium
      assert_valid @host
      assert_equal @host.medium, @medium
    end

    def test_set_installation_medium
      @host.content_facet.kickstart_repository = @distro
      assert_valid @host
      assert_equal @host.content_facet.kickstart_repository, @distro
    end

    def test_change_medium_to_kickstart_repository
      @host.medium = @medium
      assert @host.save

      @host.content_facet.kickstart_repository = @distro
      assert_valid @host
      assert_nil @host.medium
      assert_equal @host.content_facet.kickstart_repository, @distro
    end

    def test_change_kickstart_repository_to_medium
      @host.content_facet.kickstart_repository = @distro
      assert @host.save

      @host.medium = @medium
      assert_valid @host
      assert_nil @host.content_facet.kickstart_repository
      assert_equal @host.medium, @medium
    end

    def test_change_os_from_facts_without_ks_repo
      @host.content_facet.kickstart_repository = @distro
      assert @host.save

      os = Redhat.new(:name => 'Zippity Do Da', :major => '9')
      @host.operatingsystem = os
      @host.send(:update_os_from_facts)
      assert_nil @host.content_facet.kickstart_repository
    end

    def test_change_os_from_facts_with_ks_repo
      @host.content_facet.kickstart_repository = @distro
      assert @host.save

      ::Redhat.any_instance.stubs(:kickstart_repos).returns([{id: @distro.id}])
      os = Redhat.new(:name => 'Zippity Do Da', :major => '9')
      @host.operatingsystem = os
      @host.send(:update_os_from_facts)

      assert_equal @host.operatingsystem, os
      assert_equal @host.content_facet.kickstart_repository, @distro
    end
  end
end
