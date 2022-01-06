require 'host_info'

module Katello
  module Host
    class InfoProvider < ::HostInfo::Provider
      def host_info
        info = {}
        info['parameters'] = {
          'foreman_host_collections' => host.host_collections.map(&:name),
          'lifecycle_environment' => host.lifecycle_environment.try(:label),

          'content_view' => host.content_view.try(:label),
          'content_view_info' => content_view_info
        }

        if host.content_facet.present?
          info['parameters']['kickstart_repository'] = host.content_facet.kickstart_repository.try(:label)
        end

        if (rhsm_url = host.content_source&.rhsm_url)
          info['parameters']['rhsm_url'] = rhsm_url.to_s
        end

        if (content_url = host.content_source&.pulp_content_url)
          info['parameters']['content_url'] = content_url.to_s
        end

        info
      end

      def content_view_info
        return {} if host.content_view.blank?

        content_view_info = {
          'label' => host.content_view.try(:label),
          'latest-version' => host.content_view.try(:latest_version),
          'version' => content_version.try(:version),
          'published' => content_version.try(:created_at).try(:time).to_s,
          'components' => content_view_components
        }

        content_view_info
      end

      def content_view_components
        return {} unless host.content_view.try(:composite)

        components = {}
        content_version.try(:content_view_version_components).map do |cv|
          cv_label = cv.component_version.content_view.label
          components[cv_label] = {}
          components[cv_label]['version'] = cv.component_version.try(:version)
          components[cv_label]['published'] = cv.component_version.try(:created_at).try(:time).to_s
        end
        components
      end

      def content_version
        host.content_view.try(:version, host.lifecycle_environment)
      end
    end
  end
end
