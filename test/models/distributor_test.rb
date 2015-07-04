require 'katello_test_helper'

module Katello
  class DistributorTest < ActiveSupport::TestCase
    def self.after_suite
      super
      Distributor.delete_all
    end

    def setup
      @distributor = Distributor.find(katello_distributors(:acme_distributor))
    end

    def test_update
      assert @distributor.save!
    end
  end
end
