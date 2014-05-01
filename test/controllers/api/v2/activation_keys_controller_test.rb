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
  class Api::V2::ActivationKeysControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["ActivationKey", "KTEnvironment",
                "ContentView", "ContentViewEnvironment", "ContentViewVersion"]
      disable_glue_layers(["Candlepin", "ElasticSearch"], models)
      super
    end

    def models
      @activation_key = katello_activation_keys(:simple_key)
      @organization = get_organization
      @view = katello_content_views(:library_view)
      @library = @organization.library

      @activation_key.stubs(:get_key_pools).returns([])
      stub_find_organization(@organization)
    end

    def permissions
      @view_permission = :view_activation_keys
      @create_permission = :create_activation_keys
      @update_permission = :update_activation_keys
      @destroy_permission = :destroy_activation_keys
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      login_user(User.find(users(:admin)))
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)

      models
      permissions
    end

    def test_index
      @fake_search_service.stubs(:retrieve).returns([[@activation_key], 1])
      @fake_search_service.stubs(:total_items).returns(1)

      results = JSON.parse(get(:index, :organization_id => @organization.id).body)

      assert_response :success
      assert_template 'api/v2/activation_keys/index'

      assert_equal results.keys.sort, ['page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 1
      assert_equal results['results'][0]['id'], @activation_key.id
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :organization_id => @organization.label
      end
    end

    def test_show
      results = JSON.parse(get(:show, :id => @activation_key.id).body)

      assert_equal results['name'], 'Simple Activation Key'

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :id => @activation_key.id
      end
    end

    def test_create
      post :create, :environment_id => @library.id, :content_view_id => @view.id,
           :activation_key => {:name => 'Key A', :description => 'Key A, Key to the World'}

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Key A'
      assert_equal results['description'], 'Key A, Key to the World'

      assert_response :success
      assert_template 'katello/api/v2/common/create'
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :environment => { :id => @library.id }, :content_view => { :id => @view.id },
             :activation_key => {:name => 'Key A2', :description => 'Key A2, Key to the World'}
      end
    end

    def test_create_nested
      post :create, :environment => { :id => @library.id }, :content_view => { :id => @view.id },
           :activation_key => {:name => 'Key A2', :description => 'Key A2, Key to the World'}

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Key A2'
      assert_equal results['description'], 'Key A2, Key to the World'

      assert_response :success
      assert_template 'katello/api/v2/common/create'
    end

    def test_create_unlimited
      post :create, :organization_id => @organization.id,
           :activation_key => {:name => 'Unlimited Key', :usage_limit => 'unlimited'}

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Unlimited Key'
      assert_equal results['usage_limit'], -1

      assert_response :success
      assert_template 'katello/api/v2/common/create'
    end

    def test_create_unlimited2
      post :create, :organization_id => @organization.id,
           :activation_key => {:name => 'Unlimited Key 2', :usage_limit => -1}

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Unlimited Key 2'
      assert_equal results['usage_limit'], -1

      assert_response :success
      assert_template 'katello/api/v2/common/create'
    end

    def test_create_zero_limit
      post :create, :organization_id => @organization.id,
           :activation_key => {:name => 'Zero Key', :usage_limit => 0}

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Zero Key'
      assert_equal results['usage_limit'], 0

      assert_response :success
      assert_template 'katello/api/v2/common/create'
    end

    def test_create_23_limit
      post :create, :organization_id => @organization.id,
           :activation_key => {:name => '23 Limited Key', :usage_limit => 23}

      results = JSON.parse(response.body)
      assert_equal results['name'], '23 Limited Key'
      assert_equal results['usage_limit'], 23

      assert_response :success
      assert_template 'katello/api/v2/common/create'
    end

    def test_update
      put :update, :id => @activation_key.id, :organization_id => @organization.id,
          :activation_key => {:name => 'New Name'}

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
      assert_equal assigns[:activation_key].name, 'New Name'
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :id => @activation_key.id, :organization_id => @organization.id,
            :activation_key => {:name => 'New Name'}
      end
    end

    def test_destroy
      delete :destroy, :organization_id => @organization.id, :id => @activation_key.id

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_destroy_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@view_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :organization_id => @organization.id, :id => @activation_key.id
      end
    end

  end
end
