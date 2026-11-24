module Katello
  module Applicability
    class ApplicableContentHelper
      attr_accessor :content_facet, :content_unit_class, :bound_library_instance_repos

      def initialize(content_facet, content_unit_class, bound_library_instance_repos, content_scope = nil)
        self.content_facet = content_facet
        self.content_unit_class = content_unit_class
        self.bound_library_instance_repos = bound_library_instance_repos
        @content_scope = content_scope
      end

      def calculate_and_import
        if self.bound_library_instance_repos.any?
          to_add, to_remove = applicable_differences
          ActiveRecord::Base.transaction do
            insert(to_add) unless to_add.blank?
            remove(to_remove) unless to_remove.blank?
          end
        end
      end

      def fetch_content_ids
        if self.content_unit_class == ::Katello::Erratum
          fetch_errata_content_ids
        elsif self.content_unit_class == ::Katello::Deb
          fetch_deb_content_ids
        elsif self.content_unit_class == ::Katello::ModuleStream
          fetch_module_stream_content_ids
        else
          fetch_rpm_content_ids
        end
      end

      def content_index_ids
        content_scope[0]
      end

      def unindexed_repository_ids
        content_scope[1]
      end

      def content_scope
        @content_scope ||= ::Katello::ContentIndex.scope_for_repositories(bound_library_instance_repos)
      end

      def no_content_sources?
        content_index_ids.empty? && unindexed_repository_ids.empty?
      end

      def source_ids_sql(unit_table, unit_field, repository_table)
        parts = []
        parts << "SELECT #{unit_field} FROM #{unit_table} WHERE content_index_id IN (#{content_index_ids.join(',')})" if content_index_ids.any?
        parts << "SELECT #{unit_field} FROM #{repository_table} WHERE repository_id IN (#{unindexed_repository_ids.join(',')})" if unindexed_repository_ids.any?
        # Callers only use this inside IN; duplicates cost nothing there.
        parts.join(" UNION ALL ")
      end

      def fetch_errata_content_ids
        return [] if no_content_sources?
        source = source_ids_sql('katello_content_index_errata', 'erratum_id', 'katello_repository_errata')
        query = "SELECT DISTINCT katello_erratum_packages.erratum_id AS id FROM katello_erratum_packages
                     INNER JOIN katello_rpms
                        ON katello_rpms.nvra = katello_erratum_packages.nvrea
                     INNER JOIN katello_content_facet_applicable_rpms
                        ON katello_content_facet_applicable_rpms.rpm_id = katello_rpms.id
                     WHERE katello_content_facet_applicable_rpms.content_facet_id = #{content_facet.id}
                        AND katello_erratum_packages.erratum_id IN (#{source})"
        Katello::Erratum.find_by_sql(query).map(&:id)
      end

      def fetch_module_stream_content_ids
        return [] if no_content_sources?
        source = source_ids_sql('katello_content_index_module_streams', 'module_stream_id', 'katello_repository_module_streams')
        query = "SELECT DISTINCT katello_module_stream_rpms.module_stream_id AS id FROM katello_module_stream_rpms
                     INNER JOIN katello_rpms
                        ON katello_rpms.id = katello_module_stream_rpms.rpm_id
                     INNER JOIN katello_content_facet_applicable_rpms
                        ON katello_content_facet_applicable_rpms.rpm_id = katello_rpms.id
                     WHERE katello_content_facet_applicable_rpms.content_facet_id = #{content_facet.id}
                        AND katello_module_stream_rpms.module_stream_id IN (#{source})"
        Katello::ModuleStream.find_by_sql(query).map(&:id)
      end

      def fetch_rpm_content_ids
        return [] if no_content_sources?
        enabled_module_stream_ids = fetch_enabled_module_stream_ids
        source = source_ids_sql('katello_content_index_rpms', 'rpm_id', 'katello_repository_rpms')

        ::Katello::Rpm.
          joins("INNER JOIN katello_installed_packages ON
            katello_rpms.name = katello_installed_packages.name AND
            katello_rpms.arch = katello_installed_packages.arch AND
            katello_rpms.evr > katello_installed_packages.evr AND
            katello_installed_packages.id in (#{newest_distinct_installed_packages_query})").
          joins("LEFT JOIN katello_module_stream_rpms ON
            katello_rpms.id = katello_module_stream_rpms.rpm_id").
          joins("INNER JOIN katello_host_installed_packages ON
            katello_installed_packages.id = katello_host_installed_packages.installed_package_id").
          where("katello_rpms.id IN (#{source})").
          where("katello_host_installed_packages.host_id = :content_facet_id",
            :content_facet_id => self.content_facet.host.id).
          where("(katello_module_stream_rpms.module_stream_id IS NULL AND
            katello_installed_packages.id NOT IN (:locked_modular_installed_packages)) OR
            (katello_module_stream_rpms.module_stream_id IN (:enabled_module_streams)
            AND katello_installed_packages.id IN (:locked_modular_installed_packages))",
            :enabled_module_streams => enabled_module_stream_ids,
            :locked_modular_installed_packages => locked_modular_installed_packages(enabled_module_stream_ids)).pluck(:id).uniq
      end

      def fetch_deb_content_ids
        return [] if no_content_sources?
        source = source_ids_sql('katello_content_index_debs', 'deb_id', 'katello_repository_debs')
        deb = ::Katello::Deb.arel_table
        installed_deb = Katello::InstalledDeb.arel_table
        host_installed_deb = Katello::HostInstalledDeb.arel_table
        deb_version_compare = Arel::Nodes::NamedFunction.new('deb_version_cmp', [deb[:version], installed_deb[:version]]).gt(0)

        content = deb.join(installed_deb).on(installed_deb[:name].eq(deb[:name]), installed_deb[:architecture].eq(deb[:architecture]))
                     .join(host_installed_deb).on(host_installed_deb[:installed_deb_id].eq(installed_deb[:id]))
                     .where(deb_version_compare)
                     .where(Arel.sql("#{deb.name}.id IN (#{source})"))
                     .where(host_installed_deb[:host_id].eq(self.content_facet.host.id))
                     .distinct
                     .project(deb[Arel.star])

        ::Katello::Deb.find_by_sql(content.to_sql).pluck(:id)
      end

      def fetch_enabled_module_stream_ids
        # Query for applicable RPM ids
        # -> Include all non-modular rpms or rpms that exist within installed module streams
        ::Katello::ModuleStream.
          joins("inner join katello_available_module_streams on
            katello_module_streams.name = katello_available_module_streams.name and
            katello_module_streams.stream = katello_available_module_streams.stream and
            katello_module_streams.context = katello_available_module_streams.context").
          joins("inner join katello_host_available_module_streams on
            katello_available_module_streams.id = katello_host_available_module_streams.available_module_stream_id").
          where("katello_host_available_module_streams.host_id = :content_facet_id and
            katello_host_available_module_streams.status = 'enabled'",
            :content_facet_id => self.content_facet.host.id).select(:id)
      end

      # Installed packages that are locked for the host due to enabled module stream membership
      def locked_modular_installed_packages(enabled_module_streams)
        rpms_in_enabled_module_streams = ::Katello::Rpm.
          joins("INNER JOIN katello_module_stream_rpms ON katello_rpms.id = katello_module_stream_rpms.rpm_id").
          where("katello_module_stream_rpms.module_stream_id IN (:enabled_module_streams)",
                :enabled_module_streams => enabled_module_streams).select(:nvra, :epoch)

        ::Katello::InstalledPackage.where(nvra: rpms_in_enabled_module_streams.map(&:nvra),
                                          epoch: rpms_in_enabled_module_streams.map(&:epoch)).select(:id)
      end

      def newest_distinct_installed_packages_query
        "SELECT DISTINCT ON (katello_installed_packages.name, katello_installed_packages.arch) katello_installed_packages.id " \
          "FROM katello_installed_packages INNER JOIN " \
          "katello_host_installed_packages ON " \
          "katello_installed_packages.id = " \
          "katello_host_installed_packages.installed_package_id " \
          "WHERE katello_host_installed_packages.host_id = " \
          "#{content_facet.host.id} ORDER BY katello_installed_packages.name, katello_installed_packages.arch, katello_installed_packages.evr DESC"
      end

      def applicable_differences
        ActiveRecord::Base.connection.uncached do
          consumer_ids = content_facet.send(applicable_units).pluck("#{content_unit_class.table_name}.id")
          content_ids = fetch_content_ids

          to_remove = consumer_ids - content_ids
          to_add = content_ids - consumer_ids

          [to_add, to_remove]
        end
      end

      def insert(applicable_ids)
        unless applicable_ids.empty?
          upserts = applicable_ids.collect do |applicable_id|
            { content_unit_association_id => applicable_id, :content_facet_id => content_facet.id }
          end
          content_facet_association_class.upsert_all(upserts, unique_by: [content_unit_association_id, :content_facet_id])
        end
      end

      def remove(applicable_ids)
        content_facet_association_class.where(:content_facet_id => content_facet.id, content_unit_association_id => applicable_ids).delete_all
      end

      def content_unit_association_id
        "#{content_unit_class.name.demodulize.underscore}_id".to_sym
      end

      def content_facet_association_class
        # Example: ContentFacetErratum
        self.content_unit_class.content_facet_association_class
      end

      def content_units
        content_unit_class.name.demodulize.pluralize.underscore.to_sym
      end

      def applicable_units
        "applicable_#{content_units}".to_sym
      end
    end
  end
end
