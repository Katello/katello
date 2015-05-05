module Katello
  class MarketingProduct < Product
    include Glue::ElasticSearch::MarketingProduct if Katello.config.use_elasticsearch

    has_many :marketing_engineering_products, :dependent => :destroy
    has_many :engineering_products, :through => :marketing_engineering_products
    validates_lengths_from_database
  end
end
