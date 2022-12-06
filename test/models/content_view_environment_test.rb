require 'katello_test_helper'

module Katello
  class ContentViewEnvironmentTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @content_facet = katello_content_facets(:content_facet_one)
    end

    def test_for_content_facets
      cve = @content_facet.content_view_environments.first
      assert_includes ContentViewEnvironment.for_content_facets(@content_facet), cve
    end

    def test_hosts
      library = katello_environments(:library)
      view = katello_content_views(:library_dev_view)
      host = FactoryBot.create(:host, :with_content, :content_view => view,
                                       :lifecycle_environment => library)
      cve = Katello::ContentViewEnvironment.where(:environment_id => library, :content_view_id => view).first

      assert_includes cve.hosts, host
    end
  end
end
