class MarketingEngineeringProduct < ActiveRecord::Base
  belongs_to :marketing_product, :class_name => "Product"
  belongs_to :engineering_product, :class_name => "Product"
end
