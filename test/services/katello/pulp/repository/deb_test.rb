require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class DebBaseTest < ::ActiveSupport::TestCase
        include RepositorySupport
        include VCR::TestCase

        def setup
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy)
          @mirror = FactoryBot.build(:smart_proxy, :pulp_mirror)

          @repo = FactoryBot.build(:katello_repository, :deb)
          @repo.content_view_version = katello_content_view_versions(:library_default_version)
        end

        def delete_repo(repo)
          ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Destroy, :pulp_id => repo.pulp_id) rescue ''
        end
      end

      class DebVcrTest < DebBaseTest
        def setup
          super
          delete_repo(@repo)
        end

        def test_create
          service = Katello::Pulp::Repository::Deb.new(@repo, @master)
          response = service.create

          assert_equal @repo.pulp_id, response['id']

          importer = service.backend_data['importers'][0]['config']
          assert_equal @repo.root.deb_releases, importer['releases']
          assert_equal @repo.root.deb_components, importer['components']
          assert_equal @repo.root.deb_architectures, importer['architectures']

          assert_equal 1, service.backend_data['distributors'].count
        ensure
          delete_repo(@repo)
        end
      end
    end
  end
end
