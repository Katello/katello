require 'katello_test_helper'

module Katello
  class ContentViewModuleStreamFilterRuleTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @module_stream = katello_module_streams(:one)
      @rule = FactoryBot.build(:katello_content_view_module_stream_filter_rule, module_stream: @module_stream)
    end

    def test_create
      assert @rule.save!
      refute_empty ContentViewModuleStreamFilterRule.where(:id => @rule)
    end

    def test_create_empty
      # user needs to specify both name and stream
      @rule.module_stream = nil
      assert_raises(ActiveRecord::RecordInvalid) do
        @rule.save!
      end
    end

    def test_with_duplicated_module_stream
      @rule.save!

      rule2 = FactoryBot.build(:katello_content_view_module_stream_filter_rule)
      rule2.module_stream = @rule.module_stream
      rule2.filter = @rule.filter

      assert_raises(ActiveRecord::RecordInvalid) do
        rule2.save!
      end
      refute rule2.save
    end
  end
end
