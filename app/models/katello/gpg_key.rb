module Katello
  class GpgKey < Katello::Model
    self.include_root_in_json = false

    include Katello::Authorization::GpgKey
    MAX_CONTENT_LENGTH = 100_000
    MAX_CONTENT_LINE_LENGTH = 65

    has_many :repositories, :class_name => "Katello::Repository", :inverse_of => :gpg_key, :dependent => :nullify
    has_many :products, :class_name => "Katello::Product", :inverse_of => :gpg_key, :dependent => :nullify

    belongs_to :organization, :inverse_of => :gpg_keys

    validates_lengths_from_database
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id,
                                                        :message => N_("has already been taken")}
    validates :content, :presence => true, :length => {:maximum => MAX_CONTENT_LENGTH}
    validates :organization, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::ContentValidator, :attributes => :content
    validates_with Validators::GpgKeyContentValidator, :attributes => :content, :if => proc { SETTINGS[:katello][:gpg_strict_validation] }

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true

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
