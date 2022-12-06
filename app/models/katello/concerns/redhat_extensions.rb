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

          if ::Redhat.where(:title => "#{os_name} #{repo.distribution_version}").present?
            description = "#{os_name} #{repo.distribution_version} #{SecureRandom.uuid}"
            create_os = lambda do
              ::Redhat.create!(:name => os_name, :major => major, :minor => minor, :description => description)
            end
          else
            create_os = lambda { ::Redhat.create!(:name => os_name, :major => major, :minor => minor) }
          end

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

      def kickstart_repos(host, content_facet: nil)
        distros = distribution_repositories(host, content_facet: content_facet).where(distribution_bootable: true)
        content_facet ||= host.content_facet
        cs = content_facet&.content_source || host.try(:content_source)
        if distros && cs
          distros.map { |distro| distro.to_hash(cs) }
        else
          []
        end
      end

      def variant_repos(host, variant)
        if variant && host.content_source
          product_id = host.try(:content_facet).try(:kickstart_repository).try(:product_id) || host.try(:kickstart_repository).try(:product_id)
          distribution_repositories(host)
            .joins(:product)
            .where("#{Katello::Repository.table_name}.distribution_variant LIKE :variant", { variant: "%#{variant}%" })
            .where("#{Katello::Product.table_name}.id": product_id).collect { |repo| repo.to_hash(host.content_source, true) }
        end
      end

      def distribution_repositories(host, content_facet: nil)
        content_facet ||= host.content_facet
        case content_facet
        when ::Katello::Host::ContentFacet
          if content_facet.new_record?
            content_views = ::Katello::ContentView.where(id: content_facet.content_view_environments.map(&:content_view_id))
            lifecycle_environments = ::Katello::KTEnvironment.where(id: content_facet.content_view_environments.map(&:environment_id))
          else
            content_views = content_facet.try(:content_views) || host.try(:content_views)
            lifecycle_environments = content_facet.try(:lifecycle_environments) || host.try(:lifecycle_environments)
          end
        when ::Katello::Hostgroup::ContentFacet
          content_views = [content_facet.try(:content_view), host.try(:content_views)].flatten.compact
          lifecycle_environments = [content_facet.try(:lifecycle_environment), host.try(:lifecycle_environments)].flatten.compact
        end
        if content_views.present? && lifecycle_environments.present? && host.os && host.architecture
          Katello::Repository.in_environment(lifecycle_environments).in_content_views(content_views).
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
