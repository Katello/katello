module Katello
  class Provider < Katello::Model
    self.include_root_in_json = false

    include ForemanTasks::Concerns::ActionSubject
    include Glue::Provider
    include Glue

    REDHAT = 'Red Hat'.encode('utf-8')
    CUSTOM = 'Custom'.encode('utf-8')
    ANONYMOUS = 'Anonymous'.encode('utf-8')
    TYPES = [REDHAT, CUSTOM, ANONYMOUS]

    belongs_to :organization, :inverse_of => :providers, :class_name => "Organization"
    belongs_to :task_status, :inverse_of => :provider
    has_many :products, :class_name => "Katello::Product", :inverse_of => :provider, :dependent => :restrict_with_error
    has_many :repositories, :through => :products

    validates_lengths_from_database
    validates :name, :uniqueness => {:scope => :organization_id}
    validates :provider_type, :inclusion => {:in => TYPES,
                                             :allow_blank => false, :message => "Please select provider type from one of the following: #{TYPES.join(', ')}."}
    validate :constraint_redhat_update
    validate :only_one_rhn_provider
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloUrlFormatValidator, :if => :redhat_provider?,
                                                          :attributes => [:repository_url]

    before_destroy :prevent_redhat_deletion
    before_validation :sanitize_repository_url

    scope :redhat, where(:provider_type => REDHAT)
    scope :custom, where(:provider_type => CUSTOM)
    scope :anonymous, where(:provider_type => ANONYMOUS)

    def self.create_anonymous!(organization)
      create!(:name => SecureRandom.uuid, :description => nil,
              :organization => organization, :provider_type => ANONYMOUS,
              :repository_url => nil)
    end

    def only_one_rhn_provider
      # validate only when new record is added (skip explicit valid? calls)
      if new_record? && provider_type == REDHAT && count_providers(REDHAT) != 0
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

    def count_providers(type)
      Provider.where(:organization_id => self.organization_id, :provider_type => type).count(:id)
    end

    def yum_repo?
      provider_type == CUSTOM || provider_type == ANONYMOUS
    end

    def redhat_provider=(is_rh)
      is_rh ? REDHAT : ANONYMOUS # Anonymous is the now the default
    end

    def redhat_provider?
      provider_type == REDHAT
    end

    def custom_provider?
      provider_type == CUSTOM
    end

    def anonymous_provider?
      provider_type == ANONYMOUS
    end

    delegate :being_deleted?, to: :organization

    def serializable_hash(options = {})
      options = {} if options.nil?
      hash = super(options)
      hash = hash.merge(:sync_state => self.sync_state,
                        :last_sync => self.last_sync)
      hash
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
                  cdn_var_substitutor.substitute_vars(url_to_releases).each do |(substitutions, _path)|
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

    def as_json(*args)
      super.merge('organization_label' => self.organization.label)
    end

    def total_products
      products.length
    end

    def total_repositories
      repositories.length
    end

    def related_resources
      self.organization
    end

    protected

    def sanitize_repository_url
      sanitize_url(:repository_url, Katello.config.redhat_repository_url)
    end

    def sanitize_url(attrib, default_value)
      if redhat_provider? && self.send(attrib).blank?
        self.send("#{attrib}=", default_value)
      end
      if self.send(attrib)
        self.send(attrib).strip!
      end
    end
  end
end
