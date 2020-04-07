module Katello
  class Content < Katello::Model
    include Katello::Glue::Candlepin::Content
    has_many :product_contents, :class_name => 'Katello::ProductContent', :dependent => :destroy
    has_many :products, :through => :product_contents
    belongs_to :organization, :inverse_of => :contents, :class_name => "::Organization"

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :content_type, :complete_value => true
    scoped_search :on => :label, :complete_value => true
    scoped_search :relation => :products, :on => :name, :rename => :product_name, :complete_value => true
    scoped_search :on => :label, :rename => :content_label, :complete_value => true

    after_update :update_repository_names, :if => :propagate_name_change?

    def update_repository_names
      root_repositories.each do |root|
        root.update!(:name => root.calculate_updated_name)
      end
    end

    def root_repositories
      Katello::RootRepository.where(:content_id => self.cp_content_id)
    end

    def repositories
      Katello::Repository.where(:root_id => root_repositories)
    end

    def redhat?
      products.redhat.any?
    end

    def propagate_name_change?
      self.saved_change_to_attribute?(:name) && self.redhat?
    end

    def self.import_all
      Organization.all.each do |org|
        cp_products = ::Katello::Resources::Candlepin::Product.all(org.label, [:id, :productContent])
        product_hash = cp_products.group_by { |prod| prod['id'] }

        prod_content_importer = Katello::ProductContentImporter.new
        org.products.each do |product|
          product_json = product_hash[product.cp_id]&.first

          if product_json.nil?
            Rails.logger.warn _("Product with ID %s not found in Candlepin. Skipping content import for it.") % product.cp_id
            next
          end

          prod_content_importer.add_product_content(product, product_json['productContent'])
        end
        prod_content_importer.import
      end
    end

    def can_update_to_url?(new_url)
      # We need to match the substitutable variables from
      # current content_url and new_url
      current_subs = content_url&.scan(/\$\w+/)&.sort
      new_url_subs = new_url&.scan(/\$\w+/)&.sort
      current_subs == new_url_subs
    end
  end
end
