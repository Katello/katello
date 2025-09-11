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

    # --- test permissions ---
    def test_version_protected
      @controller.stubs(:find_library_export_view)
      @controller.stubs(:find_incremental_history)
      @controller.stubs(:determine_export_format_from_history)

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
      @controller.stubs(:find_incremental_history)
      @controller.stubs(:determine_export_format_from_history)

      allowed_perms = [{name: @export_permission, :resource_type => "Organization"}]
      denied_perms = [@create_permission, @update_permission,
                      @destroy_permission, @view_permission]

      org = get_organization
      assert_protected_action(:library, allowed_perms, denied_perms, [org]) do
        post :library, params: { organization_id: org.id}
      end
    end

    # --- find_library_export_view tests ----
    def test_find_library_export_view_with_history_id
      @controller.params = { from_history_id: 1 }
      content_view = mock("content_view")
      content_view_version = mock("content_view_version")
      content_view_version.stubs(:content_view).returns(content_view)
      history = mock("history")
      history.stubs(:content_view_version).returns(content_view_version)
      @controller.stubs(:find_incremental_history_from_id).once
      @controller.instance_variable_set(:@history, history)

      @controller.stubs(:determine_view_from_name).never
      @controller.send(:find_library_export_view)
      assert_equal @controller.instance_variable_get(:@view), content_view
    end

    def test_find_library_export_view_without_params
      @controller.params = {}
      organization = get_organization
      @controller.instance_variable_set(:@organization, organization)
      importable_result = mock("importable_result")
      importable_result.stubs(:updated_at).returns(2.days.ago)
      syncable_result = mock("syncable_result")
      syncable_result.stubs(:updated_at).returns(1.day.ago)
      @controller.stubs(:determine_view_from_name).with(::Katello::ContentView::EXPORT_LIBRARY,
                                                        organization,
                                                        :library_export).returns(importable_result).once
      @controller.stubs(:determine_view_from_name).with("#{::Katello::ContentView::EXPORT_LIBRARY}-SYNCABLE",
                                                        organization,
                                                        :library_export_syncable).returns(syncable_result).once
      @controller.send(:find_library_export_view)

      # Ensure the newer of the two is chosen
      assert_equal @controller.instance_variable_get(:@view), syncable_result
    end

    def test_find_library_export_view_param_format_importable
      @controller.params = {format: 'importable'}
      organization = get_organization
      @controller.instance_variable_set(:@organization, organization)
      importable_result = mock("importable_result")
      importable_result.stubs(:updated_at).returns(1.day.ago)
      @controller.stubs(:determine_view_from_name).never
      @controller.stubs(:determine_view_from_name).with(::Katello::ContentView::EXPORT_LIBRARY,
                                                        organization,
                                                        :library_export).returns(importable_result).once
      @controller.send(:find_library_export_view)
      assert_equal @controller.instance_variable_get(:@view), importable_result
    end

    def test_find_library_export_view_param_format_syncable
      @controller.params = {format: 'syncable'}
      organization = get_organization
      @controller.instance_variable_set(:@organization, organization)
      syncable_result = mock("syncable_result")
      syncable_result.stubs(:updated_at).returns(1.day.ago)
      @controller.stubs(:determine_view_from_name).never
      @controller.stubs(:determine_view_from_name).with("#{::Katello::ContentView::EXPORT_LIBRARY}-SYNCABLE",
                                                        organization,
                                                        :library_export_syncable).returns(syncable_result).once
      @controller.send(:find_library_export_view)
      assert_equal @controller.instance_variable_get(:@view), syncable_result
    end

    def test_find_library_not_found
      org = get_organization
      post :library, params: { organization_id: org.id,
                               from_latest_increment: true }
      response = JSON.parse(@response.body)['displayMessage']
      assert_match(/Unable to find a base content view to use for incremental export. Please run a complete export instead./, response)
      assert_response :bad_request
    end

    # --- find_repository_export_view tests ----
    def test_find_repository_export_view_with_history_id
      @controller.params = { from_history_id: 1 }
      mock_org = mock("organization")
      library_instance = mock("library_instance")
      library_instance.stubs(:id).returns(42)
      repository = mock("repository")
      repository.stubs(:label).returns("repo_label")
      repository.stubs(:library_instance_or_self).returns(library_instance)
      repository.stubs(:organization).returns(mock_org)
      @controller.instance_variable_set(:@repository, repository)
      content_view = mock("content_view")
      content_view_version = mock("content_view_version")
      content_view_version.stubs(:content_view).returns(content_view)
      history = mock("history")
      history.stubs(:content_view_version).returns(content_view_version)
      @controller.stubs(:find_incremental_history_from_id).once
      @controller.instance_variable_set(:@history, history)

      @controller.stubs(:determine_view_from_name).never
      @controller.send(:find_repository_export_view)
      assert_equal @controller.instance_variable_get(:@view), content_view
    end

    def test_find_repository_export_view_without_params
      @controller.params = {}
      mock_org = mock("organization")
      library_instance = mock("library_instance")
      library_instance.stubs(:id).returns(42)
      repository = mock("repository")
      repository.stubs(:label).returns("repo_label")
      repository.stubs(:library_instance_or_self).returns(library_instance)
      repository.stubs(:organization).returns(mock_org)
      @controller.instance_variable_set(:@repository, repository)
      importable_result = mock("importable_result")
      importable_result.stubs(:updated_at).returns(2.days.ago)
      syncable_result = mock("syncable_result")
      syncable_result.stubs(:updated_at).returns(1.day.ago)
      @controller.stubs(:determine_view_from_name).with("Export-repo_label-42",
                                                        mock_org,
                                                        :repository_export).returns(importable_result).once
      @controller.stubs(:determine_view_from_name).with("Export-SYNCABLE-repo_label-42",
                                                        mock_org,
                                                        :repository_export_syncable).returns(syncable_result).once
      @controller.send(:find_repository_export_view)

      # Ensure the newer of the two is chosen
      assert_equal @controller.instance_variable_get(:@view), syncable_result
    end

    def test_find_respository_export_view_param_format_importable
      @controller.params = {format: 'importable'}
      mock_org = mock("organization")
      library_instance = mock("library_instance")
      library_instance.stubs(:id).returns(42)
      repository = mock("repository")
      repository.stubs(:label).returns("repo_label")
      repository.stubs(:library_instance_or_self).returns(library_instance)
      repository.stubs(:organization).returns(mock_org)
      @controller.instance_variable_set(:@repository, repository)
      importable_result = mock("importable_result")
      importable_result.stubs(:updated_at).returns(1.day.ago)
      @controller.stubs(:determine_view_from_name).never
      @controller.stubs(:determine_view_from_name).with("Export-repo_label-42",
                                                        mock_org,
                                                        :repository_export).returns(importable_result).once
      @controller.send(:find_repository_export_view)
      assert_equal @controller.instance_variable_get(:@view), importable_result
    end

    def test_find_respository_export_view_param_format_syncable
      @controller.params = {format: 'syncable'}
      mock_org = mock("organization")
      library_instance = mock("library_instance")
      library_instance.stubs(:id).returns(42)
      repository = mock("repository")
      repository.stubs(:label).returns("repo_label")
      repository.stubs(:library_instance_or_self).returns(library_instance)
      repository.stubs(:organization).returns(mock_org)
      @controller.instance_variable_set(:@repository, repository)
      syncable_result = mock("syncable_result")
      syncable_result.stubs(:updated_at).returns(1.day.ago)
      @controller.stubs(:determine_view_from_name).never
      @controller.stubs(:determine_view_from_name).with("Export-SYNCABLE-repo_label-42",
                                                        mock_org,
                                                        :repository_export_syncable).returns(syncable_result).once

      @controller.send(:find_repository_export_view)
      assert_equal @controller.instance_variable_get(:@view), syncable_result
    end

    def test_find_repository_not_found
      @controller.params = {}
      mock_org = mock("organization")
      library_instance = mock("library_instance")
      library_instance.stubs(:id).returns(42)
      repository = mock("repository")
      repository.stubs(:label).returns("repo_label")
      repository.stubs(:library_instance_or_self).returns(library_instance)
      repository.stubs(:organization).returns(mock_org)
      @controller.instance_variable_set(:@repository, repository)
      @controller.stubs(:determine_view_from_name).returns(nil)
      assert_raises(HttpErrors::BadRequest) do
        @controller.send(:find_repository_export_view)
      end
    end

    # --- determine_export_format_from_history tests ----
    def test_throws_error_on_history_and_param_format_mismatch
      @controller.params = { from_history_id: 1, format: 'importable' }
      history = mock("history")
      history.stubs(:metadata).returns({ format: 'syncable' })
      @controller.instance_variable_set(:@history, history)

      response = assert_raises(HttpErrors::BadRequest) { @controller.send(:determine_export_format_from_history) }
      assert_match(/The provided incremental export format 'importable' must match the previous export's format 'syncable'. Consider using 'from_history_id' to point to a matching export./, response.message)
    end

    def test_sets_export_format_from_history
      @controller.params = { from_history_id: 1 }
      history = mock("history")
      history.stubs(:metadata).returns({ format: 'importable' })
      @controller.instance_variable_set(:@history, history)

      @controller.send(:determine_export_format_from_history)
      assert_equal 'importable', @controller.instance_variable_get(:@export_format)
    end

    # --- check for blank view tests ----
    def test_check_for_blank_view_without_params
      @controller.params = {}
      @controller.instance_variable_set(:@view, nil)
      response = assert_raises(HttpErrors::BadRequest) { @controller.send(:check_for_blank_view) }
      assert_match(/Unable to find a base content view to use for incremental export. Please run a complete export instead./, response.message)
    end

    def test_check_for_blank_view_with_params
      @controller.params = { from_history_id: 1, format: 'importable' }
      @controller.instance_variable_set(:@view, nil)
      response = assert_raises(HttpErrors::BadRequest) { @controller.send(:check_for_blank_view) }
      assert_match(/Unable to find a base content view to use for incremental export using the provided parameters: 'from_history_id':1 'format':importable/, response.message)
    end
  end
end
