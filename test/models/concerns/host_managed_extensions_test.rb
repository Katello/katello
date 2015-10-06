# encoding: utf-8

require 'katello_test_helper'
require 'support/host_support'

module Katello
  class HostManagedExtensionsTest < ActiveSupport::TestCase
    def self.before_suite
      configure_runcible
    end

    def setup
      disable_orchestration # disable foreman orchestration
      @dev = KTEnvironment.find(katello_environments(:dev).id)
      @library = KTEnvironment.find(katello_environments(:library).id)
      @view = ContentView.find(katello_content_views(:library_dev_staging_view))
      @library_view = ContentView.find(katello_content_views(:library_view))

      content_host = Katello::System.find(katello_systems(:simple_server))
      @foreman_host = FactoryGirl.create(:host)
      @foreman_host.puppetclasses = []
      @foreman_host.content_host = content_host
      @foreman_host.save!

      new_puppet_environment = Environment.find(environments(:testing))

      @foreman_host.environment = new_puppet_environment
    end

    def teardown
      @foreman_host.content_host.destroy
      @foreman_host.reload.destroy
    end

    def test_smart_proxy_ids_with_katello
      content_source = FactoryGirl.create(:smart_proxy,
                                          :features => [Feature.find_or_create_by_name("Pulp Node")])
      @foreman_host.content_source = content_source
      assert @foreman_host.smart_proxy_ids.include?(@foreman_host.content_source_id)
    end

    def test_info_with_katello
      assert_equal @foreman_host.info['parameters']['content_view'], nil
      assert_equal @foreman_host.info['parameters']['lifecycle_environment'], nil

      @foreman_host.content_aspect = Katello::Host::ContentAspect.new(:content_view => @view, :lifecycle_environment => @library)
      @foreman_host.reload

      assert_equal @foreman_host.info['parameters']['content_view'], @foreman_host.content_view.label
      assert_equal @foreman_host.info['parameters']['lifecycle_environment'], @foreman_host.lifecycle_environment.label
    end

    def test_info_with_katello_deprecated
      assert_equal @foreman_host.info['parameters']['kt_cv'], nil
      assert_equal @foreman_host.info['parameters']['kt_env'], nil

      @foreman_host.content_aspect = Katello::Host::ContentAspect.new(:content_view => @view, :lifecycle_environment => @library)
      @foreman_host.reload

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
      content_host = System.find(katello_systems(:simple_server2))
      @foreman_host2 = FactoryGirl.create(:host, :with_content, :content_view => @library_view, :lifecycle_environment => @library)
      @foreman_host2.content_host = content_host
      @foreman_host2.save!

      @foreman_host2.expects(:update_content_host).never
      @foreman_host2.save!
    end

    def test_update_with_cv_env
      host = FactoryGirl.create(:host, :with_content, :content_view => @library_view, :lifecycle_environment => @library)
      host.content_view = @library_view
      host.lifecycle_environment = @library
      assert host.save!
    end

    def test_update_with_invalid_cv_env_combo
      host = FactoryGirl.create(:host, :with_content, :content_view => @library_view, :lifecycle_environment => @library)
      host.content_view = @library_view
      host.lifecycle_environment = @dev
      assert_raises(ActiveRecord::RecordInvalid) do
        host.save!
      end
    end
  end
end
