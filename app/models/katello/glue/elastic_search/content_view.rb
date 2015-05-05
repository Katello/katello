module Katello
  module Glue::ElasticSearch::ContentView
    extend ActiveSupport::Concern

    included do
      include Ext::IndexedModel

      update_related_indexes :repositories, :name

      index_options :extended_json => :extended_index_attrs,
                    :json => {:only => [:id, :name, :label, :description, :default, :composite]},
                    :display_attrs => [:name, :description]

      mapping do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
        indexes :label, :type => 'string', :index => :not_analyzed
        indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_autocomplete, :type => 'string', :analyzer => 'autcomplete_name_analyzer'
        indexes :default, :type => 'boolean'
        indexes :composite, :type => 'boolean'
      end
    end

    def extended_index_attrs
      {
        :name_sort => name.downcase,
        :name_autocomplete => self.name,
        :organization_id => organization.id,
        :composite => composite.nil? ? false : composite
      }
    end

    def total_package_count(env)
      repoids = self.repos(env).collect { |r| r.pulp_id }
      result = Katello::Package.legacy_search('*', 0, 1, repoids)
      result.length > 0 ? result.total : 0
    end

    def total_puppet_module_count(env)
      repoids = self.repos(env).collect { |r| r.pulp_id }
      result = Katello::PuppetModule.legacy_search('*', :page_size => 1, :repoids => repoids)
      result.length > 0 ? result.total : 0
    end
  end
end
