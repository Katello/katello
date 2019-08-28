require 'katello_test_helper'

module Katello
  class ContentViewPackageFilterTest < ActiveSupport::TestCase
    def setup
      @one_package_rule = katello_content_view_package_filter_rules(:one_package_rule)
      @one_package_rule_empty_strings = katello_content_view_package_filter_rules(:one_package_rule_empty_strings)
      @filter = katello_content_view_filters(:simple_filter)
      @fedora = katello_repositories(:fedora_17_x86_64)
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
      matched_rpms = @filter.query_rpms(@fedora, @one_package_rule_empty_strings)
      assert matched_rpms.length > 0
    end
  end
end
