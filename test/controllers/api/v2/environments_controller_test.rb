# encoding: utf-8
#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require "katello_test_helper"

module Katello
  class Api::V2::EnvironmentsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    def self.before_suite
      models = ["KTEnvironment", "ContentViewEnvironment", "Organization"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @organization = get_organization
      @library = katello_environments(:library)
      @staging = katello_environments(:staging)
    end

    def permissions
      @resource_type = "Katello::KTEnvironment"
      @view_permission = :view_lifecycle_environments
      @create_permission = :create_lifecycle_environments
      @update_permission = :edit_lifecycle_environments
      @destroy_permission = :destroy_lifecycle_environments
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      Katello::Package.stubs(:package_count).returns(0)
      Katello::PuppetModule.stubs(:module_count).returns(0)
      models
      permissions
    end

    def test_create
      Organization.any_instance.stubs(:save!).returns(@organization)
      post :create,
        :organization_id => @organization.id,
        :environment => {
          :name => 'dev env',
          :label => 'dev_env',
          :description => 'This environment is for development.',
          :prior => @library.id
        }

      assert_response :success
    end

    def test_create_fail
      Organization.any_instance.stubs(:save!).returns(@organization)
      post :create,
        :organization_id => @organization.id,
        :environment => {
          :description => 'This environment is for development.'
        }

      assert_response :bad_request
    end

    def test_create_protected
      Organization.any_instance.stubs(:save!).returns(@organization)
      KTEnvironment.expects(:readable).returns(KTEnvironment)
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create,
          :organization_id => @organization.id,
          :environment => {
            :name => 'dev env',
            :label => 'dev_env',
            :description => 'This environment is for development.',
            :prior => @library.id
          }
      end
    end

    def test_update
      original_label = @staging.label

      put :update,
        :organization_id => @organization.id,
        :id => @staging.id,
        :environment => {
          :new_name => 'New Name',
          :label => 'New Label'
        }

      assert_response :success
      assert_template 'api/v2/common/update'
      assert_equal 'New Name', @staging.reload.name
      # note: label is not editable; therefore, confirm that it is unchanged
      assert_equal original_label, @staging.label
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        put :update,
          :organization_id => @organization.id,
          :id => @staging.id,
          :environment => {
            :new_name => 'New Name'
          }
      end
    end

    def test_index
      get :index, :organization_id => @organization.id

      assert_response :success
    end

    def test_index_with_name
      get :index, :organization_id => @organization.id, :name => @organization.library.name

      assert_response :success
    end

    def test_destroy
      destroyable_env = KTEnvironment.create!(:name => "DestroyAble",
                                              :organization => @staging.organization,
                                              :prior => @staging)
      assert_sync_task(::Actions::Katello::Environment::Destroy, destroyable_env)
      delete :destroy, :organization_id => @organization.id,
                       :id => destroyable_env.id

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@view_permission, @update_permission, @create_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :organization_id => @organization.id,
                         :id => @staging.id
      end
    end

    def test_paths
      get :paths, :organization_id => @organization.id

      assert_response :success
      assert_template %w(api/v2/environments/paths api/v2/common/metadata)
    end

    def test_paths_protected
      allowed_perms = [@view_permission]
      denied_perms = [@destroy_permission, @update_permission, @create_permission]

      assert_protected_action(:paths, allowed_perms, denied_perms) do
        get :paths, :organization_id => @organization.id
      end
    end
  end
end
