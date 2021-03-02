# encoding: utf-8

require 'katello_test_helper'

module Katello
  class SmartProxyExtensionsTest < ActiveSupport::TestCase
    def setup
      @library = katello_environments(:library)
      @view = katello_content_views(:library_dev_view)
      @proxy = FactoryBot.build(:smart_proxy, :default_smart_proxy, :url => 'http://fakepath.com/foo')
      @proxy_mirror = FactoryBot.build(:smart_proxy, :pulp_mirror, :url => 'http://fakemirrorpath.com/foo')
      ::SmartProxy.any_instance.stubs(:associate_features)
    end

    def test_sets_default_download_policy
      Setting[:default_proxy_download_policy] = 'background'
      @proxy.save!

      assert_equal Setting[:default_proxy_download_policy], @proxy.download_policy
    end

    def test_save_with_download_policy
      @proxy.download_policy = 'background'
      @proxy.save!

      assert_equal 'background', @proxy.reload.download_policy
    end

    def test_destroy_with_content_facet
      @proxy.save!
      host = FactoryBot.create(:host, :with_content, :content_view => @view,
                                          :lifecycle_environment => @library)

      host.content_facet.content_source = @proxy
      host.save!

      assert @proxy.destroy!
    end

    def test_save_with_organization_location
      set_default_location
      @proxy.save!
      @proxy_mirror.save!

      assert @proxy.pulp_primary?
      refute @proxy_mirror.pulp_primary?
      refute @proxy.pulp_mirror?
      assert @proxy_mirror.pulp_mirror?

      assert_not_equal ::Organization.all.count, 0
      assert_equal @proxy.organizations.all, ::Organization.all
      assert_equal 0, @proxy_mirror.organizations.all.count

      assert_equal @proxy.locations.first.title, Setting[:default_location_subscribed_hosts]
      assert_equal @proxy_mirror.locations.all.count, 0

      assert_not_equal Katello::KTEnvironment.all.count, 0
      assert_equal @proxy.lifecycle_environments.all, Katello::KTEnvironment.all
      assert_equal @proxy_mirror.lifecycle_environments.all.count, 0
    end
  end

  class SmartProxyPulp3Test < ActiveSupport::TestCase
    def setup
      @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @file_repo = katello_repositories(:generic_file)

      @pulp3_feature = Feature.find_by(:name => SmartProxy::PULP3_FEATURE)
    end

    def teardown
      SETTINGS[:katello][:use_pulp_2_for_content_type] = {:file => false, :docker => false}
    end

    def test_pulp3_repository_support
      refute @primary.pulp3_support?(nil)
      assert @primary.pulp3_support?(@file_repo)
    end

    def test_pulp3_repository_type_support
      assert @primary.pulp3_repository_type_support?(Katello::Repository::FILE_TYPE)
    end

    def test_pulp3_content_type_support
      assert @primary.pulp3_content_support?(Katello::DockerManifest::CONTENT_TYPE)
    end

    def test_pulp2_preferred_for_type
      SETTINGS[:katello][:use_pulp_2_for_content_type] = {}
      SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = true
      assert @primary.pulp2_preferred_for_type?("file")
      refute @primary.pulp2_preferred_for_type?("docker")
    ensure
      SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = nil
    end

    def test_pulp_supported_types_map
      expected_types_map = @primary.supported_pulp_types

      assert_includes expected_types_map[:pulp3][:supported_types], "yum"
      refute_includes expected_types_map[:pulp3][:overriden_to_pulp2], "file"
    end

    def test_pulp_supported_types_map_with_overrides
      SETTINGS[:katello][:use_pulp_2_for_content_type] = {}
      SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = true

      expected_types_map = @primary.supported_pulp_types
      assert_includes expected_types_map[:pulp3][:supported_types], "yum"
      assert_includes expected_types_map[:pulp3][:overriden_to_pulp2], "file"
    ensure
      SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = nil
    end

    def test_fix_pulp3_capabilities
      @primary.expects(:refresh).once
      @primary.smart_proxy_features.where(:feature_id => @pulp3_feature.id).update(:capabilities => [])
      @primary.reload

      assert_raises(Katello::Errors::PulpcoreMissingCapabilities) do
        @primary.fix_pulp3_capabilities('file')
      end
    end

    def test_fix_pulp3_capabilities_overridden
      SETTINGS[:katello][:use_pulp_2_for_content_type] = {}
      SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = true
      @primary.smart_proxy_features.where(:feature_id => @pulp3_feature.id).update(:capabilities => [])
      @primary.expects(:refresh).never
      @primary.fix_pulp3_capabilities('file')
    ensure
      SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = nil
    end

    def test_fix_pulp3_capabilities_not_needed
      SETTINGS[:katello][:use_pulp_2_for_content_type] = {}
      @primary.smart_proxy_features.where(:feature_id => @pulp3_feature.id).update(:capabilities => [:pulpcore])
      @primary.expects(:refresh).never

      @primary.fix_pulp3_capabilities('file')
    end
  end
end
