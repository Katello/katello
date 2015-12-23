require 'katello_test_helper'

module Katello
  class Api::V2::RootControllerTest < ActionController::TestCase
    def setup
      setup_controller_defaults_api
    end

    def test_resource_list
      get :resource_list

      assert_response :success
    end

    def test_rhsm_resource_list
      results = JSON.parse(get(:rhsm_resource_list).body)

      rhsm_results = results.select { |r| r['href'].start_with?("/rhsm") }
      katello_results = results.select { |r| r['href'].start_with?("/katello") }

      # results are only for rhsm resources
      refute_empty rhsm_results
      assert_empty katello_results

      # href & rel have values
      assert_empty results.select { |r| r['href'].blank? }
      assert_empty results.select { |r| r['rel'].blank? }

      # none hrefs end with an id
      assert_empty rhsm_results.select { |r| r['href'].end_with?(:id) || r['href'].end_with?(:guest_id) }

      # check for a few of the expected routes
      refute_empty rhsm_results.select { |r| r['href'] == "/rhsm/consumers" && r['rel'] == 'consumers' }
      refute_empty rhsm_results.select { |r| r['href'] == "/rhsm/owners/:organization_id/environments" && r['rel'] == 'environments' }
      refute_empty rhsm_results.select { |r| r['href'] == "/rhsm/owners/:organization_id/pools" && r['rel'] == 'pools' }

      assert_response :success
    end
  end
end
