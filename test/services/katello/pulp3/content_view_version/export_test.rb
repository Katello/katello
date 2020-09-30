require 'katello_test_helper'
module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ExportTest < ActiveSupport::TestCase
          include Support::Actions::Fixtures
          include FactoryBot::Syntax::Methods
          include Support::ExportSupport

          it "test metadata" do
            proxy = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
            SmartProxy.any_instance.stubs(:pulp_primary).returns(proxy)
            version = katello_content_view_versions(:library_view_version_2)
            destination_server = "whereami.com"
            export = fetch_exporter(smart_proxy: proxy,
                                         content_view_version: version,
                                         destination_server: destination_server)

            data = export.generate_metadata
            assert_equal data[:content_view_version][:major], version.major
            assert_equal data[:content_view_version][:minor], version.minor
            assert_equal data[:content_view], version.content_view.name

            version_repositories = version.archived_repos.yum_type
            data[:repository_mapping].each do |name, repo_info|
              repo = version_repositories[name.to_i]
              assert_equal repo_info[:repository], repo.root.name
              assert_equal repo_info[:product], repo.root.product.name
              assert_equal repo_info[:redhat], repo.redhat?
            end
          end
        end
      end
    end
  end
end
