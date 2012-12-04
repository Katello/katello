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

class Provider < ActiveRecord::Base
  include Glue::Provider
  include Glue
  include AsyncOrchestration
  include Authorization
  include KatelloUrlHelper
  include IndexedModel

  index_options :extended_json=>:extended_index_attrs,
                :display_attrs=>[:name, :product, :repo, :description]

  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
  end

  REDHAT = 'Red Hat'
  CUSTOM = 'Custom'
  TYPES = [REDHAT, CUSTOM]
  belongs_to :organization
  belongs_to :task_status
  has_many :products, :inverse_of => :provider

  validates :name, :presence => true, :katello_name_format => true
  validates :description, :katello_description_format => true
  validates_uniqueness_of :name, :scope => :organization_id
  validates_inclusion_of :provider_type,
    :in => TYPES,
    :allow_blank => false,
    :message => "Please select provider type from one of the following: #{TYPES.join(', ')}."
  validate :constraint_redhat_update
  before_destroy :prevent_redhat_deletion
  before_validation :sanitize_repository_url


  validate :only_one_rhn_provider
  validate :valid_url, :if => :redhat_provider?

  scope :redhat, where(:provider_type => REDHAT)
  scope :custom, where(:provider_type => CUSTOM)
  def only_one_rhn_provider
    # validate only when new record is added (skip explicit valid? calls)
    if new_record? and provider_type == REDHAT and count_providers(REDHAT) != 0
      errors.add(:base, _("Only one Red Hat provider permitted for an Organization"))
    end
  end

  def prevent_redhat_deletion
    if redhat_provider?
      errors.add(:base, _("Red Hat provider can not be deleted"))
      return false
    end
    true
  end

  def constraint_redhat_update
    if !new_record? && redhat_provider?
      allowed_changes = %w(repository_url task_status_id)
      not_allowed_changes = changes.keys - allowed_changes
      unless not_allowed_changes.empty?
        errors.add(:base, _("the following attributes can not be updated for the Red Hat provider: [ %s ]") % not_allowed_changes.join(", "))
      end
    end
  end

  def valid_url
    errors.add(:repository_url, _("is too long")) if self.repository_url.length > 255
    errors.add(:repository_url, _("is invalid")) unless kurl_valid?(self.repository_url)
  end

  def count_providers type
    ::Provider.where(:organization_id => self.organization_id, :provider_type => type).count(:id)
  end

  def yum_repo?
    provider_type == CUSTOM
  end

  def redhat_provider=(is_rh)
    provider_type = is_rh ? REDHAT : CUSTOM
  end

  def redhat_provider?
    provider_type == REDHAT
  end

  # Logic to ask a Provider if it is one that has subscriptions managed for
  # the products contained within.  Right now this is just redhat products but
  # wanted to centralize the logic in one method.
  def has_subscriptions?
    redhat_provider?
  end

  def organization
    # note i need to add 'unscoped' here
    # to account for the fact that org might have been "scoped out"
    # on an Org delete action.
    # we need the organization info to be present in the provider
    # so that we can properly phase out the orchestration and handle search indices.
    (read_attribute(:organization) || Organization.unscoped.find(self.organization_id)) if self.organization_id
  end

  #permissions
  # returns list of virtual permission tags for the current user
  def self.list_tags org_id
    custom.select('id,name').where(:organization_id=>org_id).collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def self.tags(ids)
    select('id,name').where(:id => ids).collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def self.list_verbs  global = false
    if AppConfig.katello?
      {
        :create => _("Administer Providers"),
        :read => _("Read Providers"),
        :update => _("Modify Providers and Administer Products"),
        :delete => _("Delete Providers"),
      }.with_indifferent_access
    else
      {
        :read => _("Read Providers"),
        :update => _("Modify Providers and Administer Products"),
      }.with_indifferent_access
    end
  end

  def self.read_verbs
    [:read]
  end

  def self.no_tag_verbs
    [:create]
  end

  scope :readable, lambda {|org| items(org, READ_PERM_VERBS)}
  scope :editable, lambda {|org| items(org, EDIT_PERM_VERBS)}

  def readable?
    return organization.readable? if redhat_provider?
    User.allowed_to?(READ_PERM_VERBS, :providers, self.id, self.organization) || (AppConfig.katello? && self.organization.syncable?)
  end


  def self.any_readable? org
    (AppConfig.katello? && org.syncable?) || User.allowed_to?(READ_PERM_VERBS, :providers, nil, org)
  end

  def self.creatable? org
    User.allowed_to?([:create], :providers, nil, org)
  end

  def editable?
    return organization.editable? if redhat_provider?
    User.allowed_to?([:update, :create], :providers, self.id, self.organization)
  end

  def deletable?
    return false if redhat_provider?
    User.allowed_to?([:delete, :create], :providers, self.id, self.organization)
  end

  def serializable_hash(options={})
    options = {} if options == nil
    hash = super(options)
    if AppConfig.katello?
      hash = hash.merge(:sync_state => self.sync_state,
                        :last_sync => self.last_sync)
    end
    hash
  end

  def extended_index_attrs
    if AppConfig.katello?
      products = self.products.map{|prod|
        {:product=>prod.name, :repo=>prod.repos(self.organization.library).collect{|repo| repo.name}}
      }
    else
      products = self.products.map{|prod|
        {:product=>prod.name}
      }
    end
    {
      :products=>products,
      :name_sort=>name.downcase
    }
  end


  # refreshes products' repositories from CDS. If new versions are released on
  # the CDN, this method will provide loading this new versions.
  def refresh_products
    self.products.engineering.each do |product|
      product.set_repos
    end
  end

  def available_releases
    releases = []
    begin
      Util::CdnVarSubstitutor.with_cache do
        self.products.engineering.each do |product|
          cdn_var_substitutor = Resources::CDN::CdnResource.new(product.provider[:repository_url],
                                                           :ssl_client_cert => OpenSSL::X509::Certificate.new(product.certificate),
                                                           :ssl_client_key => OpenSSL::PKey::RSA.new(product.key)).substitutor
          product.productContent.each do |pc|
            if url_to_releases = pc.content.contentUrl[/^.*\$releasever/]
              begin
                cdn_var_substitutor.substitute_vars(url_to_releases).each do |(substitutions, path)|
                  releases << Resources::CDN::Utils.parse_version(substitutions['releasever'])[:minor]
                end
              rescue Errors::SecurityViolation => e
                # Some products may not be accessible but these should not impact available releases available
                Rails.logger.info "Skipping unreadable product content: #{e}"
              end
            end
          end
        end
      end
    rescue => e
      raise _("Unable to retrieve release versions from Repository URL %{url}. Error message: %{error}") % {:url => self.repository_url, :error => e.to_s}
    end
    releases.uniq.sort
  end

  def repositories
    Repository.joins(:environment_product => :product).where("products.provider_id" => self.id)
  end

  def manifest_task
    return task_status
  end

  protected

   def sanitize_repository_url
     if redhat_provider? && self.repository_url.blank?
      self.repository_url = AppConfig.REDHAT_REPOSITORY_URL
      self.repository_url = "https://cdn.redhat.com" unless self.repository_url
     end
     if self.repository_url
       self.repository_url.strip!
     end
   end

  def self.items org, verbs
    raise "scope requires an organization" if org.nil?
    resource = :providers
    if (AppConfig.katello? && verbs.include?(:read) && org.syncable?) ||  User.allowed_all_tags?(verbs, resource, org)
       where(:organization_id => org)
    else
      where("providers.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
    end
  end

  READ_PERM_VERBS = [:read, :create, :update, :delete] if AppConfig.katello?
  READ_PERM_VERBS = [:read, :update] if !AppConfig.katello?
  EDIT_PERM_VERBS = [:create, :update] if AppConfig.katello?
  EDIT_PERM_VERBS = [:update] if !AppConfig.katello?


end

