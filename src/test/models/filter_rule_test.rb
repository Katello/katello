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

require 'minitest_helper'

class FilterRuleTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User","ContentViewEnvironment", "ContentViewDefinition", "Filter"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def setup
    @filter_rule = FactoryGirl.build(:filter_rule)
    @filter = @filter_rule.filter
    @repo = Repository.find(repositories(:fedora_17_x86_64).id)
    @product = Product.find(products(:fedora).id)
  end

  def after_tests
    FilterRule.delete_all
    Filter.delete_all
    ContentViewDefinition.delete_all
    Organization.delete_all
    Product.delete_all
    Repository.delete_all
  end

  def test_include_filter_clause
    actual = get_filter_clause(true, "rpm", :units => [{:name => "foo*"}, {:name => "goo*"} ])
    expected = {"$nor"=>[{"name"=>{"$regex"=>"foo*"}}, {"name"=>{"$regex"=>"goo*"}}]}
    assert_equal expected, actual
  end

  def test_exclude_filter_clause
    actual = get_filter_clause(false, "rpm", :units => [{:name => "foo*"}, {:name => "goo*"} ])
    expected = {"$or"=>[{"name"=>{"$regex"=>"foo*"}}, {"name"=>{"$regex"=>"goo*"}}]}
    assert_equal expected, actual
  end


  def get_filter_clause(inclusion, content_type, parameter)
    @filter_rule.inclusion = inclusion
    @filter_rule.content_type = content_type
    @filter_rule.parameters = HashWithIndifferentAccess.new(parameter)
    @filter_rule.save!
    cvd =  @filter.content_view_definition
    cvd.repositories << @repo
    @filter.repositories << @repo
    cvd.send(:generate_unassociate_filter_clauses, @repo, @filter_rule.content_type)
   end
end