module Katello
  module Glue::Candlepin::CandlepinObject
    extend ActiveSupport::Concern

    module ClassMethods
      def get_candlepin_ids(organization)
        self.get_for_owner(organization.label).map { |subscription| subscription["id"] }
      end

      def import_candlepin_ids(organization)
        candlepin_ids = self.get_candlepin_ids(organization)
        candlepin_ids.each do |cp_id|
          Katello::Util::Support.active_record_retry do
            self.where(:cp_id => cp_id, :organization_id => organization.id).first_or_create unless cp_id.nil?
          end
        end
        candlepin_ids
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
          candlepin_ids = import_candlepin_ids(org)

          objects = self.in_organization(org)
          objects.each do |item|
            exists_in_candlepin = candlepin_ids.include?(item.cp_id)

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
