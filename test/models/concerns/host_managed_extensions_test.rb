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

      content_host = Katello::System.find(katello_systems(:simple_server).id)
      @foreman_host = FactoryGirl.create(:host)
      @foreman_host.puppetclasses = []
      @foreman_host.content_host = content_host
      @foreman_host.save!

      new_puppet_environment = Environment.find(environments(:testing))

      @foreman_host.environment = new_puppet_environment
    end
  end

  class HostManagedExtensionsTest < HostManagedExtensionsTestBase
    def test_destroy_host
      system_id = @foreman_host.content_host.id

      assert @foreman_host.destroy
      assert_nil Katello::System.find_by_id(system_id)
    end

    def test_full_text_search
      other_host = FactoryGirl.create(:host)
      found = ::Host.search_for(@foreman_host.name)

      assert_includes found, @foreman_host
      refute_includes found, other_host
    end

    def test_smart_proxy_ids_with_katello
      content_source = FactoryGirl.create(:smart_proxy,
                                          :features => [Feature.where(:name => "Pulp Node").first_or_create])
      @foreman_host.content_source = content_source
      assert @foreman_host.smart_proxy_ids.include?(@foreman_host.content_source_id)
    end

    def test_info_with_katello
      assert_equal @foreman_host.info['parameters']['content_view'], nil
      assert_equal @foreman_host.info['parameters']['lifecycle_environment'], nil

      Support::HostSupport.attach_content_facet(@foreman_host, @view, @library)

      assert_equal @foreman_host.info['parameters']['content_view'], @foreman_host.content_view.label
      assert_equal @foreman_host.info['parameters']['lifecycle_environment'], @foreman_host.lifecycle_environment.label
    end

    def test_info_with_katello_deprecated
      assert_equal @foreman_host.info['parameters']['kt_cv'], nil
      assert_equal @foreman_host.info['parameters']['kt_env'], nil

      Support::HostSupport.attach_content_facet(@foreman_host, @view, @library)

      assert_equal @foreman_host.info['parameters']['kt_cv'], @foreman_host.content_view.label
      assert_equal @foreman_host.info['parameters']['kt_env'], @foreman_host.lifecycle_environment.label
    end

    def test_update_puppet_environment_does_not_update_content_host
      # we are making an update to the foreman host that should NOT result in a change to the content host.
      # this can happen if the user is only using puppet environments that they create within foreman
      # vs those that automatically created as part of the katello content management
      @foreman_host.content_host.expects(:save!).never
      @foreman_host.save!
    end

    def test_update_does_not_update_content_host
      content_host = System.find(katello_systems(:simple_server2).id)
      @foreman_host2 = FactoryGirl.create(:host, :with_content, :content_view => content_host.content_view,
                                          :lifecycle_environment => content_host.environment)
      @foreman_host2.content_host = content_host
      @foreman_host2.save!

      @foreman_host2.expects(:update_content_host).never
      @foreman_host2.save!
    end

    def test_update_with_cv_env
      host = FactoryGirl.create(:host, :with_content, :content_view => @library_view, :lifecycle_environment => @library)
      host.content_facet.content_view = @library_view
      host.content_facet.lifecycle_environment = @library
      assert host.content_facet.save!
    end

    def test_update_with_invalid_cv_env_combo
      host = FactoryGirl.create(:host, :with_content, :content_view => @library_view, :lifecycle_environment => @library)
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

      @foreman_host = FactoryGirl.create(:host, :with_content, :content_view => @library_dev_staging_view,
                                     :lifecycle_environment => @library, :organization => @library.organization, :environment => @library_puppet_env)
    end

    def test_correct_puppet_environment
      assert_equal @library_puppet_env, @foreman_host.environment

      @foreman_host.content_facet.lifecycle_environment = @dev
      @foreman_host.save!

      assert_equal @dev_puppet_env, @foreman_host.environment
    end

    def test_non_matching_puppet_environment
      third_party_env = ::Environment.create!(:name => 'someotherenv')
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
    end

    def test_installed_packages
      assert_equal 1, @foreman_host.installed_packages.count
      assert_equal 'foo', @foreman_host.installed_packages.first.name
      assert_equal @nvra, @foreman_host.installed_packages.first.nvra
    end

    def test_search_installed_package
      assert_includes ::Host::Managed.search_for("installed_package = #{@nvra}"), @foreman_host
      assert_includes ::Host::Managed.search_for("installed_package_name = foo"), @foreman_host
    end
  end
end
