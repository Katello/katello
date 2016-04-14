# encoding: utf-8

require 'katello_test_helper'

module Katello
  class ContentViewErratumFilterRuleValidatorTest < ActiveSupport::TestCase
    def setup
      User.current = User.first
      @validator = Validators::ContentViewErratumFilterRuleValidator.new({})
      @filter = FactoryGirl.create(:katello_content_view_erratum_filter)
    end

    test "fails if no parameters are provided" do
      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id)
      @validator.validate(model)
      refute_empty model.errors[:base]
    end

    test "passes with errata_id" do
      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id, :errata_id => "RHSA-2014:1234")
      @validator.validate(model)
      assert_empty model.errors[:base]
    end

    test "fails with start_date or end_date, if already has a rule" do
      rule1 = FactoryGirl.create(:katello_content_view_erratum_filter_rule, :errata_id => '1')
      Katello::ContentViewErratumFilter.any_instance.stubs(:erratum_rules).returns([rule1])

      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id, :start_date => '2014/01/20')
      @validator.validate(model)
      refute_empty model.errors[:base]

      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id, :end_date => '2014/09/30')
      @validator.validate(model)
      refute_empty model.errors[:base]
    end

    test "fails with errata_id, if already has a date range" do
      Katello::ContentViewErratumFilterRule.any_instance.stubs(:filter_has_date_or_type_rule?).returns(true)
      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id, :errata_id => "RHSA-2014:1234")
      @validator.validate(model)
      refute_empty model.errors[:base]
    end

    test "passes with either start_date or end_date" do
      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id, :start_date => '2014/01/20')
      @validator.validate(model)
      assert_empty model.errors[:base]

      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id, :end_date => '2014/09/30')
      @validator.validate(model)
      assert_empty model.errors[:base]
    end

    test "passes with valid date range" do
      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id,
                                               :start_date => '2010/01/20', :end_date => '2014/01/20')
      @validator.validate(model)
      assert_empty model.errors[:base]
    end

    test "fails with invalid date range" do
      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id,
                                               :start_date => '2014/01/20', :end_date => '2010/01/20')
      @validator.validate(model)
      refute_empty model.errors[:base]
    end

    test "passes with valid types" do
      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id,
                                               :types => ['security', 'enhancement', 'bugfix'])
      @validator.validate(model)
      assert_empty model.errors[:base]
    end

    test "fails with invalid types" do
      model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id, :types => ['invalid'])
      @validator.validate(model)
      refute_empty model.errors[:base]

      assert_raises(ActiveRecord::SerializationTypeMismatch) do
        model = ContentViewErratumFilterRule.new(:content_view_filter_id => @filter.id, :types => 'invalid')
      end
    end
  end
end
