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
      assert_equal 6, response[:subtotal], "subtotal"
      assert_equal 6, response[:total], "total"
      assert_equal 6, response[:selectable], "selectable"
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
      assert_equal 0, response[:selectable], "selectable"
      assert_nil response[:error], "error"
    end

    def test_with_reduced_perms
      params = {}
      @controller.stubs(:params).returns(params)
      @default_sort = %w(name desc)

      User.current = users(:restricted)
      key = katello_activation_keys(:simple_key)
      setup_current_user_with_permissions({ :name => "view_activation_keys",
                                            :search => "environment = #{key.environment}" })

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
      assert_equal ["RHBA-2014-013", "RHEA-2014-111", "RHEA-2017-007", "RHEA-2019-002", "RHEA-2022-007", "RHSA-1999-1231"], results.map(&:errata_id)
    end

    def test_scoped_search_order_via_hammer_order
      params = {:order => "errata_id DESC"}
      @controller.stubs(:params).returns(params)

      query = Erratum.all
      options = {resource_class: Katello::Erratum}

      results = @controller.scoped_search(query, "errata_id", "desc", options)[:results]
      assert_equal ["RHBA-2014-013", "RHEA-2014-111", "RHEA-2017-007", "RHEA-2019-002", "RHEA-2022-007", "RHSA-1999-1231"].sort.reverse, results.map(&:errata_id)
    end

    def test_scoped_search_invalid_column
      bad_column = "booo"
      params = {:order => "#{bad_column} DESC"}
      @controller.stubs(:params).returns(params)

      query = Erratum.all
      options = {resource_class: Katello::Erratum}

      # It should raise an error identifying the sort column
      results = @controller.scoped_search(query, "errata_id", "desc", options)
      refute results[:error].blank?
      assert_includes results[:error], bad_column
      assert_equal [], results[:results]
      assert_equal 0, results[:subtotal]
      assert_equal 0, results[:total]
      assert_nil results[:page]
      assert_nil results[:per_page]
    end

    def test_scoped_search_group
      types = Katello::Erratum.pluck(:errata_type).uniq
      4.times do
        Katello::Erratum.create!(:errata_id => "RHRA-#{rand(9999)}", :errata_type => 'security', :pulp_id => rand(9999).to_s)
      end
      @controller.stubs(:params).returns({})

      @options[:group] = 'errata_type'
      results = @controller.scoped_search(@query, 'errata_type', @default_sort[1], @options)

      assert_equal types.count, results[:subtotal]
      assert_equal types.count, results[:total]
      assert_equal types.count, results[:selectable]
      assert_equal types.sort, results[:results].map { |i| i['errata_type'] }.sort
    end

    def test_scoped_search_not_supported_error
      @controller.stubs(:params).returns({})
      error_message = 'invalid query'
      @controller.stubs(:scoped_search_total).raises(ScopedSearch::QueryNotSupported.new(error_message))

      results = @controller.scoped_search(@query, 'errata_type', @default_sort[1], @options)

      assert_equal [], results[:results]
      assert_equal 0, results[:subtotal]
      assert_equal 0, results[:total]
      assert_nil results[:page]
      assert_nil results[:per_page]
      assert_equal error_message, results[:error]
    end

    def test_scoped_search_statement_invalid_error
      @controller.stubs(:params).returns({})
      @controller.stubs(:scoped_search_total).raises(ActiveRecord::StatementInvalid.new('invalid statement'))
      error_message = 'Your search query was invalid. Please revise it and try again. The full error has been sent to the application logs.'

      results = @controller.scoped_search(@query, 'errata_type', @default_sort[1], @options)

      assert_equal [], results[:results]
      assert_equal 0, results[:subtotal]
      assert_equal 0, results[:total]
      assert_nil results[:page]
      assert_nil results[:per_page]
      assert_equal error_message, results[:error]
    end

    def test_scoped_search_csv_query
      params = {}
      @controller.stubs(:params).returns(params)

      query = Pool.all
      options = {resource_class: Katello::Pool, csv: true}

      results = @controller.scoped_search(query, nil, nil, options)
      assert_equal results.sort, query.sort
    end
  end
end
