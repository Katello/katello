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

class ContentViewsControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "Product", "Repository",
              "ContentViewEnvironment", "Filter", "ContentViewDefinitionBase",
              "ContentViewDefinition", "ContentViewDefinitionRepository",
              "ContentViewDefinitionProduct", "FilterRule", "PackageRule",
              "PackageGroupRule", "ErratumRule", "ContentView", "ContentViewVersion",
              "ContentViewVersionEnvironment"]

    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models, true)
  end

  def setup
    @org = organizations(:acme_corporation)

    login_user(User.find(users(:admin)), @org)

    @content_view_definition = content_view_definition_bases(:simple_cvd)
    @content_view = content_views(:library_dev_view)
    @content_view.content_view_definition = @content_view_definition
    @content_view.save!
  end

  test "DELETE destroy should be successful" do
    content_view = content_views(:library_view)

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    delete :destroy, :content_view_definition_id => @content_view_definition.id, :id => content_view.id

    assert_response :success
    assert_nil ContentView.find_by_id(content_view.id)
  end

  test "POST refresh should be successful" do
    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    assert_nil @content_view.versions.last.task_status
    assert_equal @content_view.versions.last.version, 1

    post :refresh, :content_view_definition_id => @content_view_definition.id, :id => @content_view.id

    assert_response :success
    assert_template :partial => 'content_view_definitions/views/_view'

    view = ContentView.find_by_id(@content_view.id)
    refute_nil view.versions.last.task_status
    assert_equal view.reload.versions.last.version, 2
  end
end
