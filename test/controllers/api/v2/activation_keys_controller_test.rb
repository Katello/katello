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
      disable_glue_layers(["Candlepin"], models)
      super
    end

    def models
      ActivationKey.any_instance.stubs(:products).returns([])
      ActivationKey.any_instance.stubs(:content_overrides).returns([])

      @activation_key = ActivationKey.find(katello_activation_keys(:simple_key))
      @organization = get_organization
      @view = katello_content_views(:library_view)
      @library = @organization.library

      @activation_key.stubs(:get_key_pools).returns([])
      stub_find_organization(@organization)
    end

    def permissions
      @view_permission = :view_activation_keys
      @create_permission = :create_activation_keys
      @update_permission = :edit_activation_keys
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
      @fake_search_service.stubs(:retrieve).returns([[@activation_key], 1])
      @fake_search_service.stubs(:total_items).returns(1)
      results = JSON.parse(get(:show, :id => @activation_key.id).body)

      assert_equal results['name'], 'Simple Activation Key'

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_show_protected
      @fake_search_service.stubs(:retrieve).returns([[@activation_key], 1])
      @fake_search_service.stubs(:total_items).returns(1)

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

    def test_create_unlimited_content_hosts
      post :create, :organization_id => @organization.id,
           :activation_key => {:name => 'Unlimited Key', :unlimited_content_hosts => true}

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Unlimited Key'
      assert_equal results['unlimited_content_hosts'], true

      assert_response :success
      assert_template 'katello/api/v2/common/create'
    end

    def test_create_zero_limit
      post :create, :organization_id => @organization.id,
           :activation_key => {:name => 'Zero Key', :max_content_hosts => 0, :unlimited_content_hosts => false}

      assert_response 422 
    end

    def test_create_23_limit
      post :create, :organization_id => @organization.id,
           :activation_key => {:name => '23 Limited Key', :max_content_hosts => 23, :unlimited_content_hosts => false}

      results = JSON.parse(response.body)
      assert_equal results['name'], '23 Limited Key'
      assert_equal results['max_content_hosts'], 23

      assert_response :success
      assert_template 'katello/api/v2/common/create'
    end

    def test_update
      put :update, :id => @activation_key.id, :organization_id => @organization.id,
          :activation_key => {:name => 'New Name', :max_content_hosts => 2}

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
      assert_equal assigns[:activation_key].name, 'New Name'
      assert_equal assigns[:activation_key].max_content_hosts, 2
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :id => @activation_key.id, :organization_id => @organization.id,
            :activation_key => {:name => 'New Name'}
      end
    end

    def test_update_limit_below_consumed
      content_host1 = System.find(katello_systems(:simple_server))
      content_host2 = System.find(katello_systems(:simple_server2))
      @activation_key.system_ids = [content_host1.id, content_host2.id]

      results = JSON.parse(put(:update, :id => @activation_key.id, :organization_id => @organization.id,
                               :activation_key => {:max_content_hosts => 1}).body)

      assert_response 422
      assert_includes results['errors']['max_content_hosts'][0], 'cannot be lower than current usage count'
    end

    def test_destroy
      @controller.stubs(:sync_task).returns(true)
      delete :destroy, :organization_id => @organization.id, :id => @activation_key.id

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@view_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :organization_id => @organization.id, :id => @activation_key.id
      end
    end

    def test_content_override_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:content_override, allowed_perms, denied_perms) do
        put(:content_override, :id => @activation_key.id, :content_label => 'some-content',
            :name => 'enabled', :value => 1)
      end
    end

    def test_content_override
      results = JSON.parse(put(:update ,:id => @activation_key.id, :content_label => 'some-content',
                               :name => 'enabled', :value => 1).body)

      assert_equal results['name'], 'enabled'

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_content_override_empty
      results = JSON.parse(put(:update, :id => @activation_key.id, :content_label => 'some-content',
                               :name => 'enabled').body)

      assert_equal results['name'], 'enabled'

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_failed_validator
      results = JSON.parse(post(:create, :organization_id => @organization.id,
                           :activation_key => { :max_content_hosts => 0 }).body)

      assert_response 422
      assert_includes results['errors']['name'], 'cannot be blank'
    end

  end
end
