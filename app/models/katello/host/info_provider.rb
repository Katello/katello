require 'host_info'

module Katello
  module Host
    class InfoProvider < ::HostInfo::Provider
      def host_info
        info = {}
        info['parameters'] = {
          'foreman_host_collections' => host.host_collections.map(&:name),
        }

        if host.content_facet.present?
          info['parameters']['kickstart_repository'] = host.content_facet.kickstart_repository.try(:label)
          if host.single_content_view_environment?
            info['parameters']['lifecycle_environment'] = host.single_lifecycle_environment.try(:label)
            info['parameters']['content_view'] = host.single_content_view.try(:label)
            info['parameters']['content_view_info'] = content_view_info(host.content_view_environments.first)
          end
          info['parameters']['content_views'] = host.content_view_environments.map do |cve|
            content_view_info(cve).merge(
              'lifecycle_environment' => cve.lifecycle_environment.try(:label)
            )
          end
        end

        if (rhsm_url = host.content_source&.rhsm_url)
          info['parameters']['rhsm_url'] = rhsm_url.to_s
        end

        if (content_url = host.content_source&.pulp_content_url)
          info['parameters']['content_url'] = content_url.to_s
        end

        info
      end

      def content_view_info(content_view_environment)
        content_view = content_view_environment.content_view
        return {} if content_view.blank?
        {
          'label' => content_view.try(:label),
          'latest-version' => content_view.try(:latest_version),
          'version' => content_version(content_view_environment).try(:version),
          'published' => content_version(content_view_environment).try(:created_at).try(:time).to_s,
          'components' => content_view_components(content_view_environment),
        }
      end

      def content_view_components(content_view_environment)
        return {} unless content_view_environment.content_view.try(:composite)

        components = {}
        content_version(content_view_environment).try(:content_view_version_components).map do |cv|
          cv_label = cv.component_version.content_view.label
          components[cv_label] = {}
          components[cv_label]['version'] = cv.component_version.try(:version)
          components[cv_label]['published'] = cv.component_version.try(:created_at).try(:time).to_s
        end
        components
      end

      def content_version(content_view_environment)
        content_view_environment.content_view.try(:version, content_view_environment.lifecycle_environment)
      end
    end
  end
end
