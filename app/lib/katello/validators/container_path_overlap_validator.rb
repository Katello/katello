module Katello
  module Validators
    # Core engine for container path overlap detection: pure logic over candidate
    # paths and DistributionReference records, no knowledge of operations.
    # Candidates describe distributions that will actually be written, not their source repositories.
    class ContainerPathOverlapValidator
      Candidate = Struct.new(:path, :repository, :reference_id, :namespace, keyword_init: true)
      Conflict = Struct.new(:candidate, :other, keyword_init: true)

      def self.overlap?(first, second)
        first = normalize(first)
        second = normalize(second)
        first == second || first.start_with?("#{second}/") || second.start_with?("#{first}/")
      end

      def self.normalize(path)
        fail ArgumentError, "Distribution path must be present" if path.blank? || path.delete('/').blank?
        path.sub(%r{\A/+}, '').sub(%r{/+\z}, '')
      end

      def self.ancestor_paths(path)
        segments = path.split('/')
        (1...segments.length).map { |count| segments.first(count).join('/') }
      end

      # Load only references that could overlap a candidate (equal, ancestor, or
      # descendant paths) instead of every distribution reference in the database.
      def self.relevant_references(paths)
        normalized = paths.map { |path| normalize(path) }.uniq
        return [] if normalized.empty?
        table = Katello::Pulp3::DistributionReference.table_name
        clauses = ["#{table}.path IN (:exact)"]
        params = { exact: (normalized + normalized.flat_map { |path| ancestor_paths(path) }).uniq }
        normalized.each_with_index do |path, index|
          clauses << "#{table}.path LIKE :descendants#{index}"
          params[:"descendants#{index}"] = "#{ActiveRecord::Base.sanitize_sql_like(path)}/%"
        end
        Katello::Pulp3::DistributionReference.unscoped.includes(:repository).where(clauses.join(' OR '), params).to_a
      end

      # A nil namespace is unknown, and therefore potentially overlaps every namespace.
      # References are unscoped: authorization controls presentation, not detection.
      def self.conflicts(candidates:, references: nil)
        candidates.each { |candidate| normalize(candidate.path) }
        current = existing_candidates(references || relevant_references(candidates.map(&:path)))
        conflicts = []
        candidates.each_with_index do |candidate, index|
          candidates.drop(index + 1).each do |other|
            conflicts << Conflict.new(candidate: candidate, other: other) if conflict_between?(candidate, other)
          end
          current.each do |other|
            next if candidate.reference_id.present? && candidate.reference_id == other.reference_id
            conflicts << Conflict.new(candidate: candidate, other: other) if conflict_between?(candidate, other)
          end
        end
        conflicts
      end

      # A blank stored path cannot overlap anything; skip it rather than raising.
      def self.existing_candidates(references)
        references.filter_map do |reference|
          next if reference.path.blank? || reference.path.delete('/').blank?
          Candidate.new(path: reference.path, repository: reference.repository, reference_id: reference.id)
        end
      end

      def self.conflict_between?(first, second)
        same_namespace?(first, second) && overlap?(first.path, second.path)
      end

      def self.same_namespace?(first, second)
        first.namespace.nil? || second.namespace.nil? || first.namespace == second.namespace
      end

      # Explicit user and organization arguments prevent anonymous task contexts from inheriting admin visibility.
      def self.details_allowed?(repositories, organization:, user:)
        return false unless user && organization&.id && !user.hidden?
        return false if [::User::ANONYMOUS_ADMIN, ::User::ANONYMOUS_API_ADMIN, ::User::ANONYMOUS_CONSOLE_ADMIN].include?(user.login)
        return false if repositories.any? { |repo| !repo || repo.organization_id != organization.id }
        # An unpersisted repository is the caller's own proposed object and may be
        # named; only persisted repositories need a readability check.
        ids = repositories.select(&:persisted?).map(&:id).uniq
        ids.empty? || Katello::Repository.readable_as(user).where(id: ids).distinct.count == ids.length
      end

      # Privacy-safe message for overlap errors reported by Pulp itself (races and
      # unmanaged distributions); it names only the caller's own repository path.
      def self.late_overlap_message(repository)
        path = repository.docker? ? repository.container_repository_name : repository.relative_path
        N_("Distribution path '%{path}' overlaps with an existing distribution in Pulp. Change the lifecycle environment registry name pattern, or contact an administrator.") % {path: path}
      end

      def self.messages(candidates:, organization:, user: nil, references: nil)
        results = conflicts(candidates: candidates, references: references).map do |conflict|
          first = conflict.candidate
          second = conflict.other
          if details_allowed?([first.repository, second.repository], organization: organization, user: user)
            N_("Distribution path '%{path}' for repository '%{repository}' overlaps path '%{other_path}' for repository '%{other_repository}'. Change the lifecycle environment registry name pattern.") %
              {path: first.path, repository: first.repository.name, other_path: second.path, other_repository: second.repository.name}
          else
            N_("A distribution path overlaps an existing or proposed distribution. Change the lifecycle environment registry name pattern or contact an administrator.")
          end
        end
        results.uniq
      end
    end
  end
end
