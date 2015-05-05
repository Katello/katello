module Katello
  module Glue::ElasticSearch::ActivationKey
    def self.included(base)
      base.send :include, Ext::IndexedModel

      base.class_eval do
        index_options :extended_json => :extended_json, :display_attrs => [:name, :description, :environment, :content_view]

        mapping do
          indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
          indexes :name_sort, :type => 'string', :index => :not_analyzed
        end
      end
    end

    def extended_json
      to_ret = {
        :environment  => self.environment.try(:name),
        :name_sort    => name.downcase,
        :content_view => self.content_view.try(:name)
      }
      to_ret
    end
  end
end
