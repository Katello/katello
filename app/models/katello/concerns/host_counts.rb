module Katello
  module Concerns
    module HostCounts
      extend ActiveSupport::Concern

      class_methods do
        # Content facet rows for units that are applicable to a host.
        def applicable_host_facets(unit_ids, org_id = nil)
          return ::Katello::Host::ContentFacet.none if unit_ids.empty?

          association_table = content_facet_association_class.table_name
          facet_scope(
            ::Katello::Host::ContentFacet.
              joins("INNER JOIN #{association_table} ON #{association_table}.content_facet_id = " \
                    "#{::Katello::Host::ContentFacet.table_name}.id").
              where("#{association_table}.#{unit_id_field}" => unit_ids),
            org_id
          )
        end

        # Content facet rows for units that are available in a repository the
        # facet is bound to. The unit table is not joined: availability is the
        # intersection of the facet's bound repositories with the unit's.
        def available_host_facets(unit_ids, org_id = nil)
          return ::Katello::Host::ContentFacet.none if unit_ids.empty?

          association_table = content_facet_association_class.table_name
          facet_repository_table = ::Katello::ContentFacetRepository.table_name
          repository_association_table = repository_association_class.table_name
          facet_scope(
            ::Katello::Host::ContentFacet.
              joins("INNER JOIN #{association_table} ON #{association_table}.content_facet_id = " \
                    "#{::Katello::Host::ContentFacet.table_name}.id").
              joins("INNER JOIN #{facet_repository_table} ON #{facet_repository_table}.content_facet_id = " \
                    "#{::Katello::Host::ContentFacet.table_name}.id").
              where("#{association_table}.#{unit_id_field}" => unit_ids).
              where("EXISTS (SELECT 1 FROM #{repository_association_table} " \
                    "WHERE #{repository_association_table}.#{unit_id_field} = #{association_table}.#{unit_id_field} " \
                    "AND #{repository_association_table}.repository_id = #{facet_repository_table}.repository_id)"),
            org_id
          ).distinct
        end

        # Batched equivalents of hosts_applicable/hosts_available for a page of
        # content units. Both return { unit_id => count }.
        def applicable_host_counts(unit_ids, org_id = nil)
          count_host_facets(unit_ids) { |ids| applicable_host_facets(ids, org_id) }
        end

        def available_host_counts(unit_ids, org_id = nil)
          count_host_facets(unit_ids) { |ids| available_host_facets(ids, org_id) }
        end

        private

        def count_host_facets(unit_ids)
          return {} if unit_ids.empty?

          association_table = content_facet_association_class.table_name
          Katello::Util::IdBatches.slices(unit_ids).each_with_object({}) do |ids, counts|
            counts.merge!(yield(ids).group("#{association_table}.#{unit_id_field}").
              count("#{association_table}.content_facet_id"))
          end
        end

        def facet_scope(scope, org_id)
          scope = scope.joins(:host)
          scope = scope.where(::Host.table_name => { :organization_id => org_id }) if org_id.present?
          scope
        end
      end

      def hosts_applicable(org_id = nil)
        self.class.applicable_host_facets([id], org_id)
      end

      def hosts_available(org_id = nil)
        self.class.available_host_facets([id], org_id)
      end

      def hosts_applicable_count(org_id = nil)
        self.class.applicable_host_facets([id], org_id).count
      end

      def hosts_available_count(org_id = nil)
        self.class.available_host_facets([id], org_id).count
      end
    end
  end
end
