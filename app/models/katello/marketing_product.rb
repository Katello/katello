module Katello
  class MarketingProduct < Product
    has_many :marketing_engineering_products, :dependent => :destroy
    has_many :engineering_products, :through => :marketing_engineering_products
    validates_lengths_from_database
  end
end
