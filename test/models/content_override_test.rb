require 'katello_test_helper'

module Katello
  class ContentOverrideTest < ActiveSupport::TestCase
    def test_new
      label = "boo"
      value = 1
      override = ContentOverride.new(label)

      assert_nil override.name
      assert_nil override.value

      override.enabled = value

      assert_equal "enabled", override.name
      assert_equal value, override.value
      assert_equal label, override.content_label

      label2 = "bar"
      override2 = ContentOverride.new(label2, :enabled => 0)

      assert_equal "enabled", override2.name
      assert_equal 0, override2.value
      assert_equal label2, override2.content_label
    end

    def test_to_entitlement_hash
      label = "boo"
      value = 1
      override = ContentOverride.new(label)
      override.enabled = value
      assert_equal({"contentLabel" => label, "value" => value, "name" => "enabled"}, override.to_entitlement_hash)

      override.enabled = 0
      assert_equal({"contentLabel" => label, "value" => 0, "name" => "enabled"}, override.to_entitlement_hash)

      override.enabled = nil
      assert_equal({"contentLabel" => label, "name" => "enabled"}, override.to_entitlement_hash)

      override.name = nil
      assert_equal({"contentLabel" => label}, override.to_entitlement_hash)
    end

    def test_from_entitlement_hash
      label = "boo"
      value = 1
      override = ContentOverride.new(label)
      override.enabled = value
      assert_equal(override, ContentOverride.from_entitlement_hash(override.to_entitlement_hash))

      override.enabled = 0
      assert_equal(override, ContentOverride.from_entitlement_hash(override.to_entitlement_hash))

      override.name = "mirrorlist"
      assert_equal(override, ContentOverride.from_entitlement_hash(override.to_entitlement_hash))
    end

    def test_to_hash
      label = "boo"
      value = 1
      override = ContentOverride.new(label)
      override.enabled = value
      assert_equal({"content_label" => label, "value" => value, "name" => "enabled"}, override.to_hash)

      override.enabled = 0
      assert_equal({"content_label" => label, "value" => 0, "name" => "enabled"}, override.to_hash)

      override.enabled = nil
      assert_equal({"content_label" => label, "name" => "enabled", "value" => nil}, override.to_hash)

      override.name = nil
      assert_equal({"content_label" => label, "name" => nil, "value" => nil}, override.to_hash)
    end

    def test_fetch_from_hash
      label = "boo"
      value = 1
      override = ContentOverride.new(label)
      assert_equal(override, ContentOverride.fetch(override))

      override.enabled = value
      assert_equal(override, ContentOverride.fetch(override.to_hash))

      override.enabled = 0
      assert_equal(override, ContentOverride.fetch(override.to_hash))

      override.name = "mirrorlist"
      assert_equal(override, ContentOverride.fetch(override.to_hash))
    end
  end
end
