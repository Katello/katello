require 'katello_test_helper'

module Katello
  class ContentViewPackageFilterRuleTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @rule = FactoryBot.build(:katello_content_view_package_filter_rule)
      @one_package_rule = katello_content_view_package_filter_rules(:one_package_rule)
      @one_package_rule_empty_string = katello_content_view_package_filter_rules(:one_package_rule_empty_string_arch)
      @filter = katello_content_view_filters(:simple_filter)
      @fedora = katello_repositories(:fedora_17_x86_64)
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
      attrs = FactoryBot.attributes_for(:katello_content_view_package_filter_rule,
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
      attrs = FactoryBot.attributes_for(:katello_content_view_package_filter_rule,
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

    def test_query_rpms
      matched_rpms = @filter.query_rpms(@fedora, @one_package_rule)
      assert matched_rpms.length > 0

      all_applicable_rpms = @filter.applicable_repos.map(&:rpms).flatten.pluck(:filename)
      matched_rpms.each do |rpm|
        assert_includes all_applicable_rpms, rpm
      end
    end

    def test_rule_with_empty_string_arch_matched
      matched_rpms = @filter.query_rpms(@fedora, @one_package_rule_empty_string)
      assert matched_rpms.length > 0
    end
  end
end
