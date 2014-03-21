#
# Copyright 2014 Red Hat, Inc.
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

class Util::PackageClauseGeneratorTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  INCLUDE_ALL_PACKAGES = {"filename" => {"$exists" => true}}

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User","ContentViewEnvironment",
              "ContentViewFilter", "ContentView", "ContentViewPackageFilterRule",
              "ContentViewPackageGroupFilterRule", "ContentViewErratumFilterRule"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
  end

  def setup
    Repository.any_instance.stubs(:package_count).returns(2)
  end

  def test_package_names
    search_results1 = array_to_struct([{:filename => "100"},
                                      {:filename => "102"}])
    expected_ids1 = search_results1.collect(&:filename)
    search_results2 = array_to_struct([{:filename => "103"},
                                      {:filename => "104"}])
    expected_ids2 = search_results2.collect(&:filename)
    units = {:units => [{:name => "foo*"}, {:name => "goo*"}]}
    combined = [{"filename"=>{"$in"=>expected_ids1 + expected_ids2}}]

    Package.expects(:search).twice.returns(search_results1, search_results2)
    clause_gen = setup_whitelist_filter( "rpm", units)
    expected = {"$or" => combined}
    assert_equal expected, clause_gen.copy_clause
    assert_nil clause_gen.remove_clause

    Package.expects(:search).twice.returns(search_results1, search_results2)
    blacklist_expected = {"$or" => combined}
    clause_gen = setup_blacklist_filter( "rpm", units)
    expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [blacklist_expected]} ]}
    assert_equal expected, clause_gen.copy_clause
    assert_equal blacklist_expected, clause_gen.remove_clause
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

    combined = [{"filename"=>{"$in"=>expected_ids1 + expected_ids2}}]

    Package.expects(:search).twice.returns(search_results1, search_results2)
    expected = {"$or" => combined}
    clause_gen = setup_whitelist_filter( "rpm", units)
    assert_equal expected, clause_gen.copy_clause
    assert_nil clause_gen.remove_clause

    Package.expects(:search).twice.returns(search_results1, search_results2)
    blacklist_expected = {"$or" => combined}
    clause_gen = setup_blacklist_filter( "rpm", units)
    expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [blacklist_expected]} ]}
    assert_equal expected, clause_gen.copy_clause
    assert_equal blacklist_expected, clause_gen.remove_clause
  end


  def test_package_group_names
    search_results1 = array_to_struct([{:package_group_id => "300"},
                                      {:package_group_id => "302"}])
    expected_ids1 = search_results1.collect(&:package_group_id)
    search_results2 = array_to_struct([{:package_group_id => "303"},
                                      {:package_group_id => "304"}])
    expected_ids2 = search_results2.collect(&:package_group_id)

    units = {:units => [{:name => "foo*"}, {:name => "goo*"}]}

    expected_group_clause = [{"id"=>{"$in"=>expected_ids1 + expected_ids2}}]

    returned_packages = {'names' => {"$in" => ["foo", "bar"]}}

    PackageGroup.expects(:search).twice.returns(search_results1, search_results2)
    clause_gen = setup_whitelist_filter( "package_group", units) do |gen|
        gen.expects(:package_clauses_for_group).once.
                    with(expected_group_clause).returns(returned_packages)
    end
    assert_equal returned_packages, clause_gen.copy_clause
    assert_nil clause_gen.remove_clause

    PackageGroup.expects(:search).twice.returns(search_results1, search_results2)
    clause_gen = setup_blacklist_filter( "package_group", units) do |gen|
        gen.expects(:package_clauses_for_group).once.
                    with(expected_group_clause).returns(returned_packages)
    end
    expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [returned_packages]} ]}
    assert_equal expected, clause_gen.copy_clause
    assert_equal returned_packages, clause_gen.remove_clause
  end

  def test_errata_ids
    units = {:units => [{:id => "Foo1"}, {:id => "Foo2"} ]}
    expected_errata = [{"id"=>{"$in"=>["Foo1", "Foo2"]}}]
    assert_errata_rules(units, expected_errata)
  end

  def test_errata_dates
    from = DateTime.now
    to = DateTime.now
    units = {:date_range => {:start =>from.to_i , :end => to.to_i}}
    expected = [{"issued"=>{"$gte"=>from.as_json,
                            "$lte"=>to.as_json}}]
    assert_errata_rules(units, expected)
  end

  def test_errata_types
    units = {:errata_type => [:bugfix, :security]}
    expected = [{"type"=>{"$in"=>[:bugfix, :security]}}]
    assert_errata_rules(units, expected)
  end

  def test_errata_both
    from = DateTime.now
    to = DateTime.now
    units = {:errata_type => [:enhancement, :security],
             :date_range => {:start => from.to_i, :end => to.to_i}}
    expected = [{"$and"=>[{"issued"=>{"$gte"=>from.as_json,
                  "$lte"=>to.as_json}},
                  {"type"=>{"$in"=>[:enhancement, :security]}}]}]
    assert_errata_rules(units, expected)
  end

  def assert_errata_rules(input, expected_errata)
    returned_packages = {'filenames' => {"$in" => ["foo", "bar"]}}

    clause_gen = setup_whitelist_filter( "erratum", input) do |gen|
        gen.expects(:package_clauses_for_errata).once.
                    with(expected_errata).returns(returned_packages)
    end
    assert_equal returned_packages, clause_gen.copy_clause
    assert_nil clause_gen.remove_clause

    clause_gen = setup_blacklist_filter( "erratum", input) do |gen|
        gen.expects(:package_clauses_for_errata).once.
                    with(expected_errata).returns(returned_packages)
    end
    expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [returned_packages]} ]}
    assert_equal expected, clause_gen.copy_clause
    assert_equal returned_packages, clause_gen.remove_clause

  end

  def array_to_struct(items)
    items.collect do |item|
      OpenStruct.new(item)
    end
  end

  def setup_whitelist_filter(content_type, parameter, &block)
    setup_filter_clause(true, content_type, parameter, &block)
  end

  def setup_blacklist_filter(content_type, parameter, &block)
    setup_filter_clause(false, content_type, parameter, &block)
  end


  def setup_filter_clause(inclusion, content_type, parameter)
    repo = Repository.find(repositories(:fedora_17_x86_64).id)
    content_rule_hash = { ContentViewPackageFilter::CONTENT_TYPE => :katello_package_filter_rule,
                          ContentViewPackageGroupFilter::CONTENT_TYPE => :katello_package_group_filter_rule,
                          ContentViewErratumFilter::CONTENT_TYPE => :katello_erratum_filter_rule,
                        }

    fr_build = content_rule_hash[content_type] || :katello_filter_rule
    filter_rule = FactoryGirl.build(fr_build)
    filter = filter_rule.filter
    filter_rule.inclusion = inclusion
    filter_rule.parameters = HashWithIndifferentAccess.new(parameter)
    filter_rule.save!
    cvd =  filter.content_view_definition
    cvd.repositories << repo
    filter.repositories << repo
    clause_gen = Util::PackageClauseGenerator.new(repo, [filter])
    yield clause_gen if block_given?
    clause_gen.generate
    clause_gen
   end
end
