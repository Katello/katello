require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class YumBaseTest < ::ActiveSupport::TestCase
        include VCR::TestCase
        include RepositorySupport

        def setup
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy)
          @mirror = FactoryBot.build(:smart_proxy, :pulp_mirror)

          @rhel6 = katello_repositories(:rhel_6_x86_64)
          @rhel6_cv = katello_repositories(:rhel_6_x86_64_dev)
          @custom = katello_repositories(:fedora_17_x86_64)

          @rhel6.product.stubs(:certificate).returns('mycert')
          @rhel6.product.stubs(:key).returns('mykey')

          Cert::Certs.stubs(:ueber_cert).returns({})
        end

        def delete_repo(repo)
          ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Destroy, :pulp_id => repo.pulp_id) rescue ''
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
              checksum_type: 'sha1',
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
              ignorable_content: ['drpm'],
              checksum_type: 'sha1'
          )
          repo = Katello::Pulp::Repository::Yum.new(@custom, @master)

          response = repo.create
          assert_equal @custom.pulp_id, response['id']

          importer = repo.backend_data['importers'][0]['config']
          assert_equal importer['ssl_validation'], @custom.root.verify_ssl_on_sync
          assert_equal importer['type_skip_list'], @custom.root.ignorable_content
          assert_equal importer['download_policy'], @custom.root.download_policy
          assert_equal importer['basic_auth_username'], @custom.root.upstream_username

          distributor = repo.backend_data['distributors'].find { |dist| dist['distributor_type_id'] == 'yum_distributor' }
          assert_equal @custom.root.checksum_type, distributor['config']['checksum_type']
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
          repo_refresh = Katello::Pulp::Repository::Yum.new(@custom, @master)
          repo_refresh.refresh
          assert_equal 3, repo.backend_data(true)['distributors'].count
        ensure
          delete_repo(@custom)
        end
      end
    end
  end
end
