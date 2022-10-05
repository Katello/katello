module Katello
  class AlternateContentSourceProduct < Katello::Model
    audited
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    self.table_name = :katello_alternate_content_source_products
    belongs_to :alternate_content_source, inverse_of: :alternate_content_source_products, class_name: 'Katello::AlternateContentSource'
    belongs_to :product, inverse_of: :alternate_content_source_products, class_name: 'Katello::Product'
    delegate :custom?, :rhui?, to: :alternate_content_source
    delegate :simplified?, to: :alternate_content_source

    validates_with Validators::AlternateContentSourceProductsValidator, :attributes => [:product_id], if: :simplified?
  end
end
