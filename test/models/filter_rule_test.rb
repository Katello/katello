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
    models = ["Organization", "KTEnvironment", "User","ContentViewEnvironment", "ContentViewDefinitionBase",
              "ContentViewDefinition", "Filter", "FilterRule", "ContentView",
              "PackageRule", "PackageGroupRule", "ErratumRule"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
  end
  def setup
    @repo = Repository.find(repositories(:fedora_17_x86_64).id)
    @product = Product.find(products(:fedora).id)
    Repository.any_instance.stubs(:package_count).returns(2)
    Repository.any_instance.stubs(:puppet_module_count).returns(2)
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
    search_results1 = array_to_struct([{:filename => "200"},
                                      {:filename => "202"}])
    expected_ids1 = search_results1.collect(&:filename)
    search_results2 = array_to_struct([{:filename => "203"},
                                      {:filename => "204"}])
    expected_ids2 = search_results2.collect(&:filename)

    units = {:units => [{:name => "foo*", :version => "5.0"},
                        {:name => "goo*", :min_version => "0.5", :max_version => "0.7" }]}
    expected = [{"filename"=>{"$in"=> expected_ids1}},
                {"filename"=>{"$in"=> expected_ids2}}
               ]
    Package.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_includes("rpm", units, expected)

    Package.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_excludes("rpm", units, expected)
  end

  def test_package_group_names
    search_results1 = array_to_struct([{:package_group_id => "300"},
                                      {:package_group_id => "302"}])
    expected_ids1 = search_results1.collect(&:package_group_id)
    search_results2 = array_to_struct([{:package_group_id => "303"},
                                      {:package_group_id => "304"}])
    expected_ids2 = search_results2.collect(&:package_group_id)
    units = {:units => [{:name => "foo*"}, {:name => "goo*"}]}
    expected = [{"id"=>{"$in"=>expected_ids1 + expected_ids2}}]

    PackageGroup.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_includes("package_group", units, expected)

    PackageGroup.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_excludes("package_group", units, expected)
  end

  def test_puppet_names_and_authors
    search_results1 = array_to_struct([{:_id => "501a4"},
                                      {:_id => "501a5"}])
    expected_ids1 = search_results1.collect(&:_id)
    search_results2 = array_to_struct([{:_id => "501a6"},
                                      {:_id => "501a7"}])
    expected_ids2 = search_results2.collect(&:_id)
    units = {:units => [{:name => "foo*", :author => "magoo"}, {:name => "goo*"}]}
    expected = [{"_id"=>{"$in"=>expected_ids1}}, {"_id"=>{"$in"=>expected_ids2}}]

    PuppetModule.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_includes("puppet_module", units, expected)

    PuppetModule.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_excludes("puppet_module", units, expected)
  end

  def test_puppet_versions
    search_results1 = array_to_struct([{:_id => "60e56"},
                                      {:_id => "60e57"}])
    expected_ids1 = search_results1.collect(&:_id)
    search_results2 = array_to_struct([{:_id => "60f58"},
                                      {:_id => "60f59"}])
    expected_ids2 = search_results2.collect(&:_id)

    units = {:units => [{:name => "foo*", :version => "5.0", :author => "magoo"},
                        {:name => "goo*", :min_version => "0.5", :max_version => "0.7" }]}
    expected = [{"_id"=>{"$in"=> expected_ids1}},
                {"_id"=>{"$in"=> expected_ids2}}
               ]
    PuppetModule.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_includes("puppet_module", units, expected)

    PuppetModule.expects(:search).twice.returns(search_results1, search_results2)
    exec_test_excludes("puppet_module", units, expected)
  end

  def test_errata_ids
    units = {:units => [{:id => "Foo1"}, {:id => "Foo2"} ]}
    expected = [{"id"=>{"$in"=>["Foo1", "Foo2"]}}]
    exec_test_includes_and_excludes("erratum", units, expected)
  end

  def test_errata_dates
    from = DateTime.now
    to = DateTime.now
    units = {:date_range => {:start =>from.to_i , :end => to.to_i}}
    expected = [{"issued"=>{"$gte"=>from.as_json,
                            "$lte"=>to.as_json}}]
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
    from = DateTime.now
    to = DateTime.now
    units = {:errata_type => [:enhancement, :security],
             :date_range => {:start => from.to_i, :end => to.to_i}}
    expected = [{"$and"=>[{"issued"=>{"$gte"=>from.as_json,
                  "$lte"=>to.as_json}},
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
    content_rule_hash = { FilterRule::PACKAGE => :package_filter_rule,
                          FilterRule::PACKAGE_GROUP => :package_group_filter_rule,
                          FilterRule::ERRATA => :erratum_filter_rule,
                          FilterRule::PUPPET_MODULE => :puppet_module_filter_rule
                        }

    fr_build = content_rule_hash[content_type] || :filter_rule
    #FactoryGirl.build(:filter)
    @filter_rule = FactoryGirl.build(fr_build)
    @filter = @filter_rule.filter
    @filter_rule.inclusion = inclusion
    @filter_rule.parameters = HashWithIndifferentAccess.new(parameter)
    @filter_rule.save!
    cvd =  @filter.content_view_definition
    cvd.repositories << @repo
    @filter.repositories << @repo
    cvd.send(:unassociation_clauses, @repo, @filter_rule.content_type)
   end
end