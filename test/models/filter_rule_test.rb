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
    Package.delete_all
  end

  def test_package_names
    search_results1 = array_to_struct([{:filename => "100"},
                                      {:filename => "102"}])
    expected_ids1 = search_results1.collect(&:filename)

    search_results2 = array_to_struct([{:filename => "103"},
                                      {:filename => "104"}])
    expected_ids2 = search_results2.collect(&:filename)

    units = {:units => [{:name => "foo*"}, {:name => "goo*"}]}
    expected = [{"filename"=>{"$in"=>expected_ids1}}, {"filename"=>{"$in"=>expected_ids2}}]

    Package.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_includes("rpm", units, expected)

    Package.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_excludes("rpm", units, expected)
  end


  def test_package_versions
    search_results1 = array_to_struct([{:filename => "100"},
                                      {:filename => "102"}])
    expected_ids1 = search_results1.collect(&:filename)

    search_results2 = array_to_struct([{:filename => "103"},
                                      {:filename => "104"}])
    expected_ids2 = search_results2.collect(&:filename)


    units = {:units => [{:name => "foo*", :version => "5.0"},
                        {:name => "goo*", :min_version => "0.5", :max_version => "0.7" }]}
    expected = [{"$and" => [{"filename"=>{"$in"=> expected_ids1}}, {"version" => "5.0"}]},
                {"$and" => [{"filename"=>{"$in"=> expected_ids2}}, {"version" => {"$gte" => "0.5", "$lte" => "0.7"}}]}
               ]

    Package.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_includes("rpm", units, expected)

    Package.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_excludes("rpm", units, expected)
  end


  def test_package_group_names
    search_results1 = array_to_struct([{:package_group_id => "100"},
                                      {:package_group_id => "102"}])
    expected_ids1 = search_results1.collect(&:package_group_id)

    search_results2 = array_to_struct([{:package_group_id => "103"},
                                      {:package_group_id => "104"}])
    expected_ids2 = search_results2.collect(&:package_group_id)

    units = {:units => [{:name => "foo*"}, {:name => "goo*"}]}
    expected = [{"id"=>{"$in"=>expected_ids1 + expected_ids2}}]

    PackageGroup.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_includes("package_group", units, expected)

    PackageGroup.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_excludes("package_group", units, expected)
  end


  def test_errata_ids
    units = {:units => [{:id => "Foo1"}, {:id => "Foo2"} ]}
    expected = [{"id"=>{"$in"=>["Foo1", "Foo2"]}}]
    exec_test_includes_and_excludes("erratum", units, expected)
  end

  def test_errata_dates
    fr = FilterRule.new
    from = "01/23/2000"
    to = "02/23/2010"
    units = {:date_range => {:start =>from , :end => to}}
    expected = [{"issued"=>{"$gte"=>fr.send(:convert_date,from),
                            "$lte"=>fr.send(:convert_date,to)}}]
    exec_test_includes_and_excludes("erratum", units, expected)
  end

  def test_errata_types
    units = {:errata_type => [:bugfix, :security]}
    expected = [{"type"=>{"$in"=>[:bugfix, :security]}}]
    exec_test_includes_and_excludes("erratum", units, expected)
  end


  def test_errata_severity
    units = {:severity => [:low, :critical]}
    expected = [{"severity"=>{"$in"=>[:low, :critical]}}]
    exec_test_includes_and_excludes("erratum", units, expected)
  end



  def test_errata_both
    fr = FilterRule.new
    from = "03/22/2000"
    to = "05/23/2012"
    units = {:errata_type => [:enhancement, :security],
             :date_range => {:start => from, :end => to}}
    expected = [{"$and"=>[{"issued"=>{"$gte"=>fr.send(:convert_date,from),
                  "$lte"=>fr.send(:convert_date,to)}},
                  {"type"=>{"$in"=>[:enhancement, :security]}}]}]
    exec_test_includes_and_excludes("erratum", units, expected)
  end


  def array_to_struct(items)
    items.collect do |item|
      OpenStruct.new(item)
    end
  end

  def exec_test_includes_and_excludes(content_type, units, expected_fragments)
      exec_test_includes(content_type, units, expected_fragments)
      exec_test_excludes(content_type, units, expected_fragments)

  end
  def exec_test_includes(content_type, units, expected_fragments)
    actual = get_filter_clause(true, content_type, units)
    expected = {"$nor"=> expected_fragments}
    assert_equal expected, actual

  end

  def exec_test_excludes(content_type, units, expected_fragments)
    actual = get_filter_clause(false, content_type, units)
    expected = {"$or"=> expected_fragments}
    assert_equal expected, actual

  end

  def get_filter_clause(inclusion, content_type, parameter)
    @filter_rule = FactoryGirl.build(:filter_rule)
    @filter = @filter_rule.filter
    @filter_rule.inclusion = inclusion
    @filter_rule.content_type = content_type
    @filter_rule.parameters = HashWithIndifferentAccess.new(parameter)
    @filter_rule.save!
    cvd =  @filter.content_view_definition
    cvd.repositories << @repo
    @filter.repositories << @repo
    cvd.send(:unassociation_clauses, @repo, @filter_rule.content_type)
   end
end