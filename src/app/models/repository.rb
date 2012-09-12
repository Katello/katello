#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class RepoDisablementValidator < ActiveModel::Validator
  def validate(record)
    if record.redhat? && record.enabled_changed? && (!record.enabled?) && record.promoted?
      record.errors[:base] << N_("Repository cannot be disabled since it has already been promoted.")
    end
  end
end


class Repository < ActiveRecord::Base
  include Glue::Pulp::Repo if (AppConfig.use_cp and AppConfig.use_pulp)
  include Glue if AppConfig.use_cp
  include Authorization
  include AsyncOrchestration
  include IndexedModel

  index_options :extended_json=>:extended_index_attrs,
                :json=>{:except=>[:pulp_repo_facts, :groupid, :feed_cert, :environment_product_id]}

  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
  end


  after_save :update_related_index
  before_save :refresh_content

  belongs_to :environment_product, :inverse_of => :repositories
  has_and_belongs_to_many :changesets
  validates :pulp_id, :presence => true, :uniqueness => true
  validates :name, :presence => true
  validates :enabled, :repo_disablement => true, :on => [:update]
  belongs_to :gpg_key, :inverse_of => :repositories
  belongs_to :library_instance, :class_name=>"Repository"

  def self.in_product(product)
    joins(:environment_product).where(:environment_products => { :product_id => product })
  end

  def self.in_environment(env)
    joins(:environment_product).where(:environment_products => { :environment_id => env })
  end

  def product
    self.environment_product.product
  end

  def environment
    self.environment_product.environment
  end

  def organization
    self.environment.organization
  end

  def yum_gpg_key_url
    # if the repo has a gpg key return a url to access it
    if (self.gpg_key && self.gpg_key.content.present?)
      host = AppConfig.host
      host += ":" + AppConfig.port.to_s unless AppConfig.port.blank? || AppConfig.port.to_s == "443"
      gpg_key_content_api_repository_url(self, :host => host + ENV['RAILS_RELATIVE_URL_ROOT'].to_s, :protocol => 'https')
    end
  end

  #temporary major version
  def major_version
    return nil if release.nil?
    release.to_i
  end

  def redhat?
    product.redhat?
  end

  def custom?
    !(redhat?)
  end

  def has_filters?
    return false unless environment.library?
    filters.count > 0 || product.filters.count > 0
  end

  scope :enabled, where(:enabled => true)

  scope :readable, lambda { |env|
    prod_ids = ::Product.readable(env.organization).collect{|p| p.id}
    if env.contents_readable?
      joins(:environment_product).where("environment_products.environment_id" => env.id)
    else
      #none readable
      where("1=0")
    end
  }

  #NOTE:  this scope returns all library instances of repositories that have content readable
  scope :libraries_content_readable, lambda {|org|
    repos = Repository.enabled.content_readable(org)
    lib_ids = []
    repos.each{|r|  lib_ids << (r.library_instance_id || r.id)}
    where(:id=>lib_ids)
  }

  scope :content_readable, lambda{|org|
    prod_ids = ::Product.readable(org).collect{|p| p.id}
    env_ids = KTEnvironment.content_readable(org)
    joins(:environment_product).where("environment_products.product_id" => prod_ids).
        where("environment_products.environment_id"=>env_ids)
  }

  scope :readable_for_product, lambda{|env, prod|
    if env.contents_readable?
      joins(:environment_product).where("environment_products.environment_id" => env.id).where(
                                'environment_products.product_id'=>prod.id)
    else
      #none readable
      where("1=0")
    end
  }

  scope :editable_in_library, lambda {|org|
    joins(:environment_product).
        where("environment_products.environment_id" => org.library.id).
        where("environment_products.product_id in (#{Product.editable(org).select("products.id").to_sql})")
  }

  scope :readable_in_org, lambda {|org, *skip_library|
    if (skip_library.empty? || skip_library.first.nil?)
      # 'skip library' not included, so retrieve repos in library in the result
      joins(:environment_product).where("environment_products.environment_id" =>  KTEnvironment.content_readable(org))
    else
      joins(:environment_product).where("environment_products.environment_id" =>  KTEnvironment.content_readable(org).where(:library => false))
    end
  }

  def self.any_readable_in_org? org, skip_library = false
    KTEnvironment.any_contents_readable? org, skip_library
  end


  def extended_index_attrs
    {:environment=>self.environment.name, :environment_id=>self.environment.id, :clone_ids=>self.clones.pluck(:pulp_id),
     :product=>self.product.name, :product_id=> self.product.id, :name_sort=>self.name }
  end

  def update_related_index
    self.product.provider.update_index if self.product.provider.respond_to? :update_index
  end

  def sync_complete task
    notify = task.parameters.try(:[], :options).try(:[], :notify)
    user = task.user
    if task.state == TaskStatus::Status::FINISHED
      Notify.success _("Repository '%s' finished syncing successfully.") % [self.name],
                     :user => user if user && notify
    elsif task.state == 'error'

      details = ''
      log_details = []
      if(!task.progress.error_details.nil? and !task.progress.error_details.empty?)
        task.progress.error_details.each do |error|
          log_details << error
          details += error[:error].to_s + "\n"
        end
      end
      Rails.logger.error("*** Sync error: " +  log_details.to_json)
      Notify.error _("There were errors syncing repository '%s'. See notices page for more details.") % self.name,
                   :details => details, :user => user if user && notify
    end
  end

  def index_packages
    pkgs = self.packages.collect{|pkg| pkg.as_json.merge(pkg.index_options)}
    Tire.index Glue::Pulp::Package.index do
      create :settings => Glue::Pulp::Package.index_settings, :mappings => Glue::Pulp::Package.index_mapping
      import pkgs
    end if !pkgs.empty?
  end

  def update_packages_index
    # for each of the packages in the repo, unassociate the repo from the package
    pkgs = self.packages.collect{|pkg| pkg.as_json.merge(pkg.index_options)}
    pulp_id = self.pulp_id

    Tire.index Glue::Pulp::Package.index do
      create :settings => Glue::Pulp::Package.index_settings, :mappings => Glue::Pulp::Package.index_mapping

      import pkgs do |documents|
        documents.each do |document|
          if document["repoids"].length > 1
            # if there is more than 1 repo associated w/ the pkg, remove this repo
            document["repoids"].delete(pulp_id)
          end
        end
      end

    end if !pkgs.empty?

    # now, for any package that only had this repo asscociated with it, remove the package from the index
    repoids = "repoids:#{pulp_id}"
    Tire::Configuration.client.delete "#{Tire::Configuration.url}/katello_package/_query?q=#{repoids}"
    Tire.index('katello_package').refresh
  end

  def index_errata
    errata = self.errata.collect{|err| err.as_json.merge(err.index_options)}
    Tire.index Glue::Pulp::Errata.index do
      create :settings => Glue::Pulp::Errata.index_settings, :mappings => Glue::Pulp::Errata.index_mapping
      import errata
    end if !errata.empty?
  end

  def update_errata_index
    # for each of the errata in the repo, unassociate the repo from the errata
    errata = self.errata.collect{|err| err.as_json.merge(err.index_options)}
    pulp_id = self.pulp_id

    Tire.index Glue::Pulp::Errata.index do
      create :settings => Glue::Pulp::Errata.index_settings, :mappings => Glue::Pulp::Errata.index_mapping

      import errata do |documents|
        documents.each do |document|
          if document["repoids"].length > 1
            # if there is more than 1 repo associated w/ the errata, remove this repo
            document["repoids"].delete(pulp_id)
          end
        end
      end

    end if !errata.empty?

    # now, for any errata that only had this repo asscociated with it, remove the errata from the index
    repoids = "repoids:#{pulp_id}"
    Tire::Configuration.client.delete "#{Tire::Configuration.url}/katello_errata/_query?q=#{repoids}"
    Tire.index('katello_errata').refresh
  end

  def create_clone to_env
    library = self.environment.library? ? self : self.library_instance
    raise _("Cannot clone repository from #{self.environment.name} to #{to_env.name}.  They are not sequential.") if to_env.prior != self.environment
    raise _("Repository has already been promoted to #{to_env}") if Repository.where(:library_instance_id=>library.id).in_environment(to_env).count > 0

    key = EnvironmentProduct.find_or_create(to_env, self.product)
    clone = Repository.new(:environment_product => key,
                           :cp_label => self.cp_label,
                           :library_instance=>library,
                           :name=>self.name,
                           :arch=>self.arch,
                           :major=>self.major,
                           :minor=>self.minor,
                           :enable=>self.enabled,
                           :content_id=>self.content_id
                           )
    clone.pulp_id = clone.clone_id(to_env)
    clone.relative_path = Glue::Pulp::Repos.clone_repo_path(self, to_env)
    clone.save!
    self.clone_contents(clone) #return clone task
  end

  def clone_contents to_repo
    Resources::Pulp::Repository.unit_copy(self.pulp_id, to_repo.pulp_id)
  end

  def clones
    lib_id = self.library_instance_id || self.id
    Repository.in_environment(self.environment.successors).where(:library_instance_id=>lib_id)
  end

  #is the repo cloned in the specified environment
  def is_cloned_in? env
    lib_id = self.library_instance_id ? self.library_instance_id : self.id
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
    lib_id = self.library_instance_id || self.id
    Repository.in_environment(env).where(:library_instance_id=>lib_id).first
  end

  def gpg_key_name=(name)
    if name.blank?
      self.gpg_key = nil
    else
      self.gpg_key = GpgKey.readable(organization).find_by_name!(name)
    end
  end

  def as_json(*args)
    ret = super
    ret["gpg_key_name"] = gpg_key ? gpg_key.name : ""
    ret["package_count"] = package_count rescue nil
    ret["last_sync"] = last_sync rescue nil
    ret
  end

  # returns other instances of this repo with the same library
  # equivalent of repo
  def environmental_instances
    if self.environment.library?
      repo = self
    else
      repo = self.library_instance
    end
    Repository.where("library_instance_id=%s or repositories.id=%s"  % [repo.id, repo.id] )
  end


  def errata_count
    results = Glue::Pulp::Errata.search('', 0, 1, :repoids => [self.pulp_id])
    results.empty? ? 0 : results.total
  end

  def package_count
    results = Glue::Pulp::Package.search('', 0, 1, :repoids => [self.pulp_id])
    results.empty? ? 0 : results.total
  end

  #Filters that should be applied for content coming into this repository.
  def applicable_filters
    previous = self.environmental_instances.in_environment(self.environment.prior).first
    if previous && previous.environment.prior.nil?  #if previous exists and is library
      previous.filters + self.product.filters
    else
      []
    end
  end

  private

  def refresh_content
    return if self.new_record?  #don't try to refresh on create

    #if the gpg key was enabled
    #we only update the content if the content is actually not set properly
    #this means we don't recreate the environment for the same repo in 
    #each environment.   We do the same for it being disabled, we check
    #to make sure it is not enabled in the contnet before refreshing
    if (self.gpg_key_id_was == nil && self.gpg_key_id != nil) 
        self.product.refresh_content(self) if self.content.gpgUrl == ''
    elsif (self.gpg_key_id_was != nil && self.gpg_key_id == nil)
        self.product.refresh_content(self) if self.content.gpgUrl != ''
    end
  end

end
