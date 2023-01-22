require "katello_test_helper"

module Katello
  class Api::V2::ContentExportIncrementalsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
      @export_permission = :export_content
    end

    def setup
      setup_controller_defaults_api
      @library_dev_staging_view = ContentView.find(katello_content_views(:library_dev_staging_view).id)
      @library_view_version = katello_content_view_versions(:library_dev_staging_view_version)
      permissions
    end

    def test_version_protected
      @controller.stubs(:find_library_export_view)
      @controller.stubs(:find_history)

      allowed_perms = [@export_permission]
      denied_perms = [@create_permission, @update_permission,
                      @destroy_permission, @view_permission]
      version = @library_dev_staging_view.versions.first

      assert_protected_action(:version, allowed_perms, denied_perms) do
        post :version, params: { :id => version.id }
      end
    end

    def test_library_protected
      @controller.stubs(:find_library_export_view)
      @controller.stubs(:find_history)

      allowed_perms = [{name: @export_permission, :resource_type => "Organization"}]
      denied_perms = [@create_permission, @update_permission,
                      @destroy_permission, @view_permission]

      org = get_organization
      assert_protected_action(:library, allowed_perms, denied_perms, [org]) do
        post :library, params: { organization_id: org.id}
      end
    end

    def test_version_recent_history
      chunk_size_gb = 100
      destination = "example.com"
      history = {foo: 100}
      ContentViewVersionExportHistory.expects(:latest)
                                     .with(@library_view_version.content_view,
                                           destination_server: destination)
                                     .returns(history)
      export_task = @controller.expects(:async_task).with do |action_class, options|
        assert_equal Actions::Katello::ContentViewVersion::Export, action_class
        assert_equal options[:content_view_version].id, @library_view_version.id
        assert_equal options[:destination_server], destination
        assert_equal options[:chunk_size], chunk_size_gb
        assert_equal options[:from_history], history
      end
      export_task.returns(build_task_stub)
      post :version, params: { id: @library_view_version.id,
                               destination_server: destination,
                               chunk_size_gb: chunk_size_gb
                             }
      assert_response :success
    end

    def test_version_recent_history_with_history_id
      chunk_size_gb = 100
      destination = "example.com"
      history = {id: 100}
      ContentViewVersionExportHistory.expects(:find)
                                     .with(history[:id])
                                     .returns(history)

      export_task = @controller.expects(:async_task).with do |action_class, options|
        assert_equal Actions::Katello::ContentViewVersion::Export, action_class
        assert_equal options[:content_view_version].id, @library_view_version.id
        assert_equal options[:destination_server], destination
        assert_equal options[:chunk_size], chunk_size_gb
        refute options[:fail_on_missing_content]
        assert_equal options[:from_history], history
      end
      export_task.returns(build_task_stub)
      post :version, params: { id: @library_view_version.id,
                               destination_server: destination,
                               chunk_size_gb: chunk_size_gb,
                               from_history_id: history[:id]
                             }
      assert_response :success
    end

    def test_version_not_found_on_incremental
      destination = "example.com"

      ContentViewVersionExportHistory.expects(:latest)
                                     .with(@library_view_version.content_view,
                                           destination_server: destination)
                                     .returns

      post :version, params: { id: @library_view_version.id,
                               destination_server: destination
                             }
      response = JSON.parse(@response.body)['displayMessage']
      assert_match(%r{No existing export history was found to perform an incremental export}, response)
      assert_response :not_found
    end

    def test_library
      org = get_organization
      chunk_size_gb = 100
      destination = "example.com"
      history = {foo: 100}
      ::Katello::Pulp3::ContentViewVersion::Export
                 .expects(:find_library_export_view)
                 .with(create_by_default: false,
                       destination_server: destination,
                       organization: org,
                       format: ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE)
                 .returns(@library_dev_staging_view)

      ContentViewVersionExportHistory.expects(:latest)
                                     .with(@library_dev_staging_view,
                                           destination_server: destination)
                                     .returns(history)

      export_task = @controller.expects(:async_task).with do |action_class, organization, options|
        assert_equal ::Actions::Pulp3::Orchestration::ContentViewVersion::ExportLibrary, action_class
        assert_equal organization.id, org.id
        assert_equal options[:destination_server], destination
        assert_equal options[:chunk_size], chunk_size_gb
        assert_equal options[:from_history], history
        assert options[:fail_on_missing_content]
      end
      export_task.returns(build_task_stub)
      post :library, params: { organization_id: org.id,
                               destination_server: destination,
                               chunk_size_gb: chunk_size_gb,
                               fail_on_missing_content: true
                             }
      assert_response :success
    end

    def test_library_bad_request_on_incremental
      org = get_organization
      post :library, params: { organization_id: org.id,
                               from_latest_increment: true
                             }
      response = JSON.parse(@response.body)['displayMessage']
      assert_match(/Unable to incrementally export/, response)
      assert_response :bad_request
    end

    def test_library_not_found_on_incremental
      org = get_organization
      post :library, params: { organization_id: org.id,
                               from_latest_increment: true }
      response = JSON.parse(@response.body)['displayMessage']
      assert_match(/Unable to incrementally export/, response)
      assert_response :bad_request
    end
  end
end
