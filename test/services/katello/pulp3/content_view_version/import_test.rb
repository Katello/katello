require 'katello_test_helper'
module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportTest < ActiveSupport::TestCase
          include Support::Actions::Fixtures

          it "fails on blank path" do
            exception = assert_raises(RuntimeError) do
              ::Katello::Pulp3::ContentViewVersion::Import.check_permissions!(nil)
            end
            assert_match(/Invalid path/, exception.message)
          end

          it "fails if not a dir" do
            path = __FILE__ # set it to current file path
            exception = assert_raises(RuntimeError) do
              ::Katello::Pulp3::ContentViewVersion::Import.check_permissions!(path)
            end
            assert_match(/Invalid path/, exception.message)
          end

          it "fails if not a an importable basedir prefixed" do
            path = __dir__ # current directory
            exception = assert_raises(RuntimeError) do
              ::Katello::Pulp3::ContentViewVersion::Import.check_permissions!(path)
            end
            assert_match(/import path must be in a subdirectory under/, exception.message)
          end

          it "fails if not a metadata json found" do
            import_export_dir = File.join(Katello::Engine.root, 'test/fixtures')
            stub_constant(::Katello::Pulp3::ContentViewVersion::Import, :BASEDIR, import_export_dir) do
              exception = assert_raises(RuntimeError) do
                ::Katello::Pulp3::ContentViewVersion::Import.check_permissions!(import_export_dir)
              end
              assert_match(/Could not find metadata/, exception.message)
            end
          end

          it "can skip the metadata json check" do
            import_export_dir = File.join(Katello::Engine.root, 'test/fixtures')
            File.expects(:readable?).with("#{import_export_dir}/metadata.json").never
            stub_constant(::Katello::Pulp3::ContentViewVersion::Import, :BASEDIR, import_export_dir) do
              ::Katello::Pulp3::ContentViewVersion::Import.check_permissions!(import_export_dir, assert_metadata: false)
            end
          end

          it "fails if not able to read metadata json" do
            import_export_dir = File.join(Katello::Engine.root, 'test/fixtures/import-export')
            File.expects(:readable?).with("#{import_export_dir}/metadata.json").returns(false)

            stub_constant(::Katello::Pulp3::ContentViewVersion::Import, :BASEDIR, import_export_dir) do
              exception = assert_raises(RuntimeError) do
                ::Katello::Pulp3::ContentViewVersion::Import.check_permissions!(import_export_dir)
              end
              assert_match(/Unable to read the metadata/, exception.message)
            end
          end

          it "fails if pulp user is not able to access metadata json" do
            import_export_dir = File.join(Katello::Engine.root, 'test/fixtures/import-export')
            ::Katello::Pulp3::ContentViewVersion::Import.expects(:pulp_user_accessible?).with(import_export_dir).returns(false)

            stub_constant(::Katello::Pulp3::ContentViewVersion::Import, :BASEDIR, import_export_dir) do
              exception = assert_raises(RuntimeError) do
                ::Katello::Pulp3::ContentViewVersion::Import.check_permissions!(import_export_dir)
              end
              assert_match(/Pulp user or group unable to read content/, exception.message)
            end
          end

          it "pulp_user_accessible returns false if no pulp user" do
            ::Katello::Pulp3::ContentViewVersion::Import.expects(:fetch_pulp_user_info).returns(nil)
            refute ::Katello::Pulp3::ContentViewVersion::Import.pulp_user_accessible?("/tmp")
          end

          it "pulp_user_accessible returns false if no uid/gid/readable does not match" do
            path = "/tmp"
            stats = mock(gid: 1001, uid: 1002, mode: 1)
            File.expects(:stat).with(path).returns(stats)

            user_info = mock(gid: 1003.to_s, uid: 1004.to_s)
            ::Katello::Pulp3::ContentViewVersion::Import.expects(:fetch_pulp_user_info).returns(user_info)
            refute ::Katello::Pulp3::ContentViewVersion::Import.pulp_user_accessible?(path)
          end

          it "pulp_user_accessible returns true if world readable" do
            path = "/tmp"
            stats = mock(gid: 1001, uid: 1002, mode: 7)
            File.expects(:stat).with(path).returns(stats)

            user_info = mock(gid: 1004.to_s, uid: 1005.to_s)
            ::Katello::Pulp3::ContentViewVersion::Import.expects(:fetch_pulp_user_info).returns(user_info)
            assert ::Katello::Pulp3::ContentViewVersion::Import.pulp_user_accessible?(path)
          end

          it "pulp_user_accessible returns true if groups match" do
            path = "/tmp"
            stats = mock(gid: 1001)
            File.expects(:stat).with(path).returns(stats)

            user_info = mock(gid: 1001.to_s)
            ::Katello::Pulp3::ContentViewVersion::Import.expects(:fetch_pulp_user_info).returns(user_info)
            assert ::Katello::Pulp3::ContentViewVersion::Import.pulp_user_accessible?(path)
          end

          it "pulp_user_accessible returns true if uids match" do
            path = "/tmp"
            stats = mock(gid: 1001, uid: 1002)
            File.expects(:stat).with(path).returns(stats)

            user_info = mock(gid: 1003.to_s, uid: 1002.to_s)
            ::Katello::Pulp3::ContentViewVersion::Import.expects(:fetch_pulp_user_info).returns(user_info)
            assert ::Katello::Pulp3::ContentViewVersion::Import.pulp_user_accessible?(path)
          end
        end
      end
    end
  end
end
