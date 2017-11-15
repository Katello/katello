module Katello
  class GpgKey < Katello::Model
    include Katello::Authorization::GpgKey
    MAX_CONTENT_LENGTH = 100_000
    MAX_CONTENT_LINE_LENGTH = 65

    has_many :repositories, :class_name => "Katello::Repository", :inverse_of => :gpg_key, :dependent => :nullify
    has_many :products, :class_name => "Katello::Product", :inverse_of => :gpg_key, :dependent => :nullify
    has_many :ssl_ca_products, :class_name => "Katello::Product", :foreign_key => "ssl_ca_cert_id",
                               :inverse_of => :ssl_ca_cert, :dependent => :nullify
    has_many :ssl_client_products, :class_name => "Katello::Product", :foreign_key => "ssl_client_cert_id",
                                   :inverse_of => :ssl_client_cert, :dependent => :nullify
    has_many :ssl_key_products, :class_name => "Katello::Product", :foreign_key => "ssl_client_key_id",
                                :inverse_of => :ssl_client_key, :dependent => :nullify
    belongs_to :organization, :inverse_of => :gpg_keys

    validates_lengths_from_database
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id,
                                                        :message => N_("has already been taken")}
    validates :content_type, :presence => true, :inclusion => { :in => %w(gpg_key cert),
                                                                :message => N_("must be gpg_key or cert")}
    validates :content, :presence => true, :length => {:maximum => MAX_CONTENT_LENGTH}
    validates :organization, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::ContentValidator, :attributes => :content
    validates_with Validators::GpgKeyContentValidator, :attributes => :content, :if => :use_gpg_content_validator?

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

    def use_gpg_content_validator?
      content_type == "gpg_key" && SETTINGS[:katello][:gpg_strict_validation]
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
  end
end
