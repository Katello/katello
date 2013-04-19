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

class Api::FilterRulesControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def setup
    models = ["Organization", "KTEnvironment", "User", "Filter",
                "FilterRule", "ErratumRule", "PackageRule", "PackageGroupRule",
                "ContentViewEnvironment", "ContentViewDefinition"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    login_user(User.find(users(:admin)))
    @filter = filters(:simple_filter)
  end


  test "should delete a filter_rule" do
    populated_filter = filters(:populated_filter)
    rule_id =  populated_filter.rules.first.id
    delete :destroy, :organization_id => populated_filter.content_view_definition.organization.label,
                :content_view_definition_id=> populated_filter.content_view_definition.id,
                :filter_id => populated_filter.id.to_s, :id => rule_id
    assert_response :success
    assert_empty FilterRule.where(:id => rule_id)
  end

  [
      [FilterRule::PACKAGE, {:units => [{:name =>"w*", :version => "4.0"}]}],
      [FilterRule::PACKAGE_GROUP, {:units => [{:name =>["w*"]}]}],
      [FilterRule::ERRATA, {:units => [{:id =>["RH1", "RH2"]}]}],
      [FilterRule::ERRATA, {:errata_type => ["bugfix", "enhancement", "security"]}]
  ].each do |content, rule|
    [true, false].each do |inclusion|
      test "should create a filter #{content} rule for inclusion = #{inclusion}" do
        rule = rule.with_indifferent_access
        post :create, :organization_id => @filter.content_view_definition.organization.label,
             :content_view_definition_id=> @filter.content_view_definition.id,
             :filter_id => @filter.id.to_s, :content => content, :inclusion => inclusion,
             :rule => rule.to_json
        assert_response :success
        response_hash = JSON.parse(response.body)
        assert_kind_of Hash, response_hash
        response_hash = response_hash.with_indifferent_access
        assert_equal content, response_hash[:content]
        assert_equal inclusion, response_hash[:inclusion]
        assert_equal rule, response_hash["rule"]
        refute_nil FilterRule.find(response_hash["id"])
      end
    end
  end

  test "should create an errata rule based on date" do
    content = FilterRule::ERRATA
    inclusion = true
    rule = {:date_range => {:start => "2013-04-15T15:44:48-04:00",
                           :end => "2013-05-15T15:44:48-04:00"}}.with_indifferent_access
    post :create, :organization_id => @filter.content_view_definition.organization.label,
         :content_view_definition_id=> @filter.content_view_definition.id,
         :filter_id => @filter.id.to_s, :content => content, :inclusion => inclusion,
         :rule => rule.to_json
    assert_response :success
    response_hash = JSON.parse(response.body)
    assert_kind_of Hash, response_hash
    response_hash = response_hash.with_indifferent_access
    assert_equal content, response_hash[:content]
    assert_equal inclusion, response_hash[:inclusion]
    assert_equal rule[:date_range][:start].to_date, response_hash[:rule][:date_range][:start].to_date
    assert_equal rule[:date_range][:end].to_date, response_hash[:rule][:date_range][:end].to_date
    refute_nil FilterRule.find(response_hash["id"])
  end
end
