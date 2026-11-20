require "katello_test_helper"

module Katello
  class Api::V2::EnvironmentRegistryRepublishTest < ActionController::TestCase
    tests Api::V2::EnvironmentsController

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      @organization = get_organization
      @environment = katello_environments(:staging)
    end

    def update_environment(attributes)
      put :update, params: { organization_id: @organization.id, id: @environment.id, environment: attributes }
    end

    test "clearing pattern republishes container repositories" do
      @environment.update_columns(registry_name_pattern: "old/path")
      @controller.expects(:async_task).with(::Actions::Katello::Environment::PublishContainerRepositories, @environment).returns({})
      update_environment(registry_name_pattern: nil)
      assert_response :success
      assert_nil @environment.reload.registry_name_pattern
    end

    test "resubmitting unchanged pattern retries publishing container repositories" do
      @environment.update_columns(registry_name_pattern: "old/path")
      @controller.expects(:async_task).with(::Actions::Katello::Environment::PublishContainerRepositories, @environment).returns({})
      update_environment(registry_name_pattern: "old/path")
      assert_response :success
    end

    test "resubmitting nil pattern republishes container repositories" do
      @environment.update_columns(registry_name_pattern: nil)
      @controller.expects(:async_task).with(::Actions::Katello::Environment::PublishContainerRepositories, @environment).returns({})
      update_environment(registry_name_pattern: nil)
      assert_response :success
    end

    test "empty pattern republishes container repositories" do
      @controller.expects(:async_task).with(::Actions::Katello::Environment::PublishContainerRepositories, @environment).returns({})
      update_environment(registry_name_pattern: "")
      assert_response :success
      assert_equal "", @environment.reload.registry_name_pattern
    end

    test "update without registry parameters does not republish container repositories" do
      @controller.expects(:async_task).never
      update_environment(description: "updated description")
      assert_response :success
      assert_equal "updated description", @environment.reload.description
    end

    test "disabling unauthenticated pull republishes container repositories" do
      @environment.update_columns(registry_unauthenticated_pull: true)
      @controller.expects(:async_task).with(::Actions::Katello::Environment::PublishContainerRepositories, @environment).returns({})
      update_environment(registry_unauthenticated_pull: false)
      assert_response :success
      refute @environment.reload.registry_unauthenticated_pull
    end

    test "resubmitting disabled unauthenticated pull republishes container repositories" do
      @environment.update_columns(registry_unauthenticated_pull: false)
      @controller.expects(:async_task).with(::Actions::Katello::Environment::PublishContainerRepositories, @environment).returns({})
      update_environment(registry_unauthenticated_pull: false)
      assert_response :success
    end
  end
end
