# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ApiControllerTest < ActionController::TestCase
    def setup
      @controller = Katello::Api::V2::ApiController.new
      @query = Erratum.all
      @default_sort = %w(updated desc)
      @options = { :resource_class => Katello::Erratum }
      @errata = katello_errata
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

    def test_scoped_search_order
      params = {:sort_by => "errata_id", :sort_order => "DESC'"} # sql injection
      @controller.stubs(:params).returns(params)

      query = Erratum.all
      options = {resource_class: Katello::Erratum}

      results = @controller.scoped_search(query, "errata_id", "asc", options)[:results]
      assert_equal ["RHBA-2014-013", "RHEA-2014-111", "RHSA-1999-1231"], results.map(&:errata_id)
    end
  end
end
