require 'katello_test_helper'

module Katello
  class ContentViewDockerFilterRuleTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @rule = FactoryGirl.build(:katello_content_view_docker_filter_rule)
    end

    def test_create
      assert @rule.save!
      refute_empty ContentViewDockerFilterRule.where(:id => @rule)
    end

    def test_create_without_name
      assert_raises(ActiveRecord::RecordInvalid) do
        @rule.name = nil
        @rule.save!
      end
    end

    def test_with_duplicate_name
      @rule.save!
      attrs = FactoryGirl.attributes_for(:katello_content_view_docker_filter_rule,
                                         :name => @rule.name)

      rule_item = ContentViewDockerFilterRule.create(attrs)
      assert rule_item.persisted?
      assert rule_item.save
    end
  end
end
