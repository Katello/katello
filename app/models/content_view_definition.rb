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


class ContentViewDefinition < ContentViewDefinitionBase
  include Glue::ElasticSearch::ContentViewDefinition if Katello.config.use_elasticsearch
  include Ext::LabelFromName
  include Authorization::ContentViewDefinition
  include AsyncOrchestration

  has_many :content_views, :dependent => :destroy
  has_many :content_view_definition_archives, :foreign_key => :source_id
  alias :archives :content_view_definition_archives

  validates :label, :uniqueness => {:scope => :organization_id},
    :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
  validate :validate_content
  validate :validate_filters

  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label

  scope :composite, where(:composite=>true)
  scope :non_composite, where(:composite=>false)

  def publish(name, description, label=nil, options = { })
    options = { :async => true, :notify => false }.merge options

    view = ContentView.create!(:name => name,
                        :label=>label,
                        :description => description,
                        :content_view_definition => self,
                        :organization => organization
                       )

    version = ContentViewVersion.new(:version=>1, :content_view=>view)
    version.environments << organization.library
    version.save!

    if options[:async]
      async_task = self.async(:organization => self.organization,
                              :task_type => TaskStatus::TYPES[:content_view_publish][:type]).
                        generate_repos(view, options[:notify])

      version.task_status = async_task
      version.save!
    else
      version.task_status = nil
      version.save!
      generate_repos(view, options[:notify])
    end

    view
  end

  def generate_repos(view, notify = false)
    # Publish algorithm
    #
    # Copy all rpms over
    # Copy all errata over
    # Copy all pkg groups over
    # Copy all distro over
    # Start Filtering errata in the copied
    # Start Filtering package groups in the copied repo
    # Start Filtering packages in the copied repo
    # Remove all empty errata
    # Remove all empty package groups
    # Publish metadata
    async_tasks = []
    cloned_repos = []

    # Copy all rpms over
    # Copy all errata over
    # Copy all pkg groups over
    # Copy all distro over
    repos.each do |repo|
      clone = repo.create_clone(self.organization.library, view)
      async_tasks << repo.clone_contents(clone)
      cloned_repos << clone
    end
    PulpTaskStatus::wait_for_tasks async_tasks.flatten(1)

    # Start Filtering errata in the copied repo
    # Start Filtering package groups in the copied repo
    # Start Filtering packages in the copied repo
    unassociate_contents(cloned_repos)

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

  # Runs through the filtering process
  # and unassociates contents dictated
  # by the filters and filter rules
  def unassociate_contents(repos)
    # Start Filtering errata in the copied repo
    # Start Filtering package groups in the copied repo
    # Start Filtering packages in the copied repo
    repos.each do |repo|
      [FilterRule::ERRATA, FilterRule::PACKAGE_GROUP, FilterRule::PACKAGE].each do |content_type|
        filter_clauses = unassociation_clauses(repo.library_instance, content_type)
        if filter_clauses
          pulp_task = repo.unassociate_by_filter(content_type, filter_clauses)
          PulpTaskStatus::wait_for_tasks [pulp_task]
        end
      end
    end

    repos.each do |repo|
      repo.purge_empty_groups_errata
      # update search indices for package and errata
      repo.index_content
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
    excluded = ["type", "created_at", "updated_at"]
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
    # TODO: copy filters
    new_definition.save!

    new_definition
  end

  protected

  def unassociation_clauses(repo, content_type)
    # find applicable filters
    # split filter rules by content type, since each content type has its own copy call
    # depending on include or exclude filters combine or remove
    applicable_filters = filters.applicable(repo)

    applicable_rules = FilterRule.class_for(content_type).where(:filter_id => applicable_filters)
    inclusion_rules = applicable_rules.where(:inclusion => true)
    exclusion_rules = applicable_rules.where(:inclusion => false)

    #   If there is no include/exclude filters  -  Everything is included. - so do not delete anything
    return if inclusion_rules.count == 0 && exclusion_rules.count == 0


    #  If there are only exclude filters (aka blacklist filters),
    #  then unassociate them from the repo
    #  If there are only include filters (aka whitelist) then only the packages/errata included will get included.
    #    Everything else is thus excluded.
    #  If there are include and exclude filters, the exclude filters then the include filters, get processed first,
    #     then the exclude filter excludes content from the set included by the include filters.
    clauses = [generate_clauses(repo, inclusion_rules, true)] + [generate_clauses(repo, exclusion_rules, false)]
    clauses = clauses.compact
    if clauses.size > 1
      return {'$or' => clauses}
    elsif clauses.size == 1
      return clauses.first
    end
  end

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
    elsif has_component_views? && !self.composite?
      errors.add(:base, _("cannot contain views if not composite definition"))
    end
  end

  def validate_filters
    filters.each do |f|
      f.validate_filter_products_and_repos(self.errors, self)
      break if errors.any?
    end
  end


  def generate_clauses(repo, rules, inclusion = true)
    join_clause = "$nor"
    join_clause = "$or" unless inclusion

    if rules.count > 0
      rule_items = rules.collect do |rule|
        rule.generate_clauses(repo)
      end.compact.flatten
      {join_clause => rule_items} unless rule_items.empty?
    end
  end

end
