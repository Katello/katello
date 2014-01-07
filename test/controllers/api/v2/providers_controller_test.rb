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
class Api::V2::ProvidersControllerTest < ActionController::TestCase

  def self.before_suite
    models = %w(Provider Organization Repository Product)
    disable_glue_layers(%w(Candlepin Pulp ElasticSearch), models)
    super
  end

  def models
    @organization = get_organization(:organization1)
    @provider = katello_providers(:fedora_hosted)
  end

  def permissions
    @read_permission = UserPermission.new(:read, :providers)
    @create_permission = UserPermission.new(:create, :providers)
    @update_permission = UserPermission.new(:update, :providers)
    @delete_permission = UserPermission.new(:delete, :providers)
    @no_permission = NO_PERMISSION
  end

  def setup
    setup_controller_defaults_api
    login_user(User.find(users(:admin)))
    User.current = User.find(users(:admin))
    @request.env['HTTP_ACCEPT'] = 'application/json'
    @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
    models
    permissions
    Provider.any_instance.stubs(:owner_imports).returns([])
  end

  def test_index
    get :index, :organization_id => @organization.label

    assert_response :success
    assert_template 'api/v2/providers/index'
  end

  def test_index_protected
    allowed_perms = [@update_permission, @read_permission]
    denied_perms = [@no_permission]

    assert_protected_action(:index, allowed_perms, denied_perms) do
      get :index, :organization_id => @organization.label
    end
  end

  def test_show
    get :show, :id => @provider.id

    assert_response :success
    assert_template 'api/v2/providers/show'
  end

  def test_show_protected
    allowed_perms = [@read_permission, @create_permission, @update_permission, @delete_permission]
    denied_perms = [@no_permission]

    assert_protected_action(:show, allowed_perms, denied_perms) do
      get :show, :id => @provider.id
    end
  end

  def test_create
    post :create, :name => 'Fedora Provider',
                  :organization_id => @organization.label

    assert_response :success
    assert_template 'api/v2/common/create'
  end

  def test_create_fail
    post :create

    assert_response :unprocessable_entity
  end

  def test_create_protected
    allowed_perms = [@create_permission]
    denied_perms = [@read_permission, @no_permission]

    assert_protected_action(:create, allowed_perms, denied_perms) do
      post :create, :organization_id => @organization.label
    end
  end

  def test_update
    put :update, :id => @provider.id, :name => 'CentOS Provider'

    assert_response :success
    assert_template %w(katello/api/v2/common/show katello/api/v2/layouts/resource)
  end

  def test_update_protected
    allowed_perms = [@update_permission]
    denied_perms = [@read_permission, @no_permission]

    assert_protected_action(:update, allowed_perms, denied_perms) do
      put :update, :id => @provider.id, :name => 'CentOS Provider'
    end
  end

  def test_destroy
    provider_sans_repos = @provider.dup
    provider_sans_repos.name = "new provider"
    provider_sans_repos.repositories.delete_all
    provider_sans_repos.save!

    delete :destroy, :id => provider_sans_repos.id

    assert provider_sans_repos.repositories.none? { |p| p.promoted? }
    assert_response :success
    assert_template %w(katello/api/v2/common/show katello/api/v2/layouts/resource)
  end

  def test_destroy_fail
    delete :destroy, :id => @provider.id

    assert @provider.repositories.any? { |p| p.promoted? }
    assert_response :bad_request
  end

  def test_destroy_protected
    allowed_perms = [@create_permission, @delete_permission]
    denied_perms = [@read_permission, @update_permission, @no_permission]

    assert_protected_action(:destroy, allowed_perms, denied_perms) do
      delete :destroy, :id => @provider.id
    end
  end
end
end
