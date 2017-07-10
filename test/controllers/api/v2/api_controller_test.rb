# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ApiControllerTest < ActionController::TestCase
    include Katello::AuthorizationSupportMethods

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
      assert_equal 4, response[:subtotal], "subtotal"
      assert_equal 4, response[:total], "total"
      assert_equal 1, response[:page], "page"
      assert_equal Setting[:entries_per_page], response[:per_page], "per page"
      assert_nil response[:error], "error"
    end

    def test_scoped_search_full_results_true
      params = { full_result: 'true', per_page: 2 }
      @controller.stubs(:params).returns(params)

      response = @controller.scoped_search(@query, @default_sort[0], @default_sort[1], @options)
      refute_empty response[:results], "results"
      assert_nil response[:error], "error"
      refute_equal(2, response[:results].length)
    end

    def test_scoped_search_full_results_false
      params = { full_result: 'false', per_page: 2 }
      @controller.stubs(:params).returns(params)

      response = @controller.scoped_search(@query, @default_sort[0], @default_sort[1], @options)
      refute_empty response[:results], "results"
      assert_nil response[:error], "error"
      assert_equal(2, response[:results].length)
    end

    def test_scoped_search_no_results
      params = { :search => "asdfasdf" }
      @controller.stubs(:params).returns(params)

      response = @controller.scoped_search(@query, @default_sort[0], @default_sort[1], @options)
      assert_empty response[:results], "results"
      assert_equal 0, response[:subtotal], "subtotal"
      assert_nil response[:error], "error"
    end

    def test_with_reduced_perms
      params = {}
      @controller.stubs(:params).returns(params)
      @default_sort = %w(name desc)

      User.current = users(:restricted)
      key = katello_activation_keys(:simple_key)
      setup_current_user_with_permissions(:name => "view_activation_keys",
                                          :search => "environment = #{key.environment}")

      @options = { :resource_class => Katello::ActivationKey }
      keys = @controller.scoped_search(ActivationKey.readable, @default_sort[0], @default_sort[1], @options)
      assert_includes keys[:results], key
    end

    def test_scoped_search_zero_total
      @query = Erratum.where('1=0')
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
      assert_equal ["RHBA-2014-013", "RHEA-2014-111", "RHEA-2017-007", "RHSA-1999-1231"], results.map(&:errata_id)
    end

    def test_scoped_search_group
      types = Katello::Erratum.pluck(:errata_type).uniq
      4.times do
        Katello::Erratum.create!(:errata_id => "RHRA-#{rand(9999)}", :errata_type => 'security', :uuid => rand(9999).to_s)
      end
      @controller.stubs(:params).returns({})

      @options[:group] = 'errata_type'
      results = @controller.scoped_search(@query, 'errata_type', @default_sort[1], @options)

      assert_equal types.count, results[:subtotal]
      assert_equal types.count, results[:total]
      assert_equal types.sort, results[:results].map { |i| i['errata_type'] }.sort
    end
  end
end
