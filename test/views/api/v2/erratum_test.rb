require 'katello_test_helper'

module Katello
  class ErratumViewTest < ActiveSupport::TestCase
    def setup
      @erratum = katello_errata(:security)
    end

    def test_show
      assert_service_not_used(Pulp::Erratum) do
        render_rabl('katello/api/v2/errata/show.json', @erratum)
      end
    end
  end
end
