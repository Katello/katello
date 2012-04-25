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

class LibraryPresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << N_("must contain 'Library'") if value.select {|e| e.library}.empty?
  end
end

class ProductNameUniquenessValidator < ActiveModel::Validator
  def validate(record)
    name_duplicate_ids = Product.select("products.id").joins(:provider).where("products.name" => record.name, "providers.organization_id" => record.organization.id).all.map {|p| p.id}
    name_duplicate_ids = name_duplicate_ids - [record.id]
    record.errors[:base] << N_("Products within an organization must have unique name.") if name_duplicate_ids.count > 0
  end
end

class Product < ActiveRecord::Base
  include Glue::Candlepin::Product if AppConfig.use_cp
  include Glue::Pulp::Repos if AppConfig.katello?
  include Glue if AppConfig.use_cp
  include Authorization
  include AsyncOrchestration

  validates_with ProductNameUniquenessValidator

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

  scope :with_repos_only, lambda { |env|
    with_repos(env, false)
  }

  scope :with_enabled_repos_only, lambda { |env|
        with_repos(env, true)
  }

  scope :engineering, where(:type => "Product")

  after_save :update_related_index

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
      hash = hash.merge(:sync_plan_name => self.sync_plan ? self.sync_plan.name : nil)
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

  def reset_repo_gpgs!
    self.environment_products.each do |ep|
      ep.repositories.each do |repo|
        repo.update_attributes!(:gpg_key => self.gpg_key)
      end
    end
  end

  def total_package_count env
    repoids = self.repos(env).collect{|r| r.pulp_id}
    result = Glue::Pulp::Package.search('*', 0, 1, repoids)
    result.length > 0 ? result.total : 0
  end

  def has_filters? env
    return false unless env == organization.library
    return true if filters.count > 0
    repos(organization.library).any?{|repo| repo.has_filters?}

  end

  #Permissions
  scope :all_readable, lambda {|org| ::Provider.readable(org).joins(:provider)}
  scope :readable, lambda{|org| all_readable(org).with_enabled_repos_only(org.library)}
  scope :all_editable, lambda {|org| ::Provider.editable(org).joins(:provider)}
  scope :editable, lambda {|org| all_editable(org).with_enabled_repos_only(org.library)}
  scope :syncable, lambda {|org| sync_items(org).with_enabled_repos_only(org.library)}

  def self.any_readable?(org)
    ::Provider.any_readable?(org)
  end

  def readable?
    Product.all_readable(self.organization).where(:id => id).count > 0
  end

  def syncable?
    Product.syncable(self.organization).where(:id => id).count > 0
  end

  def editable?
    Product.all_editable(self.organization).where(:id => id).count > 0
  end

  def update_related_index
      self.provider.update_index if self.provider.respond_to? :update_index
  end

  def as_json(*args)
    ret = super
    ret["gpg_key_name"] = gpg_key ? gpg_key.name : ""
    ret
  end

  protected

  def self.authorized_items org, verbs, resource = :providers
     raise "scope requires an organization" if org.nil?
     if User.allowed_all_tags?(verbs, resource, org)
       joins(:provider).where('providers.organization_id' => org)
     else
       joins(:provider).where("providers.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
     end
  end


  def self.sync_items org
    org.syncable? ? (joins(:provider).where('providers.organization_id' => org)) : where("0=1")
  end

  READ_PERM_VERBS = [:read, :create, :update, :delete]

  def self.with_repos env, enabled_only
    query = EnvironmentProduct.joins(:repositories).where(
          :environment_id => env).select("environment_products.product_id")
    query = query.where("repositories.enabled" => true) if enabled_only
    joins(:provider).where('providers.organization_id' => env.organization).
        where("(providers.provider_type ='#{::Provider::CUSTOM}') OR ( providers.provider_type ='#{::Provider::REDHAT}' AND products.id in (#{query.to_sql}))")
  end
end
