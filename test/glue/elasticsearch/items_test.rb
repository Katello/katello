require 'katello_test_helper'

module Katello
  class GlueElasticSearchTest < ActiveSupport::TestCase
    def setup
      @fake_class = Class.new do
        def self.search
          {}
        end

        def self.where(*_args)
          {}
        end

        def self.mapping(*_args)
          {}
        end
      end

      @results = MiniTest::Mock.new
      @results.expect(:class, 0)
      @results.expect(:empty?, true)

      @items = Glue::ElasticSearch::Items.new(@fake_class)
    end

    def test_items
      @results.expect(:total, 0)
      @results.expect(:total, 0)
      @results.expect(:subtotal, 0)
      @results.expect(:results, [])
      @results.expect(:facets, {})

      @fake_class.expects(:search).twice.returns(@results)
      items, count = @items.retrieve("*")

      assert_empty items
      assert_equal 0, count
    end

    def test_load_records
      @results.expect(:length, 0)
      @results.expect(:order, [], [[]])

      @fake_class.expects(:where).returns(@results)
      @items.results = []
      items = @items.load_records

      assert_empty items
    end

    def test_total_items
      @results.expect(:total, 10)

      @fake_class.expects(:search).returns(@results)
      total = @items.total_items

      assert_equal 10, total
    end
  end
end
