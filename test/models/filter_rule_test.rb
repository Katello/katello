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

  [:includes, :excludes].each do |m|
    define_method("test_package_name_#{m}") do
      units = {:units => [{:name => "foo*"}, {:name => "goo*"}]}
      expected = [{"name"=>{"$regex"=>"foo*"}}, {"name"=>{"$regex"=>"goo*"}}]
      send("exec_test_#{m}", "rpm", units, expected )
    end

    define_method("test_package_versions_#{m}") do
      units = {:units => [{:name => "foo*", :version => "5.0"},
                          {:name => "goo*", :min_version => "0.5", :max_version => "0.7" }]}
      expected = [{"$and" => [{"name"=>{"$regex"=>"foo*"}}, {"version" => "5.0"}]},
                  {"$and" => [{"name"=>{"$regex"=>"goo*"}}, {"version" => {"$gte" => "0.5", "$lte" => "0.7"}}]}]

      send("exec_test_#{m}", "rpm", units, expected)
    end


    define_method("test_package_group_names_#{m}") do
      units = {:units => [{:name => "foo*"}, {:name => "goo*"} ]}
      expected = [{"name"=>{"$regex"=>"foo*"}}, {"name"=>{"$regex"=>"goo*"}}]
      send("exec_test_#{m}", "package_group", units, expected)
    end

    define_method("test_errata_ids_#{m}") do
      units = {:units => [{:id => "Foo1"}, {:id => "Foo2"} ]}
      expected = [{"id"=>{"$in"=>["Foo1", "Foo2"]}}]
      send("exec_test_#{m}", "erratum", units, expected)
    end

    define_method("test_errata_dates_#{m}") do
      units = {:date_range => {:start => "01/23/2000", :end => "02/23/2010"}}
      expected = [{"issued"=>{"$gte"=>"2000-01-23T00:00:00-04:00",
                              "$lte"=>"2010-02-23T00:00:00-04:00"}}]
      send("exec_test_#{m}", "erratum", units, expected)
    end


    define_method("test_errata_types_#{m}") do
      units = {:errata_type => [:bugfix, :security]}
      expected = [{"type"=>{"$in"=>[:bugfix, :security]}}]
      send("exec_test_#{m}", "erratum", units, expected)
    end

    define_method("test_errata_both_#{m}") do
      units = {:errata_type => [:enhancement, :security],
               :date_range => {:start => "03/27/2000", :end => "05/23/2010"}}
      expected = [{"$and"=>[{"issued"=>{"$gte"=>"2000-03-27T00:00:00-04:00",
                    "$lte"=>"2010-05-23T00:00:00-04:00"}},
                    {"type"=>{"$in"=>[:enhancement, :security]}}]}]
      send("exec_test_#{m}", "erratum", units, expected)
    end
  end

  def exec_test_includes content_type, units, expected_fragments
    actual = get_filter_clause(true, content_type, units)
    expected = {"$nor"=> expected_fragments}
    assert_equal expected, actual

  end

  def exec_test_excludes  content_type, units, expected_fragments
    actual = get_filter_clause(false, content_type, units)
    expected = {"$or"=> expected_fragments}
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