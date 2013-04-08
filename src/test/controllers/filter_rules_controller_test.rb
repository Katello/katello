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

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "Product", "EnvironmentProduct", "Repository",
              "ContentViewEnvironment", "ContentViewDefinitionBase",
              "ContentViewDefinition", "ContentViewDefinitionRepository",
              "ContentViewDefinitionProduct", "Filter", "FilterRule"]
    services = ["Candlepin", "Pulp", "ElasticSearch", "Foreman"]
    disable_glue_layers(services, models, true)
  end

  def setup
    @org = organizations(:acme_corporation)

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

    @controller.expects(:render).at_least_once

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

    @controller.expects(:render).at_least_once

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

    @controller.expects(:render).at_least_once

    assert_empty @filter.rules

    post :create, :content_view_definition_id=> @filter.content_view_definition.id, :filter_id => @filter.id,
         :filter_rule => {:content_type => 'erratum'}

    assert_response :success

    @filter.reload
    assert_equal @filter.rules.length, 1
    assert_equal @filter.rules.first.content_type, 'erratum'
  end

  test "GET edit - should be successful" do
    @filter = filters(:populated_filter)

    get :edit, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => @filter.rules.first.id

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_edit'
  end

  test "GET edit_inclusion - should be successful" do
    @filter = filters(:populated_filter)

    get :edit_inclusion, :content_view_definition_id => @filter.content_view_definition.id,
        :filter_id => @filter.id, :id => @filter.rules.first.id

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_inclusion'
  end

  test "GET edit_parameter_list - should be successful" do
    @filter = filters(:populated_filter)

    get :edit_parameter_list, :content_view_definition_id => @filter.content_view_definition.id,
        :filter_id => @filter.id, :id => PackageRule.where(:filter_id => @filter.id).first.id

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_parameter_list'
  end

  test "GET edit_date_type_parameters - should be successful" do
    @filter = filters(:populated_filter)

    get :edit_date_type_parameters, :content_view_definition_id => @filter.content_view_definition.id,
        :filter_id => @filter.id, :id => ErratumRule.where(:filter_id => @filter.id).first.id

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_edit_errata_parameters'
  end

  test "PUT update - inclusion=false should be successful" do
    @filter = filters(:populated_filter)
    rule = ErratumRule.where(:filter_id => @filter.id).first

    assert_equal rule.inclusion, true

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    put :update, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :filter_rule => {:inclusion => false}

    assert_response :success
    assert_equal rule.reload.inclusion, false
  end

  test "PUT add_parameter - for package rule should be successful" do
    @filter = filters(:populated_filter)
    rule = PackageRule.where(:filter_id => @filter.id).first

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:unit => {:name => 'kernel.*'}}

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_package_item'
    assert_includes rule.reload.parameters[:units], {"name" => "kernel.*"}
  end

  test "PUT add_parameter - for package group rule should be successful" do
    @filter = filters(:populated_filter)
    rule = PackageGroupRule.where(:filter_id => @filter.id).first

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:unit => {:name => 'Desktop'}}

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_package_group_item'
    assert_includes rule.reload.parameters[:units], {"name" => "Desktop"}
  end

  test "PUT add_parameter - for errata parameter rule should be successful" do
    @filter = filters(:populated_filter)
    rule = ErratumRule.where(:filter_id => @filter.id).first
    rule.parameters = HashWithIndifferentAccess.new({:errata_type => 'security',
                                                     :date_range => {:start => '01/01/2013', :end => '01/31/2013'}})
    rule.save!

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:unit => {:id => 'RHSA-2013-1234'}}

    assert_response :success
    assert_template :partial => 'content_view_definitions/filters/rules/_errata_item'
    assert_equal rule.reload.parameters, {"units" => [{"id" => "RHSA-2013-1234"}]}
  end

  test "PUT add_parameter - for errata date/type rule should be successful" do
    # The erratum rule that is in the populated_filter contains an id parameter;
    # however, for this test, we'll convert it to one that contains a date
    # range and type, by adding each individually.
    @filter = filters(:populated_filter)
    rule = ErratumRule.where(:filter_id => @filter.id).first

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:date_range => {:start => '01/01/2013'}}

    assert_response :success
    assert_equal rule.reload.parameters, {"date_range" => {"start" => '01/01/2013'}}

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:date_range => {:end => '01/31/2013'}}

    assert_response :success
    assert_equal rule.reload.parameters, {"date_range" => {"start" => '01/01/2013',
                                                           "end" => '01/31/2013'}}

    put :add_parameter, :content_view_definition_id => @filter.content_view_definition.id, :filter_id => @filter.id,
        :id => rule.id, :parameter => {:errata_type => ['security']}

    assert_response :success
    assert_equal rule.reload.parameters, {"errata_type" => ['security'],
                                          "date_range" => {"start" => '01/01/2013',
                                                           "end" => '01/31/2013'}}
  end

  test "DELETE destroy_parameters - should be successful" do
    @filter = filters(:populated_filter)
    rule = ErratumRule.where(:filter_id => @filter.id).first

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    assert_equal rule.parameters[:units].length, 1

    delete :destroy_parameters, :content_view_definition_id => @filter.content_view_definition.id,
           :filter_id => @filter.id, :id => rule.id, :units => {rule.parameters[:units].first[:id] => ""}

    assert_response :success
    assert_empty rule.reload.parameters[:units]
  end

  test "DELETE destroy_rules - should be successful" do
    @filter = filters(:populated_filter)

    # success notice created
    notify = Notifications::Notifier.new
    notify.expects(:success).at_least_once
    @controller.expects(:notify).at_least_once.returns(notify)

    refute_empty @filter.rules

    delete :destroy_rules, :content_view_definition_id => @filter.content_view_definition.id,
           :filter_id => @filter.id,
           :filter_rules => @filter.rule_ids.inject({}) {|result, id| result.update id => ""}

    assert_response :success
    assert_empty @filter.rules
  end

end
