module Katello
  module Concerns
    module HostgroupExtensions
      extend ActiveSupport::Concern

      included do
        before_save :add_organization_for_environment

        has_one :content_view_environment, :through => :content_facet
        has_one :kickstart_repository, :through => :content_facet
        has_one :content_source, :through => :content_facet

        # Add scoped_search-friendly associations through content_view_environment
        # These work alongside the delegations defined below
        has_one :content_view, :through => :content_view_environment
        has_one :lifecycle_environment, :through => :content_view_environment, :source => :environment

        scoped_search :relation => :content_source, :on => :name, :complete_value => true, :rename => :content_source, :only_explicit => true
        scoped_search :relation => :content_view, :on => :name, :complete_value => true, :rename => :content_view, :only_explicit => true
        scoped_search :relation => :lifecycle_environment, :on => :name, :complete_value => true, :rename => :lifecycle_environment, :only_explicit => true

        # Scope to filter hostgroups by lifecycle environment(s)
        scope :in_environments, ->(lifecycle_environments) do
          joins(:content_facet => :content_view_environment).
            where("#{::Katello::ContentViewEnvironment.table_name}.environment_id" => lifecycle_environments)
        end

        before_validation :correct_kickstart_repository

        delegate :content_source_name, to: :content_facet, allow_nil: true
        delegate :content_source_id, :kickstart_repository_id, :content_view_id, :lifecycle_environment_id, :content_view_environment_id, to: :content_facet, allow_nil: true
        delegate :'content_source_id=', :'kickstart_repository_id=', :'content_view_environment_id=', to: :safe_content_facet, allow_nil: true

        apipie :class do
          property :content_source, 'SmartProxy', desc: 'Returns Smart Proxy object as the content source for the host group'
          property :subscription_manager_configuration_url, String, desc: 'Returns URL for subscription manager configuration'
          property :rhsm_organization_label, String, desc: 'Returns label of the Red Hat Subscription Manager organization'
        end
      end

      def correct_kickstart_repository
        reconcile_medium_and_kickstart_repository
        return unless should_recalculate_kickstart_repository?

        equivalent = equivalent_kickstart_repository
        return if equivalent.blank? || equivalent[:id] == content_facet.kickstart_repository_id

        self.content_facet.kickstart_repository_id = equivalent[:id]
      end

      def content_view_environment
        return super if ancestry.nil? || self.content_view_environment_id.present?
        cvenv_id = inherited_ancestry_attribute(:content_view_environment_id, :content_facet)
        Katello::ContentViewEnvironment.find_by(:id => cvenv_id)
      end

      def content_view
        return content_facet&.content_view if ancestry.nil? || self.content_view_id.present?
        Katello::ContentView.find_by(:id => inherited_content_view_id)
      end

      def lifecycle_environment
        return content_facet&.lifecycle_environment if ancestry.nil? || self.lifecycle_environment_id.present?
        Katello::KTEnvironment.find_by(:id => inherited_lifecycle_environment_id)
      end

      def kickstart_repository
        return super if ancestry.nil? || self.kickstart_repository_id.present?
        Katello::Repository.find_by(:id => inherited_kickstart_repository_id)
      end

      # instead of calling nested_attribute_for(:content_source_id) in Foreman, define the methods explictedly
      def content_source
        return super if ancestry.nil? || self.content_source_id.present?
        SmartProxy.unscoped.find_by(:id => inherited_content_source_id)
      end

      def inherited_content_source_id
        inherited_ancestry_attribute(:content_source_id, :content_facet)
      end

      def inherited_content_view_environment_id
        inherited_ancestry_attribute(:content_view_environment_id, :content_facet)
      end

      def inherited_content_view_id
        cvenv_id = inherited_ancestry_attribute(:content_view_environment_id, :content_facet)
        return nil unless cvenv_id

        Katello::ContentViewEnvironment.find_by(id: cvenv_id)&.content_view_id
      end

      def inherited_lifecycle_environment_id
        cvenv_id = inherited_ancestry_attribute(:content_view_environment_id, :content_facet)
        return nil unless cvenv_id

        Katello::ContentViewEnvironment.find_by(id: cvenv_id)&.environment_id
      end

      def inherited_kickstart_repository_id
        inherited_ancestry_attribute(:kickstart_repository_id, :content_facet)
      end

      def content_view_name
        content_view&.name
      end

      def lifecycle_environment_name
        lifecycle_environment&.name
      end

      def rhsm_organization_label
        #used for rhsm registration snippet, since hostgroup can belong to muliple organizations, use lifecycle environment or cv
        (self.lifecycle_environment || self.content_view).try(:organization).try(:label)
      end

      def add_organization_for_environment
        #ensures that the group's orgs include whatever lifecycle environment is assigned
        if self.lifecycle_environment && !self.organizations.include?(self.lifecycle_environment.organization)
          self.organizations << self.lifecycle_environment.organization
        end
      end

      def equivalent_kickstart_repository
        return unless operatingsystem &&
                      content_facet.kickstart_repository &&
                      operatingsystem.respond_to?(:kickstart_repos)
        ks_repos = operatingsystem.kickstart_repos(self, content_facet: effective_content_facet_for_kickstart(content_facet))
        return if ks_repos.blank?

        if operatingsystem_changed_for_recalculation? || kickstart_repository_release_mismatch?
          release_match = equivalent_kickstart_repository_for_release(ks_repos)
          return release_match if release_match

          # When the OS changes and we cannot detect a strict release match,
          # prefer non-label heuristics to avoid sticking to a stale repo label.
          return equivalent_kickstart_repository_for_variant(ks_repos)
        end

        by_label = ks_repos.find { |repo| repo[:name] == content_facet.kickstart_repository.label }
        return by_label if by_label

        equivalent_kickstart_repository_for_variant(ks_repos)
      end

      def matching_kickstart_repository?(content_facet)
        return true unless operatingsystem

        if operatingsystem.respond_to? :kickstart_repos
          effective_content_facet = effective_content_facet_for_kickstart(content_facet)
          operatingsystem.kickstart_repos(self, content_facet: effective_content_facet).any? do |repo|
            repo[:id] == (content_facet&.kickstart_repository_id || content_facet&.kickstart_repository&.id)
          end
        end
      end

      private

      def reconcile_medium_and_kickstart_repository
        # If switched from ks repo to install media:
        if medium_id_changed? && medium && content_facet&.kickstart_repository_id
          # since it's :through association, nullify both the actual data source and delegate
          self.content_facet.kickstart_repository = nil
          self.kickstart_repository = nil
        # If switched from install media to ks repo:
        elsif content_facet&.kickstart_repository && medium
          self.medium = nil
        end
      end

      def should_recalculate_kickstart_repository?
        return false unless content_facet&.kickstart_repository_id
        return true if operatingsystem_changed_for_recalculation?
        return true if kickstart_repository_release_mismatch?
        return true unless matching_kickstart_repository?(content_facet)

        # Child hostgroups with inherited kickstart context can become stale when
        # parent CVE/content source/OS changes while the stale repo ID remains listed.
        ancestry.present? &&
          (content_facet.content_view_environment_id.blank? || content_facet.content_source_id.blank?)
      end

      def operatingsystem_changed_for_recalculation?
        changed_by_legacy_api = respond_to?(:operatingsystem_id_changed?) && operatingsystem_id_changed?
        changed_by_dirty_tracking = respond_to?(:will_save_change_to_operatingsystem_id?) &&
                                    will_save_change_to_operatingsystem_id?
        changed_by_legacy_api || changed_by_dirty_tracking
      end

      def kickstart_repository_release_mismatch?
        repo_release = content_facet&.kickstart_repository&.distribution_version
        target_release = preferred_os_release_values.first
        return false if repo_release.blank? || target_release.blank?

        !(repo_release == target_release || repo_release.start_with?("#{target_release}."))
      end

      def equivalent_kickstart_repository_for_release(ks_repos)
        repos_by_id = indexed_kickstart_repositories(ks_repos)
        release_matches = nil

        preferred_os_release_values.each do |os_release|
          matches = ks_repos.select do |repo|
            repo_release = repos_by_id[repo[:id]]&.distribution_version
            repo_release == os_release || repo_release&.start_with?("#{os_release}.")
          end

          # Some repos keep generic distribution_version values across minor releases.
          # In those cases, use the repository label/name as a release hint.
          matches = ks_repos.select { |repo| repository_name_matches_release?(repo[:name], os_release) } if matches.blank?
          next if matches.blank?

          release_matches = matches
          break
        end
        return if release_matches.blank?

        equivalent_kickstart_repository_for_variant(release_matches, repos_by_id) || release_matches.first
      end

      def equivalent_kickstart_repository_for_variant(ks_repos, repos_by_id = indexed_kickstart_repositories(ks_repos))
        current_repo = content_facet&.kickstart_repository
        return if current_repo.blank?

        if current_repo.distribution_variant.present?
          same_variant = ks_repos.find do |repo|
            repos_by_id[repo[:id]]&.distribution_variant == current_repo.distribution_variant
          end
          return same_variant if same_variant
        end

        if current_repo.product_id.present?
          same_product = ks_repos.find do |repo|
            repos_by_id[repo[:id]]&.product_id == current_repo.product_id
          end
          return same_product if same_product
        end
      end

      def indexed_kickstart_repositories(ks_repos)
        Katello::Repository.where(id: ks_repos.map { |repo| repo[:id] }).index_by(&:id)
      end

      def effective_content_facet_for_kickstart(facet)
        return facet if ancestry.blank? || facet.blank?

        inherited_cvenv_id = inherited_ancestry_attribute(:content_view_environment_id, :content_facet)
        inherited_content_source_id = inherited_ancestry_attribute(:content_source_id, :content_facet)
        return facet if inherited_cvenv_id.blank? && inherited_content_source_id.blank?

        facet.dup.tap do |effective_facet|
          effective_facet.content_view_environment_id ||= inherited_cvenv_id
          effective_facet.content_source_id ||= inherited_content_source_id
        end
      end

      def preferred_os_release_values
        releases = []
        major = operatingsystem&.major.to_s.presence
        minor = operatingsystem&.minor.to_s.presence
        releases << "#{major}.#{minor}" if major && minor
        releases << operatingsystem.release if operatingsystem&.release.present?
        releases.uniq
      end

      def repository_name_matches_release?(repository_name, os_release)
        return false if repository_name.blank? || os_release.blank?

        normalized_name = repository_name.to_s.downcase
        release_tokens = [
          os_release,
          os_release.tr('.', '_'),
          os_release.tr('.', '-'),
        ].map(&:downcase).uniq
        release_tokens.any? { |token| normalized_name.include?(token) }
      end

      def inherited_ancestry_attribute(attribute, facet)
        value = self.send(facet)&.send(attribute)

        if value.nil? && ancestry.present?
          # take first non-null value for the attribute going up the ancestry tree.
          # example: you have hg1 -> hg11 -> hg111 -> hg1111 hostgroups.
          # given we are querying hg1111 (the leaf), and a value is set on:
          # hg1: 1
          # hg11: 2
          # it will return the value 2.
          facet_model = Facets.registered_facets[facet].hostgroup_configuration.model
          value = facet_model.where.not(attribute => nil).joins(:hostgroup).merge(
            ::Hostgroup.where(id: self.ancestor_ids).reorder(
              "#{::Hostgroup.table_name}.ancestry desc nulls last"
            )
          ).pick(attribute)
        end
        value
      end

      def safe_content_facet
        content_facet || build_content_facet
      end
    end
  end
end

class ::Hostgroup::Jail < Safemode::Jail
  allow :content_source, :rhsm_organization_label, :subscription_manager_configuration_url
end
