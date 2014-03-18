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
class ContentView < Katello::Model
  self.include_root_in_json = false

  include Ext::LabelFromName
  include Authorization::ContentView
  include Glue::ElasticSearch::ContentView if Katello.config.use_elasticsearch
  include AsyncOrchestration
  include Glue::Event
  include ForemanTasks::Concerns::ActionSubject

  CONTENT_DIR = "content_views"

  before_destroy :confirm_not_promoted # RAILS3458: this needs to come before associations

  belongs_to :organization, :inverse_of => :content_views, :class_name => "::Organization"

  has_many :content_view_environments, :class_name => "Katello::ContentViewEnvironment", :dependent => :destroy
  has_many :environments, :class_name => "Katello::KTEnvironment", :through => :content_view_environments

  has_many :content_view_versions, :class_name => "Katello::ContentViewVersion", :dependent => :destroy
  alias_method :versions, :content_view_versions

  has_many :content_view_components, :class_name => "Katello::ContentViewComponent", :dependent => :destroy
  has_many :components, :through => :content_view_components, :class_name => "Katello::ContentViewVersion",
    :source => :content_view_version do
    def <<(*args)
      # this doesn't go through validation and generate a nice error message
      fail "Adding components without doing validation is not supported"
    end
  end

  has_many :distributors, :class_name => "Katello::Distributor", :dependent => :restrict
  has_many :content_view_repositories, :dependent => :destroy
  has_many :repositories, :through => :content_view_repositories, :class_name => "Katello::Repository",
           :after_remove => :remove_repository,
           :after_add => :add_repository

  has_many :content_view_puppet_modules, :class_name => "Katello::ContentViewPuppetModule",
           :dependent => :destroy
  alias_method :puppet_modules, :content_view_puppet_modules

  has_many :filters, :dependent => :destroy, :class_name => "Katello::ContentViewFilter"

  has_many :activation_keys, :class_name => "Katello::ActivationKey", :dependent => :restrict
  has_many :systems, :class_name => "Katello::System", :dependent => :restrict

  validates :label, :uniqueness => {:scope => :organization_id},
                    :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
  validates :organization_id, :presence => true
  validate :check_repo_conflicts
  validate :check_puppet_conflicts

  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label

  scope :default, where(:default => true)
  scope :non_default, where(:default => false)
  scope :composite, where(:composite => true)

  def self.in_environment(env)
    joins(:content_view_environments).
      where("#{Katello::ContentViewEnvironment.table_name}.environment_id = ?", env.id)
  end

  def self.promoted(safe = false)
    # retrieve the view, if it has been promoted (i.e. exists in more than 1 environment)
    relation = select("distinct #{Katello::ContentView.table_name}.*").
               joins(:content_view_versions => :environments).
               where("#{Katello::KTEnvironment.table_name}.library" => false).
               where("#{Katello::ContentView.table_name}.default" => false)

    if safe
      # do not include group and having in returned relation
      self.where :id => relation.all.map(&:id)
    else
      relation
    end
  end

  def to_s
    name
  end

  def promoted?
    # if the view exists in more than 1 environment, it has been promoted
    self.environments.length > 1 ? true : false
  end

  #NOTE: this function will most likely become obsolete once we drop api v1
  def as_json(options = {})
    result = self.attributes
    result['organization'] = self.organization.try(:name)
    result['environments'] = environments.map{|e| e.try(:name)}
    result['versions'] = versions.map(&:version)
    result['versions_details'] = versions.map do |v|
      {
        :version => v.version,
        :published => v.created_at.to_s,
        :environments => v.environments.map{|e| e.name}
      }
    end

    if options && options[:environment].present?
      result['repositories'] = repos(options[:environment]).map(&:name)
    end

    result
  end

  def in_environment?(env)
    environments.include?(env)
  end

  def version(env)
    self.versions.in_environment(env).order("#{Katello::ContentViewVersion.table_name}.id ASC").scoped(:readonly => false).last
  end

  def history
    Katello::ContentViewHistory.joins(:content_view_version).where(
        "#{Katello::ContentViewVersion.table_name}.content_view_id" => self.id)
  end

  def version_environment(env)
    # TODO: rewrite this into SQL or use content_view_environment when that
    # points to environment
    version(env).content_view_version_environments.select {|cvve| cvve.environment_id == env.id}
  end

   def resulting_products
     (self.repositories.collect{|r| r.product}).uniq
   end

  def repos(env)
    if env
      repo_ids = versions.flat_map { |version| version.repositories.in_environment(env) }.map(&:id)
    else
      repo_ids = []
    end
    Repository.where(:id => repo_ids)
  end

  def puppet_env(env)
    if env
      ids = versions.flat_map { |version| version.content_view_puppet_environments.in_environment(env) }.map(&:id)
    else
      ids = []
    end
    ContentViewPuppetEnvironment.where(:id => ids).first
  end

  def  puppet_repos
    # These are the repos that may contain puppet modules that can be associated with the content view
    self.organization.library.repositories.puppet_type
  end

  def library_repos
    Repository.where(:id => library_repo_ids)
  end

  def library_repo_ids
    repos(self.organization.library).map { |r| r.library_instance_id }
  end

  def all_version_repos
    Repository.joins(:content_view_version).
      where("#{Katello::ContentViewVersion.table_name}.content_view_id" => self.id)
  end

  def repositories_to_publish
    if composite?
      ids = components.flat_map { |version| version.repositories.archived }.map(&:id)
      Repository.where(:id => ids)
    else
      repositories
    end
  end

  def repositories_to_publish_ids
    composite? ? repositories_to_publish.pluck(&:id) : repository_ids
  end

  def puppet_modules_to_publish
    if composite?
      components.flat_map { |version| version.puppet_modules }
    else
      content_view_puppet_modules
    end
  end

  def repos_in_product(env, product)
    version = version(env)
    if version
      version.repositories.in_environment(env).in_product(product)
    else
      []
    end
  end

  def products(env)
    repos = repos(env)
    Product.joins(:repositories).where("#{Katello::Repository.table_name}.id" => repos.map(&:id)).uniq
  end

  def version_products(env)
    repos = repos(env)
    Product.joins(:repositories).where("#{Katello::Repository.table_name}.id" => repos.map(&:id)).uniq
  end

  #list all products associated to this view across all versions
  def all_version_products
    Product.joins(:repositories).where("#{Katello::Repository.table_name}.id" => self.all_version_repos).uniq
  end

  #get the library instances of all repos within this view
  def all_version_library_instances
    all_repos = all_version_repos.where(:library_instance_id => nil).pluck("#{Katello::Repository.table_name}.id")
    all_repos += all_version_repos.pluck(:library_instance_id)
    Repository.where(:id => all_repos)
  end

  def get_repo_clone(env, repo)
    lib_id = repo.library_instance_id || repo.id
    Repository.in_environment(env).where(:library_instance_id => lib_id).
        joins(:content_view_version).
        where("#{Katello::ContentViewVersion.table_name}.content_view_id" => self.id)
  end

  def delete(from_env)
    if from_env.library? && in_non_library_environment?
      fail Errors::ChangesetContentException.new(_("Cannot delete view while it exists in environments"))
    end

    version = self.version(from_env)
    if version.nil?
      fail Errors::ChangesetContentException.new(_("Cannot delete from %s, view does not exist there.") % from_env.name)
    end
    version = ContentViewVersion.find(version.id)

    Glue::Event.trigger(Katello::Actions::ContentViewDemote, self, from_env)

    if foreman_env = Environment.find_by_katello_id(self.organization, from_env, self)
      foreman_env.destroy
    end

    version.delete(from_env)
    self.destroy if self.versions.empty?
  end

  def in_non_library_environment?
    environments.where(:library => false).length > 0
  end

  def publish(options = { })
    fail "Cannot publish content view without a logged in user." if User.current.nil?
    options = { :async => true, :notify => false }.merge(options)

    version = create_new_version

    if options[:async]
      task  = self.async(:organization => self.organization,
                         :task_type => TaskStatus::TYPES[:content_view_publish][:type]).
        publish_content(version, options[:notify])

      version.task_status = task
      version.save!
    else
      version.create_task_status!(
        :uuid => ::UUIDTools::UUID.random_create.to_s,
        :user_id => ::User.current.try(:id),
        :organization => self.organization,
        :state => Katello::TaskStatus::Status::WAITING,
        :task_type => TaskStatus::TYPES[:content_view_publish][:type]
      )

      begin
        publish_content(version, options[:notify])
        version.task_status.update_attributes!(:state => Katello::TaskStatus::Status::FINISHED)
      rescue => e
        version.task_status.update_attributes!(:state => Katello::TaskStatus::Status::ERROR)
        raise e
      end
    end
    version
  end

  def publish_content(version, notify = false)
    # 1. generate the version repositories
    publish_version_content(version)

    # 2. generate the library repositories
    publish_library_yum_content(version)
    publish_library_puppet_content(version)

    # 3. update candlepin, etc
    update_cp_content(self.organization.library)

    clone_overrides = self.repositories.select{|r| self.filters.applicable(r).empty?}
    version.trigger_contents_changed(:cloned_repo_overrides => clone_overrides, :non_archive => true)

    Katello::Foreman.update_foreman_content(self.organization, self.organization.library, self)

    if notify
      message = _("Successfully published content view '%s'.") % name
      Notify.success(message, :request_type => "content_view___publish",
                              :organization => self.organization)
    end
  rescue => e
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))

    if notify
      message = _("Failed to publish content view '%s'.") % self.name
      Notify.exception(message, e, :request_type => "content_view___publish",
                                   :organization => self.organization)
    end

    raise e
  end

  def publish_library_yum_content(version)

    # prepare the yum repos currently in the library for the publish
    async_tasks = []
    repos(organization.library).each do |repo|
      if repositories_to_publish_ids.include?(repo.library_instance_id)
        repo.content_view_version_id = version.id
        repo.save!

        # this repo is in both the content view and in the library,
        # so clear it and later we'll regenerate the content... this is more
        # efficient than deleting the repo and recreating it...
        async_tasks += repo.clear_contents
      else
        # this repo no longer exists in the view, so destroy it
        repo.destroy
      end
    end
    PulpTaskStatus.wait_for_tasks async_tasks unless async_tasks.blank?

    async_tasks = []
    repos_to_filter = []
    repositories_to_publish.each do |repo|
      # the repos from the content view are based upon initial synced repos, we need to
      # determine if each of those repos has been cloned in library
      library_clone = get_repo_clone(organization.library, repo).first
      if library_clone.nil?
        # this repo doesn't currently exist in the library
        clone = repo.create_clone(:environment => organization.library, :content_view => self)
        repos_to_filter << clone
      else
        # this repo already exists in the library, so update it
        library_clone = Repository.find(library_clone) # reload readonly obj
        repos_to_filter << library_clone
      end
    end

    repos_to_filter.each do |repo|
      associate_yum_content(repo) unless repo.puppet?
    end

    PulpTaskStatus.wait_for_tasks async_tasks unless async_tasks.blank?
  end

  def publish_library_puppet_content(version)
    # prepare the puppet environment currently in the library for the publish
    async_tasks = []
    if puppet_env = puppet_env(organization.library)
      if !content_view_puppet_modules.empty?
        puppet_env.content_view_version_id = version.id
        puppet_env.save!

        # this puppet environment has been previously published and the version
        # being published has puppet modules, so clear it and later we'll
        # regenerate the content... this is more efficient than deleting the
        # env/repo and recreating it...
        async_tasks += puppet_env.clear_contents
      else
        # this content view doesn't contain any puppet modules, so destroy
        # the environment
        puppet_env.destroy
      end
    end
    PulpTaskStatus.wait_for_tasks async_tasks unless async_tasks.blank?

    unless content_view_puppet_modules.empty?
      unless puppet_env
        puppet_env = create_puppet_env(:environment => organization.library, :content_view => self)
      end
      associate_puppet_content(puppet_env)
    end

    PulpTaskStatus.wait_for_tasks async_tasks unless async_tasks.blank?
  end

  def publish_version_content(version)
    repositories_to_publish.each do |repo|
      clone = repo.create_clone(:content_view => self, :version => version)
      associate_yum_content(clone)
    end

    unless content_view_puppet_modules.empty?
      puppet_env = create_puppet_env(:content_view => self, :version => version)
      associate_puppet_content(puppet_env)
    end

    clone_overrides = repositories_to_publish.select{|r| self.filters.applicable(r).empty?}
    version.trigger_contents_changed(:cloned_repo_overrides => clone_overrides, :wait => true)
  end

  def duplicate_repositories
    counts = repositories_to_publish.each_with_object(Hash.new(0)) do |repo, h|
      h[repo.library_instance_id] += 1
    end
    ids = counts.select { |k, v| v > 1 }.keys
    Repository.where(:id => ids)
  end

  def duplicate_puppet_modules
    counts = puppet_modules_to_publish.each_with_object(Hash.new(0)) do |puppet_module, h|
      h[puppet_module.name] += 1
    end
    counts.select { |k, v| v > 1 }.keys
  end

  def check_repo_conflicts
    duplicate_repositories.each do |repo|
      versions = components.with_library_repo(repo).uniq.map(&:name).join(", ")
      msg = _("Repository conflict: '%{repo}' is in %{versions}.") % {repo: repo.name, versions: versions}
      errors.add(:base, msg)
    end
  end

  def check_puppet_conflicts
    duplicate_puppet_modules.each do |name|
      versions = components.select { |v| v.puppet_modules.map(&:name).include?(name) }
      names = versions.map(&:name).join(", ")
      msg = _("Puppet module conflict: '%{mod}' is in %{versions}.") % {mod: name, versions: names}
      errors.add(:base, msg)
    end
  end

  def content_view_environment(environment)
    self.content_view_environments.where(:environment_id => environment.id).first
  end

  def update_cp_content(env)
    view_env = content_view_environment(env)
    view_env.update_cp_content if view_env
  end

  # Associate an environment with this content view.  This can occur whenever
  # a version of the view is promoted to an environment.  It is necessary for
  # candlepin to become aware that the view is available for consumers.
  def add_environment(env, version)
    if self.content_view_environments.where(:environment_id => env.id).empty?
      label = generate_cp_environment_label(env)
      ContentViewEnvironment.create!(:name => label,
                                     :label => label,
                                     :cp_id => generate_cp_environment_id(env),
                                     :environment_id => env.id,
                                     :content_view => self,
                                     :content_view_version => version
                                    )
    end
  end

  # Unassociate an environment from this content view. This can occur whenever
  # a view is deleted from an environment. It is necessary to make candlepin
  # aware that the view is no longer available for consumers.
  def remove_environment(env)
    # Do not remove the content view environment, if there is still a view
    # version in the environment.
    if self.versions.in_environment(env).blank?
      view_env = self.content_view_environments.where(:environment_id => env.id)
      view_env.first.destroy unless view_env.blank?
    end
  end

  def cp_environment_label(env)
    ContentViewEnvironment.where(:content_view_id => self, :environment_id => env).first.label
  end

  def cp_environment_id(env)
    ContentViewEnvironment.where(:content_view_id => self, :environment_id => env).first.cp_id
  end

  def create_new_version
    next_version_id = (self.versions.maximum(:version) || 0) + 1
    ContentViewVersion.create!(:version => next_version_id,
                               :content_view => self,
                               :environments => [organization.library])
  end

  def create_puppet_env(options)
    if options[:environment] && options[:version]
      fail "Cannot create into both an environment and a content view version archive"
    end

    to_env       = options[:environment]
    version      = options[:version]
    content_view = options[:content_view] || to_env.default_content_view
    to_version   = version || content_view.version(to_env)

    # Construct the pulp id using org/view/version or org/env/view
    pulp_id = ContentViewPuppetEnvironment.generate_pulp_id(organization.label, to_env.try(:label),
                                                            self.label, version.try(:version))

    ContentViewPuppetEnvironment.create!(:environment => to_env,
                                         :content_view_version => to_version,
                                         :name => self.name,
                                         :pulp_id => pulp_id)
  end

  protected

  def remove_repository(repository)
    filters.each do |filter_item|
      repo_exists = Repository.unscoped.joins(:filters).where(
          ContentViewFilter.table_name => {:id => filter_item.id}, :id => repository.id).count
      if repo_exists
        filter_item.repositories.delete(repository)
        filter_item.save!
      end
    end

    reindex_on_association_change(repository) if Katello.config.use_elasticsearch
  end

  def add_repository(repository)
    reindex_on_association_change(repository) if Katello.config.use_elasticsearch
  end

  private

  def generate_cp_environment_label(env)
    # The label for a default view, will simply be the env label; otherwise, it
    # will be a combination of env and view label.  The reason being, the label
    # for a default view is internally generated (e.g. 'Default_View_for_dev')
    # and we do not need to expose it to the user.
    self.default ? env.label : [env.label, self.label].join('/')
  end

  def generate_cp_environment_id(env)
    # The id for a default view, will simply be the env id; otherwise, it
    # will be a combination of env id and view id.  The reason being,
    # for a default view, the same candlepin environment will be referenced
    # by the kt_environment and content_view_environment.
    self.default ? env.id.to_s : [env.id, self.id].join('-')
  end

  def confirm_not_promoted
    if promoted?
      errors.add(:base, _("cannot be deleted if it has been promoted."))
      return false
    end
    return true
  end

  def associate_puppet_content(puppet_env)
    unless content_view_puppet_modules.empty?
      # In order to copy the puppet modules to the new repo, we need to retrieve the module
      # details.  This is necessary since pulp requires both a source and destination
      # repo id to copy content.
      ids = []
      names_and_authors = []
      content_view_puppet_modules.each do |cvpm|
        if cvpm.uuid
          ids << cvpm.uuid
        else
          names_and_authors << { :name => cvpm.name, :author => cvpm.author }
        end
      end

      puppet_modules = ids.blank? ? [] : PuppetModule.id_search(ids)
      unless names_and_authors.blank?
        puppet_modules << PuppetModule.latest_modules_search(names_and_authors,
                                                             self.organization.library.repositories.puppet_type.map(&:pulp_id))
      end

      # In order to minimize the number of copy requests, organize the data by repoid.
      modules_by_repoid = puppet_modules.flatten.each_with_object({}) do |puppet_module, result|
        result[puppet_module.repoids.first] ||= []
        result[puppet_module.repoids.first] << puppet_module.id
      end

      async_tasks = []
      modules_by_repoid.each_pair do |repoid, puppet_module_ids|
        async_tasks << Katello.pulp_server.extensions.puppet_module.copy(repoid,
                                                                         puppet_env.pulp_id,
                                                                         :ids => puppet_module_ids)
      end
      PulpTaskStatus.wait_for_tasks(async_tasks)
    end
  end

  def associate_yum_content(cloned)
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
    applicable_filters = filters.applicable(repo).yum
    copy_clauses = nil
    remove_clauses = nil
    process_errata_and_groups = false

    if applicable_filters.any?
      clause_gen = Util::PackageClauseGenerator.new(repo, applicable_filters)
      clause_gen.generate
      copy_clauses = clause_gen.copy_clause
      remove_clauses = clause_gen.remove_clause
    end

    if applicable_filters.empty? || copy_clauses
      pulp_task = repo.clone_contents_by_filter(cloned, ContentViewFilter::PACKAGE, copy_clauses)
      PulpTaskStatus.wait_for_tasks([pulp_task])
      process_errata_and_groups = true
    end

    if remove_clauses
      pulp_task = cloned.unassociate_by_filter(ContentViewFilter::PACKAGE, remove_clauses)
      PulpTaskStatus.wait_for_tasks([pulp_task])
      process_errata_and_groups = true
    end

    if process_errata_and_groups
      group_tasks = [ContentViewFilter::ERRATA, ContentViewFilter::PACKAGE_GROUP].collect do |content_type|
        repo.clone_contents_by_filter(cloned, content_type, nil)
      end
      PulpTaskStatus.wait_for_tasks(group_tasks)
      cloned.purge_empty_groups_errata
    end

    PulpTaskStatus.wait_for_tasks([repo.clone_distribution(cloned)])
    PulpTaskStatus.wait_for_tasks([repo.clone_file_metadata(cloned)])
  end

  def related_resources
    self.organization
  end
end
end
