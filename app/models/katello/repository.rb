#
# Copyright 2014 Red Hat, Inc.
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
class Repository < Katello::Model
  self.include_root_in_json = false

  before_destroy :assert_deletable

  include ForemanTasks::Concerns::ActionSubject
  include Glue::Candlepin::Content if (Katello.config.use_cp && Katello.config.use_pulp)
  include Glue::Pulp::Repo if Katello.config.use_pulp
  include Glue::ElasticSearch::Repository if Katello.config.use_elasticsearch

  include Glue if (Katello.config.use_cp || Katello.config.use_pulp)
  include Authorization::Repository

  include AsyncOrchestration
  include Ext::LabelFromName
  include Katello::Engine.routes.url_helpers

  YUM_TYPE = 'yum'
  FILE_TYPE = 'file'
  PUPPET_TYPE = 'puppet'
  TYPES = [YUM_TYPE, FILE_TYPE, PUPPET_TYPE]
  SELECTABLE_TYPES = [YUM_TYPE, PUPPET_TYPE]

  belongs_to :environment, :inverse_of => :repositories, :class_name => "Katello::KTEnvironment"
  belongs_to :product, :inverse_of => :repositories
  belongs_to :gpg_key, :inverse_of => :repositories
  belongs_to :library_instance, :class_name => "Katello::Repository", :inverse_of => :library_instances_inverse
  has_many :library_instances_inverse, # TODOp what is the proper name?
           :class_name  => 'Katello::Repository',
           :dependent   => :restrict,
           :foreign_key => :library_instance_id
  has_many :content_view_repositories, :class_name => "Katello::ContentViewRepository",
           :dependent => :destroy
  has_many :content_views, :through => :content_view_repositories
  # rubocop:disable HasAndBelongsToMany
  # TODO: change this into has_many :through association
  has_and_belongs_to_many :filters, :class_name => "Katello::ContentViewFilter",
                          :join_table => :katello_content_view_filters_repositories,
                          :foreign_key => :content_view_filter_id
  belongs_to :content_view_version, :inverse_of => :repositories

  validates :name, :presence => true
  validates :label, :presence => true
  validates :product_id, :presence => true
  validates :pulp_id, :presence => true, :uniqueness => true
  #validates :content_id, :presence => true #add back after fixing add_repo orchestration
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::RepositoryUniqueAttributeValidator, :attributes => :label
  validates_with Validators::RepositoryUniqueAttributeValidator, :attributes => :name
  validates_with Validators::KatelloUrlFormatValidator,
    :attributes => :url, :nil_allowed => proc { |o| o.custom? }, :field_name => :url,
    :if => proc { |o| o.in_default_view? }
  validates :content_type, :inclusion => {
      :in => TYPES,
      :allow_blank => false,
      :message => (_("Please select content type from one of the following: %s") % TYPES.join(', '))
  }

  default_scope order("#{Katello::Repository.table_name}.name ASC")
  scope :has_url, where('url IS NOT NULL')
  scope :in_default_view, joins(:content_view_version => :content_view).
    where("#{Katello::ContentView.table_name}.default" => true)

  scope :yum_type, where(:content_type => YUM_TYPE)
  scope :file_type, where(:content_type => FILE_TYPE)
  scope :puppet_type, where(:content_type => PUPPET_TYPE)
  scope :non_puppet, where("content_type != ?", PUPPET_TYPE)
  scope :non_archived, where('environment_id is not NULL')
  scope :archived, where('environment_id is NULL')

  def organization
    if self.environment
      self.environment.organization
    else
      self.content_view.organization
    end
  end

  def content_view
    self.content_view_version.content_view
  end

  def self.in_environment(env_id)
    where(environment_id: env_id)
  end

  def self.in_product(prod)
    where(product_id: prod)
  end

  def self.in_content_views(views)
    joins(:content_view_version)
      .where("#{Katello::ContentViewVersion.table_name}.content_view_id" => views.map(&:id))
  end

  def puppet?
    content_type == PUPPET_TYPE
  end

  def archive?
    self.environment.nil?
  end

  def yum?
    content_type == YUM_TYPE
  end

  def file?
    content_type == FILE_TYPE
  end

  def in_default_view?
    content_view_version && content_view_version.has_default_content_view?
  end

  def self.in_environments_products(env_ids, product_ids)
    in_environment(env_ids).in_product(product_ids)
  end

  def other_repos_with_same_product_and_content
    list = Repository.in_product(Product.find(self.product.id)).where(:content_id => self.content_id).all
    list.delete(self)
    list
  end

  def other_repos_with_same_content
    list = Repository.where(:content_id => self.content_id).all
    list.delete(self)
    list
  end

  def yum_gpg_key_url
    # if the repo has a gpg key return a url to access it
    if (self.gpg_key && self.gpg_key.content.present?)
      host = Katello.config.host
      port = Katello.config.port
      host += ":" + port.to_s unless port.blank? || port.to_s == "443"
      gpg_key_content_api_repository_url(self, :host => host, :protocol => 'https')
    end
  end

  def product_type
    redhat? ? "redhat" : "custom"
  end

  def redhat?
    product.redhat?
  end

  def custom?
    !(redhat?)
  end

  def clones
    lib_id = self.library_instance_id || self.id
    Repository.where(:library_instance_id => lib_id)
  end

  #is the repo cloned in the specified environment
  def is_cloned_in?(env)
    !get_clone(env).nil?
  end

  def promoted?
    if environment && environment.library? && Repository.where(:library_instance_id => self.id).any?
      true
    else
      false
    end
  end

  def get_clone(env)
    if self.content_view.default
      # this repo is part of a default content view
      lib_id = self.library_instance_id || self.id
      Repository.in_environment(env).where(:library_instance_id => lib_id).
          joins(:content_view_version => :content_view).where("#{Katello::ContentView.table_name}.default" => true).first
    else
      # this repo is part of a content view that was published from a user created view
      self.content_view.get_repo_clone(env, self).first
    end
  end

  def gpg_key_name=(name)
    if name.blank?
      self.gpg_key = nil
    else
      self.gpg_key = GpgKey.readable.find_by_name!(name)
    end
  end

  def after_sync(pulp_task_id)
    self.handle_sync_complete_task(pulp_task_id)
    #don't publish as auto_publish should be enabled
    self.trigger_contents_changed(:wait => false, :publish => false, :reindex => true)
    Medium.update_media(self)
  end

  def as_json(*args)
    ret = super
    ret["gpg_key_name"] = gpg_key ? gpg_key.name : ""
    ret["package_count"] = package_count rescue nil
    ret["last_sync"] = last_sync rescue nil
    ret["puppet_module_count"] = puppet_module_count rescue nil
    ret
  end

  def self.clone_repo_path(options)
    repo = options[:repository]
    repo_lib = repo.library_instance ? repo.library_instance : repo
    org, _, content_path = repo_lib.relative_path.split("/", 3)
    if options[:environment]
      cve = ContentViewEnvironment.where(:environment_id => options[:environment],
                                         :content_view_id => options[:content_view]).first
      "#{org}/#{cve.label}/#{content_path}"
    else
      "#{org}/#{ContentView::CONTENT_DIR}/#{options[:content_view].label}/#{options[:version].version}/#{content_path}"
    end
  end

  def self.repo_id(product_label, repo_label, env_label, organization_label, view_label, version)
    [organization_label, env_label, view_label, version, product_label, repo_label].compact.join("-").gsub(/[^-\w]/, "_")
  end

  def clone_id(env, content_view, version = nil)
    Repository.repo_id(self.product.label, self.label, env.try(:label),
                       organization.label, content_view.label,
                       version)
  end

  def packages_without_errata
    filenames = errata_filenames
    packages_without_filenames(filenames)
  end

  def errata_filenames
    repo = self
    bulk_size = Katello.config.pulp.bulk_load_size
    initial_list = Errata.search do
      size 1
      fields ['pkglist.packages.filename']
      filter :term, {:repoids => repo.pulp_id}
    end

    found_errata = (0..initial_list.total).step(bulk_size).flat_map do |offset|
      Errata.search do
        size bulk_size
        fields ['pkglist.packages.filename']
        filter :term, {:repoids => repo.pulp_id}
        from offset
      end
    end

    found_errata.map{|e| e['pkglist.packages.filename']}.flatten.uniq
  end

  def packages_without_filenames(filenames)
    repo = self
    bulk_size = Katello.config.pulp.bulk_load_size
    filters = [{:term => {:repoids => repo.pulp_id}}, {:not => { :terms => {:filename => filenames} } }]

    initial_list = Package.search do
      size 1
      fields ['id']
      filter :and, filters
    end

    (0..initial_list.total).step(bulk_size).flat_map do |offset|
      Package.search do
        size bulk_size
        fields %w(id filename)
        filter :and, filters
        from offset
      end
    end
  end

  def trigger_contents_changed(options)
    Repository.trigger_contents_changed([self], options)
  end

  def self.trigger_contents_changed(repos, options)
    wait = options.fetch(:wait, false)
    reindex = options.fetch(:reindex, true) && Katello.config.use_elasticsearch
    publish = options.fetch(:publish, true) && Katello.config.use_pulp
    cloned_repo_overrides = options.fetch(:cloned_repo_overrides, [])

    tasks = []
    if publish
      tasks += repos.flat_map do |repo|
        clone = cloned_repo_overrides.find do |c|
          repo.library_instance_id == c.id || repo.library_instance_id == c.library_instance_id
        end
        repo.generate_metadata(:cloned_repo_override => clone, :node_publish_async => true)
      end
    end
    repos.each{|repo| repo.generate_applicability } #don't wait on applicability
    repos.each{|repo| repo.index_content } if reindex

    PulpTaskStatus.wait_for_tasks(tasks) if wait
  end

  # TODO: break up method
  # rubocop:disable MethodLength
  def build_clone(options)
    to_env       = options[:environment]
    version      = options[:version]
    content_view = options[:content_view] || to_env.default_content_view
    to_version   = version || content_view.version(to_env)
    library      = self.library_instance ? self.library_instance : self

    if to_env && version
      fail "Cannot clone into both an environment and a content view version archive"
    end

    if to_version.nil?
      fail _("View %{view} has not been promoted to %{env}") %
                {:view => content_view.name, :env => to_env.name}
    end

    if content_view.default?
      fail _("Cannot clone repository from %{from_env} to %{to_env}. They are not sequential.") %
                {:from_env => self.environment.name, :to_env => to_env.name} if to_env.prior != self.environment
      fail _("Repository has already been promoted to %{to_env}") %
              {:to_env => to_env} if self.is_cloned_in?(to_env)
    else
      fail _("Repository has already been cloned to %{cv_name} in environment %{to_env}") %
                {:to_env => to_env, :cv_name => content_view.name} if to_env &&
          content_view.repos(to_env).where(:library_instance_id => library.id).count > 0
    end

    Repository.new(:environment => to_env,
                   :product => self.product,
                   :cp_label => self.cp_label,
                   :library_instance => library,
                   :label => self.label,
                   :name => self.name,
                   :arch => self.arch,
                   :major => self.major,
                   :minor => self.minor,
                   :content_id => self.content_id,
                   :content_view_version => to_version,
                   :content_type => self.content_type,
                   :unprotected => self.unprotected) do |clone|

      clone.checksum_type = self.checksum_type
      clone.pulp_id = clone.clone_id(to_env, content_view, version.try(:version))
      clone.relative_path = Repository.clone_repo_path(:repository => self,
                                                       :environment => to_env,
                                                       :content_view => content_view,
                                                       :version => version)
    end

  end

  def cancel_dynflow_sync
    if latest_dynflow_sync
      plan = latest_dynflow_sync.execution_plan

      plan.steps.each_pair do |number, step|
        if step.cancellable? && step.is_a?(Dynflow::ExecutionPlan::Steps::RunStep)
          ::ForemanTasks.dynflow.world.event(plan.id, step.id, Dynflow::Action::Cancellable::Cancel)
        end
      end
    end
  end

  def latest_dynflow_sync
    ForemanTasks::Task::DynflowTask.for_action(::Actions::Katello::Repository::Sync).
              for_resource(self).order(:started_at).last
  end

  def create_clone(options)
    clone = build_clone(options)
    clone.save!
    return clone
  end

  # returns other instances of this repo with the same library
  # equivalent of repo
  def environmental_instances(view)
    repo = self.library_instance || self
    search = Repository.non_archived.where("library_instance_id=%s or #{Katello::Repository.table_name}.id=%s"  % [repo.id, repo.id])
    search.in_content_views([view])
  end

  def url?
    url.present?
  end

  def name_conflicts
    if puppet?
      modules = PuppetModule.search("*", :repoids => self.pulp_id,
                                         :fields => [:name],
                                         :page_size => self.puppet_module_count)

      modules.map(&:name).group_by(&:to_s).select { |_, v| v.size > 1 }.keys
    else
      []
    end
  end

  def related_resources
    self.product
  end

  def node_syncable?
    environment && !(environment.library? && content_view.default? && puppet?)
  end

  def exist_for_environment?(environment, content_view, attribute = nil)
    if environment.present?
      repos = content_view.version(environment).repos(environment)

      repos.any? do |repo|
        not_self = (repo.id != self.id)
        same_product = (repo.product.id == self.product.id)

        repo_exists = same_product && not_self

        if repo_exists && attribute
          same_attribute = repo.send(attribute) == self.send(attribute)
          repo_exists = same_attribute
        end

        repo_exists
      end
    else
      false
    end
  end

  protected

  def assert_deletable
    if self.environment.try(:library?) && self.content_view.default?
      if self.environment.organization.being_deleted?
        return true
      elsif self.custom? && self.deletable?
        return true
      elsif !self.custom? && self.redhat_deletable?
        return true
      else
        errors.add(:base, _("Repository cannot be deleted since it has already been included in a published Content View. " +
                            "Please delete all Content View versions containing this repository before attempting to deleting it."))

        return false
      end
    end
  end
end
end
