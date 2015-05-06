module Katello
  module Glue::ElasticSearch::MarketingProduct
    def self.included(base)
      base.class_eval do
        index_name "#{Katello.config.elastic_index}_marketing_product"
      end
    end
  end
end
