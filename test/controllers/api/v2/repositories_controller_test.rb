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


require "minitest_helper"

class Api::V2::RepositoriesControllerTest < Minitest::Rails::ActionController::TestCase

  fixtures :all

  def self.before_suite
    models = ["Repository", "Product"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def models
    @organization = organizations(:acme_corporation)
    @repository = repositories(:fedora_17_unpublished)
    @product = products(:fedora)
  end

  def permissions
    @read_permission = UserPermission.new(:read, :providers)
    @create_permission = UserPermission.new(:create, :providers)
    @update_permission = UserPermission.new(:update, :providers)
    @delete_permission = UserPermission.new(:delete, :providers)
    @no_permission = NO_PERMISSION
  end

  def setup
    login_user(User.find(users(:admin)))
    User.current = User.find(users(:admin))
    @request.env['HTTP_ACCEPT'] = 'application/json'
    @fake_search_service = @controller.load_search_service(FakeSearchService.new)
    models
    permissions
  end

  def test_index
    get :index, :organization_id => @organization.label

    assert_response :success
    assert_template 'api/v2/common/index'
  end

  def test_index_protected
    allowed_perms = [@read_permission, @create_permission, @update_permission, @delete_permission]
    denied_perms = [@no_permission]

    assert_protected_action(:index, allowed_perms, denied_perms) do
      get :index, :organization_id => @organization.label
    end
  end

  def test_create
    product = MiniTest::Mock.new
    product.expect(:add_repo, {}, [
      'Fedora_Repository',
      'Fedora Repository',
      'http://www.google.com',
      'yum',
      nil,
      nil
    ])
    product.expect(:editable?, @product.editable?)
    product.expect(:gpg_key, nil)

    Product.stub(:find_by_cp_id, product) do
      post :create, :name => 'Fedora Repository',
                    :product_id => @product.cp_id,
                    :url => 'http://www.google.com',
                    :content_type => 'yum'

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end
  end

  def test_create_with_gpg_key
    key = GpgKey.find(gpg_keys('fedora_gpg_key'))

    product = MiniTest::Mock.new
    product.expect(:gpg_key, key)
    product.expect(:editable?, @product.editable?)

    product.expect(:add_repo, {}, [
      'Fedora_Repository',
      'Fedora Repository',
      'http://www.google.com',
      'yum',
      nil,
      key
    ])

    Product.stub(:find_by_cp_id, product) do
      post :create, :name => 'Fedora Repository',
                    :product_id => @product.cp_id,
                    :url => 'http://www.google.com',
                    :content_type => 'yum'

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end
  end

  def test_create_protected
    allowed_perms = [@create_permission]
    denied_perms = [@read_permission, @no_permission]

    assert_protected_action(:create, allowed_perms, denied_perms) do
      post :create, :product_id => @product.cp_id
    end
  end

  def test_show
    get :show, :id => @repository.id

    assert_response :success
    assert_template 'api/v2/repositories/show'
  end

  def test_show_protected
    allowed_perms = [@read_permission, @create_permission, @update_permission, @delete_permission]
    denied_perms = [@no_permission]

    assert_protected_action(:show, allowed_perms, denied_perms) do
       Rails.logger.error "FOOO\n\n\n"
      get :show, :id => @repository.id
    end
  end

  def test_update
    put :update, :id => @repository.id, :gpg_key_id => 1

    assert_response :success
    assert_template 'api/v2/repositories/show'
  end

  def test_update_protected
    allowed_perms = [@create_permission, @update_permission]
    denied_perms = [@no_permission, @delete_permission]

    assert_protected_action(:update, allowed_perms, denied_perms) do
      put :update, :id => @repository.id
    end
  end

  def test_destroy
    delete :destroy, :id => @repository.id

    assert_response :success
  end

  def test_destroy_protected
    allowed_perms = [@create_permission, @update_permission]
    denied_perms = [@read_permission, @no_permission]

    assert_protected_action(:destroy, allowed_perms, denied_perms) do
      delete :destroy, :id => @repository.id
    end
  end

end
