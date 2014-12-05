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

require 'set'

module Katello
  module Glue::Pulp::PulpContentUnit
    extend ActiveSupport::Concern

    #  Any class that includes this module should define:
    #  Class.unit_handler
    #  Class::CONTENT_TYPE
    #  Class::PULP_INDEXED_FIELDS (optional)
    #  Class.repository_association_class
    #  Class#update_from_json

    def backend_data
      self.class.pulp_data(uuid)
    end

    module ClassMethods
      def unit_handler
        Katello.pulp_server.extensions.send(self.name.demodulize.pluralize.underscore)
      end

      def repository_association
        repository_association_class.name.demodulize.pluralize.underscore
      end

      def in_repositories(repos)
        self.joins(repository_association.to_sym)
          .where("#{repository_association_class.table_name}.repository_id" => repos)
      end

      def pulp_data(uuid)
        unit_handler.find_by_unit_id(uuid)
      end

      # Import all units of a single type and refresh their repository associations
      def import_all
        all_items = items = fetch_all(0, Katello.config.pulp.bulk_load_size)
        until items.empty? #we can't know how many there are, so we have to keep looping until we get nothing
          items = fetch_all(all_items.length, Katello.config.pulp.bulk_load_size)
          all_items.concat(items)
        end

        all_items.each do |item_json|
          item = self.find_or_create_by_uuid(:uuid => item_json['_id'])
          item.update_from_json(item_json)
        end
        update_repository_associations(all_items)
        all_items.count
      end

      def sync_repository_associations(repository, unit_uuids)
        associated_ids = with_uuid(unit_uuids).pluck(:id)
        table_name = self.repository_association_class.table_name
        attribute_name = "#{self.name.demodulize.underscore}_id"

        existing_ids = self.repository_association_class.where(:repository_id => repository).pluck(attribute_name)
        new_ids = associated_ids - existing_ids
        delete_ids = existing_ids - associated_ids

        queries = []

        unless delete_ids.empty?
          queries << "DELETE FROM #{table_name} WHERE repository_id=#{repository.id} AND #{attribute_name} IN (#{delete_ids.join(', ')})"
        end

        unless new_ids.empty?
          inserts = new_ids.map { |unit_id| "(#{unit_id.to_i}, #{repository.id.to_i}, '#{Time.now.utc}', '#{Time.now.utc}')" }
          queries << "INSERT INTO #{table_name} (#{attribute_name}, repository_id, created_at, updated_at) VALUES #{inserts.join(', ')}"
        end

        ActiveRecord::Base.transaction do
          queries.each do |query|
            ActiveRecord::Base.connection.execute(query)
          end
        end
      end

      def with_uuid(unit_uuids)
        where(:uuid => unit_uuids)
      end

      def fetch_all(offset, page_size)
        fields = self::PULP_INDEXED_FIELDS if self.constants.include?(:PULP_INDEXED_FIELDS)
        criteria = {:limit => page_size, :skip => offset}
        criteria[:fields] = fields if fields
        Katello.pulp_server.resources.unit.search(self::CONTENT_TYPE, criteria, :include_repos => true)
      end

      def update_repository_associations(units_json)
        ActiveRecord::Base.transaction do
          repo_unit_id = {}
          units_json.each do |unit_json|
            unit_json['repository_memberships'].each do |repo_pulp_id|
              repo_unit_id[repo_pulp_id] ||= []
              repo_unit_id[repo_pulp_id]  << unit_json['_id']
            end
          end

          repo_unit_id.each do |repo_pulp_id, unit_uuids|
            sync_repository_associations(Repository.find_by_pulp_id(repo_pulp_id), unit_uuids)
          end
        end
      end
    end
  end
end
