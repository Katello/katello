require 'katello_test_helper'

module Katello
  class ContentViewDockerFilterRuleTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @rule = FactoryBot.build(:katello_content_view_docker_filter_rule)
    end

    def test_create
      assert @rule.save!
      refute_empty ContentViewDockerFilterRule.where(:id => @rule)
    end

    def test_audit_creation
      assert @rule.save!
      auditable_id = @rule.id
      rules_audit = Audit.where(auditable_id: auditable_id)
      assert_equal rules_audit.size, 1
      @rule.update_attribute(:name, @rule.name + 'updated')
      rules_audit = Audit.where(auditable_id: auditable_id)
      assert_equal rules_audit.size, 2
      @rule.destroy
      rules_audit = Audit.where(auditable_id: auditable_id)
      assert_equal rules_audit.size, 3
    end

    def test_create_without_name
      assert_raises(ActiveRecord::RecordInvalid) do
        @rule.name = nil
        @rule.save!
      end
    end

    def test_with_duplicate_name
      @rule.save!
      attrs = FactoryBot.attributes_for(:katello_content_view_docker_filter_rule,
                                         :name => @rule.name)
      ContentViewDockerFilterRule.any_instance.stubs(:create_audit_record).returns({})
      rule_item = ContentViewDockerFilterRule.create(attrs)
      assert rule_item.persisted?
      assert rule_item.save
    end
  end
end
