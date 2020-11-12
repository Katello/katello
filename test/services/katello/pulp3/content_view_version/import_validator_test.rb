require 'katello_test_helper'
module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportValidatorTest < ActiveSupport::TestCase
          include Support::Actions::Fixtures

          def validator(content_view: nil, path: nil, metadata: {})
            content_view ||= katello_content_views(:acme_default)
            ::Katello::Pulp3::ContentViewVersion::ImportValidator.new(
                                                        content_view: content_view,
                                                        path: path,
                                                        metadata: metadata)
          end

          describe "Path Permissions" do
            it "fails on blank path" do
              exception = assert_raises(RuntimeError) do
                validator(path: nil).check_permissions!
              end
              assert_match(/Invalid path/, exception.message)
            end

            it "fails if not a dir" do
              path = __FILE__ # set it to current file path
              exception = assert_raises(RuntimeError) do
                validator(path: path).check_permissions!
              end
              assert_match(/Invalid path/, exception.message)
            end

            it "fails if not a an importable basedir prefixed" do
              path = __dir__ # current directory
              exception = assert_raises(RuntimeError) do
                validator(path: path).check_permissions!
              end
              assert_match(/import path must be in a subdirectory under/, exception.message)
            end

            it "fails if pulp user is not able to access the export path" do
              import_export_dir = File.join(Katello::Engine.root, 'test/fixtures/import-export')
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:pulp_user_accessible?).with(import_export_dir).returns(false)

              stub_constant(::Katello::Pulp3::ContentViewVersion::ImportValidator, :BASEDIR, import_export_dir) do
                exception = assert_raises(RuntimeError) do
                  validator(path: import_export_dir).check_permissions!
                end
                assert_match(/Pulp user or group unable to read content/, exception.message)
              end
            end

            it "fails if toc in the metadata doesnot  exist in the path" do
              import_export_dir = File.join(Katello::Engine.root, 'test/fixtures/import-export')
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:pulp_user_accessible?).returns(true).at_least_once

              stub_constant(::Katello::Pulp3::ContentViewVersion::ImportValidator, :BASEDIR, import_export_dir) do
                exception = assert_raises(RuntimeError) do
                  validator(path: import_export_dir, metadata: { toc: 'not-here-lalaland.toc' }).check_permissions!
                end
                assert_match(/ TOC file specified in the metadata does not exist/, exception.message)
              end
            end

            it "should not error in the perfect world!" do
              import_export_dir = File.join(Katello::Engine.root, 'test/fixtures/import-export')
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:pulp_user_accessible?).returns(true).at_least_once

              stub_constant(::Katello::Pulp3::ContentViewVersion::ImportValidator, :BASEDIR, import_export_dir) do
                assert_nothing_raised do
                  validator(path: import_export_dir, metadata: { toc: 'metadata.json' }).check_permissions!
                end
              end
            end

            it "pulp_user_accessible returns false if no pulp user" do
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:fetch_pulp_user_info).returns(nil)
              refute validator.pulp_user_accessible?("/tmp")
            end

            it "pulp_user_accessible returns false if no uid/gid/readable does not match" do
              path = "/tmp"
              stats = mock(gid: 1001, uid: 1002, mode: 1)
              File.expects(:stat).with(path).returns(stats)

              user_info = mock(gid: 1003.to_s, uid: 1004.to_s)
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:fetch_pulp_user_info).returns(user_info)
              refute validator.pulp_user_accessible?(path)
            end

            it "pulp_user_accessible returns true if world readable" do
              path = "/tmp"
              stats = mock(gid: 1001, uid: 1002, mode: 7)
              File.expects(:stat).with(path).returns(stats)

              user_info = mock(gid: 1004.to_s, uid: 1005.to_s)
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:fetch_pulp_user_info).returns(user_info)
              assert validator.pulp_user_accessible?(path)
            end

            it "pulp_user_accessible returns true if groups match" do
              path = "/tmp"
              stats = mock(gid: 1001)
              File.expects(:stat).with(path).returns(stats)

              user_info = mock(gid: 1001.to_s)
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:fetch_pulp_user_info).returns(user_info)
              assert validator.pulp_user_accessible?(path)
            end

            it "pulp_user_accessible returns true if uids match" do
              path = "/tmp"
              stats = mock(gid: 1001, uid: 1002)
              File.expects(:stat).with(path).returns(stats)

              user_info = mock(gid: 1003.to_s, uid: 1002.to_s)
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:fetch_pulp_user_info).returns(user_info)
              assert validator.pulp_user_accessible?(path)
            end
          end

          describe "Metadata" do
            before do
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:check_permissions!).returns
            end

            it "fails on metadata if content view already exists" do
              cvv = katello_content_view_versions(:library_view_version_2)
              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cvv.content_view.name, content_view_version: cvv.slice(:major, :minor) }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_match(/already exists/, exception.message)
            end

            it "fails on metadata if from content view does not exist" do
              cvv = katello_content_view_versions(:library_view_version_2)
              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cvv.content_view.name,
                             content_view_version: { major: cvv.major + 10, minor: cvv.minor },
                             from_content_view_version: { major: cvv.major + 8, minor: cvv.minor }
                }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_match(/ does not exist/, exception.message)
            end

            it "fails on metadata if the 'from' repositories in the content view does not match repositories in the metadata" do
              cv = katello_content_views(:acme_default)
              cvv = cv.versions.last
              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cv.name,
                             content_view_version: { major: cvv.major + 10, minor: cvv.minor },
                             repository_mapping: {
                               "misc-24037": { "repository": "misc",
                                               "product": "prod",
                                               "redhat": false
                                             }
                             }
                }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_match(/importing content view do not match the repositories provided in the import metadata/, exception.message)
            end
          end
        end
      end
    end
  end
end
