require 'katello_test_helper'

module Katello
  class EnvironmentDockerRepositoriesValidatorTest < ActiveSupport::TestCase
    def setup
      @previous_user = User.current
      User.current = users(:admin)
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

    def teardown
      User.current = @previous_user
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
    test "pattern child conflicts with another current distribution before save" do
      version = create(:registry_content_view_version, :hq_cvv_single_repo, content_view: @hq_cv_single_repo)
      repo = create(:registry_repository, :hq_repo_alpha, environment: @hq_env_dev, product: @hq_product, content_view_version: version)
      other = create(:registry_repository, :hq_repo_beta, environment: @hq_env_dev, product: @hq_product, content_view_version: version)
      Katello::Pulp3::DistributionReference.create!(repository: repo, path: "old/path", href: "/pulp/dist/one/")
      Katello::Pulp3::DistributionReference.create!(repository: other, path: "new", href: "/pulp/dist/two/")

      @hq_env_dev.registry_name_pattern = "new/<%= repository.label %>"
      assert_not @hq_env_dev.save
      assert(@hq_env_dev.errors[:registry_name_pattern].any? { |message| message.include?("overlaps") })
      assert_not_equal @hq_env_dev.registry_name_pattern, @hq_env_dev.reload.registry_name_pattern
    end

    test "pattern candidates overlap even when no references exist" do
      version = create(:registry_content_view_version, :hq_cvv_multi_repo, content_view: @hq_cv_multi_repo)
      create(:registry_repository, :hq_repo_alpha, environment: @hq_env_dev, product: @hq_product, content_view_version: version,
             docker_upstream_name: "team/image")
      create(:registry_repository, :hq_repo_beta, environment: @hq_env_dev, product: @hq_product, content_view_version: version,
             docker_upstream_name: "team/image/child")
      @hq_env_dev.registry_name_pattern = "<%= repository.docker_upstream_name %>"
      @validator.validate(@hq_env_dev)
      assert(@hq_env_dev.errors[:registry_name_pattern].any? { |message| message.include?("overlaps") })
    end

    test "clearing a pattern uses default paths and checks current distributions" do
      version = create(:registry_content_view_version, :hq_cvv_single_repo, content_view: @hq_cv_single_repo)
      repo = create(:registry_repository, :hq_repo_alpha, environment: @hq_env_dev, product: @hq_product, content_view_version: version)
      other = create(:registry_repository, :hq_repo_beta, environment: @hq_env_dev, product: @hq_product, content_view_version: version)
      @hq_env_dev.update_column(:registry_name_pattern, "previous/<%= repository.label %>")
      @hq_env_dev.reload
      @hq_env_dev.registry_name_pattern = nil
      repo.environment = @hq_env_dev
      new_path = Katello::Repository.safe_render_container_name(repo, nil)
      Katello::Pulp3::DistributionReference.create!(repository: repo, path: "old/path", href: "/pulp/dist/one/")
      Katello::Pulp3::DistributionReference.create!(repository: other, path: "#{new_path}/child", href: "/pulp/dist/two/")
      assert_not @hq_env_dev.save
      assert(@hq_env_dev.errors[:registry_name_pattern].any? { |message| message.include?("overlaps") })
      assert @hq_env_dev.reload.registry_name_pattern.present?
    end

    test "rename may repair an old overlap but not an unsafe transition" do
      version = create(:registry_content_view_version, :hq_cvv_multi_repo, content_view: @hq_cv_multi_repo)
      first = create(:registry_repository, :hq_repo_alpha, environment: @hq_env_dev, product: @hq_product, content_view_version: version)
      second = create(:registry_repository, :hq_repo_beta, environment: @hq_env_dev, product: @hq_product, content_view_version: version)
      Katello::Pulp3::DistributionReference.create!(repository: first, path: "legacy", href: "/pulp/dist/one/")
      Katello::Pulp3::DistributionReference.create!(repository: second, path: "legacy/child", href: "/pulp/dist/two/")
      @hq_env_dev.registry_name_pattern = "safe/<%= repository.label %>"
      @validator.validate(@hq_env_dev)
      assert_empty @hq_env_dev.errors[:registry_name_pattern]
    end

    test "unchanged pattern does not reject unrelated existing overlaps" do
      version = create(:registry_content_view_version, :hq_cvv_single_repo, content_view: @hq_cv_single_repo)
      repo = create(:registry_repository, :hq_repo_alpha, environment: @hq_env_dev, product: @hq_product, content_view_version: version)
      Katello::Pulp3::DistributionReference.create!(repository: repo, path: "existing", href: "/pulp/dist/one/")
      Katello::Pulp3::DistributionReference.create!(repository: repo, path: "existing/child", href: "/pulp/dist/two/")
      @hq_env_dev.description = "different description"
      assert @hq_env_dev.valid?
    end

    test "references of non-container repositories block a registry pattern" do
      version = create(:registry_content_view_version, :hq_cvv_single_repo, content_view: @hq_cv_single_repo)
      create(:registry_repository, :hq_repo_alpha, environment: @hq_env_dev, product: @hq_product, content_view_version: version)
      other = create(:registry_repository, :fo_repo_alpha, environment: @fo_env_dev, product: @fo_product,
                     content_view_version: create(:registry_content_view_version, :fo_cvv_single_repo, content_view: @fo_cv_single_repo))
      other.root.update_column(:content_type, 'yum')
      Katello::Pulp3::DistributionReference.create!(repository: other, path: "namespace", href: "/pulp/dist/noncontainer/")
      @hq_env_dev.registry_name_pattern = "namespace/<%= repository.label %>"
      assert_not @hq_env_dev.save
      message = @hq_env_dev.errors[:registry_name_pattern].join(' ')
      assert_includes message, 'overlaps'
      assert_not_includes message, other.name
      assert_not_includes message, 'namespace'
    end

    test "same organization readable conflict is detailed, but denied and anonymous are generic" do
      version = create(:registry_content_view_version, :hq_cvv_multi_repo, content_view: @hq_cv_multi_repo)
      first = create(:registry_repository, :hq_repo_alpha, environment: @hq_env_dev, product: @hq_product, content_view_version: version)
      second = create(:registry_repository, :hq_repo_beta, environment: @hq_env_dev, product: @hq_product, content_view_version: version)
      validator = Validators::ContainerPathOverlapValidator
      candidates = [validator::Candidate.new(path: 'private/path', repository: first),
                    validator::Candidate.new(path: 'private/path/child', repository: second)]
      detailed = validator.messages(candidates: candidates, organization: @org_hq, user: users(:admin), references: []).first
      assert_includes detailed, first.name
      assert_includes detailed, second.name
      assert_includes detailed, 'private/path'
      Katello::Repository.stubs(:readable_as).with(users(:restricted)).returns(Katello::Repository.none)
      [users(:restricted), users(:anonymous), nil].each do |user|
        message = validator.messages(candidates: candidates, organization: @org_hq, user: user, references: []).first
        assert_not_includes message, first.name
        assert_not_includes message, second.name
        assert_not_includes message, 'private/path'
      end
    end

    test "cross organization details stay hidden even from an administrator" do
      hq_version = create(:registry_content_view_version, :hq_cvv_single_repo, content_view: @hq_cv_single_repo)
      fo_version = create(:registry_content_view_version, :fo_cvv_single_repo, content_view: @fo_cv_single_repo)
      first = create(:registry_repository, :hq_repo_alpha, environment: @hq_env_dev, product: @hq_product, content_view_version: hq_version)
      second = create(:registry_repository, :fo_repo_alpha, environment: @fo_env_dev, product: @fo_product, content_view_version: fo_version)
      reference = Katello::Pulp3::DistributionReference.create!(repository: second, path: 'crossorg/child', href: '/pulp/dist/other/')
      validator = Validators::ContainerPathOverlapValidator
      candidate = validator::Candidate.new(path: 'crossorg', repository: first)
      message = validator.messages(candidates: [candidate], organization: @org_hq, user: users(:admin), references: [reference]).first
      assert_includes message, 'overlaps'
      assert_not_includes message, second.name
      assert_not_includes message, 'crossorg'
    end
  end
end
