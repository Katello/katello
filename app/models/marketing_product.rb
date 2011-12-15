class MarketingProduct < Product

  has_many :marketing_engineering_products
  has_many :engineering_products, :through => :marketing_engineering_products
end
