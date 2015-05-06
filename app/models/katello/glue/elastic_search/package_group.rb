module Katello
  module Glue::ElasticSearch::PackageGroup
    # TODO: break up into modules
    # rubocop:disable MethodLength
    def self.included(base)
      base.class_eval do
        include Glue::ElasticSearch::BackendIndexedModel
        def index_options
          {
            "_type" => Katello::PackageGroup.search_type,
            "name_autocomplete" => name
          }
        end

        def self.search_type
          :package_group
        end

        def self.index_settings
          {
            "index" => {
              "analysis" => {
                "filter" => Util::Search.custom_filters,
                "analyzer" => Util::Search.custom_analyzers
              }
            }
          }
        end

        def self.index_mapping
          {
            :package_group => {
              :properties => {
                :id            => {:type => 'string', :index => :not_analyzed},
                :package_group_id => {:type => 'string', :index => :not_analyzed},
                :name          => { :type => 'string', :analyzer => :kt_name_analyzer},
                :name_sort    => { :type => 'string', :index => :not_analyzed },
                :repo_id       => { :type => 'string', :index => :not_analyzed}
              }
            }
          }
        end

        def self.index
          "#{Katello.config.elastic_index}_package_group"
        end

        def self.mapping
          Tire.index(self.index).mapping
        end

        def self.search(_options = {}, &block)
          Tire.search(self.index, &block).results
        end

        def self.id_search(ids)
          return Util::Support.array_with_total unless Tire.index(self.index).exists?
          search = Tire.search self.index do
            fields [:id, :name, :repo_id]
            query do
              all
            end
            size ids.size
            filter :terms, :id => ids
          end
          search.results
        end

        def self.new_from_search(params)
          group_name = params.delete('package_group_id')
          id = params.delete('id')
          params['id'] = group_name
          params['_id'] = id
          self.new(params)
        end

        def self.legacy_search(query, start, page_size, repoid = nil, sort = [:name_sort, "asc"],
                               default_field = 'name')
          return Util::Support.array_with_total unless Tire.index(self.index).exists?

          all_rows = query.blank? #if blank, get all rows

          search = Tire.search self.index do
            query do
              if all_rows
                all
              else
                string query, :default_field => default_field
              end
            end

            if page_size > 0
              size page_size
              from start
            end

            if repoid
              filter :term, :repo_id => repoid
            end
            sort { by sort[0], sort[1] } if all_rows
          end

          return search.results
        rescue Tire::Search::SearchRequestFailed
          Util::Support.array_with_total
        end

        def self.index_package_groups(pkg_grp_ids)
          pkg_grps = pkg_grp_ids.collect do |pkg_grp_id|
            pkg_grp = self.find(pkg_grp_id)
            pkg_grp.as_json.merge(pkg_grp.index_options)
          end

          unless pkg_grps.empty?
            create_index
            Tire.index PackageGroup.index do
              import pkg_grps
            end
          end
        end
      end
    end
  end
end
