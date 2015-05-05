module Katello
  module Glue::ElasticSearch::ContentViewFilter
    extend ActiveSupport::Concern

    included do
      include Ext::IndexedModel

      index_options :extended_json => :extended_index_attrs,
                    :json => { :only => [:id, :type, :name, :inclusion] },
                    :display_attrs => [:name]

      mapping do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
        indexes :type, :type => 'string', :index => :not_analyzed
        indexes :inclusion, :type => 'boolean'
      end
    end

    def extended_index_attrs
      {
        :name_sort => name.downcase,
        :content_view_id => self.content_view_id
      }
    end
  end
end
