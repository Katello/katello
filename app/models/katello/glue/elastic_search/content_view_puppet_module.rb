module Katello
  module Glue::ElasticSearch::ContentViewPuppetModule
    extend ActiveSupport::Concern

    included do
      include Ext::IndexedModel

      index_options :extended_json => :extended_index_attrs,
                    :json => { :only => [:id, :name, :author, :uuid, :content_view] },
                    :display_attrs => [:id, :name, :author, :uuid, :content_view]

      mapping do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
        indexes :author, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :uuid, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :content_view, :type => 'string', :analyzer => :kt_name_analyzer
      end
    end

    def extended_index_attrs
      {
        :name_sort => name.try(:downcase),
        :name_autocomplete => self.name,
        :content_view => self.content_view.name
      }
    end
  end
end
