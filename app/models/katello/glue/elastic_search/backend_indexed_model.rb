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
  module Glue::ElasticSearch::BackendIndexedModel
    UPDATE_BATCH_SIZE = 200
    ID_FETCH_BATCH_SIZE = 50

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
    end

    module InstanceMethods
    end

    module ClassMethods
      def index_all
        self.create_index

        total = 0
        pkgs = fetch_all(total, Katello.config.pulp.bulk_load_size)
        until pkgs.empty? #we can't know how many there are, so we have to keep looping until we get nothing
          Tire.index(self.index) do
            import pkgs
          end

          total += pkgs.length
          pkgs = fetch_all(total, Katello.config.pulp.bulk_load_size)
        end
        total
      end

      def fetch_all(offset, page_size)
        fields = self::PULP_INDEXED_FIELDS if self.constants.include?(:PULP_INDEXED_FIELDS)
        criteria = {:limit => page_size, :skip => offset}
        criteria[:fields] = fields if fields

        obj_hashes =  Katello.pulp_server.resources.unit.search(self::CONTENT_TYPE, criteria, :include_repos => true)
        obj_hashes.map do |item|
          obj = self.new(item)
          obj.as_json.merge(obj.index_options)
        end
      end

      def indexed_ids_for_repo(repo_id)
        search = Tire::Search::Search.new(self.index)

        search.instance_eval do
          fields [:id]
          query do
            all
          end
          size 1
          filter :term, :repoids => repo_id
        end

        total = search.perform.results.total
        (0..total).step(ID_FETCH_BATCH_SIZE).flat_map do |start|
          search.instance_eval do
            fields [:id]
            size ID_FETCH_BATCH_SIZE
            from start
            sort { by :id, 'asc' }
          end

          search.perform.results.collect { |p| p.id }
        end
      end

      def index_exists?
        Tire.index(self.index).exists?
      end

      def update_array(object_ids, field, add_ids, remove_ids)
        obj_class = self
        script = ""
        add_ids.each { |add_id| script += "ctx._source.#{field}.add(\"#{add_id}\");" }
        remove_ids.each { |remove_id| script +=  "ctx._source.#{field}.remove(\"#{remove_id}\");" }

        documents = object_ids.map do |id|
          {
            :_id => id,
            :_type => obj_class.search_type,
            :script => script
          }
        end
        documents.in_groups_of(UPDATE_BATCH_SIZE, false) do |docs|
          Tire.index(obj_class.index).bulk_update(docs)
        end
        Tire.index(self.index).refresh
      end

      def delete_index
        Tire.index(self.index).delete
      end

      def create_index
        unless index_exists?
          class_obj = self
          Tire.index self.index do
            create :settings => class_obj.index_settings, :mappings => class_obj.index_mapping
          end
        end
      end

      def tire
        Tire.index(self.index)
      end

      def remove_from_index(id, options = {})
        tire.remove(search_type.to_s, id, options)
      end
    end
  end
end
