require 'katello_test_helper'

module Katello
  class Api::V2::ApiControllerTest < ActionController::TestCase
    def setup
      katello_errata
      @controller = Katello::Api::V2::ApiController.new
      @query = Erratum.all
      @default_sort = %w(updated desc)
      @options = { :resource_class => Katello::Erratum }
    end

    def teardown
      @controller = nil
      @query = nil
      @default_sort = nil
      @options = nil
    end

    def test_scoped_search
      params = {}
      @controller.stubs(:params).returns(params)

      response = @controller.scoped_search(@query, @default_sort[0], @default_sort[1], @options)
      refute_empty response[:results], "results"
      assert_equal 3, response[:subtotal], "subtotal"
      assert_equal 3, response[:total], "total"
      assert_equal 1, response[:page], "page"
      assert_equal ::Setting::General.entries_per_page, response[:per_page], "per page"
      assert_nil response[:error], "error"
    end

    def test_scoped_search_no_results
      params = { :search => "asdfasdf" }
      @controller.stubs(:params).returns(params)

      response = @controller.scoped_search(@query, @default_sort[0], @default_sort[1], @options)
      assert_empty response[:results], "results"
      assert_equal 0, response[:subtotal], "subtotal"
      assert_nil response[:error], "error"
    end

    def test_scoped_search_zero_total
      @query = []
      params = {}
      @controller.stubs(:params).returns(params)

      response = @controller.scoped_search(@query, @default_sort[0], @default_sort[1], @options)
      assert_empty response[:results], "results"
      assert_equal 0, response[:subtotal], "subtotal"
      assert_equal 0, response[:total], "total"
      assert_nil response[:error], "error"
    end
  end
end
