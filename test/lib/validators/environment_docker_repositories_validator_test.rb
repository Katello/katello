require 'katello_test_helper'

module Katello
  class EnvironmentDockerRepositoriesValidatorTest < ActiveSupport::TestCase
    def setup
      @validator = Validators::EnvironmentDockerRepositoriesValidator.new({})

      @org_hq = create(:registry_organization, :headquarters)
      @org_fo = create(:registry_organization, :fieldoffice)
      @hq_env_dev = create(:registry_environment, :hq_env_dev, organization: @org_hq)
      @fo_env_dev = create(:registry_environment, :fo_env_dev, organization: @org_fo)
      @hq_cv_single_repo = create(:registry_content_view, :hq_cv_single_repo, organization: @org_hq)
      @hq_cv_multi_repo = create(:registry_content_view, :hq_cv_multi_repo, organization: @org_hq)
      @fo_cv_single_repo = create(:registry_content_view, :fo_cv_single_repo, organization: @org_fo)
      @fo_cv_multi_repo = create(:registry_content_view, :fo_cv_multi_repo, organization: @org_fo)

      @hq_product = create(:registry_product, :hq_product, organization: @org_hq,
                           provider: create(:katello_provider, organization: @org_hq))
      @fo_product = create(:registry_product, :fo_product, organization: @org_fo,
                           provider: create(:katello_provider, organization: @org_fo))
    end

    test "success empty pattern" do
      hq_cvv_single_repo = create(:registry_content_view_version, :hq_cvv_single_repo,
                                  content_view: @hq_cv_single_repo)
      create(:registry_repository, :hq_repo_alpha,
             environment: @hq_env_dev,
             product: @hq_product,
             content_view_version: hq_cvv_single_repo)

      @validator.validate(@hq_env_dev)
      assert_empty @hq_env_dev.errors[:base]
    end

    test "success static pattern for single repo" do
      hq_cvv_single_repo = create(:registry_content_view_version, :hq_cvv_single_repo,
                                  content_view: @hq_cv_single_repo)
      create(:registry_repository, :hq_repo_alpha,
             environment: @hq_env_dev,
             product: @hq_product,
             content_view_version: hq_cvv_single_repo)

      @hq_env_dev.registry_name_pattern = "pattern"
      @validator.validate(@hq_env_dev)
      assert_empty @hq_env_dev.errors[:registry_name_pattern]
    end

    test "success static pattern for single repo with cvv version" do
      hq_cvv_single_repo = create(:registry_content_view_version, :hq_cvv_single_repo,
                                  content_view: @hq_cv_single_repo)
      create(:registry_repository, :hq_repo_alpha,
             environment: @hq_env_dev,
             product: @hq_product,
             content_view_version: hq_cvv_single_repo)

      @hq_env_dev.registry_name_pattern = "content_view_version.version"
      @validator.validate(@hq_env_dev)
      assert_empty @hq_env_dev.errors[:registry_name_pattern]
    end

    test "fails static pattern for multiple repos" do
      hq_cvv_multi_repo = create(:registry_content_view_version, :hq_cvv_multi_repo,
                                  content_view: @hq_cv_multi_repo)
      create(:registry_repository, :hq_repo_alpha,
                              environment: @hq_env_dev,
                              product: @hq_product,
                              content_view_version: hq_cvv_multi_repo)
      create(:registry_repository, :hq_repo_beta,
                              environment: @hq_env_dev,
                              product: @hq_product,
                              content_view_version: hq_cvv_multi_repo)

      @hq_env_dev.registry_name_pattern = "pattern"
      @validator.validate(@hq_env_dev)
      assert_equal ["Registry name pattern results in duplicate container image names for these repositories: Alpha Image, Beta Image."],
                   @hq_env_dev.errors[:registry_name_pattern]
    end

    test "passes good pattern for multiple repos" do
      hq_cvv_multi_repo = create(:registry_content_view_version, :hq_cvv_multi_repo,
                                  content_view: @hq_cv_multi_repo)
      create(:registry_repository, :hq_repo_alpha,
             environment: @hq_env_dev,
             product: @hq_product,
             content_view_version: hq_cvv_multi_repo)
      create(:registry_repository, :hq_repo_beta,
             environment: @hq_env_dev,
             product: @hq_product,
             content_view_version: hq_cvv_multi_repo)

      @hq_env_dev.registry_name_pattern = "<%= organization.label %>/<%= repository.label %>"
      @validator.validate(@hq_env_dev)
      assert_empty @hq_env_dev.errors[:registry_name_pattern]
    end

    test "fails same name in two orgs" do
      hq_cvv_single_repo = create(:registry_content_view_version, :hq_cvv_single_repo,
                                  content_view: @hq_cv_single_repo)
      hq_repo = create(:registry_repository, :hq_repo_alpha,
             environment: @hq_env_dev,
             product: @hq_product,
             content_view_version: hq_cvv_single_repo)
      hq_repo.save!

      @fo_env_dev.registry_name_pattern = "<%= repository.label %>"
      @fo_env_dev.save
      fo_cvv_single_repo = create(:registry_content_view_version, :fo_cvv_single_repo,
                                  content_view: @fo_cv_single_repo)
      fo_repo = create(:registry_repository, :hq_repo_alpha,
             :root => hq_repo.root,
             environment: @fo_env_dev,
             product: @fo_product,
             content_view_version: fo_cvv_single_repo)

      @hq_env_dev.registry_name_pattern = "<%= repository.label %>"
      @validator.validate(@hq_env_dev)

      assert fo_repo.save!
      assert_raises(ActiveRecord::RecordInvalid) do
        hq_repo.save!
      end
    end

    test "fails when registry pattern creates overlapping paths" do
      hq_cvv_multi_repo = create(:registry_content_view_version, :hq_cvv_multi_repo,
                                  content_view: @hq_cv_multi_repo)
      parent_repo = create(:registry_repository, :hq_repo_alpha,
                           environment: @hq_env_dev,
                           product: @hq_product,
                           content_view_version: hq_cvv_multi_repo)
      parent_repo.root.update!(docker_upstream_name: "parent")

      child_repo = create(:registry_repository, :hq_repo_beta,
                          environment: @hq_env_dev,
                          product: @hq_product,
                          content_view_version: hq_cvv_multi_repo)
      child_repo.root.update!(docker_upstream_name: "parent/child")

      @hq_env_dev.registry_name_pattern = "<%= organization.label %>/<%= repository.docker_upstream_name %>"
      @validator.validate(@hq_env_dev)

      assert_includes @hq_env_dev.errors[:registry_name_pattern].first,
                      "Registry name pattern results in overlapping container image paths"
      assert_includes @hq_env_dev.errors[:registry_name_pattern].first, "headquarters/parent"
      assert_includes @hq_env_dev.errors[:registry_name_pattern].first, "headquarters/parent/child"
    end

    test "passes when paths don't overlap" do
      hq_cvv_multi_repo = create(:registry_content_view_version, :hq_cvv_multi_repo,
                                  content_view: @hq_cv_multi_repo)
      repo1 = create(:registry_repository, :hq_repo_alpha,
                     environment: @hq_env_dev,
                     product: @hq_product,
                     content_view_version: hq_cvv_multi_repo)
      repo1.root.update!(docker_upstream_name: "alpha")

      repo2 = create(:registry_repository, :hq_repo_beta,
                     environment: @hq_env_dev,
                     product: @hq_product,
                     content_view_version: hq_cvv_multi_repo)
      repo2.root.update!(docker_upstream_name: "beta")

      @hq_env_dev.registry_name_pattern = "<%= organization.label %>/<%= repository.docker_upstream_name %>"
      @validator.validate(@hq_env_dev)

      assert_empty @hq_env_dev.errors[:registry_name_pattern]
    end

    test "detects all overlaps when multiple exist" do
      hq_cvv_multi_repo = create(:registry_content_view_version, :hq_cvv_multi_repo,
                                  content_view: @hq_cv_multi_repo)

      # Create parent, child1, and child2 repos
      parent = create(:registry_repository, :hq_repo_alpha,
                      environment: @hq_env_dev,
                      product: @hq_product,
                      content_view_version: hq_cvv_multi_repo)
      parent.root.update!(docker_upstream_name: "app")

      child1 = create(:registry_repository, :hq_repo_beta,
                      environment: @hq_env_dev,
                      product: @hq_product,
                      content_view_version: hq_cvv_multi_repo)
      child1.root.update!(docker_upstream_name: "app/frontend")

      @hq_env_dev.registry_name_pattern = "<%= organization.label %>/<%= repository.docker_upstream_name %>"
      @validator.validate(@hq_env_dev)

      errors = @hq_env_dev.errors[:registry_name_pattern]
      # Should detect the overlap between app and app/frontend
      assert(errors.any? { |e| e.include?("overlapping container image paths") })
      assert(errors.any? { |e| e.include?("headquarters/app") && e.include?("headquarters/app/frontend") })
    end

    test "passes when paths share prefix but no slash separator" do
      hq_cvv_multi_repo = create(:registry_content_view_version, :hq_cvv_multi_repo,
                                  content_view: @hq_cv_multi_repo)
      repo1 = create(:registry_repository, :hq_repo_alpha,
                     environment: @hq_env_dev,
                     product: @hq_product,
                     content_view_version: hq_cvv_multi_repo)
      repo1.root.update!(docker_upstream_name: "app")

      repo2 = create(:registry_repository, :hq_repo_beta,
                     environment: @hq_env_dev,
                     product: @hq_product,
                     content_view_version: hq_cvv_multi_repo)
      repo2.root.update!(docker_upstream_name: "application")

      @hq_env_dev.registry_name_pattern = "<%= organization.label %>/<%= repository.docker_upstream_name %>"
      @validator.validate(@hq_env_dev)

      assert_empty @hq_env_dev.errors[:registry_name_pattern]
    end
  end
end
