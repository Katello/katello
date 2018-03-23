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
        names = []
        repositories.each do |repository|
          name = Katello::Repository.safe_render_container_name(repository, registry_name_pattern)

          unless ContainerImageNameValidator.validate_name(name)
            error_messages << N_("Registry name pattern results in invalid container image name of member repository '%{name}'") % {name: repository.name}
            return error_messages
          end
          names << name
        end

        if names.length != names.uniq.length
          error_messages << N_("Registry name pattern results in duplicate container image names")
          return error_messages
        end

        []
      end

      def test_repository
        Katello::Validators::EnvironmentDockerRepositoriesValidator::RepositoryOpenStruct.new(
            name: "bad name!", label: "good_label", docker_upstream_name: "image/name", url: "https://registry.example.com",
            organization: SafeOpenStruct.new(name: "bad name!", label: "good_label"),
            product: SafeOpenStruct.new(name: "bad name!", label: "good_label"),
            environment: SafeOpenStruct.new(name: "bad name!", label: "good_label"),
            content_view_version: OpenStruct.new(content_view: ContentViewOpenStruct.new(name: "bad name!", label: "good_label", version: "1.2"))
        )
      end

      class RepositoryOpenStruct < OpenStruct
        class Jail < ::Safemode::Jail
          allow :name, :label, :version, :docker_upstream_name, :url
        end
      end

      class ContentViewOpenStruct < OpenStruct
        class Jail < ::Safemode::Jail
          allow :name, :label, :version
        end
      end

      class SafeOpenStruct < OpenStruct
        class Jail < ::Safemode::Jail
          allow :name, :label
        end
      end
    end
  end
end
