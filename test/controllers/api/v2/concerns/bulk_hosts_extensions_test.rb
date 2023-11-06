# encoding: utf-8

require "katello_test_helper"

module Katello
  class TestController
    # this now tests the bulk hosts extension that was moved to Foreman
    include ::Api::V2::BulkHostsExtension

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

    def test_select_all_hosts_for_errata_apply_bastion
      # bastion sends the install_all param
      @controller.instance_variable_set(
        :@params,
        {
          :install_all => true
        })
      result = @controller.find_bulk_hosts(@edit, {})

      assert_equal_arrays [@host1, @host2, @host3, @host4, @host5, @host6], result
    end
  end
end
