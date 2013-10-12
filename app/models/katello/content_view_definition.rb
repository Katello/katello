#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
class ContentViewDefinition < ContentViewDefinitionBase
  include Glue::ElasticSearch::ContentViewDefinition if Katello.config.use_elasticsearch
  include Ext::LabelFromName
  include Authorization::ContentViewDefinition
  include AsyncOrchestration

  has_many :content_views, :dependent => :destroy
  has_many :content_view_definition_archives, :foreign_key => :source_id, :dependent => :destroy
  alias_method :archives, :content_view_definition_archives

  validates :label, :uniqueness => {:scope => :organization_id},
                    :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
  validate :validate_content
  validate :validate_filters

  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description

  scope :composite, where(:composite => true)
  scope :non_composite, where(:composite => false)

  # TODO: break up method
  # rubocop:disable MethodLength
  def publish(name, description, label = nil, options = {})
    fail _("Cannot publish definition. Please check for repository conflicts.") if !ready_to_publish?
    options = { :async => true, :notify => false }.merge options

    view = ContentView.create!(:name => name,
                               :label => label,
                               :description => description,
                               :content_view_definition => self,
                               :organization => organization
                       )

    version = ContentViewVersion.new(:version => 1, :content_view => view)
    version.environments << organization.library
    version.save!

    if options[:async]
      async_task = self.async(:organization => self.organization,
                              :task_type => TaskStatus::TYPES[:content_view_publish][:type]).
                        generate_repos(view, options[:notify])

      version.task_status = async_task
      version.save!
    else
      # We need to track the status for even the non async case because
      # the lack of a task status is automatically implied as a failure
      # by the UI.
      # At present sync publish call is used by the migration script.
      # but it makes sense for this to be the general behavior.
      version.task_status = ::TaskStatus.create!(
                               :uuid => ::UUIDTools::UUID.random_create.to_s,
                               :user_id => ::User.current.id,
                               :organization => self.organization,
                               :state => ::TaskStatus::Status::WAITING,
                               :task_type => TaskStatus::TYPES[:content_view_publish][:type])
      version.save!
      begin
        generate_repos(view, options[:notify])
        version.task_status.update_attributes!(:state => ::TaskStatus::Status::FINISHED)
      rescue => e
        version.task_status.update_attributes!(:state => ::TaskStatus::Status::ERROR)
        raise e
      end
    end
    view
  end

  def generate_repos(view, notify = false)
    repos.each do |repo|
      cloned = repo.create_clone(self.organization.library, view)
      associate_contents(cloned)
    end
    view.update_cp_content(view.organization.library)
    view.versions.first.trigger_repository_changes
    Glue::Event.trigger(Katello::Actions::ContentViewPublish, view)

    if notify
      message = _("Successfully published content view '%{view_name}' from definition '%{definition_name}'.") %
          {:view_name => view.name, :definition_name => self.name}

      Notify.success(message, :request_type => "content_view_definitions___publish",
                              :organization => self.organization)
    end
  rescue => e
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))

    if notify
      message = _("Failed to publish content view '%{view_name}' from definition '%{definition_name}'.") %
          {:view_name => view.name, :definition_name => self.name}

      Notify.exception(message, e, :request_type => "content_view_definitions___publish",
                                   :organization => self.organization)
    end

    raise e
  end

  def associate_contents(cloned)
    if cloned.puppet?
      associate_puppet(cloned)
    else
      associate_yum_types(cloned)
    end
  end

  def has_promoted_views?
    !! self.content_views.promoted.first
  end

  def has_repo_conflicts?
    # Check to see if there is a repo conflict in the component views associated with
    # the definition.  A conflict exists if the same repo exists in more than
    # one of those component views.
    if self.composite?
      repos_hash = self.views_repos
      repos_hash.each do |view_id, repo_ids|
        repos_hash.each do |other_view_id, other_repo_ids|
          return true if (view_id != other_view_id) && !repo_ids.intersection(other_repo_ids).empty?
        end
      end
    end
    false
  end

  def has_puppet_repo_conflicts?
    # Check to see if there is a puppet conflict in the component views
    # associated with the definition.  A conflict exists if more than one view
    # has a puppet repo
    if self.composite?
      repos = component_content_views.map { |view| view.repos(organization.library) }.flatten
      return repos.select(&:puppet?).length > 1
    end
    false
  end

  def ready_to_publish?
    !has_puppet_repo_conflicts? && !has_repo_conflicts?
  end

  #NOTE: this function will most likely become obsolete once we drop api v1
  def as_json(options = {})
    result = self.attributes
    result["organization"] = self.organization.try(:name)
    result["content_views"] = self.content_views.map(&:name)
    result["components"] = self.component_content_views.map(&:name)
    result["products"] = products.map(&:name)
    result["repos"] = repositories.map(&:name)
    result
  end

  def archive
    excluded = %w(type created_at updated_at)
    cvd_archive = ContentViewDefinitionArchive.new(self.attributes.except(*excluded))

    cvd_archive.repositories            = self.repositories
    cvd_archive.products                = self.products
    cvd_archive.component_content_views = self.component_content_views
    cvd_archive.filters                 = self.filters.reload.map(&:clone_for_archive)
    cvd_archive.source_id               = self.id
    cvd_archive.save!

    cvd_archive
  end

  def copy(new_attrs = {})
    new_definition = ContentViewDefinition.new
    new_definition.attributes = new_attrs.slice(:name, :label, :description)
    new_definition.composite = self.composite
    new_definition.organization = self.organization
    new_definition.products = self.products
    new_definition.repositories = self.repositories
    new_definition.component_content_views = self.component_content_views
    new_definition.save!

    self.filters.each do |filter|
      new_filter = filter.dup
      new_filter.products = filter.products
      new_filter.repositories = filter.repositories
      filter.rules.each do |rule|
        new_filter.rules << rule.dup
      end
      new_definition.filters << new_filter
    end
    new_definition.save!

    new_definition
  end

  protected

  def views_repos
    # Retrieve a hash where, key=view.id and value=Set(view's repo library instance ids)
    self.component_content_views.inject({}) do |view_repos, view|
      view_repos.update view.id => view.repos(self.organization.library).
          inject(Set.new) { |ids, repo| ids << repo.library_instance_id }
    end
  end

  private

  def validate_content
    if has_content? && self.composite?
      errors.add(:base, _("cannot contain products, or repositories if composite definition"))
    end
  end

  def validate_filters
    filters.each do |f|
      f.validate_filter_products_and_repos(self.errors, self)
      break if errors.any?
    end
  end

  def associate_puppet(cloned)
    repo = cloned.library_instance_id ? cloned.library_instance : cloned
    applicable_filters = filters.applicable(repo)

    applicable_rules_count = PuppetModuleRule.where(:filter_id => applicable_filters).count
    copy_clauses = nil

    if applicable_rules_count > 0
      clause_gen = Util::PuppetClauseGenerator.new(repo, applicable_filters)
      clause_gen.generate
      copy_clauses = clause_gen.copy_clause
    end

    # final check here, if copy_clauses is nil there were
    # rules for this set of filters
    # This means none of the filter rules were successful in generating clauses.
    # This implies that there are no packages to copy over.

    if applicable_rules_count == 0 || copy_clauses
      pulp_task = repo.clone_contents_by_filter(cloned, FilterRule::PUPPET_MODULE, copy_clauses)
      PulpTaskStatus.wait_for_tasks([pulp_task])
    end
  end

  def associate_yum_types(cloned)
    # Intended Behaviour
    # Includes are cumulative -> If you say include errata and include packages, its the sum
    # Excludes are processed after includes
    # Excludes dont handle dependency. So if you say Include errata with pkgs P1, P2
    #         and exclude P1  and P1 has a dependency P1d1, what gets copied over is P1d1, P2

    # Another important aspect. PackageGroups & Errata are merely convinient ways to say "copy packages"
    # Its all about the packages

    # Algorithm:
    # 1) Compute all the packages to be whitelist/blacklist. In this process grok all the packages
    #    belonging to Errata/Package  groups etc  (work done by PackageClauseGenerator)
    # 2) Copy Packages (Whitelist - Blacklist) with their dependencies
    # 3) Unassociate the blacklisted items from the clone. This is so that if the deps were among
    #    the blacklisted packages, they would have gotten copied along in the previous step.
    # 4) Copy all errata and package groups
    # 5) Prune errata and package groups that have no existing packagea in the cloned repo
    # 6) Index for search.

    repo = cloned.library_instance_id ? cloned.library_instance : cloned
    applicable_filters = filters.applicable(repo)
    applicable_rules_count = FilterRule.yum_types.where(:filter_id => applicable_filters).count
    copy_clauses = nil
    remove_clauses = nil
    process_errata_and_groups = false

    if applicable_rules_count > 0
      clause_gen = Util::PackageClauseGenerator.new(repo, applicable_filters)
      clause_gen.generate
      copy_clauses = clause_gen.copy_clause
      remove_clauses = clause_gen.remove_clause
    end

    # final check here, if copy_clauses is nil AND there were
    # rules for this set of filters
    # This means none of the filter rules were successful in generating clauses.
    # This implies that there are no packages to copy over.

    if applicable_rules_count == 0 || copy_clauses
      pulp_task = repo.clone_contents_by_filter(cloned, FilterRule::PACKAGE, copy_clauses)
      PulpTaskStatus.wait_for_tasks([pulp_task])
      process_errata_and_groups = true
    end

    if remove_clauses
      pulp_task = cloned.unassociate_by_filter(FilterRule::PACKAGE, remove_clauses)
      PulpTaskStatus.wait_for_tasks([pulp_task])
      process_errata_and_groups = true
    end

    if process_errata_and_groups
      group_tasks = [FilterRule::ERRATA, FilterRule::PACKAGE_GROUP].collect do |content_type|
        repo.clone_contents_by_filter(cloned, content_type, nil)
      end
      PulpTaskStatus.wait_for_tasks(group_tasks)
      cloned.purge_empty_groups_errata
    end

    PulpTaskStatus.wait_for_tasks([repo.clone_distribution(cloned)])
    PulpTaskStatus.wait_for_tasks([repo.clone_file_metadata(cloned)])
  end
end
end
