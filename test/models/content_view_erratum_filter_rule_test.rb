require 'katello_test_helper'

module Katello
  class ContentViewErratumFilterRuleTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)

      @rule = FactoryBot.build(:katello_content_view_erratum_filter_rule, :errata_id => '1')

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

      rule2 = FactoryBot.build(:katello_content_view_erratum_filter_rule)
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

    def test_default_types_with_errata_id
      # if an errata_id is set, then types is left empty
      @rule.save!
      assert_empty @rule.types
    end

    def test_default_types_with_types
      # if an errata_id is not set and types is set, that value is stored
      @rule.errata_id = nil
      @rule.start_date = @start_date
      @rule.types = ['enhancement']
      @rule.save!
      assert_equal @rule.types, ['enhancement']
    end

    def test_default_types_without_types
      # if an errata_id is not set and types is not set, they will be set by default
      @rule.errata_id = nil
      @rule.start_date = @start_date
      @rule.save!
      assert_equal @rule.types, ContentViewErratumFilter::ERRATA_TYPES.keys
    end
  end
end
