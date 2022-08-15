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
            proxy = SmartProxy.pulp_primary
            SmartProxy.any_instance.stubs(:pulp_primary).returns(proxy)
            version = katello_content_view_versions(:library_view_version_2)
            destination_server = "whereami.com"
            export = fetch_exporter(smart_proxy: proxy,
                                         content_view_version: version,
                                         destination_server: destination_server)

            data = export.generate_metadata
            assert_equal data[:content_view_version][:major], version.major
            assert_equal data[:content_view_version][:minor], version.minor
            assert_equal data[:content_view],
                         version.content_view.slice(:name,
                                                    :label,
                                                    :description,
                                                    :generated_for)

            version_repositories = version.archived_repos.yum_type
            data[:repositories].each do |name, repo_info|
              repo = version_repositories[name.to_i]
              assert_equal repo_info[:repository][:name], repo.root.name
              assert_equal repo_info[:product].slice(:name, :label), repo.root.product.slice(:name, :label)
              assert_equal repo_info[:redhat], repo.redhat?
            end
          end

          it "fails on validate! if any 'non-immediate' repos in cvv" do
            proxy = SmartProxy.pulp_primary
            SmartProxy.any_instance.stubs(:pulp_primary).returns(proxy)
            version = katello_content_view_versions(:library_view_version_2)
            repo1 = version.archived_repos.yum_type.first
            repo1.root.update!(download_policy: "on_demand")
            export = fetch_exporter(smart_proxy: proxy,
                                    content_view_version: version.reload)
            exception = assert_raises(RuntimeError) do
              export.validate!(fail_on_missing_content: true)
            end

            assert_match(/ Unable to fully export Content View Version/, exception.message)
            assert_match(/#{repo1.name}/, exception.message)
          end

          it "does not fail on validate! if only 'immediate' repos in cvv" do
            proxy = SmartProxy.pulp_primary
            SmartProxy.any_instance.stubs(:pulp_primary).returns(proxy)
            version = katello_content_view_versions(:library_view_version_2)
            version.archived_repos.yum_type.each do |repo|
              repo.root.update!(download_policy: "immediate")
            end

            export = fetch_exporter(smart_proxy: proxy,
                                    content_view_version: version)
            assert_nothing_raised do
              export.validate!(fail_on_missing_content: true)
            end
          end

          it "fails on validate_incremental_export if the 'from' repositories and 'to' repositories point to different hrefs" do
            proxy = SmartProxy.pulp_primary
            SmartProxy.any_instance.stubs(:pulp_primary).returns(proxy)
            from_version = katello_content_view_versions(:library_view_version_1)
            version = katello_content_view_versions(:library_view_version_2)
            destination_server = "whereami.com"
            export = fetch_exporter(smart_proxy: proxy,
                                     content_view_version: version,
                                     destination_server: destination_server,
                                     from_content_view_version: from_version)
            ::Katello::Pulp3::ContentViewVersion::Export.any_instance.expects(:validate_repositories_immediate!)
            ::Katello::Pulp3::ContentViewVersion::Export.any_instance.expects(:version_href_to_repository_href).with(nil).returns(nil).twice
            ::Katello::Pulp3::ContentViewVersion::Export.any_instance.expects(:version_href_to_repository_href).with("0").returns("0")
            ::Katello::Pulp3::ContentViewVersion::Export.any_instance.expects(:version_href_to_repository_href).with("1").returns("1")

            exception = assert_raises(RuntimeError) do
              export.validate!(fail_on_missing_content: true, validate_incremental: true)
            end
            assert_match(/cannot be incrementally updated/, exception.message)
          end

          it 'finds the library export view correctly' do
            format = ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE
            org = get_organization
            assert_nil ::Katello::Pulp3::ContentViewVersion::Export.find_library_export_view(organization: org,
                                                            create_by_default: false,
                                                            destination_server: nil,
                                                            format: format)
            # now create it
            destination_server = "example.com"
            cv = ::Katello::Pulp3::ContentViewVersion::Export.find_library_export_view(organization: org,
                                                        create_by_default: true,
                                                        destination_server: destination_server,
                                                        format: format)
            assert cv.generated_for_library_export?
            assert_equal cv.name, "Export-Library-#{destination_server}"
          end

          it 'finds the library export view correctly for syncable' do
            format = ::Katello::Pulp3::ContentViewVersion::Export::SYNCABLE
            org = get_organization
            assert_nil ::Katello::Pulp3::ContentViewVersion::Export.find_library_export_view(organization: org,
                                                            create_by_default: false,
                                                            destination_server: nil,
                                                            format: format)
            # now create it
            destination_server = "example.com"
            cv = ::Katello::Pulp3::ContentViewVersion::Export.find_library_export_view(organization: org,
                                                        create_by_default: true,
                                                        destination_server: destination_server,
                                                        format: format)
            assert cv.generated_for_library_export_syncable?
            assert_equal cv.name, "Export-Library-SYNCABLE-#{destination_server}"
          end

          it 'finds the repository export view correctly for syncable' do
            repo = katello_repositories(:rhel_6_x86_64)
            format = ::Katello::Pulp3::ContentViewVersion::Export::SYNCABLE
            assert_nil ::Katello::Pulp3::ContentViewVersion::Export.find_repository_export_view(repository: repo,
                                                            create_by_default: false,
                                                            format: format)
            # now create it
            cv = ::Katello::Pulp3::ContentViewVersion::Export.find_repository_export_view(repository: repo,
                                                        create_by_default: true,
                                                        format: format)
            assert cv.generated_for_repository_export_syncable?
            assert_match(/^Export-SYNCABLE-#{repo.label}/, cv.name)
          end

          it "does not fail on validate! if chunk_size is not specified" do
            export = setup_environment

            assert_nothing_raised do
              export.validate!(fail_on_missing_content: false, validate_incremental: false, chunk_size: nil)
            end
          end

          it "does not fail on validate! if chunk_size is less than 1_000_000GB" do
            export = setup_environment

            assert_nothing_raised do
              export.validate!(fail_on_missing_content: false, validate_incremental: false, chunk_size: 1e5)
            end
          end

          it "fails on validate! if chunk_size is >= 1_000_000GB" do
            export = setup_environment

            exception = assert_raises(RuntimeError) do
              export.validate!(fail_on_missing_content: false, validate_incremental: false, chunk_size: 1e6)
            end
            assert_match(/Specify an export chunk size less than 1_000_000 GB/, exception.message)
          end

          def setup_environment
            proxy = SmartProxy.pulp_primary
            SmartProxy.any_instance.stubs(:pulp_primary).returns(proxy)
            version = katello_content_view_versions(:library_view_version_2)
            fetch_exporter(smart_proxy: proxy, content_view_version: version)
          end
        end
      end
    end
  end
end
