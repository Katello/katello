require "katello_test_helper"

module Katello
  class ContentViewDistributionReadinessTest < ActiveSupport::TestCase
    def setup
      User.current = users(:admin)
      @organization = get_organization
      @view = katello_content_views(:library_view)
      @environment = katello_environments(:dev)
    end

    test "publish readiness does not reject names rendered from source repositories" do
      @view.stubs(:check_repositories_blocking_publish!)
      @view.stubs(:check_composite_action_allowed!)
      @view.stubs(:check_orphaned_content_facets!)
      @view.stubs(:check_scheduled_publish!)
      @view.stubs(:check_component_publishes!)
      @view.expects(:check_docker_repository_names!).never
      assert @view.check_ready_to_publish!
    end

    test "promote readiness does not use current content view source repositories" do
      version = katello_content_view_versions(:library_view_version_1)
      view = version.content_view
      view.stubs(:check_composite_action_allowed!)
      view.stubs(:check_orphaned_content_facets!)
      view.expects(:check_docker_repository_names!).never
      version.check_ready_to_promote!([@environment])
    end

    test "destination repositories retain container name format validation" do
      validator = Katello::Repository.validators.grep(Katello::Validators::ContainerImageNameValidator).first
      assert validator
      repository = Katello::Repository.new
      validator.validate_each(repository, :container_repository_name, "invalid//name")
      assert repository.errors[:container_repository_name].any?
    end
  end
end
