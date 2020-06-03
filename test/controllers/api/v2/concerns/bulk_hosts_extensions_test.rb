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
      @host1 = FactoryBot.create(:host, organization: @organization)
      @host2 = FactoryBot.create(:host, organization: @organization)
      @host3 = FactoryBot.create(:host, organization: @organization)
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

      assert_includes result, @host1
      refute_includes result, @host2
      refute_includes result, @host3
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

    def test_ids
      bulk_params = {
        :included => {
          :ids => [@host1.id, @host2.id]
        }
      }
      result = @controller.find_bulk_hosts(@edit, bulk_params)

      assert_includes result, @host1
      assert_includes result, @host2
      refute_includes result, @host3
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

      assert_includes result, @host1
      refute_includes result, @host2
      refute_includes result, @host3
    end

    def test_ids_restricted
      bulk_params = {
        :included => {
          :ids => [@host1.id, @host2.id]
        }
      }
      restrict = lambda { |hosts| hosts.where("id != #{@host2.id}") }
      result = @controller.find_bulk_hosts(@edit, bulk_params, restrict)

      assert_includes result, @host1
      refute_includes result, @host2
      refute_includes result, @host3
    end
  end
end
