module Katello
  module Validators
    class EnvironmentDockerRepositoriesValidator < ActiveModel::Validator
      def validate(environment)
        return true if environment.registry_name_pattern.empty?

        unless ContainerImageNameValidator.validate_name(Katello::Repository.safe_render_container_name(test_repository, environment.registry_name_pattern))
          environment.errors.add(:registry_name_pattern, N_("Registry name pattern will result in invalid container image name of member repositories"))
          return false
        end

        error_messages = EnvironmentDockerRepositoriesValidator.validate_repositories(environment.registry_name_pattern, environment.repositories.docker_type, environment)
        return true if error_messages.empty?

        error_messages.each do |message|
          environment.errors.add(:registry_name_pattern, message)
        end
        false
      end

      # Render container name using the provided environment to validate promotion target paths
      # When content_view_version is provided, temporarily swaps it to render the target repository's name
      def self.render_container_name(repository, pattern, environment, content_view_version = nil)
        original_env = repository.environment
        original_cvv = repository.content_view_version
        begin
          repository.environment = environment if environment
          repository.content_view_version = content_view_version if content_view_version
          Katello::Repository.safe_render_container_name(repository, pattern)
        ensure
          repository.environment = original_env
          repository.content_view_version = original_cvv
        end
      end

      def self.validate_repositories(registry_name_pattern, repositories, environment = nil, content_view_version = nil)
        error_messages = []
        name_to_repos = {}
        repositories.each do |repository|
          name = render_container_name(repository, registry_name_pattern, environment, content_view_version)

          unless ContainerImageNameValidator.validate_name(name)
            error_messages << N_("Registry name pattern results in invalid container image name of member repository '%{name}'") % {name: repository.name}
            return error_messages
          end
          name_to_repos[name] ||= []
          name_to_repos[name] << repository
        end

        duplicate_repos = name_to_repos.select { |_name, repos| repos.count > 1 }.values.flatten
        if duplicate_repos.any?
          repo_names = duplicate_repos.map { |r| r.root.name }.sort.join(', ')
          error_messages << N_("Registry name pattern results in duplicate container image names for these repositories: %s.") % repo_names
          return error_messages
        end

        # Check for overlapping paths (parent/child relationships)
        # This is called when updating an environment's registry pattern, not during CV operations
        # CV operations use check_docker_repository_names! which has being_created logic
        sorted_names = name_to_repos.keys.sort
        sorted_names.each_with_index do |name, index|
          sorted_names[(index + 1)..].each do |other_name|
            if other_name.start_with?("#{name}/")
              error_messages << ::Katello::ContentView.container_overlap_error(name, other_name)
              return error_messages
            end
          end
        end

        error_messages
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
