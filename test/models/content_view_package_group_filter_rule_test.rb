require 'katello_test_helper'

module Katello
  class ContentViewPackageGroupFilterRuleTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
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
