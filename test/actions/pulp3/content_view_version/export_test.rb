require 'katello_test_helper'

module ::Actions::Pulp3::ContentView
  class ExportTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.root.update!(url: 'https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/')
      @repo = create_and_sync(@repo, @primary)
      @content_view = @repo.content_view
      @content_view_version = @content_view.versions.last
      @destination_server = 'dream-destination'
      ::Katello::Pulp3::ContentViewVersion::Export.any_instance.stubs(:date_dir).returns("date_dir")
    end

    def teardown
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
    end

    def create_exporter
      ForemanTasks.sync_task(::Actions::Pulp3::ContentViewVersion::CreateExporter,
                                     content_view_version_id: @content_view_version.id,
                                     smart_proxy_id: @primary.id,
                                     destination_server: @destination_server).output["exporter_data"]
    end

    def delete_exporter(exporter_data)
      ForemanTasks.sync_task(::Actions::Pulp3::ContentViewVersion::DestroyExporter, exporter_data: exporter_data,
                               smart_proxy_id: @primary.id)
    end

    def pulp3_cvv
      ::Katello::Pulp3::ContentViewVersion::Export.new(smart_proxy: @primary, content_view_version: @content_view_version, destination_server: @destination_server)
    end

    def test_create_exporter
      exporter_data = create_exporter
      assert_includes exporter_data["repositories"], pulp3_cvv.version_href_to_repository_href(@repo.version_href)
      assert_equal exporter_data["name"], pulp3_cvv.generate_id
      assert exporter_data["path"].end_with? pulp3_cvv.generate_exporter_path
      delete_exporter(exporter_data)
    end

    def test_destroy_exporter
      exporter_data = create_exporter
      delete_exporter(exporter_data)

      assert_raises(PulpcoreClient::ApiError) do
        Katello::Pulp3::Api::Core.new(@primary).exporter_api.read(exporter_data[:pulp_href])
      end

      assert_raises(PulpcoreClient::ApiError) do
        assert_empty Katello::Pulp3::Api::Core.new(@primary).export_api.list(exporter_data[:pulp_href])
      end
    end

    def test_export
      Actions::Pulp3::Orchestration::ContentViewVersion::Export.any_instance.expects(:action_subject).with(@content_view_version)
      File.expects(:directory?).returns(true).at_least_once
      File.expects(:write).returns.with do |path|
        assert path.end_with?(::Katello::Pulp3::ContentViewVersion::Export::METADATA_FILE)
      end

      output = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::ContentViewVersion::Export, @content_view_version, destination_server: "foo").output
      refute_empty output[:exported_file_name]
      refute_empty output[:exported_file_checksum]
      assert_includes output[:exported_file_name], 'foo'
    end
  end
end
