module Katello
  module Concerns
    module RedhatExtensions
      extend ActiveSupport::Concern

      module ClassMethods
        def find_or_create_operating_system(repo)
          os_name = construct_name(repo.distribution_family)
          major, minor = repo.distribution_version.split('.')
          minor ||= '' # treat minor versions as empty string to not confuse with nil
          os = ::Redhat.where(:name => os_name, :major => major, :minor => minor).try(:first)
          return os if os
          description = "#{os_name}-#{repo.distribution_version}"
          create_os = lambda { ::Redhat.create!(:name => os_name, :major => major, :minor => minor, :description => description) }

          begin
            create_os.call
          rescue ActiveRecord::RecordInvalid
            create_os.call
          end
        end

        def create_operating_system(name, major, minor)
          params = {
            'name' => name,
            'major' => major.to_s,
            'minor' => minor.to_s,
            'family' => 'Redhat'
          }

          return ::Redhat.create!(params)
        end

        def construct_name(family)
          if family == ::Operatingsystem::REDHAT_ATOMIC_HOST_DISTRO_NAME
            return ::Operatingsystem::REDHAT_ATOMIC_HOST_OS
          elsif family.include? 'Red Hat'
            return 'RedHat'
          else
            return family.tr(' ', '_')
          end
        end
      end

      def kickstart_repos(host)
        distros = distribution_repositories(host).where(distribution_bootable: true)
        if distros && host.content_source
          distros.map { |distro| distro.to_hash(host.content_source) }
        else
          []
        end
      end

      def variant_repo(host, variant)
        if variant && host.content_source
          product_id = host.try(:content_facet).try(:kickstart_repository).try(:product_id) || host.try(:kickstart_repository).try(:product_id)
          distro = distribution_repositories(host)
            .joins(:product)
            .where(
              distribution_variant: variant,
              "#{Katello::Product.table_name}.id": product_id
            ).first

          distro&.to_hash(host.content_source)
        end
      end

      def distribution_repositories(host)
        content_view = host.try(:content_facet).try(:content_view) || host.try(:content_view)
        lifecycle_environment = host.try(:content_facet).try(:lifecycle_environment) || host.try(:lifecycle_environment)

        if content_view && lifecycle_environment && host.os && host.architecture
          Katello::Repository.in_environment(lifecycle_environment).in_content_views([content_view]).
              where(:distribution_arch => host.architecture.name).
              where("#{Katello::Repository.table_name}.distribution_version = :release or #{Katello::Repository.table_name}.distribution_version like :match",
                      release: host.os.release, match: "#{host.os.release}.%")
        else
          Katello::Repository.none
        end
      end
    end
  end
end
