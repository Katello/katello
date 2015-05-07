require 'katello_test_helper'

module Katello
  class ContentViewEnvironmentTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin))
      @system = Katello::System.find(katello_systems(:simple_server))
    end

    def test_for_systems
      cve = @system.content_view.content_view_environment(@system.environment)
      assert_include ContentViewEnvironment.for_systems(@system), cve
    end
  end
end
