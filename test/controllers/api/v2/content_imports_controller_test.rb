require "katello_test_helper"

module Katello
  class Api::V2::ContentImportsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    METADATA = {
      organization: "org name",
      products: {
        'label' => { name: 'product name', label: 'label' },
      },
      gpg_keys: {'foo' => {label: 'lol'} },
      repositories: {
        'repo name' => {
          name: 'root repo name',
          label: 'root_label',
          product: { label: 'label' },
          redhat: true,
        },
      },
      toc: "toc file name",
      content_view: { name: "cv name", label: 'cv label' },
      content_view_version: {
        major: "4",
        minor: "5",
      },
    }.with_indifferent_access

    def models
      @library_view = katello_content_views(:library_view)
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
      @publish_permission = :publish_content_views
      @export_permission = :export_content
      @org_import_permission = :import_content
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def test_version_protected
      allowed_perms = [[@publish_permission, @create_permission, @org_import_permission]]
      denied_perms = [@create_permission, @publish_permission, @update_permission,
                      @destroy_permission, @view_permission, @export_permission]
      org = get_organization
      assert_protected_action(:version, allowed_perms, denied_perms, [org]) do
        post :version, params: { organization_id: org.id, path: '/tmp', metadata: METADATA}
      end
    end

    def test_library_protected
      allowed_perms = [{name: @org_import_permission, :resource_type => "Organization"}]
      denied_perms = [@create_permission, @update_permission,
                      @destroy_permission, @view_permission, @export_permission]

      org = get_organization
      assert_protected_action(:library, allowed_perms, denied_perms, [org]) do
        post :library, params: { organization_id: org.id, path: '/tmp', metadata: METADATA}
      end
    end

    def test_index_protected
      allowed_perms = [{name: @org_import_permission, :resource_type => "Organization"}]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, params: { :content_view_id => @library_view.id }
      end
    end

    def test_version
      metadata_params = ActionController::Parameters.new(METADATA).permit!
      path = "/tmp"
      org = get_organization
      import_task = @controller.expects(:async_task).with do |action_class, options|
        assert_equal ::Actions::Katello::ContentViewVersion::Import, action_class
        assert_equal options[:organization], org
        assert_equal options[:path], path
        assert_equal options[:metadata], METADATA
      end
      import_task.returns(build_task_stub)
      post :version, params: { organization_id: org.id, path: path, metadata: metadata_params}
      assert_response :success
    end

    def test_history_index
      get :index
      assert_response :success
      assert_template 'api/v2/content_view_version_import_histories/index'
    end
  end
end
