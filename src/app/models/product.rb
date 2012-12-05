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

class LibraryPresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << N_("must contain 'Library'") if value.select {|e| e.library}.empty?
  end
end

class Product < ActiveRecord::Base
  include Glue::Candlepin::Product if AppConfig.use_cp
  include Glue::Pulp::Repos if AppConfig.use_pulp
  include Glue::ElasticSearch::Product if AppConfig.use_elasticsearch
  include Glue if AppConfig.use_cp || AppConfig.use_pulp
  include Authorization::Product
  include AsyncOrchestration

  include Katello::LabelFromName


  has_many :environments, :class_name => "KTEnvironment", :uniq => true , :through => :environment_products  do
    def <<(*items)
      super( items - proxy_owner.environment_products.collect{|ep| ep.environment} )
    end
  end
  has_and_belongs_to_many :changesets

  has_many :environment_products, :class_name => "EnvironmentProduct", :dependent => :destroy, :uniq=>true

  belongs_to :provider, :inverse_of => :products
  belongs_to :sync_plan, :inverse_of => :products
  belongs_to :gpg_key, :inverse_of => :products

  validates :description, :katello_description_format => true
  validates :environments, :library_presence => true
  validates :name, :presence => true, :katello_name_format => true
  validates :label, :presence => true, :katello_label_format => true

  scope :with_repos_only, lambda { |env|
    with_repos(env, false)
  }

  scope :with_enabled_repos_only, lambda { |env|
        with_repos(env, true)
  }

  scope :engineering, where(:type => "Product")

  before_save :assign_unique_label

  def initialize(attrs = nil)

    unless attrs.nil?
      attrs = attrs.with_indifferent_access

      #rename "id" to "cp_id" (activerecord and candlepin variable name conflict)
      if attrs.has_key?(:id)
        if !attrs.has_key?(:cp_id)
          attrs[:cp_id] = attrs[:id]
        end
        attrs.delete(:id)
      end

      # ugh. hack-ish. otherwise we have to modify code every time things change on cp side
      attrs = attrs.reject do |k, v|
        !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
      end
    end

    super(attrs)
  end

  def organization
    provider.organization
  end

  def library
    environments.select {|e| e.library}.first
  end

  def plan_name
    return sync_plan.name if sync_plan
    N_('None')
  end

  def serializable_hash(options={})
    options = {} if options == nil

    hash = super(options.merge(:except => [:cp_id, :id]))
    hash = hash.merge(:productContent => self.productContent,
                      :multiplier => self.multiplier,
                      :attributes => self.attrs,
                      :id => self.cp_id)
    if AppConfig.katello?
      hash = hash.merge({
        :sync_plan_name => self.sync_plan ? self.sync_plan.name : nil,
        :sync_state => self.sync_state,
        :last_sync => self.last_sync
      })
    end
    hash
  end

  def redhat?
    provider.redhat_provider?
  end

  def custom?
    !(redhat?)
  end

  def gpg_key_name=(name)
    if name.blank?
      self.gpg_key = nil
    else
      self.gpg_key = GpgKey.readable(organization).find_by_name!(name)
    end
  end

  # TODO: this should be a part of product update orchestration
  def reset_repo_gpgs!
    self.environment_products.each do |ep|
      ep.repositories.each do |repo|
        repo.update_attributes!(:gpg_key => self.gpg_key)
      end
    end
  end

  def total_package_count env
    repoids = self.repos(env).collect{|r| r.pulp_id}
    result = Package.search('*', 0, 1, repoids)
    result.length > 0 ? result.total : 0
  end

  def total_errata_count env
    repo_ids = self.repos(env).collect{|r| r.pulp_id}
    results = Errata.search('', 0, 1, :repoids => repo_ids)
    results.empty? ? 0 : results.total
  end

  scope :all_in_org, lambda{|org| ::Product.joins(:provider).where('providers.organization_id = ?', org.id)}

  def assign_unique_label
    self.label = Katello::ModelUtils::labelize(self.name) if self.label.blank?

    # if the object label is already being used in this org, append the id to make it unique
    if Product.all_in_org(self.organization).where('products.label = ?', self.label).count > 0
      self.label.concat("_" + self.cp_id) unless self.cp_id.blank?
    end
  end

  def as_json(*args)
    ret = super
    ret["gpg_key_name"] = gpg_key ? gpg_key.name : ""
    ret["marketing_product"] = self.is_a? MarketingProduct
    ret
  end

  protected


  def self.with_repos env, enabled_only
    query = EnvironmentProduct.joins(:repositories).where(
          :environment_id => env).select("environment_products.product_id")
    query = query.where("repositories.enabled" => true) if enabled_only
    joins(:provider).where('providers.organization_id' => env.organization).
        where("(providers.provider_type ='#{::Provider::CUSTOM}') OR ( providers.provider_type ='#{::Provider::REDHAT}' AND products.id in (#{query.to_sql}))")
  end
end
