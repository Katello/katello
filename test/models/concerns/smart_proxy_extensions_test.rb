# encoding: utf-8

require 'katello_test_helper'

module Katello
  class SmartProxyExtensionsTest < ActiveSupport::TestCase
    include Support::CapsuleSupport

    def setup
      @library = katello_environments(:library)
      @view = katello_content_views(:library_dev_view)
      @proxy = SmartProxy.pulp_primary
      @proxy_mirror = FactoryBot.build(:smart_proxy, :pulp_mirror, :url => 'http://fakemirrorpath.com/foo')
      @http_proxy = http_proxies(:myhttpproxy)

      ::SmartProxy.any_instance.stubs(:associate_features)
    end

    def test_sets_default_download_policy
      Setting[:default_proxy_download_policy] = ::Katello::RootRepository::DOWNLOAD_ON_DEMAND
      @proxy.save!

      assert_equal Setting[:default_proxy_download_policy], @proxy.download_policy
    end

    def test_save_with_download_policy
      @proxy.download_policy = ::Katello::RootRepository::DOWNLOAD_IMMEDIATE
      @proxy.save!

      assert_equal ::Katello::RootRepository::DOWNLOAD_IMMEDIATE, @proxy.reload.download_policy
    end

    def test_save_with_http_proxy
      @proxy.http_proxy = @http_proxy
      @proxy.save!

      assert_equal @http_proxy.id, @proxy.http_proxy_id
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
      @proxy.destroy!
      @proxy = FactoryBot.build(:smart_proxy, :default_smart_proxy, :url => 'http://fakepath.com/foo')
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

    def test_rhsm_url_pulp_primary
      assert_includes @proxy.rhsm_url.to_s, "/rhsm"
      assert_not_includes @proxy.rhsm_url.to_s, ":8443"
    end

    def test_rhsm_url_pulp_mirror
      assert_includes @proxy_mirror.rhsm_url.to_s, ":8443/rhsm"
    end

    def test_sync_container_gateway
      environment = katello_environments(:library)
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)

      repo_list_update_expectation = ProxyAPI::ContainerGateway.any_instance.expects(:repository_list).with(
        :repositories => [{:repository => "empty_organization-puppet_product-busybox", :auth_required => true}, {:repository => "busybox", :auth_required => true}]
      )
      repo_list_update_expectation.once.returns(true)

      repo_mapping_update_expectation = ProxyAPI::ContainerGateway.any_instance.expects(:user_repository_mapping).with do |arg|
        arg[:users].first["secret_admin"].include?({:repository => "empty_organization-puppet_product-busybox",
                                                    :auth_required => true}) &&
        arg[:users].first["secret_admin"].include?({:repository => "busybox",
                                                    :auth_required => true})
      end
      repo_mapping_update_expectation.once.returns(true)
      capsule_content.smart_proxy.expects(:container_gateway_users).returns(::User.where(login: 'secret_admin'))
      capsule_content.smart_proxy.sync_container_gateway
    end
  end

  class SmartProxyPulp3Test < ActiveSupport::TestCase
    def setup
      @primary = SmartProxy.pulp_primary
      @file_repo = katello_repositories(:generic_file)

      @pulp3_feature = Feature.find_by(:name => SmartProxy::PULP3_FEATURE)
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

    def test_pulp_supported_types_map
      expected_types_map = @primary.supported_pulp_types
      assert_empty ["deb", "yum", "file", "docker", "ansible_collection"] - expected_types_map
    end

    def test_fix_pulp3_capabilities
      @primary.expects(:refresh).once
      @primary.smart_proxy_features.where(:feature_id => @pulp3_feature.id).update(:capabilities => [])
      @primary.reload

      assert_raises(Katello::Errors::PulpcoreMissingCapabilities) do
        @primary.fix_pulp3_capabilities('file')
      end
    end

    def test_fix_pulp3_capabilities_not_needed
      @primary.smart_proxy_features.where(:feature_id => @pulp3_feature.id).update(:capabilities => [:pulpcore])
      @primary.expects(:refresh).never

      @primary.fix_pulp3_capabilities('file')
    end

    pulpcore_features = {
      'rpm': Katello::Repository::YUM_TYPE,
      'file': Katello::Repository::FILE_TYPE,
      'container': Katello::Repository::DOCKER_TYPE,
      'ansible': Katello::Repository::ANSIBLE_COLLECTION_TYPE,
      'deb': Katello::Repository::DEB_TYPE,
      'ostree': Katello::Repository::OSTREE_TYPE,
      'python': 'python'
    }

    pulpcore_features.each_pair do |feature_name, repo_type|
      test "pulpcore_feature_#{feature_name}_is_supported" do
        @primary.smart_proxy_feature_by_name(@pulp3_feature.name)
          .update(:capabilities => [feature_name.to_s])

        assert @primary.pulp3_repository_type_support?(repo_type.to_s),
          "Repostitory type \"#{repo_type}\" is not supported by smart proxy with capabilties named \"#{feature_name}\""
      end
    end
  end
end
