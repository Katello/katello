require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class File
        class RefreshDistributionTest < ::ActiveSupport::TestCase
          include Katello::Pulp3Support

          def setup
            User.current = User.anonymous_admin
            @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
            @repo = katello_repositories(:pulp3_file_1)
            create_repo(@repo, @master)
            @service = Katello::Pulp3::Repository::File.new(@repo, @master)

            ::ForemanTasks.sync_task(Actions::Pulp3::Repository::RefreshDistribution, @repo, @master)
          end

          def teardown
            User.current = User.anonymous_admin
            ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @master)
          end

          def test_needs_distributor_update
            refute @service.distribution_needs_update?
            @repo.relative_path = "/some/other/path/that/is/different/"
            @repo.save!
            assert @service.distribution_needs_update?
          end

          def test_updates
            @service.refresh_if_needed
            @repo.relative_path = "/some/other/path/that/is/different"
            @repo.root.url = 'http://foo.com/bar'
            @repo.save!
            @service.refresh_if_needed
            assert_equal @repo.root.url + '/PULP_MANIFEST', @service.get_remote.url
            assert @repo.relative_path, @service.get_distribution.base_path
          end
        end
      end
    end
  end
end
