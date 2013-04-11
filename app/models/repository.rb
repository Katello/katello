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

  include Glue::Candlepin::Content if (Katello.config.use_cp and Katello.config.use_pulp)
  include Glue::Pulp::Repo if Katello.config.use_pulp
  include Glue::ElasticSearch::Repository if Katello.config.use_elasticsearch

  include Glue if (Katello.config.use_cp || Katello.config.use_pulp)
  include Authorization::Repository

  include AsyncOrchestration
  include Ext::LabelFromName
  include Rails.application.routes.url_helpers

  belongs_to :environment_product, :inverse_of => :repositories
  belongs_to :gpg_key, :inverse_of => :repositories
  belongs_to :library_instance, :class_name=>"Repository"
  has_and_belongs_to_many :changesets
  has_many :content_view_definition_repositories
  has_many :content_view_definitions, :through => :content_view_definition_repositories
  belongs_to :content_view_version, :inverse_of=>:repositories

  validates :environment_product, :presence => true
  validates :pulp_id, :presence => true, :uniqueness => true
  validates :name, :presence => true
  #validates :content_id, :presence => true #add back after fixing add_repo orchestration
  validates :label, :presence => true
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
  validates_with Validators::RepoDisablementValidator, :attributes => :enabled, :on => :update

  belongs_to :gpg_key, :inverse_of => :repositories
  belongs_to :library_instance, :class_name=>"Repository"

  default_scope :order => 'repositories.name ASC'
  scope :enabled, where(:enabled => true)

  scope :in_default_view, joins(:content_view_version => :content_view).
    where("content_views.default" => true)

  def product
    self.environment_product.product
  end

  def product_id
    self.environment_product.product_id
  end

  def environment
    self.environment_product.environment
  end

  def organization
    self.environment.organization
  end

  def content_view
    self.content_view_version.content_view
  end

  def self.in_environment(env)
    joins(:environment_product).where(:environment_products => { :environment_id => env })
  end

  def self.in_product(product)
    joins(:environment_product).where("environment_products.product_id" => product.id)
  end

  def self.in_content_views(views)
    joins(:content_view_version).where('content_view_versions.content_view_id' => views.map(&:id))
  end

  def in_default_view?
    content_view_version && content_view_version.has_default_content_view?
  end

  def self.in_environments_products(env_ids, product_ids)
    joins(:environment_product).where(:environment_products => { :environment_id => env_ids, :product_id=>product_ids})

  end

  def other_repos_with_same_product_and_content
    list = Repository.in_product(Product.find(self.product.id)).where(:content_id=>self.content_id).all
    list.delete(self)
    list
  end

  def other_repos_with_same_content
    list = Repository.where(:content_id=>self.content_id).all
    list.delete(self)
    list
  end

  def environment_id
    self.environment.id
  end

  def yum_gpg_key_url
    # if the repo has a gpg key return a url to access it
    if (self.gpg_key && self.gpg_key.content.present?)
      host = Katello.config.host
      port = Katello.config.port
      host += ":" + port.to_s unless port.blank? || port.to_s == "443"
      gpg_key_content_api_repository_url(self, :host => host + ENV['RAILS_RELATIVE_URL_ROOT'].to_s, :protocol => 'https')
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
    Repository.in_environment(self.environment.successors).where(:library_instance_id=>lib_id)
  end

  #is the repo cloned in the specified environment
  def is_cloned_in? env
    self.get_clone(env) != nil
  end

  def promoted?
    if self.environment.library?
      Repository.where(:library_instance_id=>self.id).count > 0
    else
      true
    end
  end

  def get_clone env
    if self.content_view.default
      # this repo is part of a default content view
      lib_id = self.library_instance_id || self.id
      Repository.in_environment(env).where(:library_instance_id => lib_id).
          joins(:content_view_version => :content_view).where('content_views.default'=>true).first
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

  def after_sync pulp_task_id
    #self.handle_sync_complete_task(pulp_task_id)
    self.index_content
  end

  def as_json(*args)
    ret = super
    ret["gpg_key_name"] = gpg_key ? gpg_key.name : ""
    ret["package_count"] = package_count rescue nil
    ret["last_sync"] = last_sync rescue nil
    ret
  end

  def self.clone_repo_path(repo, environment, content_view, for_cp = false)
    org, env, content_path = repo.relative_path.split("/",3)
    if for_cp
      "/#{content_path}"
    elsif (content_view.default? || !environment.library) &&
        !content_view.content_view_definition.try(:composite?)
      # if this repo is in a non-library environment and is not related to a
      # composite content view definition, the content view has already been
      # added to the path, so we do not need to add it again
      "#{org}/#{environment.label}/#{content_path}"
    else
      "#{org}/#{environment.label}/#{content_view.label}/#{content_path}"
    end
  end

  def self.repo_id(product_label, repo_label, env_label, organization_label, view_label)
    [organization_label, env_label, view_label, product_label, repo_label].compact.join("-").gsub(/[^-\w]/,"_")
  end

  def clone_id(env, content_view)
    Repository.repo_id(self.product.label, self.label, env.label,
                             env.organization.label, content_view.label)
  end

  def create_clone(to_env, content_view=nil)
    content_view = to_env.default_content_view if content_view.nil?
    view_version = content_view.version(to_env)
    raise _("View %{view} has not been promoted to %{env}") %
              {:view=>content_view.name, :env=>to_env.name} if view_version.nil?

    library = self.library_instance ? self.library_instance : self

    if content_view.default?
      raise _("Cannot clone repository from %{from_env} to %{to_env}.  They are not sequential.") %
                {:from_env=>self.environment.name, :to_env=>to_env.name} if to_env.prior != self.environment
      raise _("Repository has already been promoted to %{to_env}") %
              {:to_env=>to_env} if self.is_cloned_in?(to_env)
    else
      raise _("Repository has already been cloned to %{cv_name} in environment %{to_env}") %
                {:to_env=>to_env, :cv_name=>content_view.name} if
          content_view.repos(to_env).where(:library_instance_id=>library.id).count > 0
    end

    key = EnvironmentProduct.find_or_create(to_env, self.product)
    clone = Repository.new(:environment_product => key,
                           :cp_label => self.cp_label,
                           :library_instance=>library,
                           :label=>self.label,
                           :name=>self.name,
                           :arch=>self.arch,
                           :major=>self.major,
                           :minor=>self.minor,
                           :enabled=>self.enabled,
                           :content_id=>self.content_id,
                           :content_view_version=>view_version,
                           :unprotected=>self.unprotected
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
    search = Repository.where("library_instance_id=%s or repositories.id=%s"  % [repo.id, repo.id] )
    search.in_content_views([view])
  end
end
