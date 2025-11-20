# encoding: utf-8

# rubocop:disable Metrics/ClassLength
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

    def setup_yum_repo
      yum_repo = katello_repositories(:fedora_17_x86_64)
      yum_repo.srpms << ::Katello::Srpm.find_by(pulp_id: 'three-uuid')
      yum_service = yum_repo.backend_service(@proxy).with_mirror_adapter
      yum_repo.expects(:backend_service).with(@proxy).once.returns(yum_service)
      yum_service.expects(:count_by_pulpcore_type).with(::Katello::Pulp3::Srpm).once.returns(1)
      yum_repo.update(library_instance_id: yum_repo.id)
      yum_counts = {
        "rpm.advisory" => {count: 4, href: 'href'},
        "rpm.package" => {count: 32, href: 'href'},
        "rpm.modulemd" => {count: 7, href: 'href'},
        "rpm.modulemd_defaults" => {count: 3, href: 'href'},
        "rpm.packagegroup" => {count: 7, href: 'href'},
        "rpm.packagecategory" => {count: 1, href: 'href'},
      }
      yum_service.expects(:latest_content_counts).once.returns(yum_counts)
      yum_repo
    end

    def setup_file_repo
      file_repo = katello_repositories(:pulp3_file_1)
      file_repo.update library_instance_id: file_repo.id
      file_service = file_repo.backend_service(@proxy).with_mirror_adapter
      file_repo.expects(:backend_service).with(@proxy).once.returns(file_service)
      file_counts = {
        "file.file" => {count: 100, href: 'href'},
      }
      file_service.expects(:latest_content_counts).once.returns(file_counts)
      file_repo
    end

    def setup_ansible_collection_repo
      ansible_repo = katello_repositories(:pulp3_ansible_collection_1)
      ansible_repo.update library_instance_id: ansible_repo.id
      ansible_service = ansible_repo.backend_service(@proxy).with_mirror_adapter
      ansible_repo.expects(:backend_service).with(@proxy).once.returns(ansible_service)
      ansible_counts = {
        "ansible.collection" => {count: 802, href: 'href'},
      }
      ansible_service.expects(:latest_content_counts).once.returns(ansible_counts)
      ansible_repo
    end

    def setup_container_repo
      container_repo = katello_repositories(:pulp3_docker_1)
      container_repo.update library_instance_id: container_repo.id
      container_repo.docker_manifest_lists << ::Katello::DockerManifestList.create(pulp_id: 'manifester-lister')
      container_service = container_repo.backend_service(@proxy).with_mirror_adapter
      container_repo.expects(:backend_service).with(@proxy).once.returns(container_service)
      container_service.expects(:count_by_pulpcore_type).with(::Katello::Pulp3::DockerManifestList).once.returns(1)
      container_counts = {
        "container.blob" => {count: 30, href: 'href'},
        "container.manifest" => {count: 10, href: 'href'},
        "container.tag" => {count: 5, href: 'href'},
      }
      container_service.expects(:latest_content_counts).once.returns(container_counts)
      container_repo
    end

    def setup_cvv_container_repo
      busybox_repo = katello_repositories(:busybox)
      container_repo = katello_repositories(:busybox_dev)
      container_repo.update library_instance_id: busybox_repo.id
      container_repo.docker_manifest_lists << ::Katello::DockerManifestList.create(pulp_id: 'manifester-list1')
      container_service = container_repo.backend_service(@proxy).with_mirror_adapter
      container_repo.expects(:backend_service).with(@proxy).once.returns(container_service)
      container_service.expects(:count_by_pulpcore_type).with(::Katello::Pulp3::DockerManifestList).once.returns(1)
      container_counts = {
        "container.blob" => {count: 30, href: 'href'},
        "container.manifest" => {count: 10, href: 'href'},
        "container.tag" => {count: 5, href: 'href'},
      }
      container_service.expects(:latest_content_counts).once.returns(container_counts)
      container_repo
    end

    def setup_ostree_repo
      ostree_repo = katello_repositories(:pulp3_ostree_1)
      ostree_repo.update library_instance_id: ostree_repo.id
      ostree_service = ostree_repo.backend_service(@proxy).with_mirror_adapter
      ostree_repo.expects(:backend_service).with(@proxy).once.returns(ostree_service)
      ostree_counts = {
        "ostree.refs" => {count: 30, href: 'href'},
      }
      ostree_service.expects(:latest_content_counts).once.returns(ostree_counts)
      ostree_repo
    end

    def setup_deb_repo
      deb_repo = katello_repositories(:pulp3_deb_1)
      deb_repo.update library_instance_id: deb_repo.id
      deb_service = deb_repo.backend_service(@proxy).with_mirror_adapter
      deb_repo.expects(:backend_service).with(@proxy).once.returns(deb_service)
      deb_counts = {
        "deb.package" => {count: 987, href: 'href'},
      }
      deb_service.expects(:latest_content_counts).once.returns(deb_counts)
      deb_repo
    end

    def setup_python_repo
      python_repo = katello_repositories(:pulp3_python_1)
      python_repo.update library_instance_id: python_repo.id
      python_service = python_repo.backend_service(@proxy).with_mirror_adapter
      python_repo.expects(:backend_service).with(@proxy).once.returns(python_service)
      python_counts = {
        "python.python" => {count: 42, href: 'href'},
      }
      python_service.expects(:latest_content_counts).once.returns(python_counts)
      python_repo
    end

    # rubocop:disable Metrics/AbcSize
    def test_update_global_content_counts
      @proxy_mirror.features << ::Feature.find_by(name: ::SmartProxy::PULP3_FEATURE)
      yum_repo = setup_yum_repo
      file_repo = setup_file_repo
      ansible_repo = setup_ansible_collection_repo
      container_repo = setup_container_repo
      cvv_container_repo = setup_cvv_container_repo
      ostree_repo = setup_ostree_repo
      deb_repo = setup_deb_repo
      python_repo = setup_python_repo
      repos = [yum_repo, file_repo, ansible_repo, container_repo,
               ostree_repo, deb_repo, python_repo, cvv_container_repo]
      @proxy.lifecycle_environments << [container_repo.environment, cvv_container_repo.environment]
      ::Katello::SmartProxyHelper.any_instance.expects(:repositories_available_to_capsule).once.returns(repos)
      @proxy.expects(:refresh_smart_proxy_sync_histories).returns(true)
      @proxy.update_content_counts!
      counts = @proxy.content_counts
      expected_counts = { "content_view_versions" =>
        { yum_repo.content_view_version.id.to_s =>
          { "repositories" =>
            { yum_repo.id.to_s => {
              "metadata" => {
                "env_id" => yum_repo.environment.id,
                "library_instance_id" => yum_repo.library_instance_or_self.id,
                "product_id" => yum_repo.product_id,
                "content_type" => yum_repo.content_type,
              },
              "counts" => { "erratum" => 4, "srpm" => 1, "rpm" => 31, "module_stream" => 7, "rpm.modulemd_defaults" => 3, "package_group" => 7, "rpm.packagecategory" => 1 },
            },
              file_repo.id.to_s => {
                "metadata" => {
                  "env_id" => file_repo.environment.id,
                  "library_instance_id" => file_repo.library_instance_or_self.id,
                  "product_id" => file_repo.product_id,
                  "content_type" => file_repo.content_type,
                },
                "counts" =>
              { "file" => 100 },
              },
              ansible_repo.id.to_s => {
                "metadata" => {
                  "env_id" => ansible_repo.environment.id,
                  "library_instance_id" => ansible_repo.library_instance_or_self.id,
                  "product_id" => ansible_repo.product_id,
                  "content_type" => ansible_repo.content_type},
                "counts" =>
                  { "ansible.collection" => 802 },
              },
              container_repo.id.to_s => {
                "metadata" => {
                  "env_id" => container_repo.environment.id,
                  "library_instance_id" => container_repo.library_instance_or_self.id,
                  "product_id" => container_repo.product_id,
                  "content_type" => container_repo.content_type,
                },
                "counts" =>
                  { "container.blob" => 30, "docker_manifest_list" => 1, "docker_manifest" => 9, "docker_tag" => 5 },
              },
              ostree_repo.id.to_s => {
                "metadata" => {
                  "env_id" => ostree_repo.environment.id,
                  "library_instance_id" => ostree_repo.library_instance_or_self.id,
                  "product_id" => ostree_repo.product_id,
                  "content_type" => ostree_repo.content_type,
                },
                "counts" =>
                  {"ostree_ref" => 30 },
              },
              deb_repo.id.to_s => {
                "metadata" => {
                  "env_id" => deb_repo.environment.id,
                  "library_instance_id" => deb_repo.library_instance_or_self.id,
                  "product_id" => deb_repo.product_id,
                  "content_type" => deb_repo.content_type,
                },
                "counts" =>
                  { "deb" => 987 },
              },
              python_repo.id.to_s => {
                "metadata" => {
                  "env_id" => python_repo.environment.id,
                  "library_instance_id" => python_repo.library_instance_or_self.id,
                  "product_id" => python_repo.product_id,
                  "content_type" => python_repo.content_type,
                },
                "counts" =>
                  { "python_package" => 42 },
              },
            },
          },
          cvv_container_repo.content_view_version.id.to_s =>
          { "repositories" =>
            { cvv_container_repo.id.to_s => {
              "metadata" => {
                "env_id" => cvv_container_repo.environment.id,
                "library_instance_id" => cvv_container_repo.library_instance_or_self.id,
                "product_id" => cvv_container_repo.product_id,
                "content_type" => cvv_container_repo.content_type,
              },
              "counts" => { "container.blob" => 30, "docker_manifest_list" => 1, "docker_manifest" => 9, "docker_tag" => 5 },
            },
            },
        },
        },
      }
      assert_equal expected_counts, counts
    end
    # rubocop:enable Metrics/AbcSize

    def test_update_environment_content_counts
      @proxy_mirror.features << ::Feature.find_by(name: ::SmartProxy::PULP3_FEATURE)
      container_repo = setup_container_repo
      repos = [container_repo]
      @proxy.lifecycle_environments << container_repo.environment
      ::Katello::SmartProxyHelper.any_instance.expects(:repositories_available_to_capsule)
                                 .with(container_repo.environment, nil)
                                 .once
                                 .returns(repos)
      @proxy.expects(:refresh_smart_proxy_sync_histories).returns(true)
      @proxy.update_content_counts!(environment: container_repo.environment)
      counts = @proxy.content_counts
      expected_counts = { "content_view_versions" =>
                           { container_repo.content_view_version.id.to_s =>
                              { "repositories" =>
                                 { container_repo.id.to_s => {
                                   "metadata" => {
                                     "env_id" => container_repo.environment.id,
                                     "library_instance_id" => container_repo.library_instance_or_self.id,
                                     "product_id" => container_repo.product_id,
                                     "content_type" => container_repo.content_type,
                                   },
                                   "counts" =>
                                   { "container.blob" => 30, "docker_manifest_list" => 1, "docker_manifest" => 9, "docker_tag" => 5 },
                                 },
                                 },
                              },
                           },
                         }
      assert_equal expected_counts, counts
    end

    def test_update_content_view_counts
      cvv_container_repo = setup_cvv_container_repo
      repos = [cvv_container_repo]
      @proxy.lifecycle_environments = [cvv_container_repo.environment]
      ::Katello::SmartProxyHelper.any_instance.expects(:repositories_available_to_capsule)
                                 .with(nil, cvv_container_repo.content_view_version.content_view)
                                 .once
                                 .returns(repos)
      @proxy.expects(:refresh_smart_proxy_sync_histories).returns(true)
      @proxy.update_content_counts!(environment: nil,
                                    content_view: cvv_container_repo.content_view_version.content_view,
                                    repository: nil)
      counts = @proxy.content_counts
      expected_counts = { "content_view_versions" =>
                           { cvv_container_repo.content_view_version.id.to_s =>
                              { "repositories" =>
                                 { cvv_container_repo.id.to_s => {
                                   "metadata" => {
                                     "env_id" => cvv_container_repo.environment.id,
                                     "library_instance_id" => cvv_container_repo.library_instance_or_self.id,
                                     "product_id" => cvv_container_repo.product_id,
                                     "content_type" => cvv_container_repo.content_type,
                                   },
                                   "counts" =>
                                   { "container.blob" => 30, "docker_manifest_list" => 1, "docker_manifest" => 9, "docker_tag" => 5 },
                                 },
                                 },
                              },
                           },
      }
      assert_equal expected_counts, counts
    end

    def test_update_repository_counts
      cvv_container_repo = setup_cvv_container_repo
      @proxy.expects(:refresh_smart_proxy_sync_histories).returns(true)
      @proxy.lifecycle_environments << cvv_container_repo.environment
      @proxy.update_content_counts!(repository: cvv_container_repo)
      counts = @proxy.content_counts
      expected_counts = { "content_view_versions" =>
                           { cvv_container_repo.content_view_version.id.to_s =>
                              { "repositories" =>
                                 { cvv_container_repo.id.to_s => {
                                   "metadata" => {
                                     "env_id" => cvv_container_repo.environment.id,
                                     "library_instance_id" => cvv_container_repo.library_instance_or_self.id,
                                     "product_id" => cvv_container_repo.product_id,
                                     "content_type" => cvv_container_repo.content_type,
                                   },
                                   "counts" =>
                                   { "container.blob" => 30, "docker_manifest_list" => 1, "docker_manifest" => 9, "docker_tag" => 5 },
                                 },
                                 },
                              },
                           },
      }
      assert_equal expected_counts, counts
    end

    def test_refresh_sync_history
      file_repo = katello_repositories(:pulp3_file_1)
      file_repo.update library_instance_id: file_repo.id
      repos = [file_repo]
      @proxy.lifecycle_environments = [file_repo.environment]
      ::Katello::SmartProxyHelper.any_instance.expects(:repositories_available_to_capsule)
                                 .returns(repos)
      file_repo.create_smart_proxy_sync_history(@proxy)
      assert_equal 1, @proxy.smart_proxy_sync_histories.count
      @proxy.remove_lifecycle_environment(file_repo.environment)
      assert_equal 0, @proxy.smart_proxy_sync_histories.count
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

    def test_rhsm_url_without_rhsm_url_setting
      Setting[:foreman_url] = 'https://foreman.example.com/'
      proxy = FactoryBot.build(:smart_proxy, :with_pulp3)
      assert_equal "https://foreman.example.com/rhsm", proxy.rhsm_url.to_s
    end

    def test_rhsm_url_with_rhsm_url_setting
      proxy = FactoryBot.create(:smart_proxy, :with_pulp3)
      feature = proxy.smart_proxy_feature_by_name(::SmartProxy::PULP3_FEATURE)
      feature.settings['rhsm_url'] = 'https://rhsm.example.com/rhsm'
      feature.save!
      assert_equal 'https://rhsm.example.com/rhsm', proxy.rhsm_url.to_s
    end

    def test_sync_container_gateway
      environment = katello_environments(:library)
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)

      expected_repo_list_args = {
        :repositories => [{:repository => "empty_organization-puppet_product-busybox", :auth_required => true}, {:repository => "busybox", :auth_required => true}, {:repository => "id/1/2/container-push-repo", :auth_required => true}],
      }
      repo_list_update_expectation = ProxyAPI::ContainerGateway.any_instance.expects(:repository_list).with do |value|
        Set.new(value[:repositories]) == Set.new(expected_repo_list_args[:repositories])
      end
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

    def test_sync_container_gateway_with_hosts
      environment = katello_environments(:library)
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)

      host = FactoryBot.build(:host, :with_content, :with_subscription,
                              :content_view => @view,
                              :lifecycle_environment => @library)
      host.content_facet.content_source = capsule_content.smart_proxy
      host.subscription_facet.uuid = 'test-uuid-123'
      ::Katello::Resources::Candlepin::Consumer.stubs(:update)
      host.save!

      ProxyAPI::ContainerGateway.any_instance.expects(:repository_list).returns(true)
      update_hosts_expectation = ProxyAPI::ContainerGateway.any_instance.expects(:update_hosts).with do |arg|
        arg[:hosts].length == 1 && arg[:hosts].first[:uuid] == 'test-uuid-123'
      end
      update_hosts_expectation.returns(true)
      host_mapping_expectation = ProxyAPI::ContainerGateway.any_instance.expects(:host_repository_mapping).with do |arg|
        arg[:hosts].length == 1 && arg[:hosts].first.key?('test-uuid-123')
      end
      host_mapping_expectation.returns(true)

      capsule_content.smart_proxy.expects(:container_gateway_users).returns([])
      capsule_content.smart_proxy.sync_container_gateway
    end

    def test_sync_container_gateway_skips_nil_uuid
      environment = katello_environments(:library)
      with_pulp3_features(capsule_content.smart_proxy)
      capsule_content.smart_proxy.add_lifecycle_environment(environment)

      ::Katello::Resources::Candlepin::Consumer.stubs(:update)

      host_with_uuid = FactoryBot.build(:host, :with_content, :with_subscription,
                                        :content_view => @view,
                                        :lifecycle_environment => @library)
      host_with_uuid.content_facet.content_source = capsule_content.smart_proxy
      host_with_uuid.subscription_facet.uuid = 'valid-uuid'
      host_with_uuid.save!

      host_without_uuid = FactoryBot.build(:host, :with_content, :with_subscription,
                                           :content_view => @view,
                                           :lifecycle_environment => @library)
      host_without_uuid.content_facet.content_source = capsule_content.smart_proxy
      host_without_uuid.subscription_facet.uuid = nil
      host_without_uuid.save!

      ProxyAPI::ContainerGateway.any_instance.expects(:repository_list).returns(true)
      update_hosts_expectation = ProxyAPI::ContainerGateway.any_instance.expects(:update_hosts).with do |arg|
        arg[:hosts].length == 1 && arg[:hosts].first[:uuid] == 'valid-uuid'
      end
      update_hosts_expectation.returns(true)
      host_mapping_expectation = ProxyAPI::ContainerGateway.any_instance.expects(:host_repository_mapping).with do |arg|
        arg[:hosts].length == 1 && arg[:hosts].first.key?('valid-uuid')
      end
      host_mapping_expectation.returns(true)

      capsule_content.smart_proxy.expects(:container_gateway_users).returns([])
      capsule_content.smart_proxy.sync_container_gateway
    end

    def test_update_host_repositories
      ::Katello::Resources::Candlepin::Consumer.stubs(:update)
      host = FactoryBot.build(:host, :with_content, :with_subscription,
                              :content_view => @view,
                              :lifecycle_environment => @library)
      host.subscription_facet.uuid = 'host-uuid-456'
      host.save!

      update_repo_expectation = ProxyAPI::ContainerGateway.any_instance.expects(:update_host_repositories).with do |arg|
        arg[:hosts].length == 1 && arg[:hosts].first.key?('host-uuid-456')
      end
      update_repo_expectation.returns(true)

      @proxy.update_host_repositories(host)
    end

    def test_update_host_repositories_with_nil_uuid
      ::Katello::Resources::Candlepin::Consumer.stubs(:update)
      host = FactoryBot.build(:host, :with_content, :with_subscription,
                              :content_view => @view,
                              :lifecycle_environment => @library)
      host.subscription_facet.uuid = nil
      host.save!

      ProxyAPI::ContainerGateway.any_instance.expects(:update_host_repositories).never

      @proxy.update_host_repositories(host)
    end

    def test_update_host_repositories_without_subscription_facet
      host = FactoryBot.build(:host, :with_content,
                              :content_view => @view,
                              :lifecycle_environment => @library)
      host.save!

      ProxyAPI::ContainerGateway.any_instance.expects(:update_host_repositories).never

      @proxy.update_host_repositories(host)
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
      'python': 'python',
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
# rubocop:enable Metrics/ClassLength
