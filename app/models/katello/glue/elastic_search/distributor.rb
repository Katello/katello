# rubocop:disable SymbolName
module Katello
  module Glue::ElasticSearch::Distributor
    # TODO: break this up into modules
    # rubocop:disable MethodLength
    def self.included(base)
      base.class_eval do
        include Ext::IndexedModel

        index_options :extended_json => :extended_index_attrs,
                      :json => {:only => [:name, :description, :id, :uuid, :created_at, :lastCheckin, :environment_id]},
                      :display_attrs => [:name,
                                         :description,
                                         :id,
                                         :uuid,
                                         :created_at,
                                         :lastCheckin]

        dynamic_templates = []

        mapping :dynamic_templates => dynamic_templates do
          indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
          indexes :description, :type => 'string'
          indexes :name_sort, :type => 'string', :index => :not_analyzed
          indexes :lastCheckin, :type => 'date'
          indexes :name_autocomplete, :type => 'string', :analyzer => 'autcomplete_name_analyzer'
        end
      end
    end

    def extended_index_attrs
      {:organization_id => self.organization.id,
       :name_sort => name.downcase, :name_autocomplete => self.name
      }
    end
  end
end
