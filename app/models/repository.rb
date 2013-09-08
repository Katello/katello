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

class Repository < ActiveRecord::Base

  include Glue::Candlepin::Content if (Katello.config.use_cp && Katello.config.use_pulp)
  include Glue::Pulp::Repo if Katello.config.use_pulp
  include Glue::ElasticSearch::Repository if Katello.config.use_elasticsearch

  include Glue if (Katello.config.use_cp || Katello.config.use_pulp)
  include Authorization::Repository

  include Glue::Event
  def destroy_event
    Katello::Actions::RepositoryDestroy
  end

  def create_event
    Katello::Actions::RepositoryCreate
  end

  include AsyncOrchestration
  include Ext::LabelFromName
  include Rails.application.routes.url_helpers

  YUM_TYPE = 'yum'
  FILE_TYPE = 'file'
  PUPPET_TYPE = 'puppet'
  TYPES = [YUM_TYPE, FILE_TYPE, PUPPET_TYPE]
  SELECTABLE_TYPES = [YUM_TYPE, PUPPET_TYPE]

  belongs_to :environment, :inverse_of => :repositories, :class_name => "KTEnvironment"
  belongs_to :product, :inverse_of => :repositories
  belongs_to :gpg_key, :inverse_of => :repositories
  belongs_to :library_instance, :class_name => "Repository"
  has_many :content_view_definition_repositories, :dependent => :destroy
  has_many :content_view_definitions, :through => :content_view_definition_repositories
  has_and_belongs_to_many :filters
  belongs_to :content_view_version, :inverse_of => :repositories

  validates :product_id, :presence => true
  validates :environment_id, :presence => true
  validates :pulp_id, :presence => true, :uniqueness => true
  validates :name, :presence => true
  #validates :content_id, :presence => true #add back after fixing add_repo orchestration
  validates :label, :presence => true
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
  validates_with Validators::RepoDisablementValidator, :attributes => :enabled, :on => :update
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name

  validates_inclusion_of :content_type,
      :in => TYPES,
      :allow_blank => false,
      :message => (_("Please select content type from one of the following: %s") % TYPES.join(', '))

  belongs_to :gpg_key, :inverse_of => :repositories
  belongs_to :library_instance, :class_name => "Repository"

  default_scope order('repositories.name ASC')
  scope :enabled, where(:enabled => true)
  scope :in_default_view, joins(:content_view_version => :content_view).
    where("content_views.default" => true)
  scope :in_environment, lambda { |env| where(environment_id: env.id) }

  scope :yum_type, where(:content_type => YUM_TYPE)
  scope :file_type, where(:content_type => FILE_TYPE)
  scope :puppet_type, where(:content_type => PUPPET_TYPE)
  scope :non_puppet, where("content_type != ?", PUPPET_TYPE)

  def organization
    self.environment.organization
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
    joins(:content_view_version).where('content_view_versions.content_view_id' => views.map(&:id))
  end

  def puppet?
    content_type == PUPPET_TYPE
  end

  def yum?
    content_type == YUM_TYPE
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
      gpg_key_content_api_repository_url(self, :host => host + Katello.config.url_prefix.to_s, :protocol => 'https')
    end
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
    if self.environment.library?
      Repository.where(:library_instance_id => self.id).count > 0
    else
      true
    end
  end

  def get_clone(env)
    if self.content_view.default
      # this repo is part of a default content view
      lib_id = self.library_instance_id || self.id
      Repository.in_environment(env).where(:library_instance_id => lib_id).
          joins(:content_view_version => :content_view).where('content_views.default' => true).first
    else
      # this repo is part of a content view that was published from a user created definition
      self.content_view.get_repo_clone(env, self).first
    end
  end

  def gpg_key_name=(name)
    if name.blank?
      self.gpg_key = nil
    else
      self.gpg_key = GpgKey.readable(organization).find_by_name!(name)
    end
  end

  def after_sync(pulp_task_id)
    #self.handle_sync_complete_task(pulp_task_id)
    self.index_content
  end

  def as_json(*args)
    ret = super
    ret["gpg_key_name"] = gpg_key ? gpg_key.name : ""
    ret["package_count"] = package_count rescue nil
    ret["last_sync"] = last_sync rescue nil
    ret["puppet_module_count"] = puppet_module_count rescue nil
    ret
  end

  def self.clone_repo_path(repo, environment, content_view)
    repo_lib = repo.library_instance ? repo.library_instance : repo
    org, _, content_path = repo_lib.relative_path.split("/", 3)
    cve = ContentViewEnvironment.where(:environment_id => environment,
                                      :content_view_id => content_view).first
    "#{org}/#{cve.label}/#{content_path}"
  end

  def self.repo_id(product_label, repo_label, env_label, organization_label, view_label)
    [organization_label, env_label, view_label, product_label, repo_label].compact.join("-").gsub(/[^-\w]/, "_")
  end

  def clone_id(env, content_view)
    Repository.repo_id(self.product.label, self.label, env.label,
                             env.organization.label, content_view.label)
  end

  # TODO: break up method
  # rubocop:disable MethodLength
  def create_clone(to_env, content_view = nil)
    content_view = to_env.default_content_view if content_view.nil?
    view_version = content_view.version(to_env)
    raise _("View %{view} has not been promoted to %{env}") %
              {:view => content_view.name, :env => to_env.name} if view_version.nil?

    library = self.library_instance ? self.library_instance : self

    if content_view.default?
      raise _("Cannot clone repository from %{from_env} to %{to_env}.  They are not sequential.") %
                {:from_env => self.environment.name, :to_env => to_env.name} if to_env.prior != self.environment
      raise _("Repository has already been promoted to %{to_env}") %
              {:to_env => to_env} if self.is_cloned_in?(to_env)
    else
      raise _("Repository has already been cloned to %{cv_name} in environment %{to_env}") %
                {:to_env => to_env, :cv_name => content_view.name} if
          content_view.repos(to_env).where(:library_instance_id => library.id).count > 0
    end

    clone = Repository.new(:environment => to_env,
                           :product => self.product,
                           :cp_label => self.cp_label,
                           :library_instance => library,
                           :label => self.label,
                           :name => self.name,
                           :arch => self.arch,
                           :major => self.major,
                           :minor => self.minor,
                           :enabled => self.enabled,
                           :content_id => self.content_id,
                           :content_view_version => view_version,
                           :content_type => self.content_type,
                           :unprotected => self.unprotected
                           )
    clone.pulp_id = clone.clone_id(to_env, content_view)
    clone.relative_path = Repository.clone_repo_path(self, to_env, content_view)
    clone.save!
    return clone
  end

  # returns other instances of this repo with the same library
  # equivalent of repo
  def environmental_instances(view)
    repo = self.library_instance || self
    search = Repository.where("library_instance_id=%s or repositories.id=%s"  % [repo.id, repo.id])
    search.in_content_views([view])
  end

end
