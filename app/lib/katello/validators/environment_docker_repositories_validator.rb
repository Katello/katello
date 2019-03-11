module Katello
  module Validators
    class EnvironmentDockerRepositoriesValidator < ActiveModel::Validator
      def validate(environment)
        return true if environment.registry_name_pattern.empty?

        unless ContainerImageNameValidator.validate_name(Katello::Repository.safe_render_container_name(test_repository, environment.registry_name_pattern))
          environment.errors.add(:registry_name_pattern, N_("Registry name pattern will result in invalid container image name of member repositories"))
          return false
        end

        error_messages = EnvironmentDockerRepositoriesValidator.validate_repositories(environment.registry_name_pattern, environment.repositories.docker_type)
        return true if error_messages.empty?

        error_messages.each do |message|
          environment.errors.add(:registry_name_pattern, message)
        end
        false
      end

      def self.validate_repositories(registry_name_pattern, repositories)
        error_messages = []
        name_to_repos = {}
        repositories.each do |repository|
          name = Katello::Repository.safe_render_container_name(repository, registry_name_pattern)
          unless ContainerImageNameValidator.validate_name(name)
            error_messages << N_("Registry name pattern results in invalid container image name of member repository '%{name}'") % {name: repository.name}
            return error_messages
          end
          name_to_repos[name] ||= []
          name_to_repos[name] << repository
        end

        duplicate_repos = name_to_repos.select { |_name, repos| repos.count > 1 }.values.flatten
        if duplicate_repos.any?
          repo_names = duplicate_repos.map(&:name).sort.join(', ')
          error_messages << N_("Registry name pattern results in duplicate container image names for these repositories: %s.") % repo_names
          return error_messages
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
