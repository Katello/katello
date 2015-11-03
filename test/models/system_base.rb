require 'katello_test_helper'

module Katello
  class SystemTestBase < ActiveSupport::TestCase
    def setup
      configure_runcible
      @acme_corporation   = get_organization

      @fedora             = Product.find(katello_products(:fedora).id)
      @dev                = KTEnvironment.find(katello_environments(:dev).id)
      @library            = KTEnvironment.find(katello_environments(:library).id)
      @library_view       = ContentView.find(katello_content_views(:library_view))
      @acme_default       = ContentView.find(katello_content_views(:acme_default))
      @library_dev_staging_view   = ContentView.find(katello_content_views(:library_dev_staging_view))
      @system             = System.find(katello_systems(:simple_server))
      @errata_system      = System.find(katello_systems(:errata_server))
    end
  end
end
