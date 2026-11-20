module Katello
  module Validators
    # Boundary adapter for publish/promote: builds the projected version's container
    # paths per target environment, then delegates to ContainerPathOverlapValidator.
    class ContentViewContainerPathValidator
      def self.candidates(version:, sources:, environments:, include_archive: false)
        view = version.content_view
        destinations = environments.to_a.uniq
        destinations << nil if include_archive

        entries = sources.flat_map do |source|
          next [] unless source.docker?

          destinations.map do |environment|
            existing = environment && view.get_repo_clone(environment, source).first
            projected = Katello::Repository.new(root: source.root, library_instance: source.library_instance_or_self,
                                                environment: environment, content_view_version: version)
            path = Katello::Repository.safe_render_container_name(projected)
            unless path.present? && ContainerImageNameValidator.validate_name(path)
              fail Katello::HttpErrors::Conflict, N_("The generated container image name is invalid. Review the lifecycle environment registry name pattern, repository upstream image name, and labels used to generate the name, or contact an administrator.")
            end

            { path: path, repository: existing || source, existing_id: existing&.id }
          end
        end

        reference_ids = existing_reference_ids(entries.filter_map { |entry| entry[:existing_id] })
        entries.map do |entry|
          ContainerPathOverlapValidator::Candidate.new(
            path: entry[:path],
            repository: entry[:repository],
            reference_id: entry[:existing_id] && reference_ids[entry[:existing_id]]
          )
        end
      end

      def self.existing_reference_ids(repository_ids)
        return {} if repository_ids.empty?
        Katello::Pulp3::DistributionReference.where(repository_id: repository_ids).pluck(:repository_id, :id).to_h
      end

      def self.validate!(version:, sources:, environments:, user:, include_archive: false)
        proposed = candidates(version: version, sources: sources, environments: environments, include_archive: include_archive)
        return if proposed.empty?

        messages = ContainerPathOverlapValidator.messages(candidates: proposed, organization: version.content_view.organization, user: user)
        fail Katello::HttpErrors::Conflict, messages.join("  ") if messages.any?
      end
    end
  end
end
