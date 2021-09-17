require 'katello_test_helper'

module Katello
  class OstreeTest < ActiveSupport::TestCase
    def setup

      @ostree = FactoryBot.create(:katello_repository, :ostree, :with_product)
    end

    def test_created

      assert @ostree
    end
  end
end
