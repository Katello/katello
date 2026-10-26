module Katello
  module Validators
    # Boundary adapter for repository operations: determines which container path
    # each operation is about to write, then delegates to ContainerPathOverlapValidator.
    class RepositoryContainerPathValidator
      def self.validate_create!(root, user:)
        return unless root.docker? && !root.is_container_push && root.product && root.name.present?

        organization = root.organization
        environment = organization&.library
        version = organization&.library&.default_content_view_version
        return unless environment && version

        # Match the label callback that will run when the root is saved.
        root.setup_label_from_name if root.label.blank?
        return if root.label.blank? || root.product.label.blank?
        projected_root = root.dup
        projected_root.product = root.product
        repository = Katello::Repository.new(root: projected_root, environment: environment, content_view_version: version)
        validate!(repository, path: Katello::Repository.safe_render_container_name(repository), user: user)
      end

      def self.validate_update!(root, repository, params, user:)
        return unless root.docker? && repository

        # Run the same validations and dirty tracking used by update! without saving.
        # pulp_update_needed? reads previous_changes, so supply the projected changes
        # on an isolated copy rather than duplicating its list of Pulp attributes.
        probe = root.class.find(root.id)
        probe.assign_attributes(root.changes_to_save.transform_values(&:last))
        probe.assign_attributes(params)
        return unless probe.valid?

        probe.define_singleton_method(:previous_changes) { changes_to_save }
        return unless probe.pulp_update_needed?

        # The update re-renders container_repository_name (e.g. a docker_upstream_name
        # change), so validate the path the repository will have after the update.
        original_root = repository.root
        begin
          repository.root = probe
          projected_path = Katello::Repository.safe_render_container_name(repository)
        ensure
          repository.root = original_root
        end
        validate!(repository, path: projected_path, user: user)
        validate_pulp_overlap!(repository, projected_path) if moves_path?(repository, projected_path)
      end

      def self.moves_path?(repository, projected_path)
        projected_path.present? && projected_path.delete('/').present? &&
          projected_path != repository.container_repository_name
      end

      # Unmanaged Pulp distributions have no DistributionReference, so the checks
      # above cannot see them. Consult Pulp directly before a path move commits,
      # turning a mid-task failure into a plan-time conflict.
      def self.validate_pulp_overlap!(repository, path)
        return if unmanaged_pulp_overlaps(repository, path).empty?
        fail Katello::HttpErrors::Conflict,
             _("The path '%{path}' overlaps with a distribution that exists in Pulp but is not managed by Katello. Remove or move the existing Pulp distribution, or contact an administrator.") % {path: path}
      end

      def self.unmanaged_pulp_overlaps(repository, path)
        api = repository.backend_service(::SmartProxy.pulp_primary).api
        hits = api.distributions_api.list(base_path__in: [path] + ContainerPathOverlapValidator.ancestor_paths(path)).results
        hits += api.distributions_api.list(base_path__contains: "#{path}/").results.select do |distribution|
          distribution.base_path.start_with?("#{path}/")
        end
        tracked = Katello::Pulp3::DistributionReference.where(href: hits.map(&:pulp_href)).pluck(:href)
        hits.uniq(&:pulp_href).reject { |distribution| tracked.include?(distribution.pulp_href) }
      end

      def self.validate_existing!(repository, user:)
        if repository.docker?
          validate!(repository, path: repository.container_repository_name, user: user)
        else
          path = repository.relative_path&.sub(%r{\A/}, '')
          return if path.blank? || path.delete('/').blank?
          # Non-docker paths only conflict with docker distributions; load just the
          # references whose paths could overlap instead of the whole docker set.
          references = ContainerPathOverlapValidator.relevant_references([path]).select do |reference|
            reference.repository&.docker?
          end
          validate!(repository, path: path, user: user, references: references)
        end
      end

      def self.validate!(repository, path:, user:, references: nil)
        return if path.blank? || path.delete('/').blank?

        candidate = ContainerPathOverlapValidator::Candidate.new(
          path: path,
          repository: repository,
          reference_id: repository.persisted? ? Katello::Pulp3::DistributionReference.find_by(repository_id: repository.id)&.id : nil
        )
        messages = ContainerPathOverlapValidator.messages(candidates: [candidate], organization: repository.organization, user: user, references: references)
        fail Katello::HttpErrors::Conflict, messages.join("  ") if messages.any?
      end
    end
  end
end
