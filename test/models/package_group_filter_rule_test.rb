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

require 'katello_test_helper'

module Katello
class PackageGroupFilterRuleTest < ActiveSupport::TestCase

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentView",
              "ContentViewEnvironment", "Filter", "PackageGroupFilter",
              "PackageGroupFilterRule"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def setup
    User.current = User.find(users(:admin))
    @rule = FactoryGirl.build(:katello_package_group_filter_rule)
  end

  def test_create
    assert @rule.save!
    refute_empty PackageGroupFilterRule.where(:id => @rule)
  end

  def test_without_name
    assert_raises(ActiveRecord::RecordInvalid) do
      @rule.name = nil
      @rule.save!
    end
  end

  def test_with_duplicate_name
    @rule.save!
    attrs = FactoryGirl.attributes_for(:katello_package_filter_rule, :name => @rule.name)
    assert_raises(ActiveRecord::RecordInvalid) do
      PackageGroupFilterRule.create!(attrs)
    end
    rule_item = PackageGroupFilterRule.create(attrs)
    refute rule_item.persisted?
    refute rule_item.save
  end

end
end
