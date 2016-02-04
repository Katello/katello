require 'katello_test_helper'

module Katello
  class ContentViewEnvironmentTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin))
      @content_facet = katello_content_facets(:one)
    end

    def test_for_content_facets
      cve = @content_facet.content_view.content_view_environment(@content_facet.lifecycle_environment)
      assert_includes ContentViewEnvironment.for_content_facets(@content_facet), cve
    end
  end
end
