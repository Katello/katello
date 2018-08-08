module Katello
  class Content < Katello::Model
    include Katello::Glue::Candlepin::Content
    has_many :product_contents, :class_name => 'Katello::ProductContent', :dependent => :destroy
    has_many :products, :through => :product_contents
    belongs_to :organization, :inverse_of => :contents, :class_name => "::Organization"

    validates :label, :uniqueness => {:scope => :organization_id}
    validates :cp_content_id, :uniqueness => {:scope => :organization_id}

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :content_type, :complete_value => true
    scoped_search :on => :label, :complete_value => true
    scoped_search :relation => :products, :on => :name, :rename => :product_name, :complete_value => true

    after_save :update_repository_names, :if => :propagate_name_change?

    def update_repository_names
      root_repositories.each do |root|
        root.update_attributes!(:name => root.calculate_updated_name)
      end
    end

    def root_repositories
      Katello::RootRepository.where(:content_id => self.cp_content_id)
    end

    def repositories
      Katello::Repository.where(:root_id => root_repositories)
    end

    def redhat?
      self.products.first.try(:redhat?)
    end

    def propagate_name_change?
      self.saved_change_to_attribute?(:name) && self.redhat?
    end

    def self.import_all
      Organization.all.each do |org|
        org.products.each do |product|
          begin
            product_json = Katello::Resources::Candlepin::Product.get(org.label,
                                                                  product.cp_id,
                                                                  %w(productContent)).first
            product_content_attrs = product_json['productContent']
            Katello::Glue::Candlepin::Product.import_product_content(product, product_content_attrs)
          rescue RestClient::NotFound
            Rails.logger.warn _("Product with ID %s not found in Candlepin. Skipping content import for it.") % product.cp_id
          end
        end
      end
    end
  end
end
