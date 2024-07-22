require 'katello_test_helper'

module Katello
  class RemoteExecutionControllerTest < ActionController::TestCase
    def setup
      setup_controller_defaults
      login_user(User.find(users(:admin).id))
      models
      permissions

      @mock_composer = mock
      @mock_composer.stubs(:save).returns(:true)
      @mock_composer.stubs(:trigger).returns(:true)
      @mock_composer.stubs(:job_invocation).returns(::JobInvocation.new)
      @mock_composer.stubs(:rerun_possible?).returns(true)
      @mock_composer.stubs(:available_job_categories).returns([])
      @mock_composer.stubs(:remote_execution_feature_id).returns(1)
      @mock_composer.stubs(:displayed_provider_types).returns([])

      RemoteExecutionController.any_instance.stubs(:prepare_composer).returns(@mock_composer)
    end

    def test_customized_errata_install_shows_new
      bulk_host_ids =
        {
          included: {
            ids: [hosts(:one).id],
          },
        }.to_json

      post :create, params: {
        :remote_action => "errata_install",
        bulk_host_ids: bulk_host_ids, customize: true }

      assert_response :found
    end

    def test_customized_errata_install_with_install_all_shows_new
      bulk_host_ids =
        {
          included: {
            ids: [hosts(:one).id],
          },
        }.to_json

      post :create, params: {
        :remote_action => "errata_install",
        bulk_host_ids: bulk_host_ids, customize: true,
        install_all: true }

      assert_response :found
    end

    def test_customized_errata_install_with_errata_id_shows_new
      bulk_host_ids =
        {
          included: {
            ids: [hosts(:one).id],
          },
        }.to_json

      bulk_errata_ids =
        {
          included: {
            ids: [katello_errata(:security).errata_id],
          },
        }.to_json

      post :create, params: {
        :remote_action => "errata_install",
        bulk_host_ids: bulk_host_ids, bulk_errata_ids: bulk_errata_ids,
        customize: true }

      assert_response :found
    end
  end
end
