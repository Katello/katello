#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
