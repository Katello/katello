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
  class Provider < ActiveRecord::Base
    include Katello::Concerns::Taxonomix

    include Glue::ElasticSearch::Provider if Katello.config.use_elasticsearch
    include Glue::Provider
    include Glue
    include Katello::Authorization::Provider
    include AsyncOrchestration

    include Ext::PermissionTagCleanup

    REDHAT = 'Red Hat'
    CUSTOM = 'Custom'
    TYPES = [REDHAT, CUSTOM]

    serialize :discovered_repos, Array

    belongs_to :task_status
    belongs_to :discovery_task, :class_name=>'TaskStatus'
    has_many :products, :inverse_of => :provider
    has_many :repositories, through: :products

    validates :name, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description

    validates_uniqueness_of :name, :scope => :organization_id
    validates_inclusion_of :provider_type,
      :in => TYPES,
      :allow_blank => false,
      :message => "Please select provider type from one of the following: #{TYPES.join(', ')}."
    validate :constraint_redhat_update
    before_destroy :prevent_redhat_deletion
    before_validation :sanitize_repository_url

    validate :only_one_rhn_provider
    validates :repository_url, :length => {:maximum => 255}, :if => :redhat_provider?
    validates_with Validators::KatelloUrlFormatValidator, :if => :redhat_provider?,
                   :attributes => :repository_url


    default_scope lambda {
      with_taxonomy_scope
    }
    scope :redhat, where(:provider_type => REDHAT)
    scope :custom, where(:provider_type => CUSTOM)

    def only_one_rhn_provider
      # validate only when new record is added (skip explicit valid? calls)
      if new_record? and provider_type == REDHAT and count_providers(REDHAT) != 0
        errors.add(:base, _("Only one Red Hat provider permitted for an Organization"))
      end
    end

    def prevent_redhat_deletion
      if !being_deleted? && redhat_provider?
        Rails.logger.error _("Red Hat provider can not be deleted")
        false
      else
        # organization that is being deleted via background destroyer can delete rh provider
        true
      end
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

    def count_providers type
      Provider.where(:organization_id => self.organization_id, :provider_type => type).count(:id)
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

    def being_deleted?
      organization.being_deleted?
    end

    def serializable_hash(options={})
      options = {} if options == nil
      hash = super(options)
      if Katello.config.katello?
        hash = hash.merge(:sync_state => self.sync_state,
                          :last_sync => self.last_sync)
      end
      hash
    end

    # refreshes products' repositories from CDS. If new versions are released on
    # the CDN, this method will provide loading this new versions.
    def refresh_products
      raise _("Products cannot be refreshed for custom provider.") unless self.redhat_provider?
      self.products.engineering.each do |product|
        product.productContent.each do |pc|
          product.refresh_content(pc.content.id) if pc.katello_enabled? #only refresh PCs that are already enabled
        end
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

    def manifest_task
      return task_status
    end

    def discover_repos(notify = false)
      raise _("Cannot discover repos for the Red Hat Provider") if self.redhat_provider?
      raise _("Repository Discovery already in progress") if self.discovery_task && !self.discovery_task.finished?
      raise _("Discovery URL not set.") if self.discovery_url.blank?
      self.discovered_repos = []
      self.discovery_task = self.async(:organization=>self.organization).start_discovery_task(notify)
      self.save!
    end

    def discovery_url=(value)
      self.discovered_repos = []
      write_attribute(:discovery_url, value)
    end

    def as_json(*args)
      super.merge('organization_label' => self.organization.label)
    end

    protected

     def sanitize_repository_url
       if redhat_provider? && self.repository_url.blank?
        self.repository_url = Katello.config.redhat_repository_url
       end
       if self.repository_url
         self.repository_url.strip!
       end
     end

    private

    def start_discovery_task(notify = false)
      task_id = AsyncOperation.current_task_id
      provider_id = self.id

      #Lambda to continually update the provider
      found_func = lambda do |url|
        provider = ::Provider.find(provider_id)
        provider.discovered_repos << url
        provider.save!
      end
      #Lambda to decide to continue or not
      #  Using the saved task_id to compare current providers
      #  task id
      continue_func = lambda do
        new_prov = ::Provider.find(provider_id)
        if new_prov.discovery_task.nil? || new_prov.discovery_task.id != task_id
          return false
        end
        true
      end

      discover = RepoDiscovery.new(self.discovery_url)
      discover.run(found_func, continue_func)

    rescue => e
      Notify.exception _('Repos discovery failed.'), e if notify
      raise e
    ensure
      ##in case of error
    end
  end
end
