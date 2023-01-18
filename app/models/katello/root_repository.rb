module Katello
  # rubocop:disable Metrics/ClassLength
  class RootRepository < Katello::Model
    audited :except => [:content_id]
    serialize :ignorable_content
    serialize :docker_tags_whitelist
    serialize :include_tags
    serialize :exclude_tags
    serialize :os_versions

    include Ext::LabelFromName
    include Encryptable

    encrypts :upstream_password, :upstream_authentication_token

    DOWNLOAD_IMMEDIATE = 'immediate'.freeze
    DOWNLOAD_ON_DEMAND = 'on_demand'.freeze
    DOWNLOAD_POLICIES = [DOWNLOAD_IMMEDIATE, DOWNLOAD_ON_DEMAND].freeze

    IGNORABLE_CONTENT_UNIT_TYPES = %w(srpm).freeze
    CHECKSUM_TYPES = %w(sha1 sha256).freeze

    SUBSCRIBABLE_TYPES = [Repository::YUM_TYPE, Repository::OSTREE_TYPE, Repository::DEB_TYPE].freeze
    SKIPABLE_METADATA_TYPES = [Repository::YUM_TYPE, Repository::DEB_TYPE].freeze

    CONTENT_ATTRIBUTE_RESTRICTIONS = {
      :download_policy => [Repository::YUM_TYPE, Repository::DEB_TYPE, Repository::DOCKER_TYPE]
    }.freeze

    NO_DEFAULT_HTTP_PROXY = 'none'.freeze
    GLOBAL_DEFAULT_HTTP_PROXY = 'global_default_http_proxy'.freeze
    USE_SELECTED_HTTP_PROXY = 'use_selected_http_proxy'.freeze
    HTTP_PROXY_POLICIES = [
      GLOBAL_DEFAULT_HTTP_PROXY,
      NO_DEFAULT_HTTP_PROXY,
      USE_SELECTED_HTTP_PROXY].freeze

    RHEL6 = 'rhel-6'.freeze
    RHEL7 = 'rhel-7'.freeze
    RHEL8 = 'rhel-8'.freeze
    RHEL9 = 'rhel-9'.freeze
    ALLOWED_OS_VERSIONS = [RHEL6, RHEL7, RHEL8, RHEL9].freeze

    MIRRORING_POLICY_ADDITIVE = 'additive'.freeze
    MIRRORING_POLICY_CONTENT = 'mirror_content_only'.freeze
    MIRRORING_POLICY_COMPLETE = 'mirror_complete'.freeze
    MIRRORING_POLICIES = [MIRRORING_POLICY_ADDITIVE, MIRRORING_POLICY_COMPLETE, MIRRORING_POLICY_CONTENT].freeze

    belongs_to :product, :inverse_of => :root_repositories, :class_name => "Katello::Product"
    has_one :provider, :through => :product

    belongs_to :gpg_key, :inverse_of => :root_repositories, :class_name => "Katello::ContentCredential"
    belongs_to :ssl_ca_cert, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_ca_root_repos
    belongs_to :ssl_client_cert, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_client_root_repos
    belongs_to :ssl_client_key, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_key_root_repos
    belongs_to :http_proxy, :inverse_of => :root_repositories
    has_many :repositories, :class_name => "Katello::Repository", :foreign_key => :root_id,
                          :inverse_of => :root, :dependent => :destroy

    has_many :repository_references, :class_name => 'Katello::Pulp3::RepositoryReference',
             :dependent => :destroy, :inverse_of => :root_repository

    validates_lengths_from_database :except => [:label]
    validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloUrlFormatValidator, :attributes => :url,
                   :nil_allowed => proc { |repo| repo.custom? || repo.organization.cdn_configuration.export_sync? },
                   :field_name => :url
    validates_with Validators::RootRepositoryUniqueAttributeValidator, :attributes => :name
    validates_with Validators::RootRepositoryUniqueAttributeValidator, :attributes => :label
    validates_with Validators::ContainerImageNameValidator, :attributes => :docker_upstream_name, :allow_blank => true, :if => :docker?

    validate :ensure_valid_docker_attributes, :if => :docker?
    validate :ensure_docker_repo_unprotected, :if => :docker?
    validate :ensure_compatible_download_policy, :if => :yum?
    validate :ensure_valid_collection_attributes, :if => :ansible_collection?
    validate :ensure_valid_auth_url_token, :if => :ansible_collection?
    validate :ensure_valid_ignorable_content
    validate :ensure_valid_include_tags
    validate :ensure_valid_exclude_tags
    validate :ensure_valid_os_versions
    validate :ensure_content_attribute_restrictions
    validate :ensure_valid_upstream_authorization
    validate :ensure_valid_authentication_token, :if => :yum?
    validate :ensure_valid_deb_constraints, :if => :deb?
    validate :ensure_no_checksum_on_demand
    validate :ensure_valid_mirroring_policy
    validate :ensure_valid_retain_package_versions_count
    validates :checksum_type, :inclusion => {:in => CHECKSUM_TYPES}, :allow_blank => true
    validates :product_id, :presence => true
    validates :content_type, :inclusion => {
      :in => ->(_) { Katello::RepositoryTypeManager.enabled_repository_types.keys },
      :allow_blank => false,
      :message => ->(_, _) { _("is not enabled. must be one of the following: %s") % Katello::RepositoryTypeManager.enabled_repository_types.keys.join(', ') }
    }
    validates :download_policy, inclusion: {
      :in => DOWNLOAD_POLICIES,
      :message => _("must be one of the following: %s") % DOWNLOAD_POLICIES.join(', ')
    }, if: :yum?
    validates :http_proxy_policy, inclusion: {
      :in => HTTP_PROXY_POLICIES,
      :message => _("must be one of the following: %s") % HTTP_PROXY_POLICIES.join(', ')
    }
    scope :subscribable, -> { where(content_type: RootRepository::SUBSCRIBABLE_TYPES) }
    scope :skipable_metadata_check, -> { where(content_type: RootRepository::SKIPABLE_METADATA_TYPES) }
    scope :has_url, -> { where.not(:url => nil) }
    scope :with_repository_attribute, ->(attr, value) { joins(:repositories).where("#{Katello::Repository.table_name}.#{attr}" => value) }
    scope :in_content_view_version, ->(version) { with_repository_attribute(:content_view_version_id, version) }
    scope :deb_type, -> { where(:content_type => Repository::DEB_TYPE) }
    scope :yum_type, -> { where(:content_type => Repository::YUM_TYPE) }
    scope :file_type, -> { where(:content_type => Repository::FILE_TYPE) }
    scope :docker_type, -> { where(:content_type => Repository::DOCKER_TYPE) }
    scope :ostree_type, -> { where(:content_type => Repository::OSTREE_TYPE) }
    scope :ansible_collection_type, -> { where(:content_type => Repository::ANSIBLE_COLLECTION_TYPE) }
    scope :with_global_proxy, -> { where(:http_proxy_policy => RootRepository::GLOBAL_DEFAULT_HTTP_PROXY) }
    scope :with_no_proxy, -> { where(:http_proxy_policy => RootRepository::NO_DEFAULT_HTTP_PROXY) }
    scope :with_selected_proxy, ->(http_proxy_id) {
      where(:http_proxy_policy => RootRepository::USE_SELECTED_HTTP_PROXY).
      where(:http_proxy_id => http_proxy_id)
    }
    scope :orphaned, -> { where.not(id: Katello::Repository.pluck(:root_id).uniq) }
    scope :redhat, -> { joins(:provider).merge(Katello::Provider.redhat) }
    scope :custom, -> { where.not(:id => self.redhat) }
    delegate :redhat?, :provider, :organization, to: :product
    delegate :cdn_configuration, to: :organization

    def library_instance
      repositories.in_default_view.first
    end

    def self.repositories
      Repository.where(:root => self)
    end

    def repository_type
      RepositoryTypeManager.find(self.content_type)
    end

    def custom?
      !redhat?
    end

    def self.in_organization(org)
      joins(:product).where("#{Katello::Product.table_name}.organization_id" => org)
    end

    def ensure_content_attribute_restrictions
      CONTENT_ATTRIBUTE_RESTRICTIONS.each do |attribute, value|
        if self.send(attribute).present? && !value.include?(self.content_type)
          errors.add(attribute, _("Cannot set attribute %{attr} for content type %{type}") % {:attr => attribute, :type => self.content_type})
        end
      end
    end

    def ensure_compatible_download_policy
      if !url.blank? && URI(url).scheme == 'file' &&
          download_policy == ::Katello::RootRepository::DOWNLOAD_ON_DEMAND
        errors.add(:download_policy, _("Cannot sync file:// repositories with the On Demand Download Policy"))
      end
    end

    def valid_mirroring_policies
      if self.yum?
        MIRRORING_POLICIES
      else
        [MIRRORING_POLICY_ADDITIVE, MIRRORING_POLICY_CONTENT]
      end
    end

    def ensure_valid_mirroring_policy
      unless valid_mirroring_policies.include?(self.mirroring_policy)
        errors.add(:mirroring_policy, _("Invalid mirroring policy for repository type %{type}, only %{policies} are valid.") %
          {:type => self.content_type, :policies => valid_mirroring_policies.join(', ')})
      end
    end

    def ensure_valid_docker_attributes
      if (!url.blank? && docker_upstream_name.blank?)
        errors.add(:docker_upstream_name, N_("cannot be blank when Repository URL is provided."))
        errors.add(:base, _("Upstream Name cannot be blank when Repository URL is provided."))
      end
    end

    def ensure_docker_repo_unprotected
      unless unprotected
        errors.add(:base, _("Container Image Repositories are not protected at this time. " \
                             "They need to be published via http to be available to containers."))
      end
    end

    def self.hosts_with_applicability
      ::Host.joins(:content_facet => :bound_repositories).where("#{Katello::Repository.table_name}.root_id" => self.select(:id))
    end

    def ensure_no_download_policy
      if !yum? && download_policy.present?
        errors.add(:download_policy, _("cannot be set for non-yum repositories."))
      end
    end

    def ensure_no_checksum_on_demand
      if checksum_type.present? && download_policy == DOWNLOAD_ON_DEMAND
        errors.add(:checksum_type, _("Checksum type cannot be set for yum repositories with on demand download policy."))
      end
    end

    def ensure_valid_collection_attributes
      errors.add(:base, _("URL needs to have a trailing /")) if !url.blank? && url[-1] != '/'
      return unless ansible_collection_requirements
      begin
        requirements = YAML.safe_load(ansible_collection_requirements)
        if requirements.is_a?(Hash)
          errors.add(:base,  _("Requirements yaml should have a 'collections' key")) unless requirements.key?('collections')
        else
          errors.add(:base,  _('Requirements yaml should be a key-value pair structure.'))
        end
      rescue
        errors.add(:base, _('Requirements is not valid yaml.'))
      end
    end

    def ensure_valid_ignorable_content
      return if ignorable_content.blank?
      if !yum?
        errors.add(:ignorable_content, N_("Ignorable content can be only set for Yum repositories."))
      elsif !ignorable_content.is_a?(Array)
        errors.add(:ignorable_content, N_("Invalid value specified for ignorable content."))
      elsif ignorable_content.any? { |item| !IGNORABLE_CONTENT_UNIT_TYPES.include?(item) }
        errors.add(:ignorable_content, N_("Invalid value specified for ignorable content. Permissible values %s") % IGNORABLE_CONTENT_UNIT_TYPES.join(","))
      elsif self.mirroring_policy == MIRRORING_POLICY_COMPLETE
        errors.add(:ignorable_content, N_("Ignore %s can not be set in combination with 'Complete Mirroring' mirroring policy.") % IGNORABLE_CONTENT_UNIT_TYPES.join(","))
      end
    end

    def ensure_valid_include_tags
      return if include_tags.blank?
      unless include_tags.is_a?(Array)
        errors.add(:include_tags, N_("Invalid value specified for Container Image repositories."))
      end
    end

    def ensure_valid_exclude_tags
      return if exclude_tags.blank?
      unless exclude_tags.is_a?(Array)
        errors.add(:exclude_tags, N_("Invalid value specified for Container Image repositories."))
      end
    end

    def ensure_valid_os_versions
      return if os_versions.empty?
      # os_versions here translate to candlepin as 'required tags'.
      # A host must provide ALL required tags in order for the repo to be enabled.
      # So os_versions such as ['rhel-7', 'rhel-8'] is not allowed, since the repo would always be disabled.
      unless yum?
        errors.add(:os_versions, N_("are only allowed for Yum repositories."))
      end
      if os_versions.length > 1
        errors.add(:os_versions, N_("invalid: Repositories can only require one OS version."))
      end
      os_versions.each do |tag|
        unless ALLOWED_OS_VERSIONS.include?(tag)
          errors.add(:os_versions, N_("must be one of: %s" % ALLOWED_OS_VERSIONS.join(', ')))
        end
      end
    end

    def ensure_valid_upstream_authorization
      # Make sure that the upstream_username / upstream_password is really unset
      # in case if the string is maybe just ""
      if self.upstream_username.blank? && self.upstream_password.blank?
        self.upstream_username = nil
        self.upstream_password = nil
        if !self.url.blank? && self.url.start_with?('uln') && !self.content
          errors.add(:base, N_("Upstream username and upstream password cannot be blank for ULN repositories"))
        end
        return
      end

      if redhat?
        errors.add(:base, N_("Upstream username and password may only be set on custom repositories."))
      elsif self.upstream_username.blank?
        errors.add(:base, N_("Upstream password requires upstream username be set."))
      elsif !self.upstream_password
        errors.add(:base, N_("Upstream username requires upstream password be set.")) # requirement of pulp
      end
    end

    def ensure_valid_auth_url_token
      if self.ansible_collection_auth_url.blank? && self.ansible_collection_auth_token.blank?
        self.ansible_collection_auth_url = nil
        self.ansible_collection_auth_token = nil
        return
      end

      if !self.ansible_collection_auth_url.blank? && self.ansible_collection_auth_token.blank?
        errors.add(:base, N_("Auth URL requires Auth token be set."))
      end
    end

    def ensure_valid_authentication_token
      if self.upstream_authentication_token.blank?
        self.upstream_authentication_token = nil
      end
    end

    def ensure_valid_deb_constraints
      return if self.deb_releases.blank? && self.url.blank?
      if self.deb_releases.blank?
        errors.add(:base, N_("When \"Upstream URL\" is set, \"Releases/Distributions\" must also be set!"))
      elsif self.url.blank? && !self.content
        errors.add(:base, N_("When \"Releases/Distributions\" is set, \"Upstream URL\" must also be set!"))
      end
    end

    def ensure_valid_retain_package_versions_count
      return unless self.retain_package_versions_count
      unless yum?
        errors.add(:retain_package_versions_count, N_("is only allowed for Yum repositories."))
      end
      if self.retain_package_versions_count.to_i < 0
        errors.add(:retain_package_versions_count, N_("must not be a negative value."))
      end
    end

    def custom_content_path
      parts = []
      # We generate repo path only for custom product content. We add this
      # constant string to avoid collisions with RH content. RH content url
      # begins usually with something like "/content/dist/rhel/...".
      # There we prefix custom content/repo url with "/custom/..."
      parts << "custom"
      parts += [product.label, self.label]
      "/" + parts.map { |x| x.gsub(/[^-\w]/, "_") }.join("/")
    end

    def custom_content_label
      "#{organization.label} #{product.label} #{label}".gsub(/\s/, "_")
    end

    def content
      Katello::Content.find_by(:cp_content_id => self.content_id, :organization_id => self.product.organization_id)
    end

    # For API support during deprecation period.
    def docker_tags_whitelist
      include_tags
    end

    def docker?
      self.content_type == Repository::DOCKER_TYPE
    end

    def file?
      self.content_type == Repository::FILE_TYPE
    end

    def yum?
      self.content_type == Repository::YUM_TYPE
    end

    def ostree?
      self.content_type == Repository::OSTREE_TYPE
    end

    def deb?
      self.content_type == Repository::DEB_TYPE
    end

    def ansible_collection?
      self.content_type == Repository::ANSIBLE_COLLECTION_TYPE
    end

    def generic?
      Katello::RepositoryTypeManager.generic_repository_types(false).values.map(&:id).map(&:to_s).flatten.include? self.content_type
    end

    def metadata_generate_needed?
      (%w(unprotected checksum_type container_repsoitory_name) & previous_changes.keys).any?
    end

    def using_mirrored_content?
      self.mirroring_policy != Katello::RootRepository::MIRRORING_POLICY_ADDITIVE
    end

    def on_demand?
      self.download_policy == DOWNLOAD_ON_DEMAND
    end

    def pulp_update_needed?
      changeable_attributes = %w(url unprotected checksum_type docker_upstream_name download_policy mirroring_policy verify_ssl_on_sync
                                 upstream_username upstream_password ignorable_content retain_package_versions_count
                                 ssl_ca_cert_id ssl_client_cert_id ssl_client_key_id http_proxy_policy http_proxy_id download_concurrency)
      changeable_attributes += %w(name container_repository_name include_tags exclude_tags) if docker?
      changeable_attributes += %w(deb_releases deb_components deb_architectures gpg_key_id) if deb?
      changeable_attributes += %w(ansible_collection_requirements ansible_collection_auth_url ansible_collection_auth_token) if ansible_collection?
      changeable_attributes.any? { |key| previous_changes.key?(key) }
    end

    def raw_content_path
      self.content.content_url
    end

    def repo_mapper
      @repo_mapper ||= Katello::Candlepin::RepositoryMapper.new(self.product, self.content, self.substitutions)
    end

    def calculate_updated_name
      fail _("Cannot calculate name for custom repos") if custom?
      repo_mapper.name
    end

    def substitutions
      {
        :releasever => self.minor,
        :basearch => self.arch
      }.compact
    end

    def http_proxy
      case http_proxy_policy
      when NO_DEFAULT_HTTP_PROXY
        return nil
      when GLOBAL_DEFAULT_HTTP_PROXY
        return HttpProxy.default_global_content_proxy
      end
      super
    end

    def format_arches
      if content_type == ::Katello::Repository::DEB_TYPE
        self.deb_architectures&.gsub(" ", ",")
      else
        self.arch == "noarch" ? nil : self.arch
      end
    end

    apipie :class, desc: 'A class representing Repository object' do
      name 'Repository'
      refs 'Repository'
      sections only: %w[all additional]
      prop_group :katello_basic_props, Katello::Model, meta: { friendly_name: 'Repository' }
      property :docker_upstream_name, String, desc: 'Returns name of the upstream docker repository'
      property :url, String, desc: 'Returns repository source URL'
    end
    class Jail < ::Safemode::Jail
      allow :name, :label, :docker_upstream_name, :url, :os_versions
    end
  end
end
