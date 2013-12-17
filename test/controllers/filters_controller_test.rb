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
  class FiltersControllerTest < ActionController::TestCase
    def self.before_suite
      models = ["Organization", "KTEnvironment", "User", "Product", "Repository",
                "ContentViewEnvironment", "Filter", "ContentViewDefinitionBase",
                "ContentViewDefinition", "ContentViewDefinitionRepository",
                "ContentViewDefinitionProduct", "FilterRule", "PackageRule",
                "PackageGroupRule", "ErratumRule"]
      services = ["Candlepin", "Pulp", "ElasticSearch", "Foreman"]
      disable_glue_layers(services, models, true)
      super
    end

    def setup
      setup_controller_defaults
      @org = get_organization(:organization1)
      set_organization(@org)

      @product = Product.find(katello_products(:redhat).id)
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64).id)

      @filter = katello_filters(:populated_filter)
    end

    test "GET index - should be successful" do
      get :index, :content_view_definition_id => @filter.content_view_definition.id
      assert_response :success
      assert_template :partial => 'katello/content_view_definitions/filters/_index'
    end

    test "GET new - should be successful" do
      get :new, :content_view_definition_id => @filter.content_view_definition.id
      assert_response :success
      assert_template :partial => 'katello/content_view_definitions/filters/_new'
    end

    test "POST create - should be successful" do
      name = @filter.name + "Cool"

      # success notice created
      notify = Notifications::Notifier.new
      notify.expects(:success).at_least_once
      @controller.expects(:notify).at_least_once.returns(notify)

      @controller.expects(:render).at_least_once

      post :create, :content_view_definition_id=> @filter.content_view_definition.id,
        :filter => {:name => name}

      assert_response :success
      refute_nil Filter.find_by_name(name)
    end

    test "GET edit - should be successful" do
      get :edit, :content_view_definition_id => @filter.content_view_definition.id,
        :id => @filter.id
      assert_response :success
      assert_template :partial => 'katello/content_view_definitions/filters/_edit'
    end

    test "PUT update - add product should be successful" do
      # success notice created
      notify = Notifications::Notifier.new
      notify.expects(:success).at_least_once
      @controller.expects(:notify).at_least_once.returns(notify)

      put :update, :content_view_definition_id => @filter.content_view_definition.id,
        :id => @filter.id, :products => [@product.id]

      assert_response :success
      assert_equal @filter.products.reload.first, @product
    end

    test "PUT update - remove product should be successful" do
      @filter.product_ids = [@product.id]
      @filter.save!

      # success notice created
      notify = Notifications::Notifier.new
      notify.expects(:success).at_least_once
      @controller.expects(:notify).at_least_once.returns(notify)

      assert_equal @filter.products.length, 1

      put :update, :content_view_definition_id => @filter.content_view_definition.id,
        :id => @filter.id, :products => []

      assert_response :success
      assert_empty @filter.reload.products
    end

    test "PUT update - add repository should be successful" do
      # success notice created
      notify = Notifications::Notifier.new
      notify.expects(:success).at_least_once
      @controller.expects(:notify).at_least_once.returns(notify)

      put :update, :content_view_definition_id => @filter.content_view_definition.id,
        :id => @filter.id, :repos => {@repo.product_id => @repo.id}

      assert_response :success
      assert_equal @filter.repositories.reload.first.id, @repo.id
    end

    test "PUT update - remove repository should be successful" do
      # add repo to the filter
      put :update, :content_view_definition_id => @filter.content_view_definition.id,
        :id => @filter.id, :repos => {@repo.product_id => @repo.id}
      refute_empty @filter.reload.repositories

      # success notice created
      notify = Notifications::Notifier.new
      notify.expects(:success).at_least_once
      @controller.expects(:notify).at_least_once.returns(notify)

      assert_equal @filter.repositories.length, 1

      put :update, :content_view_definition_id => @filter.content_view_definition.id,
        :id => @filter.id, :repos => {}

      assert_response :success
      assert_empty @filter.reload.repositories
    end

    test "PUT update - add a puppet repository" do
      puppet_repo = katello_repositories(:p_forge)
      @filter.content_view_definition.puppet_repository_id = puppet_repo.id

      # success notice created
      notify = Notifications::Notifier.new
      notify.expects(:success).at_least_once
      @controller.expects(:notify).at_least_once.returns(notify)

      put :update, :content_view_definition_id => @filter.content_view_definition.id,
        :id => @filter.id, :puppet_repository_id => puppet_repo.id

      assert_response :success
      assert_includes @filter.repositories.reload.map(&:id), puppet_repo.id
    end

    test "DELETE destroy_filters should be successful" do
      # success notice created
      notify = Notifications::Notifier.new
      notify.expects(:success).at_least_once
      @controller.expects(:notify).at_least_once.returns(notify)

      delete :destroy_filters, :content_view_definition_id=> @filter.content_view_definition.id,
        :filters => {@filter.id => @filter.id}

      assert_response :success
      assert_nil Filter.find_by_id(@filter.id)
    end
  end
end
