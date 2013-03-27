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

class FilterRulesControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def setup
    @org = organizations(:acme_corporation)

    models = ["Organization", "KTEnvironment", "User", "ContentViewEnvironment", "ContentViewDefinition"]
    services = ["Candlepin", "Pulp", "ElasticSearch", "Foreman"]
    disable_glue_layers(services, models)

    login_user(User.find(users(:admin)), @org)

    @filter = filters(:simple_filter)
  end

  test "GET new - should be successful" do
    get :new, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id
    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_new'
  end

  test "POST create - create package rule should be successful" do
    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    assert_empty @filter.rules

    post :create, :content_view_definition_id=> @filter.content_view_definition.id, :filter_id => @filter.id,
         :filter_rule => {:content_type => 'rpm'}

    assert_response :success

    @filter.reload
    assert_equal @filter.rules.length, 1
    assert_equal @filter.rules.first.content_type, 'rpm'
  end

  test "POST create - create package group rule should be successful" do
    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    assert_empty @filter.rules

    post :create, :content_view_definition_id=> @filter.content_view_definition.id, :filter_id => @filter.id,
         :filter_rule => {:content_type => 'package_group'}

    assert_response :success

    @filter.reload
    assert_equal @filter.rules.length, 1
    assert_equal @filter.rules.first.content_type, 'package_group'
  end

  test "POST create - create errata rule should be successful" do
    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    assert_empty @filter.rules

    post :create, :content_view_definition_id=> @filter.content_view_definition.id, :filter_id => @filter.id,
         :filter_rule => {:content_type => 'erratum'}

    assert_response :success

    @filter.reload
    assert_equal @filter.rules.length, 1
    assert_equal @filter.rules.first.content_type, 'erratum'
  end

  test "GET edit - should be successful" do
    rule = FilterRule.create!(:filter => @filter, :content_type => 'rpm')

    get :edit, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_edit'
  end

  test "GET edit_parameter_list - should be successful" do
    rule = FilterRule.create!(:filter => @filter, :content_type => 'rpm')

    get :edit_parameter_list, :content_view_definition_id => @filter.content_view_definition.id,
        :filter_id => @filter.id, :id => rule.id

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_parameter_list'
  end

  test "GET edit_date_type_parameters - should be successful" do
    rule = FilterRule.create!(:filter => @filter, :content_type => 'erratum')

    get :edit_date_type_parameters, :content_view_definition_id => @filter.content_view_definition.id,
        :filter_id => @filter.id, :id => rule.id

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_edit_errata_parameters'
  end

  test "PUT update - inclusion=true should be successful" do
    rule = FilterRule.create!(:filter => @filter, :content_type => 'rpm', :inclusion => false)

    assert_equal @filter.rules.first.inclusion, false

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    put :update, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :filter_rule => {:inclusion => true}

    assert_response :success
    assert_equal @filter.rules.first.inclusion, true
  end

  test "PUT add_parameter - for package rule should be successful" do
    rule = FilterRule.create!(:filter => @filter, :content_type => 'rpm')

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:unit => {:name => 'xterm.*'}}

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_package_item'
    assert_equal @filter.rules.first.parameters, {"units" => [{"name" => "xterm.*"}]}
  end

  test "PUT add_parameter - for package group rule should be successful" do
    rule = FilterRule.create!(:filter => @filter, :content_type => 'package_group')

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:unit => {:name => 'Desktop'}}

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_package_group_item'
    assert_equal @filter.rules.first.parameters, {"units" => [{"name" => "Desktop"}]}
  end

  test "PUT add_parameter - for errata parameter rule should be successful" do
    # We'll create the rule using date range & type, but then update it to use errata id
    rule = FilterRule.create!(:filter => @filter, :content_type => 'erratum',
                              :parameters => HashWithIndifferentAccess.new({:errata_type => 'security',
                                                                            :date_range => {:start => '01/01/2013',
                                                                                            :end => '01/31/2013'}}))

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:unit => {:id => 'RHSA-2013-1234'}}

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_errata_item'
    assert_equal @filter.rules.first.parameters, {"units" => [{"id" => "RHSA-2013-1234"}]}
  end

  test "PUT add_parameter - for errata date/type rule should be successful" do
    # We'll create the rule using errata id, but then update it to use date range & type.
    # Note: in the test, we'll have to add 1 parameter at a time (e.g. start/end/type)

    rule = FilterRule.create!(:filter => @filter, :content_type => 'erratum',
                              :parameters => HashWithIndifferentAccess.new({:units => [{:id => "RHSA-2013-1234"}]}))

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:date_range => {:start => '01/01/2013'}}

    assert_response :success
    assert_equal @filter.rules.first.parameters, {"date_range" => {"start" => '01/01/2013'}}

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:date_range => {:end => '01/31/2013'}}

    assert_response :success
    assert_equal @filter.rules.first.parameters, {"date_range" => {"start" => '01/01/2013',
                                                                   "end" => '01/31/2013'}}

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:errata_type => 'security'}

    assert_response :success
    assert_equal @filter.rules.first.parameters, {"errata_type" => 'security',
                                                  "date_range" => {"start" => '01/01/2013',
                                                                   "end" => '01/31/2013'}}
  end

  test "DELETE destroy_parameters - should be successful" do
    rule = FilterRule.create!(:filter => @filter, :content_type => 'erratum',
                              :parameters => HashWithIndifferentAccess.new({:units => [{:id => "RHSA-2013-1234"}]}))

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    assert_equal @filter.rules.first.parameters[:units].length, 1

    delete :destroy_parameters, :content_view_definition_id => @filter.content_view_definition.id,
           :filter_id => @filter.id, :id => rule.id, :units => {"RHSA-2013-1234" => ""}

    assert_response :success
    assert_empty @filter.rules.first.parameters[:units]
  end

  test "DELETE destroy_rules - should be successful" do
    rule = FilterRule.create!(:filter => @filter, :content_type => 'erratum')

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    refute_empty @filter.rules

    delete :destroy_rules, :content_view_definition_id => @filter.content_view_definition.id,
           :filter_id => @filter.id, :filter_rules => {rule.id => ""}

    assert_response :success
    assert_empty @filter.rules
  end

end
