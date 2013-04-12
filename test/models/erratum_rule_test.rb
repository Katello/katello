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

class ErratumRuleTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentViewDefinitionBase",
              "ContentViewDefinition", "Filter", "FilterRule", "ErratumRule"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end
  def setup
    @filter_rule = FactoryGirl.build(:erratum_filter_rule)
    format = "%m/%d/%Y%:z"
    zone = DateTime.now.zone
    @start_date = DateTime.strptime("01/01/2013" + zone, format)
    @end_date = DateTime.strptime("01/31/2013" + zone, format)
  end

  def after_tests
    FilterRule.delete_all
    Filter.delete_all
    ContentViewDefinition.delete_all
    ContentViewDefinitionBase.delete_all
    Organization.delete_all
    Package.delete_all
  end

  def test_create
    assert @filter_rule.save
  end

  def test_bad_params
    assert_bad_params(:date_range => {:boo => @start_date.to_i})
    assert_bad_params(:date_range => {:start => @start_date.to_i, :bad => 1000})
    assert_bad_params(:date_range => {:start => DateTime.now}) # has to be int not date
    #  end must be greater than start
    assert_bad_params(:date_range => {:start => @end_date.to_i, :end => @start_date.to_i})
    # errata types
    assert_bad_params(:errata_type => ['buggy'])
    assert_bad_params(:errata_type => ['bugfix', 'secure'])
    #id based params
    assert_bad_params(:units => {:id_val => '100'})
  end

  def test_good_params
    assert_good_params(:date_range => {:start => @start_date.to_i})
    assert_good_params(:date_range => {:start => @start_date.to_i, :end => @end_date.to_i})
    assert_good_params(:errata_type => ['bugfix', 'security', 'enhancement'])
    assert_good_params(:units => [{:id => "foo"}, {:id => "bar"}])
    assert_good_params(:severity => ["low"])
    assert_good_params({:date_range => {:start => @start_date.to_i, :end => @end_date.to_i},
                        :errata_type => ['bugfix', 'security', 'enhancement'],
                        :severity => ["low"]})
  end

  def test_date_params
    @filter_rule.start_date = @start_date
    expected = {:date_range => {:start => @start_date.to_i}}.with_indifferent_access
    assert_equal(expected, @filter_rule.parameters)
    assert_equal(@start_date.to_i, @filter_rule.start_date.to_i)
    #test end date
    @filter_rule.end_date = @end_date
    expected[:date_range][:end] = @end_date.to_i
    assert_equal(expected, @filter_rule.parameters)
    assert_equal(@end_date.to_i, @filter_rule.end_date.to_i)
  end

  def test_errata_type_params
    errata_types = ['bugfix', 'security', 'enhancement']
    @filter_rule.errata_types = errata_types
    expected = {:errata_type => errata_types}.with_indifferent_access
    assert_equal(expected, @filter_rule.parameters)
    assert_equal(errata_types, @filter_rule.errata_types)
  end

  def assert_bad_params(params)
    @filter_rule.parameters = params.with_indifferent_access
    assert_raises(ActiveRecord::RecordInvalid) do
      @filter_rule.save!
    end
  end

  def assert_good_params(params)
    @filter_rule.parameters = params.with_indifferent_access
    assert @filter_rule.save
  end
end