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

    def total_package_count(env)
      repoids = self.repos(env).collect{|r| r.pulp_id}
      result = Package.search('*', 0, 1, repoids)
      result.length > 0 ? result.total : 0
    end

    def total_errata_count(env)
      repo_ids = self.repos(env).collect{|r| r.pulp_id}
      results = Errata.search('', 0, 1, :repoids => repo_ids)
      results.empty? ? 0 : results.total
    end
  end

  included do
    include Ext::IndexedModel

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
