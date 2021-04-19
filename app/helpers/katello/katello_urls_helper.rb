require 'uri'

module Katello
  module KatelloUrlsHelper
    def foreman_settings_url(schema = 'http')
      ::Setting[:foreman_url].sub(%r|^.*?:|, "#{schema}:")
    end

    def subscription_manager_configuration_url(host = nil, rpm = true, hostname: nil)
      prefix = if hostname
                 "http://#{hostname}"
               elsif host&.content_source
                 "http://#{host.content_source.hostname}"
               else
                 foreman_settings_url
               end

      config = rpm ? SETTINGS[:katello][:consumer_cert_rpm] : SETTINGS[:katello][:consumer_cert_sh]

      "#{prefix}/pub/#{config}"
    end

    def repository_url(content_path, _content_type = nil, schema = 'http')
      return content_path if content_path =~ %r|^([\w\-\+]+)://|
      url = if @host.content_source
              "#{schema}://#{@host.content_source.hostname}"
            else
              foreman_settings_url(schema)
            end
      content_path = content_path.sub(%r|^/|, '')
      if @host.content_view && !@host.content_view.default?
        content_path = [@host.content_view.label, content_path].join('/')
      end
      path = ::Katello::Glue::Pulp::Repos.repo_path_from_content_path(
        @host.lifecycle_environment, content_path)
      "#{url}/pulp/content/#{path}"
    end
  end
end
