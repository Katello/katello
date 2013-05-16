#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


module Glue::ElasticSearch::Errata
  def self.included(base)
    base.class_eval do

      def self.index_settings
        {
            "index" => {
                "analysis" => {
                    "filter" => {
                        "ngram_filter"  => {
                            "type"      => "nGram",
                            "min_gram"  => 3,
                            "max_gram"  => 40
                        }
                    }.merge(Util::Search::custom_filters),
                    "analyzer" => {
                        "title_analyzer" => {
                            "type"      => "custom",
                            "tokenizer" => "keyword",
                            "filter"    => ["standard", "lowercase", "asciifolding", "ngram_filter"]
                        }
                    }.merge(Util::Search::custom_analyzers)
                }
            }
        }
      end

      def self.index_mapping
        {
          :errata => {
            :properties => {
              :repoids      => { :type => 'string', :index =>:not_analyzed},
              :id_sort      => { :type => 'string', :index => :not_analyzed},
              :errata_id_sort => { :type => 'string', :index => :not_analyzed},
              :id_title     => { :type => 'string', :analyzer =>:title_analyzer},
              :id           => { :type => 'string', :index =>:not_analyzed},
              :errata_id    => { :type => 'string', :analyzer =>:snowball},
              :errata_id_exact => { :type => 'string', :index =>:not_analyzed},
              :product_ids  => { :type => 'integer', :analyzer =>:kt_name_analyzer},
              :severity     => { :type => 'string', :analyzer =>:kt_name_analyzer},
              :type         => { :type => 'string', :analyzer =>:kt_name_analyzer},
              :title        => { :type => 'string', :analyzer => :title_analyzer},
            }
          }
        }
      end

      def self.index
        "#{Katello.config.elastic_index}_errata"
      end

      def index_options
        {
          "_type" => :errata,
          :errata_id_exact => self.errata_id,
          :errata_id_sort => self.errata_id,
          :id_title => self.errata_id + ' : ' + self.title,
          :product_ids=>self.product_ids,
        }
      end

      def self.filter(filter)
        filter_for_repo = filter.slice(:repository_id, :repoid, :environment_id, :product_id)
        filter_for_errata = filter.except(*filter_for_repo.keys)

        repos = repos_for_filter(filter_for_repo)
        filter_for_errata[:repoids] = repos.collect{|r| r.pulp_id} if !repos.empty?

        first = self.search('', 0, 1, filter_for_errata)
        self.search('', 0, first.total, filter_for_errata).collect{|e| Errata.new(e.as_json)}
      end

      def self.repos_for_filter(filter)
        repoid = filter[:repoid] || filter[:repository_id]
        if repoid
          return [Repository.find(repoid)]
        elsif environment_id = filter[:environment_id]
          env = KTEnvironment.find(environment_id)
          if product_id = filter[:product_id]
            products = [env.products.find_by_cp_id!(product_id)]
          else
            products = env.products
          end
          return products.map {|p| p.repos(env) }.flatten
        else
          raise "Not enough arguments for finding repos"
        end
      end

      def self.search query, start, page_size, filters={}, sort=[:errata_id_sort, "DESC"],
                                                        default_field = 'id_title'

        repoids = filters[:repoids]
        if !Tire.index(self.index).exists? || (repoids && repoids.empty?)
          return Util::Support.array_with_total
        end

        all_rows = query.blank?
        search = Tire::Search::Search.new(self.index)
        search.instance_eval do
          query do
            if all_rows
              all
            else
              string query, {:default_field=>default_field}
            end
          end

          if page_size > 0
           size page_size
           from start
          end
          if filters.has_key?(:type)
            filter :term, :type => filters[:type]
          end
          if filters.has_key?(:severity)
            filter :term, :severity => filters[:severity]
          end

          sort { by sort[0], sort[1] } unless !all_rows
        end

        if filters.has_key?(:repoids)
          search_mode = filters[:search_mode] || :all
          repoids = filters[:repoids]
          Util::Package.setup_shared_unique_filter(repoids, search_mode, search)
        end

        return search.perform.results
      rescue Tire::Search::SearchRequestFailed => e
        Util::Support.array_with_total
      end

      def self.index_errata errata_ids
        errata = errata_ids.collect{ |errata_id|
          erratum = self.find(errata_id)
          erratum.as_json.merge(erratum.index_options)
        }

        Tire.index Errata.index do
          create :settings => Errata.index_settings, :mappings => Errata.index_mapping
          import errata
        end if !errata.empty?
      end
    end
  end
end
