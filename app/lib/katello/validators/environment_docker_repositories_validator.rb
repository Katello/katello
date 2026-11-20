module Katello
  module Validators
    class EnvironmentDockerRepositoriesValidator < ActiveModel::Validator
      def validate(environment)
        return true unless environment.will_save_change_to_registry_name_pattern?

        pattern = environment.registry_name_pattern
        if pattern.present? && !ContainerImageNameValidator.validate_name(Katello::Repository.safe_render_container_name(test_repository, pattern))
          environment.errors.add(:registry_name_pattern, N_("Registry name pattern will result in invalid container image name of member repositories"))
          return false
        end

        repositories = environment.repositories.docker_type.to_a.reject do |repository|
          repository.root.is_container_push && repository.library_instance?
        end
        # Use the pending pattern, including nil, rather than a separately loaded environment instance.
        repositories.each { |repository| repository.environment = environment }
        error_messages = self.class.validate_repositories(pattern, repositories, organization: environment.organization, user: User.current)
        if error_messages.empty?
          reference_ids = Katello::Pulp3::DistributionReference
                          .where(repository_id: repositories.map(&:id))
                          .pluck(:repository_id, :id).to_h
          candidates = repositories.map do |repository|
            ContainerPathOverlapValidator::Candidate.new(
              path: Katello::Repository.safe_render_container_name(repository, pattern),
              repository: repository,
              reference_id: reference_ids[repository.id]
            )
          end
          error_messages = ContainerPathOverlapValidator.messages(candidates: candidates, organization: environment.organization, user: User.current)
        end
        error_messages.each { |message| environment.errors.add(:registry_name_pattern, message) }
        error_messages.empty?
      end

      def self.validate_repositories(registry_name_pattern, repositories, organization: nil, user: User.current)
        name_to_repos = {}
        repositories.each do |repository|
          name = Katello::Repository.safe_render_container_name(repository, registry_name_pattern)
          unless ContainerImageNameValidator.validate_name(name)
            if ContainerPathOverlapValidator.details_allowed?([repository], organization: organization, user: user)
              return [N_("Registry name pattern results in invalid container image name of member repository '%{name}'") % {name: repository.name}]
            end
            return [N_("Registry name pattern results in an invalid container image name for a member repository. Contact an administrator.")]
          end
          (name_to_repos[name] ||= []) << repository
        end

        duplicate_repos = name_to_repos.select { |_name, repos| repos.count > 1 }.values.flatten
        if duplicate_repos.any?
          if ContainerPathOverlapValidator.details_allowed?(duplicate_repos, organization: organization, user: user)
            repo_names = duplicate_repos.map(&:name).sort.join(', ')
            return [N_("Registry name pattern results in duplicate container image names for these repositories: %s.") % repo_names]
          end
          return [N_("Registry name pattern results in duplicate container image names. Contact an administrator.")]
        end
        []
      end

      def test_repository
        Katello::Repository.new(
          root: ::Katello::RootRepository.new(name: "bad name!", label: "good_label", docker_upstream_name: "image/name", url: "https://registry.example.com"),
          product: ::Katello::Product.new(name: "bad name!", label: "good_label"),
          environment: ::Katello::KTEnvironment.new(name: "bad name!", label: "good_label",
                                                    organization: Organization.new(name: "bad name!", label: "good_label")),
          content_view_version: ::Katello::ContentViewVersion.new(major: 1, minor: 20, content_view: Katello::ContentView.new(name: "bad name!", label: "good_label"))
        )
      end
    end
  end
end
