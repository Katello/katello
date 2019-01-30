module Katello
  class RootRepository < Katello::Model
    audited
    serialize :ignorable_content
    serialize :docker_tags_whitelist

    include Ext::LabelFromName

    IGNORABLE_CONTENT_UNIT_TYPES = %w(rpm drpm srpm distribution erratum).freeze
    CHECKSUM_TYPES = %w(sha1 sha256).freeze

    OSTREE_UPSTREAM_SYNC_POLICY_LATEST = "latest".freeze
    OSTREE_UPSTREAM_SYNC_POLICY_ALL = "all".freeze
    OSTREE_UPSTREAM_SYNC_POLICY_CUSTOM = "custom".freeze
    OSTREE_UPSTREAM_SYNC_POLICIES = [OSTREE_UPSTREAM_SYNC_POLICY_LATEST, OSTREE_UPSTREAM_SYNC_POLICY_ALL, OSTREE_UPSTREAM_SYNC_POLICY_CUSTOM].freeze

    SUBSCRIBABLE_TYPES = [Repository::YUM_TYPE, Repository::OSTREE_TYPE, Repository::DEB_TYPE].freeze

    CONTENT_ATTRIBUTE_RESTRICTIONS = {
      :ostree_upstream_sync_depth => [Repository::OSTREE_TYPE],
      :ostree_upstream_sync_policy => [Repository::OSTREE_TYPE],
      :download_policy => [Repository::YUM_TYPE]

    }.freeze

    belongs_to :product, :inverse_of => :root_repositories, :class_name => "Katello::Product"
    belongs_to :gpg_key, :inverse_of => :root_repositories, :class_name => "Katello::GpgKey"
    belongs_to :ssl_ca_cert, :class_name => "Katello::GpgKey", :inverse_of => :ssl_ca_root_repos
    belongs_to :ssl_client_cert, :class_name => "Katello::GpgKey", :inverse_of => :ssl_client_root_repos
    belongs_to :ssl_client_key, :class_name => "Katello::GpgKey", :inverse_of => :ssl_key_root_repos
    has_many :repositories, :class_name => "Katello::Repository", :foreign_key => :root_id,
                          :inverse_of => :root, :dependent => :destroy

    before_validation :update_ostree_upstream_sync_policy

    validates_lengths_from_database :except => [:label]
    validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloUrlFormatValidator, :attributes => :url, :nil_allowed => proc { |repo| repo.custom? },
                   :field_name => :url
    validates_with Validators::RootRepositoryUniqueAttributeValidator, :attributes => :name
    validates_with Validators::RootRepositoryUniqueAttributeValidator, :attributes => :label
    validates_with Validators::ContainerImageNameValidator, :attributes => :docker_upstream_name, :allow_blank => true, :if => :docker?

    validate :ensure_valid_docker_attributes, :if => :docker?
    validate :ensure_docker_repo_unprotected, :if => :docker?
    validate :ensure_ostree_repo_protected, :if => :ostree?
    validate :ensure_compatible_download_policy, :if => :yum?
    validate :ensure_valid_ignorable_content
    validate :ensure_valid_docker_tags_whitelist
    validate :ensure_content_attribute_restrictions
    validate :ensure_valid_upstream_authorization
    validate :ensure_no_checksum_on_demand
    validates :url, presence: true, if: :ostree?
    validates :checksum_type, :inclusion => {:in => CHECKSUM_TYPES}, :allow_blank => true
    validates :product_id, :presence => true
    validates :ostree_upstream_sync_policy, :inclusion => {:in => OSTREE_UPSTREAM_SYNC_POLICIES, :allow_blank => true}, :if => :ostree?
    validates :ostree_upstream_sync_depth, :presence => true, :numericality => { :only_integer => true },
      :if => proc { |r| r.ostree? && r.ostree_upstream_sync_policy == OSTREE_UPSTREAM_SYNC_POLICY_CUSTOM }
    validates :content_type, :inclusion => {
      :in => ->(_) { Katello::RepositoryTypeManager.repository_types.keys },
      :allow_blank => false,
      :message => ->(_, _) { _("must be one of the following: %s") % Katello::RepositoryTypeManager.repository_types.keys.join(', ') }
    }
    validates :download_policy, inclusion: {
      :in => ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES,
      :message => _("must be one of the following: %s") % ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES.join(', ')
    }, if: :yum?

    scope :subscribable, -> { where(content_type: RootRepository::SUBSCRIBABLE_TYPES) }
    scope :has_url, -> { where.not(:url => nil) }
    scope :with_repository_attribute, ->(attr, value) { joins(:repositories).where("#{Katello::Repository.table_name}.#{attr}" => value) }
    scope :in_content_view_version, ->(version) { with_repository_attribute(:content_view_version_id, version) }
    scope :deb_type, -> { where(:content_type => Repository::DEB_TYPE) }
    scope :yum_type, -> { where(:content_type => Repository::YUM_TYPE) }
    scope :file_type, -> { where(:content_type => Repository::FILE_TYPE) }
    scope :puppet_type, -> { where(:content_type => Repository::PUPPET_TYPE) }
    scope :docker_type, -> { where(:content_type => Repository::DOCKER_TYPE) }
    scope :ostree_type, -> { where(:content_type => Repository::OSTREE_TYPE) }
    delegate :redhat?, :provider, :organization, to: :product

    def library_instance
      repositories.in_default_view.first
    end

    def self.repositories
      Repository.where(:root => self)
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
          [::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND, ::Runcible::Models::YumImporter::DOWNLOAD_BACKGROUND].include?(download_policy)
        errors.add(:download_policy, _("Cannot sync file:// repositories with On Demand or Background Download Policies"))
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

    def ensure_no_download_policy
      if !yum? && download_policy.present?
        errors.add(:download_policy, _("cannot be set for non-yum repositories."))
      end
    end

    def ensure_no_checksum_on_demand
      if checksum_type.present? && ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND == download_policy
        errors.add(:checksum_type, _("Checksum type cannot be set for yum repositories with on demand download policy."))
      end
    end

    def ensure_ostree_repo_protected
      if unprotected
        errors.add(:base, _("OSTree Repositories cannot be unprotected."))
      end
    end

    def update_ostree_upstream_sync_policy
      return unless ostree?
      if self.ostree_upstream_sync_policy.blank?
        self.ostree_upstream_sync_policy = OSTREE_UPSTREAM_SYNC_POLICY_LATEST
      end

      if self.ostree_upstream_sync_policy_changed? &&
        previous_changes[:ostree_upstream_sync_policy].present?
        self.ostree_upstream_sync_depth = nil unless self.ostree_upstream_sync_policy == OSTREE_UPSTREAM_SYNC_POLICY_CUSTOM
      end
    end

    def compute_ostree_upstream_sync_depth
      if ostree_upstream_sync_policy == OSTREE_UPSTREAM_SYNC_POLICY_CUSTOM
        ostree_upstream_sync_depth
      elsif ostree_upstream_sync_policy == OSTREE_UPSTREAM_SYNC_POLICY_ALL
        -1
      else
        0
      end
    end

    def ensure_no_ostree_upstream_sync_policy
      if !ostree? && ostree_upstream_sync_policy.present?
        errors.add(:ostree_upstream_sync_policy, N_("cannot be set for non-ostree repositories."))
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
      end
    end

    def ensure_valid_docker_tags_whitelist
      return if docker_tags_whitelist.blank?
      if !docker?
        errors.add(:docker_tags_whitelist, N_("White list can be only set for Container Image repositories."))
      elsif !docker_tags_whitelist.is_a?(Array)
        errors.add(:docker_tags_whitelist, N_("Invalid value specified for Container Image repositories."))
      end
    end

    def ensure_valid_upstream_authorization
      return if (self.upstream_username.blank? && self.upstream_password.blank?)
      if redhat?
        errors.add(:base, N_("Upstream username and password may only be set on custom repositories."))
      elsif self.upstream_username.blank?
        errors.add(:base, N_("Upstream password requires upstream username be set."))
      elsif !self.upstream_password
        errors.add(:base, N_("Upstream username requires upstream password be set.")) # requirement of pulp
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

    def docker?
      self.content_type == Repository::DOCKER_TYPE
    end

    def puppet?
      self.content_type == Repository::PUPPET_TYPE
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

    def metadata_generate_needed?
      (%w(unprotected checksum_type container_repsoitory_name) & previous_changes.keys).any?
    end

    def on_demand?
      self.download_policy == Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND
    end

    def pulp_update_needed?
      changeable_attributes = %w(url unprotected checksum_type docker_upstream_name download_policy mirror_on_sync verify_ssl_on_sync
                                 upstream_username upstream_password ostree_upstream_sync_policy ostree_upstream_sync_depth ignore_global_proxy ignorable_content)
      changeable_attributes += %w(name container_repository_name docker_tags_whitelist) if docker?
      changeable_attributes += %w(deb_releases deb_components deb_architectures gpg_key_id) if deb?
      changeable_attributes.any? { |key| previous_changes.key?(key) }
    end

    def raw_content_path
      self.content.content_url
    end

    def calculate_updated_name
      fail _("Cannot calculate name for custom repos") if custom?
      Katello::Candlepin::RepositoryMapper.new(self.product, self.content, self.substitutions).name
    end

    def substitutions
      {
        :releasever => self.minor,
        :basearch => self.arch
      }
    end

    class Jail < ::Safemode::Jail
      allow :name, :label, :docker_upstream_name, :url
    end
  end
end
