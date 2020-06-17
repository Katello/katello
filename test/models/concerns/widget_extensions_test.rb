# encoding: utf-8

require 'katello_test_helper'

module Katello
  class WidgetExtensionsTest < ActiveSupport::TestCase
    def setup
      Organization.current = get_organization(:empty_organization)
    end

    def test_available_scope
      Widget.stubs(:available).returns(Widget.all)
      assert_equal 0, Widget.available.count
    end
  end
end
