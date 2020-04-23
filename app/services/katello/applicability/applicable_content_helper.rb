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
          # Query for all Errata ids that are attached to the host's applicable packages
          query = 'select katello_repository_errata.erratum_id as id from katello_repository_errata
                       inner join katello_erratum_packages
                          on  katello_repository_errata.erratum_id  = katello_erratum_packages.erratum_id
                       inner join katello_rpms
                          on katello_rpms.nvra = katello_erratum_packages.nvrea
                       inner join katello_content_facet_applicable_rpms on
                           katello_content_facet_applicable_rpms.rpm_id = katello_rpms.id
                       where
                            "katello_content_facet_applicable_rpms"."content_facet_id" = :content_facet_id
                       AND katello_repository_errata.repository_id IN (:repo_ids)'

          return Katello::Erratum.find_by_sql([query, {content_facet_id: content_facet.id, repo_ids: self.bound_library_instance_repos} ]).map(&:id).uniq
        elsif self.content_unit_class == ::Katello::ModuleStream
          fail NotImplementedError
        else
          # Query for applicable RPM ids
          return ::Katello::Rpm.joins("INNER JOIN katello_repository_rpms ON \
                                      katello_rpms.id = katello_repository_rpms.rpm_id").
                                      joins("INNER JOIN katello_installed_packages ON \
                                            katello_rpms.name = katello_installed_packages.name AND \
                                            katello_rpms.arch = katello_installed_packages.arch AND \
                                            katello_rpms.evr > katello_installed_packages.evr").
                                            joins("INNER JOIN katello_host_installed_packages ON \
                                                  katello_installed_packages.id = \
                                                  katello_host_installed_packages.installed_package_id WHERE \
                                                  katello_repository_rpms.repository_id in \
                                                  (#{self.bound_library_instance_repos.join(',')}) \
                                                  and katello_host_installed_packages.host_id = \
                                                  #{self.content_facet.host.id}").pluck(:id).uniq
        end
      end

      def applicable_differences
        consumer_ids = content_facet.send(applicable_units).pluck("#{content_unit_class.table_name}.id")
        content_ids = fetch_content_ids

        to_remove = consumer_ids - content_ids
        to_add = content_ids - consumer_ids

        [to_add, to_remove]
      end

      def insert(applicable_ids)
        unless applicable_ids.empty?
          inserts = applicable_ids.map { |applicable_id| "(#{applicable_id.to_i}, #{content_facet.id.to_i})" }
          sql = "INSERT INTO #{content_facet_association_class.table_name} (#{content_unit_association_id}, content_facet_id) VALUES #{inserts.join(', ')}"
          ActiveRecord::Base.connection.execute(sql)
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
