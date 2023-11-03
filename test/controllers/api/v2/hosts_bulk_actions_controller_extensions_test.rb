require 'katello_test_helper'

module Katello
  # testing Katello's overrides of Foreman's HostsBulkActionsController
  class Api::V2::HostsBulkActionsControllerExtensionsTest < ActionController::TestCase
    tests ::Api::V2::HostsBulkActionsController
    def setup
      @host1 = hosts(:one)
      @host2 = hosts(:two)
    end

    def test_bulk_destroy
      Katello::RegistrationManager.expects(:unregister_host).twice
      delete :bulk_destroy, params: { :search => "id ^ (#{[@host1.id, @host2.id].join(',')})" }
      assert_response :success
    end
  end
end
