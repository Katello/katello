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

require 'katello_test_helper'

module Katello
class Util::PackageClauseGeneratorTest < ActiveSupport::TestCase

  INCLUDE_ALL_PACKAGES = {"filename" => {"$exists" => true}}

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentViewEnvironment",
              "ContentViewFilter", "ContentView", "ContentViewPackageFilterRule",
              "ContentViewPackageGroupFilterRule", "ContentViewErratumFilterRule"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
  end

  def setup
    User.current = User.find(users(:admin))
    organization = get_organization
    Repository.any_instance.stubs(:package_count).returns(2)
    @repo = Repository.find(katello_repositories(:fedora_17_x86_64).id)
    @content_view = FactoryGirl.build(:katello_content_view, :organization => organization, :repositories => [@repo])
  end

  def test_package_names
    @filter = FactoryGirl.create(:katello_content_view_package_filter, :content_view => @content_view)
    foo_rule = FactoryGirl.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "foo*")
    goo_rule = FactoryGirl.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "goo*")

    search_results1 = array_to_struct([{:filename => "100"},
                                       {:filename => "102"}])
    expected_ids1 = search_results1.collect(&:filename)
    search_results2 = array_to_struct([{:filename => "103"},
                                       {:filename => "104"}])
    expected_ids2 = search_results2.collect(&:filename)
    combined = [{"filename" => {"$in" => expected_ids1 + expected_ids2}}]

    Package.expects(:legacy_search).twice.returns(search_results1, search_results2)
    clause_gen = setup_whitelist_filter([foo_rule, goo_rule])
    expected = {"$or" => combined}
    assert_equal expected, clause_gen.copy_clause
    assert_nil clause_gen.remove_clause

    Package.expects(:legacy_search).twice.returns(search_results1, search_results2)
    blacklist_expected = {"$or" => combined}
    clause_gen = setup_blacklist_filter([foo_rule, goo_rule])
    expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [blacklist_expected]}]}
    assert_equal expected, clause_gen.copy_clause
    assert_equal blacklist_expected, clause_gen.remove_clause
  end

  def test_package_versions
    @filter = FactoryGirl.create(:katello_content_view_package_filter, :content_view => @content_view)
    foo_rule = FactoryGirl.create(:katello_content_view_package_filter_rule, :filter => @filter,
                                  :name => "foo*", :version => "5.0")
    goo_rule = FactoryGirl.create(:katello_content_view_package_filter_rule, :filter => @filter,
                                  :name => "goo*", :min_version => "0.5", :max_version => "0.7")

    search_results1 = array_to_struct([{:filename => "200"},
                                       {:filename => "202"}])
    expected_ids1 = search_results1.collect(&:filename)
    search_results2 = array_to_struct([{:filename => "203"},
                                       {:filename => "204"}])
    expected_ids2 = search_results2.collect(&:filename)

    combined = [{"filename" => {"$in" => expected_ids1 + expected_ids2}}]

    Package.expects(:legacy_search).twice.returns(search_results1, search_results2)
    expected = {"$or" => combined}
    clause_gen = setup_whitelist_filter([foo_rule, goo_rule])
    assert_equal expected, clause_gen.copy_clause
    assert_nil clause_gen.remove_clause

    Package.expects(:legacy_search).twice.returns(search_results1, search_results2)
    blacklist_expected = {"$or" => combined}
    clause_gen = setup_blacklist_filter([foo_rule, goo_rule])
    expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [blacklist_expected]}]}
    assert_equal expected, clause_gen.copy_clause
    assert_equal blacklist_expected, clause_gen.remove_clause
  end

  def test_package_group_names
    @filter = FactoryGirl.create(:katello_content_view_package_group_filter, :content_view => @content_view)
    foo_rule = FactoryGirl.create(:katello_content_view_package_group_filter_rule,
                                  :filter => @filter, :name => "foo*")
    goo_rule = FactoryGirl.create(:katello_content_view_package_group_filter_rule,
                                  :filter => @filter, :name => "goo*")

    search_results1 = array_to_struct([{:package_group_id => "300"},
                                       {:package_group_id => "302"}])
    expected_ids1 = search_results1.collect(&:package_group_id)
    search_results2 = array_to_struct([{:package_group_id => "303"},
                                       {:package_group_id => "304"}])
    expected_ids2 = search_results2.collect(&:package_group_id)

    expected_group_clause = [{"id" => {"$in" => expected_ids1 + expected_ids2}}]

    returned_packages = {'names' => {"$in" => ["foo", "bar"]}}

    PackageGroup.expects(:legacy_search).twice.returns(search_results1, search_results2)
    clause_gen = setup_whitelist_filter([foo_rule, goo_rule]) do |gen|
        gen.expects(:package_clauses_for_group).once.
                    with(expected_group_clause).returns(returned_packages)
    end
    assert_equal returned_packages, clause_gen.copy_clause
    assert_nil clause_gen.remove_clause

    PackageGroup.expects(:legacy_search).twice.returns(search_results1, search_results2)
    clause_gen = setup_blacklist_filter([foo_rule, goo_rule]) do |gen|
        gen.expects(:package_clauses_for_group).once.
                    with(expected_group_clause).returns(returned_packages)
    end
    expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [returned_packages]}]}
    assert_equal expected, clause_gen.copy_clause
    assert_equal returned_packages, clause_gen.remove_clause
  end

  def test_errata_ids
    @filter = FactoryGirl.create(:katello_content_view_erratum_filter, :content_view => @content_view)
    foo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                  :filter => @filter, :errata_id => "Foo1")
    goo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                  :filter => @filter, :errata_id => "Foo2")

    expected_errata = [{"id" => {"$in" => ["Foo1", "Foo2"]}}]
    assert_errata_rules([foo_rule, goo_rule], expected_errata)
  end

  def test_errata_dates
    from = Date.today.to_s
    to = Date.today.to_s

    @filter = FactoryGirl.create(:katello_content_view_erratum_filter, :content_view => @content_view)
    foo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                  :filter => @filter, :start_date => from, :end_date => to)

    expected = [{"issued" => {"$gte" => from.to_time.as_json,
                            "$lte" => to.to_time.as_json}}]
    assert_errata_rules([foo_rule], expected)
  end

  def test_errata_types
    @filter = FactoryGirl.create(:katello_content_view_erratum_filter, :content_view => @content_view)
    foo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                  :filter => @filter, :types => [:bugfix, :security])

    expected = [{"type" => {"$in" => [:bugfix, :security]}}]
    assert_errata_rules([foo_rule], expected)
  end

  def test_errata_both
    from = Date.today
    to = Date.today

    @filter = FactoryGirl.create(:katello_content_view_erratum_filter, :content_view => @content_view)
    foo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                  :filter => @filter, :start_date => from.to_s,
                                  :end_date => to.to_s, :types => [:enhancement, :security])

    expected = [{"$and" => [{"issued" => {"$gte" => from.to_s.to_time.as_json,
                  "$lte" => to.to_s.to_time.as_json}},
                            {"type" => {"$in" => [:enhancement, :security]}}]}]
    assert_errata_rules([foo_rule], expected)
  end

  def assert_errata_rules(rules, expected_errata)
    returned_packages = {'filenames' => {"$in" => ["foo", "bar"]}}

    clause_gen = setup_whitelist_filter(rules) do |gen|
        gen.expects(:package_clauses_for_errata).once.
                    with(expected_errata).returns(returned_packages)
    end
    assert_equal returned_packages, clause_gen.copy_clause
    assert_nil clause_gen.remove_clause

    clause_gen = setup_blacklist_filter(rules) do |gen|
        gen.expects(:package_clauses_for_errata).once.
                    with(expected_errata).returns(returned_packages)
    end
    expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [returned_packages]}]}

    assert_equal expected, clause_gen.copy_clause
    assert_equal returned_packages, clause_gen.remove_clause
  end

  def array_to_struct(items)
    items.collect do |item|
      OpenStruct.new(item)
    end
  end

  def setup_whitelist_filter(filter_rules, &block)
    setup_filter_clause(true, filter_rules, &block)
  end

  def setup_blacklist_filter(filter_rules, &block)
    setup_filter_clause(false, filter_rules, &block)
  end

  def setup_filter_clause(inclusion, filter_rules, &block)
    filter = filter_rules.first.filter
    filter.inclusion = inclusion
    filter.save!
    clause_gen = Util::PackageClauseGenerator.new(@repo, [filter])
    yield clause_gen if block_given?
    clause_gen.generate
    clause_gen
  end

end
end
