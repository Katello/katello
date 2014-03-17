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
class ContentViewErratumFilterRuleTest < ActiveSupport::TestCase

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentView",
              "ContentViewEnvironment", "ContentViewFilter",
              "ContentViewErratumFilter", "ContentViewErratumFilterRule"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
  end

  def setup
    User.current = User.find(users(:admin))

    @rule = FactoryGirl.build(:katello_content_view_erratum_filter_rule)

    @start_date = "2013-01-01"
    @end_date = "2013-01-31"
  end

  def test_create
    assert @rule.save!
    refute_empty ContentViewErratumFilterRule.where(:id => @rule)
  end

  def test_create_empty
    # user needs to specify errata_id or one of: start_date, end_date, types
    @rule.errata_id = nil
    @rule.start_date = nil
    @rule.end_date = nil
    @rule.types = nil
    assert_raises(ActiveRecord::RecordInvalid) do
      @rule.save!
    end
  end

  def test_invalid_parameters
    # user may only specify id or (start_date, end_date, types)
    refute_nil @rule.errata_id
    @rule.start_date = @start_date
    @rule.end_date = @end_date
    @rule.types = ["bugfix", "enhancement", "security"]
    assert_raises(ActiveRecord::RecordInvalid) do
      @rule.save!
    end
  end

  def test_with_duplicate_errata_id
    @rule.save!

    rule2 = FactoryGirl.build(:katello_content_view_erratum_filter_rule)
    rule2.errata_id = @rule.errata_id
    rule2.filter = @rule.filter

    assert_raises(ActiveRecord::RecordInvalid) do
      rule2.save!
    end
    refute rule2.save
  end

  def test_start_date
    @rule.errata_id = nil
    @rule.start_date = @start_date
    assert @rule.save!
    refute_empty ContentViewErratumFilterRule.where(:id => @rule)
  end

  def test_end_date
    @rule.errata_id = nil
    @rule.end_date = @end_date
    assert @rule.save!
    refute_empty ContentViewErratumFilterRule.where(:id => @rule)
  end

  def test_start_end_date
    @rule.errata_id = nil
    @rule.start_date = @start_date
    @rule.end_date = @end_date
    assert @rule.save!
    refute_empty ContentViewErratumFilterRule.where(:id => @rule)
  end

  def test_invalid_date_range
    @rule.errata_id = nil
    @rule.start_date = @end_date
    @rule.end_date = @start_date
    assert_raises(ActiveRecord::RecordInvalid) do
      @rule.save!
    end
  end

  def test_invalid_type
    @rule.errata_id = nil
    @rule.types = ["enhancement", "invalid"]
    @rule.end_date = @start_date
    assert_raises(ActiveRecord::RecordInvalid) do
      @rule.save!
    end
  end
end
end
