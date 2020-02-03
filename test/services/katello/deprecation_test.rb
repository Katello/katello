require 'katello_test_helper'

module Katello
  class DeprecationTest < ActiveSupport::TestCase
    # Ensures that we actually remove deprecated behavior when we say we will. If this fails on a version bump,
    # please remove the code associated with the deprecation and the deprecation warning itself.
    def test_deprecations_have_been_removed
      katello_version = Katello::VERSION
      Katello::Deprecation.deprecations.each do |dep_key, dep|
        assert_not_nil dep[:removal_version]
        msg = "Deprecation warning #{dep_key} is marked for removal in #{dep[:removal_version]}, which "\
              "is less than or equal to the current Katello version of #{katello_version}."
        assert(Gem::Version.new(katello_version) <= Gem::Version.new(dep[:removal_version]) , msg)
      end
    end

    def test_api_deprecation_warning
      test_warning = {
        removal_version: 100.0,
        item: "Hamburger",
        action_message: "Please use Cheeseburger instead"
      }
      Katello::Deprecation.expects(:deprecations).returns({this_is_a_test: test_warning })
      dep_warning = Katello::Deprecation.api_deprecation_warning(:this_is_a_test)

      assert_includes dep_warning, test_warning[:removal_version].to_s
      assert_includes dep_warning, test_warning[:item]
      assert_includes dep_warning, test_warning[:action_message]
      assert_includes dep_warning, "will be removed"
    end
  end
end