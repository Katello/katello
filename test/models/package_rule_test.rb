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

require 'test_helper'

class PackageRuleTest < ActiveSupport::TestCase
  fixtures :all

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentViewDefinitionBase",
              "ContentViewDefinition", "Filter", "FilterRule", "PackageRule"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def setup
    @filter_rule = FactoryGirl.build(:package_filter_rule)
  end

  def test_create
    assert @filter_rule.save
  end

  def test_bad_params
    assert_bad_params(:foo => {:boo => 100})
    assert_bad_params(:units => "cool")
    assert_bad_params(:units => [{:name => "foo", :min_version => "3.0"}, {:min_version => "3.0"}]) # no name
    assert_bad_params(:units => [{:name => "foo", :min_version => "3.0",
                                    :max_version => "4.5", :blah => "33"}]) # invalid param
    assert_bad_params(:units => [{:name => "foo", :min_version => "3.0",
                                  :max_version => "4.5", :version => "33"}]) # version , min max specified

  end

  def test_good_params
    assert_good_params(:units => [{:name => "foo"}, {:name => "bar"}])
    assert_good_params(:units => [{:name => "foo", :min_version => "3.0"},
                                  {:name => "foo", :version => "3.0"},
                                  {:name => "foo*", :max_version => "4.0"}
                      ])
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