# encoding: utf-8

require "katello_test_helper"

module Katello
  class TestController
    include Concerns::Api::V2::BulkHostsExtensions

    def initialize(params = {})
      @params = params
    end

    attr_reader :params
  end

  class Api::V2::BulkHostsExtensionsTest < ActiveSupport::TestCase
    def models
      @organization = get_organization
      @host1 = hosts(:one)
      @host2 = hosts(:two)
      @host3 = hosts(:without_content_facet)
      @host4 = hosts(:without_subscription_facet)
      @host5 = hosts(:without_errata)
      @host6 = hosts(:without_organization)
    end

    def permissions
      @edit = :edit_hosts
    end

    def setup
      set_user
      models
      permissions
      @controller = TestController.new(organization_id: @organization.id)
    end

    def test_search
      bulk_params = {
        :included => {
          :search => "name = #{@host1.name}"
        }
      }
      result = @controller.find_bulk_hosts(@edit, bulk_params)

      assert_equal result, [@host1]
    end

    def test_search_restrict
      bulk_params = {
        :included => {
          :search => "name ~ host"
        }
      }
      restrict = lambda { |hosts| hosts.where("id != #{@host2.id}") }
      result = @controller.find_bulk_hosts(@edit, bulk_params, restrict)

      assert_includes result, @host1
      refute_includes result, @host2
      assert_includes result, @host3
    end

    def test_search_exclude
      bulk_params = {
        :included => {
          :search => "name ~ host"
        },
        :excluded => {
          :ids => [@host1.id]
        }
      }
      result = @controller.find_bulk_hosts(@edit, bulk_params)

      refute_includes result, @host1
      assert_includes result, @host2
      assert_includes result, @host3
    end

    def test_select_all_hosts_for_errata_apply
      @controller.instance_variable_set(
        :@params,
        {
          :install_all => true
        })
      result = @controller.find_bulk_hosts(@edit, {})

      assert_equal_arrays [@host1, @host2, @host3, @host4, @host5, @host6], result
    end

    def test_no_hosts_specified
      bulk_params = {
        :included => {}
      }

      assert_raises(HttpErrors::BadRequest) do
        @controller.find_bulk_hosts(@edit, bulk_params)
      end
    end

    def test_ids
      bulk_params = {
        :included => {
          :ids => [@host1.id, @host2.id]
        }
      }
      result = @controller.find_bulk_hosts(@edit, bulk_params)

      assert_equal [@host1, @host2].sort, result.sort
    end

    def test_ids_excluded
      bulk_params = {
        :included => {
          :ids => [@host1.id, @host2.id]
        },
        :excluded => {
          :ids => [@host2.id]
        }
      }
      result = @controller.find_bulk_hosts(@edit, bulk_params)

      assert_equal result, [@host1]
    end

    def test_ids_restricted
      bulk_params = {
        :included => {
          :ids => [@host1.id, @host2.id]
        }
      }
      restrict = lambda { |hosts| hosts.where("id != #{@host2.id}") }
      result = @controller.find_bulk_hosts(@edit, bulk_params, restrict)

      assert_equal result, [@host1]
    end

    def test_included_ids_with_nil_scoped_search
      bulk_params = {
        :included => {
          :ids => [@host1.id, @host2.id],
          :search => nil
        }
      }

      result = @controller.find_bulk_hosts(@edit, bulk_params)

      assert_equal [@host1, @host2].sort, result.sort
    end

    def test_ids_with_scoped_search
      bulk_params = {
        :included => {
          :ids => [@host1.id, @host2.id],
          :search => "name != #{@host2.name}"
        }
      }

      result = @controller.find_bulk_hosts(@edit, bulk_params)

      assert_equal result, [@host1]
    end

    def test_forbidden
      bulk_params = {
        :included => {
          :ids => [@host1.id]
        },
        :excluded => {
          :ids => [@host1.id]
        }
      }

      assert_raises(HttpErrors::Forbidden) do
        @controller.find_bulk_hosts(@edit, bulk_params)
      end
    end

    def test_empty_params
      assert_raises(HttpErrors::BadRequest) do
        @controller.find_bulk_hosts(@edit, {})
      end
    end
  end
end
