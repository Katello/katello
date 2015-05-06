module Katello
  class MarketingEngineeringProduct < Katello::Model
    self.include_root_in_json = false

    belongs_to :marketing_product, :class_name => "Product", :inverse_of => :marketing_engineering_products
    belongs_to :engineering_product, :class_name => "Product", :inverse_of => :marketing_engineering_products
    validates_lengths_from_database
  end
end
