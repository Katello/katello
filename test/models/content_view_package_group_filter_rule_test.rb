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
class ContentViewPackageGroupFilterRuleTest < ActiveSupport::TestCase

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentView",
              "ContentViewVersion", "ContentViewEnvironment", "ContentViewFilter",
              "ContentViewPackageGroupFilter", "ContentViewPackageGroupFilterRule"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def setup
    User.current = User.find(users(:admin))
    @rule = FactoryGirl.build(:katello_content_view_package_group_filter_rule)
  end

  def test_create
    assert @rule.save!
    refute_empty ContentViewPackageGroupFilterRule.where(:id => @rule)
  end

  def test_without_uuid
    assert_raises(ActiveRecord::RecordInvalid) do
      @rule.uuid = nil
      @rule.save!
    end
  end

  def test_with_duplicate_uuid
    @rule.save!
    attrs = FactoryGirl.attributes_for(:katello_content_view_package_group_filter_rule,
                                       :uuid => @rule.uuid)

    attrs[:filter] = @rule.filter
    assert_raises(ActiveRecord::RecordInvalid) do
      ContentViewPackageGroupFilterRule.create!(attrs)
    end
    rule_item = ContentViewPackageGroupFilterRule.create(attrs)
    refute rule_item.persisted?
    refute rule_item.save
  end

end
end
