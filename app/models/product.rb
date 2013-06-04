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

class Product < ActiveRecord::Base

  include Glue::ElasticSearch::Product if Katello.config.use_elasticsearch
  include Glue::Candlepin::Product if Katello.config.use_cp
  include Glue::Pulp::Repos if Katello.config.use_pulp
  include Glue if Katello.config.use_cp || Katello.config.use_pulp

  include Authorization::Product
  include AsyncOrchestration

  include Ext::LabelFromName

  has_many :environment_products, :class_name => "EnvironmentProduct", :dependent => :destroy, :uniq=>true
  has_many :environments, :class_name => "KTEnvironment", :uniq => true , :through => :environment_products  do
    def <<(*items)
      super( items - @association.owner.environment_products.collect{|ep| ep.environment} )
    end

    def default_view
      select do |env|
        env.default_content_view.products(env).include?(proxy_owner)
      end
    end
  end

  has_and_belongs_to_many :changesets

  belongs_to :provider, :inverse_of => :products
  belongs_to :sync_plan, :inverse_of => :products
  belongs_to :gpg_key, :inverse_of => :products
  has_many :content_view_definition_products
  has_many :content_view_definitions, :through => :content_view_definition_products

  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates_with Validators::LibraryPresenceValidator, :attributes => :environments
  validates :name, :presence => true
  validates :label, :presence => true
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label

  scope :with_repos_only, lambda { |env|
    with_repos(env, false)
  }

  scope :with_enabled_repos_only, lambda { |env|
        with_repos(env, true)
  }

  def self.find_by_cp_id(cp_id, organization)
    self.where(:cp_id=>cp_id).in_org(organization).first
  end

  def self.in_org(organization)
    self.joins(:provider).where('providers.organization_id' => organization.id)
  end

  scope :engineering, where(:type => "Product")

  before_save :assign_unique_label

  def initialize(attrs=nil, options={})

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
        !self.class.column_defaults.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
      end
    end

    super
  end

  def repos(env, include_disabled = false, content_view=nil)
    # cache repos so we can cache lazy_accessors
    @repo_cache ||= {}

    content_view ||= env.default_content_view
    @repo_cache[env.id] ||= content_view.repos_in_product(env, self)

    if @repo_cache[env.id].blank? || include_disabled
      @repo_cache[env.id]
    else
      # we only want the enabled repos to be visible
      # This serves as a white list for redhat repos
      @repo_cache[env.id].where(:enabled => true)
    end
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
    if Katello.config.katello?
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

  scope :all_in_org, lambda{|org| ::Product.joins(:provider).where('providers.organization_id = ?', org.id)}

  scope :repositories_cdn_import_failed, where(:cdn_import_success => false)

  def assign_unique_label
    self.label = Util::Model::labelize(self.name) if self.label.blank?

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

  def delete_repos repos
    repos.each{|repo| repo.destroy}
  end

  def delete_from_env from_env
    @orchestration_for = :delete
    delete_repos(repos(from_env))
    if from_env.products.include? self
      self.environments.delete(from_env)
    end
    save!
  end

  def environments_for_view view
    versions = view.versions.select{|version| version.products.include?(self)}
    versions.collect{|v|v.environments}.flatten
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
