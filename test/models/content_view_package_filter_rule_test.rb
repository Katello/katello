require 'katello_test_helper'

module Katello
  class ContentViewPackageFilterRuleTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
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

    def test_duplicate_version_error
      attrs = FactoryGirl.attributes_for(:katello_content_view_package_filter_rule,
                                         :name => @rule.name,
                                         :version => @rule.version,
                                         :content_view_filter_id => @rule.content_view_filter_id,
                                         :min_version => @rule.min_version,
                                         :max_version => @rule.max_version)
      @rule.save!
      rule_item = ContentViewPackageFilterRule.create(attrs)
      assert_raises(ActiveRecord::RecordInvalid) do
        rule_item.save!
      end
    end
  end
end
