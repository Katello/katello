# rubocop:disable AccessModifierIndentation
module Katello
  module Concerns
    module RedhatExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :medium_uri, :content_uri
        alias_method_chain :boot_files_uri, :content
      end

      module ClassMethods
        def find_or_create_operating_system(repo)
          os_name = construct_name(repo.distribution_family)
          major, minor = repo.distribution_version.split('.')
          minor ||= '' # treat minor versions as empty string to not confuse with nil

          create_os = lambda { ::Redhat.where(:name => os_name, :major => major, :minor => minor).first_or_create! }

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
          if family.include? 'Red Hat'
            return 'RedHat'
          else
            return family.gsub(' ', '_')
          end
        end
      end

      def medium_uri_with_content_uri(host, url = nil)
        if host.try(:content_source) && (repo_details = kickstart_repo(host))
          URI.parse(repo_details[:path])
        else
          medium_uri_without_content_uri(host, url)
        end
      end

      def kickstart_repo(host)
        distro = distribution_repositories(host).first
        {:name => distro.name, :path => distro.full_path(host.content_source)} if distro && host.content_source
      end

      private

      def distribution_repositories(host)
        content_view = host.content_aspect.try(:content_view)
        lifecycle_environment = host.content_aspect.try(:lifecycle_environment)

        if content_view && lifecycle_environment
          Katello::Repository.where(:distribution_version => host.os.release,
                                    :distribution_arch => host.architecture.name,
                                    :distribution_bootable => true
                                    )
        else
          []
        end
      end

      # overwrite foreman method in operatingsystem.rb
      def boot_files_uri_with_content(medium, architecture, host = nil)
        return boot_files_uri_without_content(medium, architecture, host) unless host.try(:content_source)
        family_class = self.family.constantize
        family_class::PXEFILES.values.collect do |img|
          "#{medium_uri(host)}/#{pxedir}/#{img}"
        end
      end
    end
  end
end
