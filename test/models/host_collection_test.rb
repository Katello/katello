require 'katello_test_helper'

module Katello
  class HostCollectionTest < ActiveSupport::TestCase
    def setup
      @simple_collection = katello_host_collections(:simple_host_collection)
      @host_one = hosts(:one)
      @host_two = hosts(:two)
    end

    def test_search_by_name
      assert_equal HostCollection.search_for("name = \"#{@simple_collection.name}\""), [@simple_collection]
      assert_equal HostCollection.search_for("name = \"unknown collection\""), []
    end

    def test_search_by_host
      assert_equal HostCollection.search_for("host = \"#{@host_one.name}\""), [@simple_collection]
      assert_equal HostCollection.search_for("host = \"#{@host_two.name}\""), []
    end
  end
end
