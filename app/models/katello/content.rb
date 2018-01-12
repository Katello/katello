module Katello
  class Content < Katello::Model
    include Katello::Glue::Candlepin::Content
    has_many :product_contents, :class_name => 'Katello::ProductContent', :dependent => :destroy
    has_many :products, :through => :product_contents

    validates :label, :uniqueness => true
    validates :cp_content_id, :uniqueness => true

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :content_type, :complete_value => true
    scoped_search :on => :label, :complete_value => true
    scoped_search :relation => :products, :on => :name, :rename => :product_name, :complete_value => true

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
