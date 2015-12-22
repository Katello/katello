module Katello
  module Concerns
    module MediumExtensions
      extend ActiveSupport::Concern

      def destroy!
        unless destroy
          fail self.errors.full_messages.join('; ')
        end
      end

      module ClassMethods
        def update_media(repo)
          return if repo.puppet?

          medium_path = ::Medium.installation_media_path(repo.uri)

          if distribution = repo.distribution_bootable?
            return if ::Medium.find_by(:path => medium_path)

            os = ::Redhat.find_or_create_operating_system(repo)

            arch = ::Architecture.where(:name => repo.distribution_arch).first_or_create!
            os.architectures << arch unless os.architectures.include?(arch)

            medium_name = ::Medium.construct_name(repo, distribution)
            medium = ::Medium.find_or_create_medium(repo.organization, medium_name, medium_path)
            os.media << medium

            os.save!

          else
            if medium = ::Medium.find_by(:path => medium_path)
              medium.destroy
            end
          end
        end

        def find_or_create_medium(org, medium_name, medium_path)
          params = { :name => medium_name, :path => medium_path,
                     :os_family => 'Redhat' }

          medium = ::Medium.joins(:organizations).where(params).where("taxonomies.id in (?)", [org.id]).first
          medium = ::Medium.create!(params.merge(:organization_ids => [org.id])) unless medium

          return medium
        end

        def find_medium(repo)
          path = ::Medium.installation_media_path(repo.uri)
          ::Medium.find_by(:path => path)
        end

        def construct_name(repo, _distribution)
          parts = [repo.organization.label, repo.environment.label]
          if repo.content_view && !repo.content_view.default?
            parts << repo.content_view.label
          end
          parts << repo.product.label
          parts << repo.label
          return normalize_name(parts.compact.join('/'))
        end

        # Foreman and Puppet uses RedHat name for Red Hat Enterprise Linux
        def normalize_name(name)
          name.sub('Red_Hat_Enterprise_Linux', 'Red_Hat')
        end

        # takes repo uri from Katello and makes installation media url
        # suitable for provisioning from it
        def installation_media_path(repo_uri)
          path = repo_uri.sub(/\Ahttps/, 'http')
          path << "/" unless path.end_with?('/')
          return path
        end
      end
    end
  end
end
