module Katello
  module Glue::ElasticSearch::Notice
    def self.included(base)
      base.send :include, Ext::IndexedModel

      base.class_eval do
        index_options :extended_json => :extended_index_attrs,
                      :json          => { :only => [:text, :created_at, :details, :level] },
                      :display_attrs => [:text, :details, :level, :organization]

        mapping do
          indexes :level_sort, :type => 'string', :index => :not_analyzed
          indexes :created_at, :type => 'date'
        end
      end
    end

    def extended_index_attrs
      { :level_sort   => level.to_s.downcase,
        :user_ids     => self.users.collect { |u| u.id },
        :organization => organization.try(:name) }
    end
  end
end
