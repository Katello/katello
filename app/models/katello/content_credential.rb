module Katello
  class ContentCredential < Katello::Model
    audited :associations => [:products]

    include ForemanTasks::Concerns::ActionSubject
    include Katello::Authorization::ContentCredential
    MAX_CONTENT_LINE_LENGTH = 65

    GPG_KEY_TYPE = 'gpg_key'.freeze
    CERT_TYPE = 'cert'.freeze

    has_many :root_repositories, :class_name => "Katello::RootRepository", :inverse_of => :gpg_key, :dependent => :restrict_with_exception, :foreign_key => 'gpg_key_id'
    has_many :repositories, :through => :root_repositories

    has_many :products, :class_name => "Katello::Product", :inverse_of => :gpg_key, :dependent => :restrict_with_exception, :foreign_key => 'gpg_key_id'
    has_many :ssl_ca_cdn_configurations, :class_name => "Katello::CdnConfiguration", :foreign_key => 'ssl_ca_credential_id',
      :inverse_of => :ssl_ca_credential, :dependent => :nullify

    has_many :ssl_ca_products, :class_name => "Katello::Product", :foreign_key => "ssl_ca_cert_id",
                               :inverse_of => :ssl_ca_cert, :dependent => :restrict_with_exception
    has_many :ssl_client_products, :class_name => "Katello::Product", :foreign_key => "ssl_client_cert_id",
                                   :inverse_of => :ssl_client_cert, :dependent => :restrict_with_exception
    has_many :ssl_key_products, :class_name => "Katello::Product", :foreign_key => "ssl_client_key_id",
                                :inverse_of => :ssl_client_key, :dependent => :restrict_with_exception
    has_many :ssl_ca_root_repos, :class_name => "Katello::RootRepository", :foreign_key => "ssl_ca_cert_id",
                            :inverse_of => :ssl_ca_cert, :dependent => :restrict_with_exception
    has_many :ssl_client_root_repos, :class_name => "Katello::RootRepository", :foreign_key => "ssl_client_cert_id",
                                :inverse_of => :ssl_client_cert, :dependent => :restrict_with_exception
    has_many :ssl_key_root_repos, :class_name => "Katello::RootRepository", :foreign_key => "ssl_client_key_id",
                             :inverse_of => :ssl_client_key, :dependent => :restrict_with_exception
    has_many :ssl_ca_alternate_content_sources, :class_name => "Katello::AlternateContentSource", :foreign_key => "ssl_ca_cert_id",
                                :inverse_of => :ssl_ca_cert, :dependent => :nullify
    has_many :ssl_client_alternate_content_sources, :class_name => "Katello::AlternateContentSource", :foreign_key => "ssl_client_cert_id",
                                :inverse_of => :ssl_client_cert, :dependent => :nullify
    has_many :ssl_key_alternate_content_sources, :class_name => "Katello::AlternateContentSource", :foreign_key => "ssl_client_key_id",
                                :inverse_of => :ssl_client_key, :dependent => :nullify
    belongs_to :organization, :inverse_of => :gpg_keys

    validates_lengths_from_database
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id,
                                                        :message => N_("has already been taken")}
    validates :content_type, :presence => true, :inclusion => { :in => [GPG_KEY_TYPE, CERT_TYPE],
                                                                :message => N_("must be %{gpg_key} or %{cert}") % { :gpg_key => GPG_KEY_TYPE, :cert => CERT_TYPE} }
    validates :content, :presence => true
    validates :organization, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::ContentValidator, :attributes => :content
    validates_with Validators::GpgKeyContentValidator, :attributes => :content, :if => :use_gpg_content_validator?

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

    def use_gpg_content_validator?
      content_type == GPG_KEY_TYPE && SETTINGS[:katello][:gpg_strict_validation]
    end

    def self.humanize_class_name(_name = nil)
      _("Content Credentials")
    end

    def to_label
      "content credential (#{content_type} - #{name})"
    end

    def skip_strip_attrs
      ['content']
    end
  end
end
