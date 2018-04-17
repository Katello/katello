module Katello
  class GpgKey < Katello::Model
    audited :associations => [:products]

    include Katello::Authorization::GpgKey
    MAX_CONTENT_LINE_LENGTH = 65

    GPG_KEY_TYPE = 'gpg_key'.freeze
    CERT_TYPE = 'cert'.freeze

    has_many :repositories, :class_name => "Katello::Repository", :inverse_of => :gpg_key, :dependent => :nullify
    has_many :products, :class_name => "Katello::Product", :inverse_of => :gpg_key, :dependent => :nullify
    has_many :ssl_ca_products, :class_name => "Katello::Product", :foreign_key => "ssl_ca_cert_id",
                               :inverse_of => :ssl_ca_cert, :dependent => :nullify
    has_many :ssl_client_products, :class_name => "Katello::Product", :foreign_key => "ssl_client_cert_id",
                                   :inverse_of => :ssl_client_cert, :dependent => :nullify
    has_many :ssl_key_products, :class_name => "Katello::Product", :foreign_key => "ssl_client_key_id",
                                :inverse_of => :ssl_client_key, :dependent => :nullify
    has_many :ssl_ca_repos, :class_name => "Katello::Repository", :foreign_key => "ssl_ca_cert_id",
                            :inverse_of => :ssl_ca_cert, :dependent => :nullify
    has_many :ssl_client_repos, :class_name => "Katello::Repository", :foreign_key => "ssl_client_cert_id",
                                :inverse_of => :ssl_client_cert, :dependent => :nullify
    has_many :ssl_key_repos, :class_name => "Katello::Repository", :foreign_key => "ssl_client_key_id",
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

    def as_json(options = {})
      options ||= {}
      ret = super(options.except(:details))
      if options[:details]
        ret[:products] = products.map { |p| {:name => p.name} }
        ret[:repositories] = repositories.map { |r| {:product => {:name => r.product.name}, :name => r.name} }
      end
      ret
    end

    def self.humanize_class_name(_name = nil)
      _("GPG Keys")
    end

    def to_label
      "content credential (#{content_type} - #{name})"
    end
  end
end
