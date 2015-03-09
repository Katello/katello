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
  class Api::V2::ContentViewPuppetModulesControllerTest < ActionController::TestCase
    def models
      @content_view = katello_content_views(:library_view)
      @puppet_module = katello_content_view_puppet_modules(:library_view_module_by_name)
      PuppetModule.stubs(:find).returns(@puppet_module)
      @puppet_module.stubs(:repositories).returns([])
      PuppetModule.stubs(:exists?).returns(true)
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      ContentViewPuppetModule.any_instance.stubs(:computed_version).returns("1.0")
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      models
      permissions
    end

    def test_index
      get :index, :content_view_id => @content_view.id

      assert_response :success
      assert_template 'api/v2/content_view_puppet_modules/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :content_view_id => @content_view.id
      end
    end

    def test_create
      @content_view = katello_content_views(:library_dev_view)
      assert_empty @content_view.puppet_modules

      post :create, :content_view_id => @content_view.id, :name => "myFavoriteModule", :author => "johndoe"

      assert_response :success
      assert_template %w(katello/api/v2/content_view_puppet_modules/show)
      assert_includes @content_view.reload.puppet_modules.map(&:name), "myFavoriteModule"
    end

    def test_create_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :name => "Test", :content_view_id => @content_view.id
      end
    end

    def test_show
      get :show, :content_view_id => @content_view.id, :id => @puppet_module.id

      assert_response :success
      assert_template 'api/v2/content_view_puppet_modules/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :content_view_id => @content_view.id, :id => @puppet_module.id
      end
    end

    def test_update_name
      put :update, :content_view_id => @content_view.id, :id => @puppet_module, :name => "myNewFavoriteModule"

      assert_response :success
      assert_template 'api/v2/common/update'
      assert_equal @puppet_module.reload.name, "myNewFavoriteModule"
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :content_view_id => @content_view.id, :id => @puppet_module.id, :name => "myNewFavoriteModule"
      end
    end

    def test_destroy
      delete :destroy, :content_view_id => @content_view.id, :id => @puppet_module.id

      assert_response :success
      assert_nil ContentViewPuppetModule.find_by_id(@puppet_module.id)
    end

    def test_destroy_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :content_view_id => @content_view.id, :id => @puppet_module.id
      end
    end
  end
end
