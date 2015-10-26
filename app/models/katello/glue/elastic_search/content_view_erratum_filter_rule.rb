module Katello
  module Glue::ElasticSearch::ContentViewErratumFilterRule
    extend ActiveSupport::Concern

    included do
      include Ext::IndexedModel

      index_options :extended_json => :extended_index_attrs,
                    :json => { :only => [:id,
                                         :errata_id,
                                         :start_date,
                                         :end_date,
                                         :types,
                                         :created_at,
                                         :updated_at]
                             },
                    :display_attrs => [:name]

      mapping do
        indexes :errata_id, :type => 'string', :analyzer => :snowball
        indexes :errata_id_sort, :type => 'string', :index => :not_analyzed
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
      end
    end

    def extended_index_attrs
      {
        :name => self.errata_id,
        :content_view_filter_id => self.content_view_filter_id
      }
    end
  end
end
