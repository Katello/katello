module Katello
  module Glue::ElasticSearch::Provider
    def self.included(base)
      base.send :include, Ext::IndexedModel

      base.class_eval do
        index_options :extended_json => :extended_index_attrs,
                      :display_attrs => [:name, :product, :repo, :description]

        mapping do
          indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
          indexes :name_sort, :type => 'string', :index => :not_analyzed
          indexes :provider_type, :type => 'string', :index => :not_analyzed
        end
      end
    end

    def extended_index_attrs
      products = self.products.map do |prod|
        {:product => prod.name, :repo => prod.repos(self.organization.library).collect { |repo| repo.name }}
      end

      {
        :products => products,
        :name_sort => name.downcase
      }
    end
  end
end
