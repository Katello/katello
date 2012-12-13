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
require "util/model_util"

class RepoDisablementValidator < ActiveModel::Validator
  def validate(record)
    if record.redhat? && record.enabled_changed? && (!record.enabled?) && record.promoted?
      record.errors[:base] << N_("Repository cannot be disabled since it has already been promoted.")
    end
  end
end


class Repository < ActiveRecord::Base
  include Glue::Candlepin::Content if (AppConfig.use_cp and AppConfig.use_pulp)
  include Glue::Pulp::Repo if (AppConfig.use_cp and AppConfig.use_pulp)
  include Glue if AppConfig.use_cp
  include Authorization
  include AsyncOrchestration
  include IndexedModel
  include Katello::LabelFromName

  index_options :extended_json=>:extended_index_attrs,
                :json=>{:except=>[:pulp_repo_facts, :groupid, :feed_cert, :environment_product_id]}

  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
    indexes :labels, :type => 'string', :index => :not_analyzed
  end


  after_save :update_related_index

  belongs_to :environment_product, :inverse_of => :repositories
  has_and_belongs_to_many :changesets
  validates :pulp_id, :presence => true, :uniqueness => true
  validates :name, :presence => true
  validates :label, :presence => true,:katello_label_format => true
  validates :enabled, :repo_disablement => true, :on => :update
  belongs_to :gpg_key, :inverse_of => :repositories
  belongs_to :library_instance, :class_name=>"Repository"

  def self.in_product(product)
    joins(:environment_product).where(:environment_products => { :product_id => product })
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

  default_scope :order => 'repositories.name ASC'

  scope :enabled, where(:enabled => true)
  scope :in_product, lambda{|p|  joins(:environment_product).where("environment_products.product_id" => p.id)}

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

  # only repositories in a given environment
  scope :in_environment, lambda { |env|
    joins(:environment_product).where(:environment_products => {:environment_id => env.id})
  }

  def self.any_readable_in_org? org, skip_library = false
    KTEnvironment.any_contents_readable? org, skip_library
  end


  def extended_index_attrs
    {:environment=>self.environment.name, :environment_id=>self.environment.id,
     :product=>self.product.name, :product_id=> self.product.id, :name_sort=>self.name }
  end

  def update_related_index
    self.product.provider.update_index if self.product.provider.respond_to? :update_index
  end

  def sync_complete task
    notify = task.parameters.try(:[], :options).try(:[], :notify)
    user = task.user
    if task.state == 'finished'
      if user && notify
        Notify.success _("Repository '%s' finished syncing successfully.") % [self.name],
                       :user => user, :organization => self.organization
      end
    elsif task.state == 'error'
      details = if task.progress.error_details.present?
                  task.progress.error_details.map { |error| error[:error].to_s }
                else
                  task.result[:errors].flatten.map(&:chomp)
                end.join("\n")

      Rails.logger.error("*** Sync error: " +  details)
      if user && notify
        Notify.error _("There were errors syncing repository '%s'. See notices page for more details.") % self.name,
                     :details => details, :user => user, :organization => self.organization
      end
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
    Repository.where("library_instance_id=%s or id=%s"  % [repo.id, repo.id] )
  end

  #ideally this would be an attribute like package_count
  def errata_count
    results = Glue::Pulp::Errata.search('', 0, 1, :repoids => [self.pulp_id])
    results.empty? ? 0 : results.total
  end
end
