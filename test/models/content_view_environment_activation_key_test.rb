require 'katello_test_helper'

module Katello
  class ContentViewEnvironmentActivationKeyTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @activation_key = katello_activation_keys(:simple_key)
    end

    def teardown
      Setting['allow_multiple_content_views'] = false
    end

    def test_reprioritize_for_activation_key
      Setting['allow_multiple_content_views'] = true
      @activation_key.content_view_environments = [
        katello_content_view_environments(:library_dev_view_dev),
        katello_content_view_environments(:library_dev_staging_view_dev)]

      cve1 = @activation_key.content_view_environments.first
      cve2 = @activation_key.content_view_environments.last
      new_cves = [cve2, cve1]
      ContentViewEnvironmentActivationKey.reprioritize_for_activation_key(@activation_key, new_cves)
      @activation_key.content_view_environments.reload
      assert_equal 1, cve1.priority(@activation_key)
      assert_equal 0, cve2.priority(@activation_key)
    end
  end
end
