module Katello
  module Pulp3
    class ContentViewVersion
      def initialize(smart_proxy:, content_view_version: nil)
        @smart_proxy = smart_proxy
        @content_view_version = content_view_version
      end

      def exporter_name
        @content_view_version.name.gsub(/\s/, '_')
      end

      def generate_exporter_id
        "#{@content_view_version.organization.label}_#{exporter_name}"
      end

      def generate_exporter_path
        export_path = "#{@content_view_version.content_view}/#{@content_view_version.version}".gsub(/\s/, '_')
        "#{@content_view_version.organization.label}/#{export_path}"
      end

      def api
        ::Katello::Pulp3::Api::Core.new(@smart_proxy)
      end

      def repository_hrefs
        version_hrefs.map { |href| version_href_to_repository_href(href) }.uniq
      end

      def version_hrefs
        if @content_view_version.default?
          @content_view_version.repositories.yum_type.pluck(:version_href).compact
        else
          @content_view_version.archived_repos.yum_type.pluck(:version_href).compact
        end
      end

      def version_href_to_repository_href(version_href)
        version_href.split("/")[0..-3].join("/") + "/"
      end

      def create_exporter(export_base_dir: Setting['pulpcore_export_destination'])
        api.exporter_api.create(name: generate_exporter_id,
                                path: "#{export_base_dir}/#{generate_exporter_path}",
                                repositories: repository_hrefs)
      end

      def create_export(exporter_href)
        [api.export_api.create(exporter_href, { versions: version_hrefs })]
      end

      def fetch_export(exporter_href)
        api.export_api.list(exporter_href).results.first
      end

      def destroy_exporter(exporter_href)
        export_data = fetch_export(exporter_href)
        api.exporter_api.partial_update(exporter_href, :last_export => nil)
        api.export_api.delete(export_data.pulp_href) unless export_data.blank?
        api.exporter_api.delete(exporter_href)
      end
    end
  end
end
