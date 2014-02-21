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
  class Api::V2::RepositorySetsControllerTest < ActionController::TestCase

    def self.before_suite
      models = %w(Organization KTEnvironment Product)
      disable_glue_layers(["Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @organization = get_organization
      @redhat_product = katello_products(:redhat)
      @custom_product = katello_products(:fedora)
      @pc = Katello::Candlepin::ProductContent.new(:content => {:id => '3'})
      @pc.product = @redhat_product
    end

    def permissions
      @read_permission = UserPermission.new(:read, :providers)
      @update_permission = UserPermission.new(:redhat_products, :organizations)
      @no_permission = NO_PERMISSION
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env["HTTP_ACCEPT"] = 'application/json'
      models
      permissions
    end

    def test_index
      Katello::Product.any_instance.stubs(:productContent).returns([])
      get :index, :product_id => @redhat_product.id

      assert_response :success
      assert_template 'api/v2/repository_sets/index'
    end

    def test_index_protected
      allowed_perms = [@read_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :product_id => @redhat_product.id
      end
    end

    def test_show
      Katello::Product.any_instance.stubs(:productContent).returns([@pc])
      get :show, :product_id => @redhat_product.id, :id => 3

      assert_response :success
      assert_template 'api/v2/repository_sets/show'
    end

    def test_show_protected
      Katello::Product.any_instance.stubs(:productContent).returns([@pc])
      allowed_perms = [@read_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :product_id => @redhat_product.id, :id => 3
      end
    end

    def test_enable
      Katello::Product.any_instance.stubs(:productContent).returns([@pc])
      Katello::Product.any_instance.expects(:refresh_content).with('3').returns(@pc)
      put :enable, :product_id => @redhat_product.id, :id => 3

      assert_response :success
      assert_template 'api/v2/repository_sets/show'
    end

    def test_enable_protected
      Katello::Product.any_instance.stubs(:productContent).returns([@pc])
      allowed_perms = [@update_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:enable, allowed_perms, denied_perms) do
        put :enable, :product_id => @redhat_product.id, :id => 3
      end
    end

    def test_disable
      Katello::Product.any_instance.stubs(:productContent).returns([@pc])
      Katello::Product.any_instance.expects(:disable_content).with('3').returns(@pc)
      put :disable, :product_id => @redhat_product.id, :id => 3

      assert_response :success
      assert_template 'api/v2/repository_sets/show'
    end

    def test_disable_protected
      Katello::Product.any_instance.stubs(:productContent).returns([@pc])
      allowed_perms = [@update_permission]
      denied_perms = [@no_permission]

      assert_protected_action(:disable, allowed_perms, denied_perms) do
        put :disable, :product_id => @redhat_product.id, :id => 3
      end
    end

  end
end
