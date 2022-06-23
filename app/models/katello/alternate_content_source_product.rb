module Katello
  class AlternateContentSourceProduct < Katello::Model
    audited
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    self.table_name = :katello_alternate_content_source_products
    belongs_to :alternate_content_source, inverse_of: :alternate_content_source_products, class_name: 'Katello::AlternateContentSource'
    belongs_to :product, inverse_of: :alternate_content_source_products, class_name: 'Katello::Product'
  end
end
