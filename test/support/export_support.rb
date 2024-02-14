module Support
  module ExportSupport
    def fetch_exporter(smart_proxy:, content_view_version:,
                       destination_server: nil, from_content_view_version: nil,
                       format: ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE)
      export = ::Katello::Pulp3::ContentViewVersion::Export.create(
        { smart_proxy: smart_proxy,
          content_view_version: content_view_version,
          destination_server: destination_server,
          from_content_view_version: from_content_view_version,
          format: format
        }
      )
      version_repositories = content_view_version.archived_repos.yum_type
      version_repositories.each_with_index do |repo, index|
        repo.update!(version_href: index)
      end

      export.instance_eval do
        @version_repositories = version_repositories
        def fetch_repository_info(href)
          fail _("invalid href %s" % href) unless href.to_i < @version_repositories.count
          OpenStruct.new(name: href.to_i)
        end
      end
      export
    end
  end
end
