require 'katello_test_helper'

module Katello
  class OstreeTest < ActiveSupport::TestCase
    def setup
      skip "TODO: Until the ostree support is present in pulp packaging"
      @ostree = FactoryBot.create(:katello_repository, :ostree, :with_product)
    end

    def test_created
      skip "TODO: Until the ostree support is present in pulp packaging"
      assert @ostree
    end
  end
end
