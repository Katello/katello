module Katello
  module Glue::ElasticSearch::Distribution
    # TODO: break this up into modules
    # rubocop:disable MethodLength
    def self.included(base)
      base.class_eval do
        include Glue::ElasticSearch::BackendIndexedModel

        def index_options
          {
            "_type" => self.class.search_type,
            "name_autocomplete" => id
          }
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
            :distribution => {
              :properties => {
                :id           => { :type => 'string', :index => :not_analyzed},
                :arch         => { :type => 'string', :index => :not_analyzed},
                :family       => { :type => 'string', :index => :not_analyzed},
                :variant      => { :type => 'string', :index => :not_analyzed},
                :version      => { :type => 'string', :index => :not_analyzed},
                :repoids      => { :type => 'string', :index => :not_analyzed}
              }
            }
          }
        end

        def self.index
          "#{Katello.config.elastic_index}_distribution"
        end

        def self.search_type
          :distribution
        end

        def self.search(_options = {}, &block)
          Tire.search(self.index, &block).results
        end

        def self.mapping
          Tire.index(self.index).mapping
        end
      end
    end
  end
end
