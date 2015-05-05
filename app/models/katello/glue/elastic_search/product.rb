module Katello
  module Glue::ElasticSearch::Product
    def self.included(base)
      base.send :include, Ext::IndexedModel

      base.class_eval do
        after_save :update_related_index

        index_options :extended_json => :extended_index_attrs,
                      :json => { :only => [:name, :description, :id] },
                      :display_attrs => [:name, :description]

        mapping do
          indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
          indexes :name_sort, :type => 'string', :index => :not_analyzed
          indexes :label, :type => 'string', :index => :not_analyzed
          indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
          indexes :name_autocomplete, :type => 'string', :analyzer => 'autcomplete_name_analyzer'
          indexes :enabled, :type => 'boolean'
        end
      end
    end

    def extended_index_attrs
      { :name_sort => name.downcase, :name_autocomplete => self.name,
        :organization_id => organization.id,
        :enabled => self.enabled?
      }
    end

    def update_related_index
      self.provider.update_index if self.provider.respond_to? :update_index
    end

    def total_package_count(env, view)
      repo_ids = view.repos(env).in_product(self).collect { |r| r.pulp_id }
      result = Katello::Package.legacy_search('*', 0, 1, repo_ids)
      result.length > 0 ? result.total : 0
    end

    def total_puppet_module_count(env, view)
      repo_ids = view.repos(env).in_product(self).collect { |r| r.pulp_id }
      results = Katello::PuppetModule.legacy_search('', :page_size => 1, :repoids => repo_ids)
      results.empty? ? 0 : results.total
    end
  end
end
