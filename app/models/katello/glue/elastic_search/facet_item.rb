module Katello
  class Glue::ElasticSearch::FacetItem
    attr_accessor :term, :count

    def initialize(params = {})
      params.each_pair { |k, v| instance_variable_set("@#{k}", v) unless v.nil? }
    end
  end
end
