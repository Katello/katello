module Katello
  module Glue::Candlepin::CandlepinObject
    extend ActiveSupport::Concern

    module ClassMethods
      def get_for_organization(organization)
        # returns objects from AR database rather than candlepin data
        pool_ids = self.get_for_owner(organization.label).collect { |x| x['id'] }
        self.where(:cp_id => pool_ids)
      end

      def get_candlepin_ids(organization)
        self.get_for_owner(organization).map { |subscription| subscription["id"] }
      end

      def import_candlepin_ids(organization)
        candlepin_ids = self.get_candlepin_ids(organization)
        candlepin_ids.each do |cp_id|
          self.find_or_create_by_cp_id(cp_id) unless cp_id.nil?
        end
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

      def import_all
        candlepin_ids = []

        Organization.all.each do |org|
          import_candlepin_ids(org.label)
          candlepin_ids.concat(get_candlepin_ids(org.label))
        end

        self.all.each do |item|
          if candlepin_ids.include?(item.cp_id)
            item.import_data
          else
            item.destroy
          end
        end
      end
    end
  end
end
