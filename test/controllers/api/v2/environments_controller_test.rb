# encoding: utf-8
#
# Copyright 2013 Red Hat, Inc.
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

    def self.before_suite
      models = ["KTEnvironment", "ContentViewEnvironment", "Organization"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @organization = get_organization(:organization1)
      @library = katello_environments(:library)
      @staging = katello_environments(:staging)
    end

    def permissions
      @manage_permission = UserPermission.new(:update, :organizations, nil, @organization)
      @read_permission = UserPermission.new(:read, :organizations, nil, @organization)
      @no_permission = NO_PERMISSION
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      models
      permissions
    end

    def test_create
      Organization.any_instance.stubs(:save!).returns(@organization)
      post :create,
        :organization_id => @organization.label,
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
        :organization_id => @organization.label,
        :environment => {
          :description => 'This environment is for development.'
        }

      assert_response :bad_request
    end

    def test_create_protected
      Organization.any_instance.stubs(:save!).returns(@organization)
      allowed_perms = [@manage_permission]
      denied_perms = [@read_permission, @no_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create,
          :organization_id => @organization.label,
          :environment => {
            :name => 'dev env',
            :label => 'dev_env',
            :description => 'This environment is for development.',
            :prior => @library.id
          }
      end
    end

    def test_update
      put :update,
        :organization_id => @organization.label,
        :id => @staging.id,
        :environment => {
          :new_name => 'New Name'
        }

      assert_response :success
      assert_template 'api/v2/common/update'
    end

    def test_update_protected
      allowed_perms = [@manage_permission]
      denied_perms = [@no_permission, @read_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        put :update,
          :organization_id => @organization.label,
          :id => @staging.id,
          :environment => {
            :new_name => 'New Name'
          }
      end
    end

    def test_destroy
      delete :destroy, :organization_id => @organization.label,
                       :id => @staging.id

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@manage_permission]
      denied_perms = [@no_permission, @read_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :organization_id => @organization.label,
                         :id => @staging.id
      end
    end

    def test_paths
      get :paths, :organization_id => @organization.label

      assert_response :success
      assert_template 'api/v2/environments/paths'
    end

    def test_paths_protected
      allowed_perms = [@manage_permission, @read_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:paths, allowed_perms, denied_perms) do
        get :paths, :organization_id => @organization.label
      end
    end

  end
end
