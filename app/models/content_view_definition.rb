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
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description

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
    PulpTaskStatus::wait_for_tasks(view.versions.first.generate_metadata)
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
    # Intended Behaviour
    # Includes are cumulative -> If you say include errata and include packages, its the sum
    # Excludes are processed after includes
    # Excludes dont handle dependency. So if you say Include errata with pkgs P1, P2
    #         and exclude P1  and P1 has a dependency P1d1, what gets copied over is P1d1, P2

    # Publish algorithm
    # Copy filtered puppet module over (with no deps)
    # Copy filtered errata over (with no deps)
    # Copy filtered pkg groups over (with no deps)
    # From the cloned repo get a list of pkgs belonging to those groups and errataa
    # Copy filtered pkgs + rpms from the previous step With the deps
    # Remove "excluded" rpms from the cloned
    # Remove "excluded" errata rpms from the cloned
    # Remove "excluded" package group rpms from the cloned
    # Remove empty errata and package groups
    # Index the cloned repo for search
    repo = cloned.library_instance_id ? cloned.library_instance : cloned
    async_tasks = []
    applicable_filters = filters.applicable(repo)
    errata_added = false
    package_groups_added = false
    [FilterRule::PUPPET_MODULE, FilterRule::ERRATA, FilterRule::PACKAGE_GROUP].each do |content_type|
      filter_clauses = association_clauses(repo, content_type)
      non_content_type_rule_count = case content_type
                                      when FilterRule::PACKAGE_GROUP
                                        FilterRule.non_package_group.whitelist.
                                          where(:filter_id => applicable_filters).count
                                      when FilterRule::ERRATA
                                        FilterRule.non_errata.whitelist.
                                          where(:filter_id => applicable_filters).count
                                      else
                                        0
                                      end

      if (filter_clauses && filter_clauses.size > 0) || non_content_type_rule_count == 0
        pulp_task = repo.clone_contents_by_filter(cloned, content_type, filter_clauses)
        async_tasks << pulp_task
        errata_added = true if content_type == FilterRule::ERRATA
        package_groups_added = true if content_type == FilterRule::PACKAGE_GROUP
      end
    end
    PulpTaskStatus::wait_for_tasks(async_tasks) if async_tasks.size > 0
    async_tasks = []

    package_inclusion_rules = PackageRule.whitelist.where(:filter_id => applicable_filters)
    package_exclusion_rules = PackageRule.blacklist.where(:filter_id => applicable_filters)

    package_inclusion_clauses = []
    package_inclusion_clauses << errata_package_clauses(cloned) if errata_added
    package_inclusion_clauses << group_package_clauses(cloned) if package_groups_added

    if package_inclusion_rules.count > 0
      package_inclusion_clauses << generate_clauses(repo, package_inclusion_rules, true)
    elsif FilterRule.non_package.whitelist.where(:filter_id => applicable_filters).count == 0
      package_inclusion_clauses << {"filename" => {"$exists" => true}}
    end
    package_inclusion_clauses =  package_inclusion_clauses.select {|cls| cls && (cls.size > 0)}

    package_clauses = []
    if package_inclusion_clauses.size > 0
      package_inclusion_clauses = package_inclusion_clauses.size > 1 ? {"$or" => package_inclusion_clauses} :
                                                                      package_inclusion_clauses.first
      package_clauses << package_inclusion_clauses
    end

    package_clauses << generate_clauses(repo, package_exclusion_rules, false) if package_exclusion_rules.count > 0

    package_clauses = package_clauses.size > 1 ? {"$and" => package_clauses} : package_clauses.first

    pulp_task =  repo.clone_contents_by_filter(cloned, FilterRule::PACKAGE,
                                                 package_clauses , :recursive => true)
    PulpTaskStatus::wait_for_tasks [pulp_task]

    # we now need to exclude what the user wants to exclude
    package_blacklist_clauses = []

    pg_black_list_rules = PackageGroupRule.blacklist.where(:filter_id => applicable_filters)
    if pg_black_list_rules.size > 0
      package_blacklist_clauses  << group_package_clauses_by_filter(
                             generate_clauses(repo, pg_black_list_rules, true))
    end


    errata_black_list_rules = ErratumRule.blacklist.where(:filter_id => applicable_filters)
    if errata_black_list_rules.size > 0
      package_blacklist_clauses  << errata_package_clauses_by_filter(
                        generate_clauses(repo, errata_black_list_rules, true))
    end

    package_blacklist_clauses  << generate_clauses(repo, package_exclusion_rules, true) if package_exclusion_rules.size > 0

    if package_blacklist_clauses.size > 0
      package_blacklist_clauses = package_blacklist_clauses.size > 1 ? {"$or" => package_blacklist_clauses} :
                                                                      package_blacklist_clauses.first
      pulp_task = cloned.unassociate_by_filter(FilterRule::PACKAGE, package_blacklist_clauses)
      PulpTaskStatus::wait_for_tasks [pulp_task]
    end

    cloned.purge_empty_groups_errata
    # update search indices for package and errata
    cloned.index_content if Katello.config.use_elasticsearch
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

  def errata_package_clauses(repo)
    ret = {}
    pkg_filenames = repo.errata.collect(&:package_filenames).flatten
    ret = {'filename' => {"$in" => pkg_filenames}} unless pkg_filenames.empty?
    ret
  end



  def errata_package_clauses_by_filter(errata_clauses)
    ret = {}
    unless errata_clauses.empty?
      pkg_filenames = Errata.list_by_filter_clauses(errata_clauses).collect(&:package_filenames).flatten
      ret = {'filename' => {"$in" => pkg_filenames}} unless pkg_filenames.empty?
    end
    ret
  end


  def group_package_clauses(repo)
    ret = {}
    pkg_names = repo.package_groups.collect(&:package_names).flatten
    ret = {'name' => {"$in" => pkg_names}} unless pkg_names.empty?
    ret
  end


  def group_package_clauses_by_filter(group_clauses)
    ret = {}
    unless group_clauses.empty?
      pkg_names = PackageGroup.list_by_filter_clauses(group_clauses).collect(&:package_names).flatten
      ret = {'name' => {"$in" => pkg_names}} unless pkg_names.empty?
    end
    ret
  end


  def association_clauses(repo, content_type)
    # find applicable filters
    # split filter rules by content type, since each content type has its own copy call
    # depending on include or exclude filters combine or remove
    applicable_filters = filters.applicable(repo)

    applicable_rules = FilterRule.class_for(content_type).where(:filter_id => applicable_filters)
    inclusion_rules = applicable_rules.where(:inclusion => true)
    exclusion_rules = applicable_rules.where(:inclusion => false)

    #   If there is no include/exclude filters  -  Everything is included. - so no filters
    return if inclusion_rules.count == 0 && exclusion_rules.count == 0


    #  If there are only exclude filters (aka blacklist filters),
    #  then
    #  If there are only include filters (aka whitelist) then only the packages/errata included will get included.
    #    Everything else is thus excluded.
    #  If there are include and exclude filters, the include filters, get processed first,
    #     then the exclude filter excludes content from the set included by the include filters.
    clauses = [generate_clauses(repo, inclusion_rules, true)] + [generate_clauses(repo, exclusion_rules, false)]
    clauses = clauses.compact
    if clauses.size > 1
      return {'$and' => clauses}
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
    end
  end

  def validate_filters
    filters.each do |f|
      f.validate_filter_products_and_repos(self.errors, self)
      break if errors.any?
    end
  end


  def generate_clauses(repo, rules, join_by_or)
    join_clause = join_by_or ? "$or" : "$nor"

    if rules.count > 0
      rule_items = rules.collect do |rule|
        rule.generate_clauses(repo)
      end.compact.flatten
      {join_clause => rule_items} unless rule_items.empty?
    end
  end

end
