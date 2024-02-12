module Katello
  module Applicability
    class ApplicableContentHelper
      attr_accessor :content_facet, :content_unit_class, :bound_library_instance_repos

      def initialize(content_facet, content_unit_class, bound_library_instance_repos)
        self.content_facet = content_facet
        self.content_unit_class = content_unit_class
        self.bound_library_instance_repos = bound_library_instance_repos
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
          fetch_errata_content_ids + fetch_deb_errata_content_ids
        elsif self.content_unit_class == ::Katello::Deb
          fetch_deb_content_ids
        elsif self.content_unit_class == ::Katello::ModuleStream
          fetch_module_stream_content_ids
        else
          fetch_rpm_content_ids
        end
      end

      def fetch_deb_errata_content_ids
        Katello::Erratum.joins([:deb_packages, :repositories],
                               "INNER JOIN #{Katello::Deb.table_name} ON #{Katello::ErratumDebPackage.table_name}.name = #{Katello::Deb.table_name}.name",
                               "INNER JOIN #{Katello::ContentFacetApplicableDeb.table_name} ON #{Katello::ContentFacetApplicableDeb.table_name}.deb_id = #{Katello::Deb.table_name}.id")
                              .where("deb_version_cmp(#{Katello::ErratumDebPackage.table_name}.version, #{Katello::Deb.table_name}.version) >= 0")
                              .where("#{Katello::ContentFacetApplicableDeb.table_name}.content_facet_id": content_facet.id)
                              .where("#{Katello::RepositoryErratum.table_name}.repository_id" => self.bound_library_instance_repos)
                              .distinct.pluck(:id)
      end

      def fetch_errata_content_ids
        # Query for all Errata ids that are attached to the host's applicable packages
        query = 'SELECT DISTINCT katello_repository_errata.erratum_id AS id FROM katello_repository_errata
                     INNER JOIN katello_erratum_packages
                        ON katello_repository_errata.erratum_id = katello_erratum_packages.erratum_id
                     INNER JOIN katello_rpms
                        ON katello_rpms.nvra = katello_erratum_packages.nvrea
                     INNER JOIN katello_content_facet_applicable_rpms
                        ON katello_content_facet_applicable_rpms.rpm_id = katello_rpms.id
                     WHERE katello_content_facet_applicable_rpms.content_facet_id = :content_facet_id
                        AND katello_repository_errata.repository_id IN (:repo_ids)'

        return Katello::Erratum.find_by_sql([query, { content_facet_id: content_facet.id, repo_ids: self.bound_library_instance_repos }]).map(&:id)
      end

      def fetch_module_stream_content_ids
        # Query for all applicable module stream ids
        query = 'SELECT DISTINCT katello_repository_module_streams.module_stream_id AS id FROM katello_repository_module_streams
                     INNER JOIN katello_module_stream_rpms
                        ON katello_repository_module_streams.module_stream_id = katello_module_stream_rpms.module_stream_id
                     INNER JOIN katello_rpms
                        ON katello_rpms.id = katello_module_stream_rpms.rpm_id
                     INNER JOIN katello_content_facet_applicable_rpms
                        ON katello_content_facet_applicable_rpms.rpm_id = katello_rpms.id
                     WHERE katello_content_facet_applicable_rpms.content_facet_id = :content_facet_id
                        AND katello_repository_module_streams.repository_id IN (:repo_ids)'

        return Katello::ModuleStream.find_by_sql([query, { content_facet_id: content_facet.id, repo_ids: self.bound_library_instance_repos }]).map(&:id)
      end

      def fetch_deb_content_ids
        repo_deb = ::Katello::RepositoryDeb.arel_table
        deb = ::Katello::Deb.arel_table
        installed_deb = Katello::InstalledDeb.arel_table
        host_installed_deb = Katello::HostInstalledDeb.arel_table
        deb_version_compare = Arel::Nodes::NamedFunction.new('deb_version_cmp', [deb[:version], installed_deb[:version]]).gt(0)

        content = deb.join(repo_deb).on(repo_deb[:deb_id].eq(deb[:id]))
                     .join(installed_deb).on(installed_deb[:name].eq(deb[:name]), installed_deb[:architecture].eq(deb[:architecture]))
                     .join(host_installed_deb).on(host_installed_deb[:installed_deb_id].eq(installed_deb[:id]))
                     .where(deb_version_compare)
                     .where(host_installed_deb[:host_id].eq(self.content_facet.host.id))
                     .distinct
                     .project(deb[Arel.star])

        ::Katello::Deb.find_by_sql(content.to_sql).pluck(:id)
      end

      def fetch_rpm_content_ids
        enabled_module_stream_ids = fetch_enabled_module_stream_ids

        ::Katello::Rpm.
          joins("INNER JOIN katello_repository_rpms ON
            katello_rpms.id = katello_repository_rpms.rpm_id").
          joins("INNER JOIN katello_installed_packages ON
            katello_rpms.name = katello_installed_packages.name AND
            katello_rpms.arch = katello_installed_packages.arch AND
            katello_rpms.evr > katello_installed_packages.evr AND
            katello_installed_packages.id in (#{newest_distinct_installed_packages_query})").
          joins("LEFT JOIN katello_module_stream_rpms ON
            katello_rpms.id = katello_module_stream_rpms.rpm_id").
          joins("INNER JOIN katello_host_installed_packages ON
            katello_installed_packages.id = katello_host_installed_packages.installed_package_id").
          where("katello_repository_rpms.repository_id in (:bound_library_repos)",
            :bound_library_repos => self.bound_library_instance_repos).
          where("katello_host_installed_packages.host_id = :content_facet_id",
            :content_facet_id => self.content_facet.host.id).
          where("(katello_module_stream_rpms.module_stream_id IS NULL AND
            katello_installed_packages.id NOT IN (:locked_modular_installed_packages)) OR
            (katello_module_stream_rpms.module_stream_id IN (:enabled_module_streams)
            AND katello_installed_packages.id IN (:locked_modular_installed_packages))",
            :enabled_module_streams => enabled_module_stream_ids,
            :locked_modular_installed_packages => locked_modular_installed_packages(enabled_module_stream_ids)).pluck(:id).uniq
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
