module Katello
  module Pulp3
    module ContentViewVersion
      module ImportExportCommon
        def generate_name
          @content_view_version.name.gsub(/\s/, '_')
        end

        def generate_id
          "#{@content_view_version.organization.label}_#{generate_name}"
        end

        def api
          ::Katello::Pulp3::Api::Core.new(@smart_proxy)
        end

        def fetch_repository_info(version_href)
          repo_api = ::Katello::Pulp3::Api::Yum.new(@smart_proxy).repositories_api
          repo_api.read(version_href_to_repository_href(version_href))
        end

        def repository_hrefs
          version_hrefs.map { |href| version_href_to_repository_href(href) }.uniq
        end

        def version_hrefs
          repositories.pluck(:version_href).compact
        end

        def repositories
          if @content_view_version.default?
            @content_view_version.repositories.yum_type
          else
            @content_view_version.archived_repos.yum_type
          end
        end

        def version_href_to_repository_href(version_href)
          version_href.split("/")[0..-3].join("/") + "/"
        end
      end
    end
  end
end
