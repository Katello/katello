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
class ContentViewPackageFilterRuleTest < ActiveSupport::TestCase

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentView",
              "ContentViewEnvironment", "ContentViewFilter",
              "ContentViewPackageFilter", "ContentViewPackageFilterRule"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
  end

  def setup
    User.current = User.find(users(:admin))
    @rule = FactoryGirl.build(:katello_content_view_package_filter_rule)
  end

  def test_create
    assert @rule.save!
    refute_empty ContentViewPackageFilterRule.where(:id => @rule)
  end

  def test_create_without_name
    assert_raises(ActiveRecord::RecordInvalid) do
      @rule.name = nil
      @rule.save!
    end
  end

  def test_with_duplicate_name
    @rule.save!
    attrs = FactoryGirl.attributes_for(:katello_content_view_package_filter_rule,
                                       :name => @rule.name)

    rule_item = ContentViewPackageFilterRule.create(attrs)
    assert rule_item.persisted?
    assert rule_item.save
  end

  def test_version
    @rule.version = "1.0"
    assert @rule.save!
    refute_empty ContentViewPackageFilterRule.where(:id => @rule)
  end

  def test_min_version
    @rule.min_version = "1.0"
    assert @rule.save!
    refute_empty ContentViewPackageFilterRule.where(:id => @rule)
  end

  def test_max_version
    @rule.max_version = "1.0"
    assert @rule.save!
    refute_empty ContentViewPackageFilterRule.where(:id => @rule)
  end

  def test_min_max_version
    @rule.min_version = "1.0"
    @rule.max_version = "2.0"
    assert @rule.save!
    refute_empty ContentViewPackageFilterRule.where(:id => @rule)
  end

  def test_invalid_version
    @rule.version = "1.0"
    @rule.min_version = "2.0"
    assert_raises(ActiveRecord::RecordInvalid) do
      @rule.save!
    end
  end
end
end
