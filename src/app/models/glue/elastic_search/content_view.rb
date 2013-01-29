module Glue::ElasticSearch::ContentView
  extend ActiveSupport::Concern

  module ClassMethods
  end

  module InstanceMethods
    def extended_index_attrs
      {
        :name_sort=>name.downcase,
        :name_autocomplete=>self.name,
        :organization_id => organization.id
      }
    end
  end

  included do
    include IndexedModel

    index_options :extended_json => :extended_index_attrs,
                  :json => {:only => [:name, :description]},
                  :display_attrs => [:name, :description]

    mapping do
      indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
      indexes :name_sort, :type => 'string', :index => :not_analyzed
      indexes :label, :type => 'string', :index => :not_analyzed
      indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
      indexes :name_autocomplete, :type=>'string', :analyzer=>'autcomplete_name_analyzer'
    end
  end
end
