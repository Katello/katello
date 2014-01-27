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

class Util::PuppetClauseGeneratorTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  INCLUDE_ALL_MODULES = {"unit_id" => {"$exists" => true}}

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User","ContentViewEnvironment",
              "Filter", "FilterRule", "ContentView",
              "PackageRule", "PackageGroupRule", "ErratumRule"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
  end

  def setup
    Repository.any_instance.stubs(:puppet_module_count).returns(2)
  end

  def test_puppet_names_and_authors
    search_results1 = array_to_struct([{:_id => "501a4"},
                                      {:_id => "501a5"}])
    expected_ids1 = search_results1.collect(&:_id)
    search_results2 = array_to_struct([{:_id => "501a6"},
                                      {:_id => "501a7"}])
    expected_ids2 = search_results2.collect(&:_id)
    units = {:units => [{:name => "foo*", :author => "magoo"}, {:name => "goo*"}]}
    expected = {"unit_id"=>{"$in"=>expected_ids1 + expected_ids2}}

    PuppetModule.expects(:search).twice.returns(search_results1, search_results2)
    clause_gen = setup_whitelist_filter(units)
    assert_equal expected, clause_gen.copy_clause

    PuppetModule.expects(:search).twice.returns(search_results1, search_results2)
    blacklist_expected = {"unit_id"=>{"$in"=>expected_ids1 + expected_ids2}}
    clause_gen = setup_blacklist_filter(units)
    expected = {"$and" => [INCLUDE_ALL_MODULES, {"$nor" => [blacklist_expected]} ]}
    assert_equal expected, clause_gen.copy_clause
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
    expected = {"unit_id"=>{"$in"=> expected_ids1 + expected_ids2}}

    PuppetModule.expects(:search).twice.returns(search_results1, search_results2)
    clause_gen = setup_whitelist_filter(units)
    assert_equal expected, clause_gen.copy_clause

    PuppetModule.expects(:search).twice.returns(search_results1, search_results2)
    blacklist_expected = {"unit_id"=>{"$in"=>expected_ids1 + expected_ids2}}
    clause_gen = setup_blacklist_filter(units)
    expected = {"$and" => [INCLUDE_ALL_MODULES, {"$nor" => [blacklist_expected]} ]}
    assert_equal expected, clause_gen.copy_clause
  end

  def array_to_struct(items)
    items.collect do |item|
      OpenStruct.new(item)
    end
  end

  def setup_whitelist_filter(parameter, &block)
    setup_filter_clause(true, parameter, &block)
  end

  def setup_blacklist_filter(parameter, &block)
    setup_filter_clause(false, parameter, &block)
  end

  def setup_filter_clause(inclusion, parameter)
    repo = Repository.find(repositories(:fedora_17_x86_64).id)
    filter_rule = FactoryGirl.build(:puppet_module_filter_rule)
    filter = filter_rule.filter
    filter_rule.inclusion = inclusion
    filter_rule.parameters = HashWithIndifferentAccess.new(parameter)
    filter_rule.save!
    cvd =  filter.content_view_definition
    cvd.repositories << repo
    filter.repositories << repo
    clause_gen = Util::PuppetClauseGenerator.new(repo, [filter])
    yield clause_gen if block_given?
    clause_gen.generate
    clause_gen
   end
end
