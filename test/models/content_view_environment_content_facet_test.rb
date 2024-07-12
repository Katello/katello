require 'katello_test_helper'

module Katello
  class ContentViewEnvironmentContentFacetTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @content_facet = katello_content_facets(:content_facet_one)
    end

    def test_reprioritize_for_content_facet
      ::Host::Managed.any_instance.stubs(:update_candlepin_associations)
      @content_facet.content_view_environments = [
        katello_content_view_environments(:library_dev_view_dev),
        katello_content_view_environments(:library_dev_staging_view_dev)]
      cve1 = @content_facet.content_view_environments.first
      cve2 = @content_facet.content_view_environments.last
      new_cves = [cve2, cve1]
      ContentViewEnvironmentContentFacet.reprioritize_for_content_facet(@content_facet, new_cves)
      @content_facet.content_view_environments.reload
      assert_equal 1, cve1.priority(@content_facet)
      assert_equal 0, cve2.priority(@content_facet)
    end
  end
end
