module Katello
  module Glue::Candlepin::CandlepinObject
    extend ActiveSupport::Concern

    module ClassMethods
      def candlepin_records_by_id(organization)
        records = get_for_owner(organization.label)
        records_by_id = {}
        records.each do |record|
          records_by_id[record['id']] = record
        end
        records_by_id
      end

      def import_candlepin_records(candlepin_objects, org)
        candlepin_objects.each do |object|
          import_candlepin_record(record: object, organization: org)
        end
      end

      def import_candlepin_record(record:, organization:)
        db_attrs = {
          cp_id: record['id'],
          organization: organization,
        }

        yield(db_attrs) if block_given?

        persisted = nil
        Katello::Util::Support.active_record_retry do
          persisted = self.where(db_attrs).first_or_create!
        end

        persisted
      end

      def with_identifier(ids)
        self.with_identifiers(ids).first
      end

      def with_identifiers(ids)
        ids = [ids] unless ids.is_a?(Array)
        ids.map!(&:to_s)
        id_integers = ids.map { |string| Integer(string) rescue -1 }
        where("#{self.table_name}.id = (?) or #{self.table_name}.cp_id = (?)", id_integers, ids)
      end

      def import_all(organization = nil, import_managed_associations = true)
        organizations = organization ? [organization] : Organization.all

        organizations.each do |org|
          candlepin_records = candlepin_records_by_id(org)
          import_candlepin_records(candlepin_records.values, org)

          objects = self.in_organization(org)
          objects.each do |item|
            exists_in_candlepin = candlepin_records.key?(item.cp_id)

            Katello::Logging.time("Imported #{self}", data: { cp_id: item.cp_id, destroyed: !exists_in_candlepin }) do
              if exists_in_candlepin
                item.import_data
                item.import_managed_associations if import_managed_associations && item.respond_to?(:import_managed_associations)
              else
                item.destroy
              end
            end
          end
        end
      end
    end
  end
end
