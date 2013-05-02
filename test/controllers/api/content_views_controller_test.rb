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

require "minitest_helper"

class Api::V1::ContentViewsControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def before_suite
    models = ["Organization", "KTEnvironment", "Changeset"]
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models)
  end

  def setup
    @content_view = content_views(:library_dev_view)
    @definition = ContentViewDefinition.find(content_view_definition_bases(:simple_cvd))
    @content_view.update_attribute(:content_view_definition_id, @definition.id)
    @environment = environments(:staging)
    @dev = environments(:dev)
    @organization = organizations(:acme_corporation)
    @read_permission = lambda {|user| user.can(:read, :content_views) }
    @read_permission = UserPermission.new(:read, :content_views)
    @env_promote_permission = UserPermission.new(:promote_changesets, :environments, @environment.id)
    @promote_permission = UserPermission.new(:promote, :content_views) + @env_promote_permission
  end

  describe "permissions" do
    test "promote" do
      refute_authorized(permission: @read_permission,
                        action: :promote,
                        request: lambda { post :promote, id: @content_view.id,
                                          environment_id: @environment.id }
                       )
      assert_authorized(permission: @promote_permission,
                        action: :promote,
                        request: lambda { post :promote, id: @content_view.id,
                                          environment_id: @environment.id }
                       )
    end

    test "index" do
      action = :index
      request = lambda { get action, :organization_id => @organization.name }

      assert_authorized(permission: [@read_permission, @promote_permission],
                        action: action,
                        request: request
                       )

      refute_authorized(permission: [],
                        action: action,
                        request: request
                       )
    end

    test "show" do
      action = :show
      request = lambda { get action, :organization_id => @organization.name, :id => @content_view.id }
      assert_authorized(permission: [@read_permission, @promote_permission],
                        action: action,
                        request: request
                       )
    end

    test "refresh" do
      action = :refresh
      request = lambda { post action, :id => @content_view.id }
      assert_authorized(permission: lambda {|user| user.can(:publish, :content_view_definitions) },
                        action: action,
                        request: request
                       )
      refute_authorized(permission: [@read_permission, @promote_permission],
                        action: action,
                        request: request
                       )
    end
  end

  test "should throw an error if environment_id is nil" do
    login_user(@promote_permission)
    post :promote, :id => @content_view.id
    assert_response :missing
  end

  test "should throw an error if id is nil" do
    login_user(@promote_permission)
    assert_raises(ActionController::RoutingError) do
      post :promote, :environment_id => @environment.id
    end
  end

  test "should assign a content view" do
    login_user(@promote_permission)
    post :promote, :id => @content_view.id, :environment_id => @environment.id
    assert_response :success
    content_view = assigns(:view)
    refute_nil content_view
    assert_equal @content_view, content_view
  end

  test "should create a new changeset" do
    login_user(User.find(users(:admin).id))
    changeset_count = Changeset.count
    post :promote, :id => @content_view.id, :environment_id => @environment.id
    assert_response :success
    assert_equal (changeset_count + 1), Changeset.count
  end

  test "should not delete promoted view" do
    login_user(User.find(users(:admin).id))
    definition = Class.new { define_method(:publishable?) { true } }.new
    ContentView.any_instance.stubs(:content_view_definition).returns(definition)
    delete :destroy, organization_id: @organization.name, id: @content_view.id
    assert response.body =~ /\AError while deleting.*promoted.*\z/
    assert ContentView.exists?(@content_view.id)
  end

end
