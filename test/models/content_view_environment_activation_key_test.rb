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
        katello_content_view_environments(:library_dev_staging_view_dev),
      ]

      cvenv1 = @activation_key.content_view_environments.first
      cvenv2 = @activation_key.content_view_environments.last
      new_cvenvs = [cvenv2, cvenv1]
      ContentViewEnvironmentActivationKey.reprioritize_for_activation_key(@activation_key, new_cvenvs)
      @activation_key.content_view_environments.reload
      assert_equal 1, cvenv1.priority(@activation_key)
      assert_equal 0, cvenv2.priority(@activation_key)
    end

    def test_content_view_environments_deduplicates
      Setting['allow_multiple_content_views'] = true
      cvenv1 = katello_content_view_environments(:library_dev_view_dev)
      cvenv2 = katello_content_view_environments(:library_dev_staging_view_dev)
      @activation_key.content_view_environments = [cvenv1, cvenv2, cvenv1]
      assert_equal [cvenv1, cvenv2], @activation_key.content_view_environments.reload.to_a
    end

    def test_content_view_environments_deduplicates_preserves_order
      Setting['allow_multiple_content_views'] = true
      cvenv1 = katello_content_view_environments(:library_dev_view_dev)
      cvenv2 = katello_content_view_environments(:library_dev_staging_view_dev)
      # uniq keeps first occurrence, so reversed duplicates keep cvenv2 first
      @activation_key.content_view_environments = [cvenv2, cvenv1, cvenv2]
      assert_equal [cvenv2, cvenv1], @activation_key.content_view_environments.reload.to_a
    end

    def test_content_view_environment_ids_deduplicates
      Setting['allow_multiple_content_views'] = true
      cvenv1 = katello_content_view_environments(:library_dev_view_dev)
      cvenv2 = katello_content_view_environments(:library_dev_staging_view_dev)
      @activation_key.content_view_environment_ids = [cvenv1.id, cvenv2.id, cvenv1.id]
      assert_equal [cvenv1, cvenv2], @activation_key.content_view_environments.reload.to_a
    end

    def test_uniqueness_of_content_view_environment_per_activation_key
      cvenv = katello_content_view_environments(:library_dev_view_dev)
      @activation_key.content_view_environments = [cvenv]
      duplicate = ContentViewEnvironmentActivationKey.new(
        activation_key: @activation_key,
        content_view_environment: cvenv
      )
      refute duplicate.valid?
      assert_includes duplicate.errors[:content_view_environment_id], "has already been taken for this activation key"
    end
  end
end
