require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class OstreeBaseTest < ::ActiveSupport::TestCase
        include VCR::TestCase
        include RepositorySupport

        def setup
          set_ca_file
          @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy)
          @mirror = FactoryBot.build(:smart_proxy, :pulp_mirror)

          @repo = katello_repositories(:ostree)

          Cert::Certs.stubs(:ueber_cert).returns({})
        end

        def delete_repo(repo)
          ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Destroy, :repository_id => repo.id) rescue ''
        end

        def test_mirrored_importer
          service = Katello::Pulp::Repository::Ostree.new(@repo, @mirror)
          Cert::Certs.stubs(:ueber_cert).returns({})
          Katello::Pulp::Repository::Ostree.any_instance.stubs(:mirror_importer_connection_options).returns(
                                                                                                         ssl_client_cert: nil,
                                                                                                           ssl_client_key: nil,
                                                                                                           ssl_ca_cert: nil,
                                                                                                           ssl_validation: false
          )
          assert_include service.generate_mirror_importer.feed, URI(SmartProxy.pulp_primary.pulp_url).host
        end
      end

      class OstreeVcrTest < OstreeBaseTest
        def setup
          super
          delete_repo(@repo)
        end

        def test_create
          repo = Katello::Pulp::Repository::Ostree.new(@repo, @primary)
          response = repo.create

          assert_equal @repo.pulp_id, response['id']

          importer = repo.backend_data['importers'][0]['config']
          assert_equal @repo.root.compute_ostree_upstream_sync_depth, importer['depth']

          distributor = repo.backend_data['distributors'].find { |dist| dist['distributor_type_id'] == 'ostree_web_distributor' }
          assert_equal repo.root.compute_ostree_upstream_sync_depth, distributor['config']['depth']
          assert_equal 1, repo.backend_data['distributors'].count
        ensure
          delete_repo(@repo)
        end
      end
    end
  end
end
