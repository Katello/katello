# encoding: utf-8

require 'katello_test_helper'

module Katello
  class ContentViewFilterVersionValidatorTest < ActiveSupport::TestCase
    def setup
      User.current = User.first
      @validator = Validators::ContentViewFilterVersionValidator.new({})
      @filter = FactoryGirl.create(:katello_content_view_package_filter)
    end

    test "fails if version and min_version provided" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id,
                                               :version => '1.0', :min_version => '1.0')
      @validator.validate(model)
      refute_empty model.errors[:base]
    end

    test "fails if version and max_version provided" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id,
                                               :version => '1.0', :max_version => '5.0')
      @validator.validate(model)
      refute_empty model.errors[:base]
    end

    test "fails if version, min_version and max_version provided" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id, :version => '1.0',
                                               :min_version => '1.0', :max_version => '5.0')
      @validator.validate(model)
      refute_empty model.errors[:base]
    end

    test "passes with version" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id, :version => '1.0')
      @validator.validate(model)
      assert_empty model.errors[:base]
    end

    test "passes with min_version" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id, :min_version => '1.0')
      @validator.validate(model)
      assert_empty model.errors[:base]
    end

    test "passes with max_version" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id, :max_version => '5.0')
      @validator.validate(model)
      assert_empty model.errors[:base]
    end

    test "passes with min_version and max_version" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id,
                                               :min_version => '1.0', :max_version => '5.0')
      @validator.validate(model)
      assert_empty model.errors[:base]
    end
  end
end
