module Katello
  module Glue::ElasticSearch::ContentViewPackageFilterRule
    extend ActiveSupport::Concern

    included do
      include Ext::IndexedModel

      index_options :extended_json => :extended_index_attrs,
                    :json => { :only => [:id,
                                         :name,
                                         :version,
                                         :min_version,
                                         :max_version,
                                         :created_at,
                                         :updated_at]
                             },
                    :display_attrs => [:name]

      mapping do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
      end
    end

    def extended_index_attrs
      {
        :name_sort => name.downcase,
        :content_view_filter_id => self.content_view_filter_id
      }
    end
  end
end
