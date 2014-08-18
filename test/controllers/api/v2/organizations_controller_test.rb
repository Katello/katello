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
  class Api::V2::OrganizationsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    include Support::ForemanTasks::Task

    def self.before_suite
      models = ["Organization"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def permissions
      @read_permission = :view_organizations
      @create_permission = :create_organizations
      @update_permission = :edit_organizations
      @delete_permission = :destroy_organizations
    end

    def models
      @organization = get_organization
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      models
      permissions
    end

    def test_index
      results = JSON.parse(get(:index).body)

      assert_response :success
      assert_template 'api/v2/organizations/index'

      assert_equal results.keys.sort, ['page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
    end

    def test_index_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @delete_permission, @update_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index
      end
    end

    def test_show
      results = JSON.parse(get(:show, :id => @organization.id).body)

      assert_equal results['name'], @organization.name

      assert_response :success
      assert_template 'api/v2/organizations/show'
    end

    def test_show_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @delete_permission, @update_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :id => @organization.id
      end
    end

    def test_delete
      assert_async_task ::Actions::Katello::Organization::Destroy do |org|
        org.id.must_equal @organization.id
      end
      delete(:destroy, :id => @organization.id)

      assert_response :success
    end

    def test_delete_protected
      allowed_perms = [@delete_permission]
      denied_perms = [@create_permission, @read_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :id => @organization.id
      end
    end

    def test_update_redhat_repo_url
      #stub foreman super class..
      ::Api::V2::TaxonomiesController.class_eval do
        def params_match_database
          @organization.id
        end
      end

      url = "http://www.redhat.com"
      redhat_provider = mock()
      redhat_provider.expects(:update_attributes!).with do |arg_hash|
        arg_hash[:repository_url] == url
      end
      Organization.any_instance.expects(:redhat_provider).returns(redhat_provider)
      put(:update, :id => @organization.id, :redhat_repository_url => url)
      assert_response :success
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@create_permission, @read_permission, @delete_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :id => @organization.id, :organization => {:name => 'NewName'}
      end
    end

    def test_autoattach_subscriptions
      assert_async_task ::Actions::Katello::Organization::AutoAttachSubscriptions do |organization|
        organization.id == @organization.id
      end

      post :autoattach_subscriptions, :id => @organization.id

      assert_response :success
    end

    def test_autoattach_subscriptions_protected
      allowed_perms = [@update_permission]

      assert_protected_action(:autoattach_subscriptions, allowed_perms) do
        post :autoattach_subscriptions, :id => @organization.id
      end
    end

  end
end
