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

          it "fails on validate_incremental_export if the 'from' repositories and 'to' repositories point to different hrefs" do
            proxy = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
            SmartProxy.any_instance.stubs(:pulp_primary).returns(proxy)
            from_version = katello_content_view_versions(:library_view_version_1)
            version = katello_content_view_versions(:library_view_version_2)
            destination_server = "whereami.com"
            export = fetch_exporter(smart_proxy: proxy,
                                         content_view_version: version,
                                         destination_server: destination_server,
                                         from_content_view_version: from_version)
            ::Katello::Pulp3::ContentViewVersion::Export.define_method(:version_href_to_repository_href) do |href|
              href
            end

            exception = assert_raises(RuntimeError) do
              export.validate_incremental_export!
            end
            assert_match(/cannot be incrementally updated/, exception.message)
          end
        end
      end
    end
  end
end
