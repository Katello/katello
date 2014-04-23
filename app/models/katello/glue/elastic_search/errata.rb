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
module Glue::ElasticSearch::Errata

  SHORT_FIELDS =  [:id, :errata_id, :type, :summary, :severity, :title, :issued]

  # TODO: break this up into modules
  # rubocop:disable MethodLength
  def self.included(base)
    base.class_eval do
      include Glue::ElasticSearch::BackendIndexedModel

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
              }.merge(Util::Search.custom_filters),
              "analyzer" => {
                "title_analyzer" => {
                  "type"      => "custom",
                  "tokenizer" => "keyword",
                  "filter"    => %w(standard lowercase ngram_filter)
                }
              }.merge(Util::Search.custom_analyzers)
            }
          }
        }
      end

      def self.index_mapping
        {
          :errata => {
            :properties => {
              :repoids      => { :type => 'string', :index => :not_analyzed},
              :id_sort      => { :type => 'string', :index => :not_analyzed},
              :errata_id_sort => { :type => 'string', :index => :not_analyzed},
              :id_title     => { :type => 'string', :analyzer => :title_analyzer},
              :id           => { :type => 'string', :index => :not_analyzed},
              :errata_id    => { :type => 'string', :analyzer => :snowball},
              :errata_id_exact => { :type => 'string', :index => :not_analyzed},
              :severity     => { :type => 'string', :analyzer => :kt_name_analyzer},
              :type         => { :type => 'string', :analyzer => :kt_name_analyzer},
              :title        => { :type => 'string', :analyzer => :title_analyzer},
              :issued       => { :type => 'date'}
            }
          }
        }
      end

      def self.index
        "#{Katello.config.elastic_index}_errata"
      end

      def self.search_type
        :errata
      end

      def index_options
        {
          "_type" => Errata.search_type,
          :errata_id_exact => self.errata_id,
          :errata_id_sort => self.errata_id,
          :id_title => self.errata_id + ' : ' + self.title,
          :issued => self.issued.split[0]
        }
      end

      def self.errata_count(repos, errata_type = nil)
        return Util::Support.array_with_total unless index_exists?
        repo_ids = repos.map(&:pulp_id)
        search = Errata.search do
          query do
            all
          end
          fields [:id]
          size 1
          filter :terms, :repoids => repo_ids
          filter :term, :type => errata_type  if errata_type
        end
        search.total
      end

      def self.filter(filter)
        filter_for_repo = filter.slice(:repository_id, :repoid, :environment_id, :product_id)
        filter_for_errata = filter.except(*filter_for_repo.keys)

        repos = repos_for_filter(filter_for_repo)
        filter_for_errata[:repoids] = repos.collect{|r| r.pulp_id} if !repos.empty?

        options = { :start => 0, :page_size => 1, :filters => filter_for_errata }
        first = self.legacy_search('', options)
        options[:page_size] = first.total
        self.legacy_search('', options).collect{ |e| Errata.new(e.as_json) }
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
          fail "Not enough arguments for finding repos"
        end
      end

      def self.search(options = {}, &block)
        Tire.search(self.index, &block).results
      end

      def self.mapping
        Tire.index(self.index).mapping
      end

      def self.legacy_search(query, options)
        options = options.with_indifferent_access
        start = options.fetch(:start, nil) || options.fetch(:offset, 0) #support start & offset for now
        page_size = options.fetch(:page_size, nil) ||  User.current.page_size
        filters = options.fetch(:filters, {})
        sort = options.fetch(:sort, [:issued, "desc"])
        default_field = options.fetch(:default_field, 'id_title')
        fields = options.fetch(:fields, [])
        search_mode = options.fetch(:search_mode, :all)

        repoids = filters[:repoids]
        if !index_exists? || (repoids && repoids.empty?)
          return Util::Support.array_with_total
        end

        all_rows = query.blank?
        search = Tire::Search::Search.new(self.index)
        search.instance_eval do
          query do
            if all_rows
              all
            else
              string query, {:default_field => default_field}
            end
          end

          fields fields unless fields.blank?

          if page_size > 0
            size page_size
            from start
          end
          if filters.key?(:type)
            filter :term, :type => filters[:type]
          end
          if filters.key?(:severity)
            filter :term, :severity => filters[:severity]
          end
          if filters.key?(:id)
            filter :terms, :id => filters[:id]
          end

          sort { by sort[0], sort[1].downcase }
        end

        if filters.key?(:repoids)
          repoids = filters[:repoids]
          Util::Package.setup_shared_unique_filter(repoids, search_mode, search)
        end

        return search.perform.results
      rescue Tire::Search::SearchRequestFailed
        Util::Support.array_with_total
      end

      def self.add_indexed_repoid(errata_ids, repoid)
        update_array(errata_ids, 'repoids', [repoid], [])
      end

      def self.remove_indexed_repoid(errata_ids, repoid)
        update_array(errata_ids, 'repoids', [], [repoid])
      end

      def self.index_errata(errata_ids)
        errata = errata_ids.collect do |errata_id|
          erratum = self.find(errata_id)
          erratum.as_json.merge(erratum.index_options)
        end

        unless errata.empty?
          create_index
          Tire.index Errata.index do
            import errata
          end
          Tire.index(::Errata.index).refresh
        end
      end

      def self.autocomplete_search(text, repoids = nil, page_size = 15)
        return [] if !index_exists?

        if text.blank?
          query = "id_title:(*)"
        else
          text = Util::Search.filter_input(text.downcase)
          query = "id_title:(*#{text}*)"
        end

        search = Tire.search self.index do
          fields [:id_title, :errata_id]
          query do
            string query
          end
          size page_size

          if repoids
            filter :terms, :repoids => repoids
          end
        end

        search.results
      end

      def self.indexed_ids_for_repo(pulp_id)
        options = {:filters => {:repoids => [pulp_id]}, :fields => [:id], :start => 0, :page_size => 1}
        options[:page_size] = ::Katello::Errata.legacy_search("", options).total
        ::Katello::Errata.legacy_search("", options).collect{|e| e.id}
      end
    end
  end
end
end
