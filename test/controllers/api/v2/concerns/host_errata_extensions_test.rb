# encoding: utf-8

require "katello_test_helper"

module Katello
  class TestController
    include Concerns::Api::V2::HostErrataExtensions
  end

  module Concerns
    class Api::V2::HostErrataExtensionsTest < ActiveSupport::TestCase
      def setup
        @hosts = ::Host.all
        @controller = TestController.new
      end

      test 'sending create with included ids yields those errata ids' do
        ::Katello::Erratum.stubs(:installable_for_hosts).returns(::Katello::Erratum.all)

        bulk_params = { included: { ids: ['RHSA-1999-1231', 'RHEA-2014-111'] }}.to_json
        result = @controller.find_bulk_errata_ids(@hosts, bulk_params)

        assert_equal ["RHSA-1999-1231", "RHEA-2014-111"].sort, result.sort
      end

      test 'sending create with included search yields those errata ids' do
        ::Katello::Erratum.stubs(:installable_for_hosts).returns(::Katello::Erratum.all)

        bulk_params = { included: { search: 'type=security' }}.to_json
        @hosts = hosts(:one)

        result = @controller.find_bulk_errata_ids(@hosts, bulk_params)

        assert_equal ["DEBIAN-1-1", "DEBIAN-2-1", "RHSA-1999-1231"].sort, result.sort
      end
    end
  end
end
