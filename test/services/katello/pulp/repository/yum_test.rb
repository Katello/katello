require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class YumBaseTest < ::ActiveSupport::TestCase
        include VCR::TestCase
        include RepositorySupport

        def setup
          set_ca_file
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy)
          @mirror = FactoryBot.build(:smart_proxy, :pulp_mirror)

          @rhel6 = katello_repositories(:rhel_6_x86_64)
          @rhel6_cv = katello_repositories(:rhel_6_x86_64_dev)
          @custom = katello_repositories(:fedora_17_x86_64)
          @custom_cv = katello_repositories(:fedora_17_x86_64_library_view_1)

          @rhel6.product.stubs(:certificate).returns('mycert')
          @rhel6.product.stubs(:key).returns('mykey')

          Cert::Certs.stubs(:ueber_cert).returns({})
        end

        def delete_repo(repo)
          ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Destroy, :repository_id => repo.id) rescue ''
        end

        def sync_repo(repo)
          ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Sync, :repo_id => repo.id)
        end

        def create_repo(repo)
          repo.backend_service(SmartProxy.pulp_master).create
        end
      end

      class YumTest < YumBaseTest
        def test_importer_rhel6_mirror
          @rhel6.root.url = "https://cdn.redhat.com/"
          repo = Katello::Pulp::Repository::Yum.new(@rhel6, @master)
          importer = repo.generate_importer
          assert_includes importer.feed, "cdn.redhat.com"
        end

        def test_importer_redhat_mirror
          repo = Katello::Pulp::Repository::Yum.new(@rhel6, @mirror)
          importer = repo.generate_importer
          assert_includes importer.feed, "https://#{URI(@master.url).host}"
        end

        def test_external_url_mirror
          @rhel6.root.url = 'http://zodiak.com/ted'
          @rhel6.relative_path = '/elbow'

          service = Katello::Pulp::Repository::Yum.new(@rhel6, @mirror)
          host = URI(@master.url).host.chomp('/')

          assert_equal service.generate_importer.feed, "https://#{host}/pulp/repos/elbow/"

          @rhel6.root.unprotected = true
          assert_equal service.generate_importer.feed, "https://#{host}/pulp/repos/elbow/"
        end

        def test_external_url_master
          @rhel6.root.url = 'http://zodiak.com/ted'
          @rhel6.relative_path = '/elbow'

          service = Katello::Pulp::Repository::Yum.new(@rhel6, @master)
          host = URI(@master.url).host.chomp('/')

          assert_equal service.generate_importer.feed, @rhel6.root.url
          assert_equal service.external_url, "https://#{host}/pulp/repos/elbow/"

          @rhel6.root.unprotected = true
          assert_equal service.external_url, "http://#{host}/pulp/repos/elbow/"
          assert_equal service.external_url(true), "https://#{host}/pulp/repos/elbow/"
        end

        def test_class_distribution_bootable?
          assert ::Katello::Pulp::Repository::Yum.distribution_bootable?('files' => [{:relativepath => '/foo/kernel.img'}])
          assert ::Katello::Pulp::Repository::Yum.distribution_bootable?('files' => [{:relativepath => '/foo/initrd.img'}])
          assert ::Katello::Pulp::Repository::Yum.distribution_bootable?('files' => [{:relativepath => '/bar/vmlinuz'}])
          assert ::Katello::Pulp::Repository::Yum.distribution_bootable?('files' => [{:relativepath => '/bar/foo/pxeboot'}])
          refute ::Katello::Pulp::Repository::Yum.distribution_bootable?('files' => [{:relativepath => '/bar/foo'}])
        end

        def test_distributor_to_publish_with_source
          @rhel6 = katello_repositories(:rhel_6_x86_64)
          options = {:source_repository => {:id => @rhel6.id}}
          ::Katello::Repository.expects(:find).with(@rhel6.id).returns(@rhel6)
          source_service = Katello::Pulp::Repository::Yum.new(@rhel6, @master)
          distributor_id = "BAR"
          source_service.expects(:lookup_distributor_id).with(Runcible::Models::YumDistributor.type_id).returns(distributor_id)
          @rhel6.expects(:backend_service).returns(source_service)

          expected_response = { Runcible::Models::YumCloneDistributor => { source_repo_id: @rhel6.pulp_id,
                                                                           source_distributor_id: distributor_id}
                              }
          assert_equal expected_response, source_service.distributors_to_publish(options)
        end

        def test_distributor_to_publish_without_source
          @rhel6 = katello_repositories(:rhel_6_x86_64)
          source_service = Katello::Pulp::Repository::Yum.new(@rhel6, @master)

          expected_response = {Runcible::Models::YumDistributor => {}}
          assert_equal expected_response, source_service.distributors_to_publish({})
        end
      end

      class YumVcrTest < YumBaseTest
        def setup
          super
          delete_repo(@rhel6)
          delete_repo(@custom)
        end

        def test_create
          @rhel6.root.update_attributes!(
              mirror_on_sync: true,
              download_policy: 'on_demand',
              verify_ssl_on_sync: true,
              ignorable_content: ['rpm'],
              url: 'https://cdn.redhat.com/foo/bar'
          )
          @rhel6.root.product.expects(:certificate).returns('repo_cert')
          @rhel6.root.product.expects(:key).returns('repo_key')
          Katello::Repository.expects(:feed_ca_cert).returns('ca_cert')

          repo = Katello::Pulp::Repository::Yum.new(@rhel6, @master)

          response = repo.create
          assert_equal @rhel6.pulp_id, response['id']

          importer = repo.backend_data['importers'][0]['config']
          assert_equal importer['ssl_validation'], @rhel6.root.verify_ssl_on_sync
          assert_equal importer['type_skip_list'], @rhel6.root.ignorable_content
          assert_equal importer['download_policy'], @rhel6.root.download_policy
          assert_equal importer['ssl_ca_cert'], 'ca_cert'
          assert_equal importer['ssl_client_cert'], 'repo_cert'
          assert_equal importer['ssl_client_key'], 'repo_key'
        ensure
          delete_repo(@rhel6)
        end

        def test_create_custom
          @custom.root.update_attributes!(
              mirror_on_sync: true,
              download_policy: 'on_demand',
              verify_ssl_on_sync: true,
               upstream_username: 'root',
               upstream_password: 'redhat',
              ignorable_content: ['drpm']
          )
          repo = Katello::Pulp::Repository::Yum.new(@custom, @master)

          response = repo.create
          assert_equal @custom.pulp_id, response['id']

          importer = repo.backend_data['importers'][0]['config']
          assert_equal importer['ssl_validation'], @custom.root.verify_ssl_on_sync
          assert_equal importer['type_skip_list'], @custom.root.ignorable_content
          assert_equal importer['download_policy'], @custom.root.download_policy
          assert_equal importer['basic_auth_username'], @custom.root.upstream_username

          assert_equal 3, repo.backend_data['distributors'].count
        ensure
          delete_repo(@custom)
        end

        def test_refresh
          repo = Katello::Pulp::Repository::Yum.new(@custom, @master)
          repo.create
          distributor = repo.backend_data['distributors'].find { |dist| dist['distributor_type_id'] == 'yum_distributor' }
          task_list = repo.smart_proxy.pulp_api.resources.repository.delete_distributor(@custom.pulp_id, distributor['id'])
          refute_empty task_list
          TaskSupport.wait_on_tasks(task_list)
          assert_equal 2, repo.backend_data(true)['distributors'].count
          TaskSupport.wait_on_tasks(repo.refresh)
          assert_equal 3, repo.backend_data(true)['distributors'].count
          assert_empty repo.refresh_if_needed
        ensure
          delete_repo(@custom)
        end
      end

      class RpmTestWithProxy < ActiveSupport::TestCase
        include RepositorySupport

        def setup
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy)
          User.current = users(:admin)

          @default_proxy = FactoryBot.create(:http_proxy, name: 'best proxy',
                                             url: "http://url_1")
          Setting.find_by(name: 'content_default_http_proxy').update(
            value: @default_proxy.name)
          @repo = katello_repositories(:fedora_17_x86_64)
        end

        def test_create_with_global_http_proxy
          @repo.root.update(http_proxy_policy: RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)
          RepositorySupport.create_repo(@repo)
          backend_data = @repo.backend_service(@master).backend_data
          importers = backend_data['importers']
          config = importers.first['config']
          uri = URI(@default_proxy.url)
          assert_equal "http://" + uri.host, config['proxy_host']
        end

        def test_sync_with_global_http_proxy
          @repo.root.update(http_proxy_policy: RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)
          RepositorySupport.create_repo(@repo)
          ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Sync, :repo_id => @repo.id)
          backend_data = @repo.backend_service(@master).backend_data
          importers = backend_data['importers']
          config = importers.first['config']
          uri = URI(@default_proxy.url)
          assert_equal "http://" + uri.host, config['proxy_host']
        end

        def teardown
          RepositorySupport.destroy_repo(@repo)
          User.current = nil
        end
      end

      class YumDepSolveNonVcrTests < YumBaseTest
        def test_generate_mapping
          @rhel6.expects(:siblings).returns mock(yum_type: [@custom])
          @rhel6_cv.expects(:siblings).returns mock(yum_type: [@custom_cv])
          assert_equal({@custom.pulp_id => @custom_cv.pulp_id}, @rhel6.backend_service(@master).generate_mapping(@rhel6_cv))
        end

        def test_build_override_config_dep_solve_and_filters
          mapping = { foo: "bar" }
          service = @rhel6.backend_service(@master)
          service.expects(:generate_mapping).with(@rhel6_cv).returns(mapping)
          rule = FactoryBot.build(:katello_content_view_package_filter_rule)
          options = { :solve_dependencies => true, :filters => rule.filter }
          override_config = service.build_override_config(@rhel6_cv, options)
          assert_equal override_config[:recursive_conservative], true
          assert_equal override_config[:additional_repos], mapping
        end

        def test_build_override_config_dep_solve_and_no_filters
          service = @rhel6.backend_service(@master)
          service.expects(:generate_mapping).never

          options = { :solve_dependencies => true }
          override_config = service.build_override_config(@rhel6_cv, options)
          assert_nil override_config[:recursive_conservative]
          assert_nil override_config[:additional_repos]
        end

        def test_build_override_config_dep_solve_forced_on_incremental_update
          mapping = { foo: "bar" }
          service = @rhel6.backend_service(@master)
          service.expects(:generate_mapping).with(@rhel6_cv).returns(mapping)
          options = { incremental_update: true}
          override_config = service.build_override_config(@rhel6_cv, options)
          assert_equal override_config[:recursive_conservative], true
          assert_equal override_config[:additional_repos], mapping
        end
      end

      class YumVcrCopyTest < YumBaseTest
        def setup
          super
          @custom.root.update_attributes(:url => 'file:///var/www/test_repos/zoo')
          delete_repo(@custom_cv)
          delete_repo(@custom)
          create_repo(@custom)
          sync_repo(@custom)
          create_repo(@custom_cv)
        end

        def teardown
          delete_repo(@custom)
          delete_repo(@custom_cv)
        end

        def test_copy_no_filters
          @custom.index_content
          TaskSupport.wait_on_tasks(@custom.backend_service(@master).copy_contents(@custom_cv))
          assert_equal SmartProxy.pulp_master.pulp_api.extensions.repository.retrieve_with_details(@custom.pulp_id)[:content_unit_counts].except('package_category'),
                       SmartProxy.pulp_master.pulp_api.extensions.repository.retrieve_with_details(@custom_cv.pulp_id)[:content_unit_counts]
        end

        def test_copy_rpm_filenames
          @custom.index_content
          TaskSupport.wait_on_tasks(@custom.backend_service(@master).copy_contents(@custom_cv, :rpm_filenames => [@custom.rpms.non_modular.first.filename]))
          counts = SmartProxy.pulp_master.pulp_api.extensions.repository.retrieve_with_details(@custom_cv.pulp_id)[:content_unit_counts]

          assert_equal 1 + @custom.rpms.modular.count, counts[:rpm]
          assert_equal @custom.errata.count, counts[:erratum]
        end

        def test_errata_filter
          @custom.index_content
          filter = Katello::ContentViewErratumFilter.create!(:inclusion => true, :content_view_id => @custom_cv.content_view.id, :name => 'asdf')
          filter.erratum_rules << Katello::ContentViewErratumFilterRule.new(:errata_id => 'KATELLO-RHEA-2010:0002')
          TaskSupport.wait_on_tasks(@custom.backend_service(@master).copy_contents(@custom_cv, :filters => Katello::ContentViewErratumFilter.where(:id => filter.id)))
          @custom_cv.index_content
          @custom_cv = @custom_cv.reload
          TaskSupport.wait_on_tasks(@custom_cv.backend_service(@master).purge_partial_errata)
          counts = SmartProxy.pulp_master.pulp_api.extensions.repository.retrieve_with_details(@custom_cv.pulp_id)[:content_unit_counts]

          assert_equal 1, counts[:rpm]
          assert_equal 1, counts[:erratum]
        end
      end
    end
  end
end
