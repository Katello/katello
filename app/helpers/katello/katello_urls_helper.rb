require 'uri'

module Katello
  module KatelloUrlsHelper
    extend ApipieDSL::Module

    apipie :class, 'Helper macros related to content to use within a template' do
      name 'Content helpers'
      sections only: %w[all reports provisioning jobs partition_tables]
    end

    apipie :method, 'Returns Foreman URL based on settings' do
      optional :schema, String, desc: 'Optional URL schema'
      returns String, desc: 'Foreman URL based on settings and schema if provided'
    end
    def foreman_settings_url(schema = 'http')
      ::Setting[:foreman_url].sub(%r|^.*?:|, "#{schema}:")
    end

    apipie :method, 'Returns subscription manager configuration URL' do
      optional :host, 'Host::Managed', desc: "The host that will be making the request (URL will be of that host's smart proxy)", default: nil
      optional :rpm, [true, false], desc: 'When true, the returned URL will lead to the configuration as an RPM package. When false, the URL will lead to the plain-text configuration script', default: true
      keyword :hostname, String, desc: 'Override the hostname in the URL with the specified hostname', default: nil
      returns String, desc: 'Subscription manager configuration URL based on provided arguments'
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

    apipie :method, 'Generates an absolute path to the file for liveimg kickstart templates' do
      required :content_path, String, desc: "Relative path to the file or it's name"
      optional :schema, String, desc: 'Optional URL schema for the content source', default: 'http'
      optional :content_type, String, desc: 'Content type', default: 'repos'
      returns String, desc: 'Absolute path to a file'
    end
    def repository_url(content_path, _content_type = nil, schema = 'http')
      return content_path if content_path =~ %r|^([\w\-\+]+)://|
      url = if @host.content_source
              "#{schema}://#{@host.content_source.hostname}"
            else
              foreman_settings_url(schema)
            end
      content_path = content_path.sub(%r|^/|, '')

      lifecycle_environment = nil
      if @host.default_environment?
        # Don't update the content_path if the host is using the default org view / library
        lifecycle_environment = ::Katello::KTEnvironment.library.find_by(organization_id: @host.organization_id)
      elsif !@host.single_content_view_environment?
        fail ::Katello::Errors::MultiEnvironmentNotSupportedError,
          "Host #{@host.name} must be subscribed to only a single content view & environment or subscribe to the default organization content view for liveimg provisioning."
      else
        lifecycle_environment = @host.single_lifecycle_environment
        content_path = [@host.single_content_view.label, content_path].join('/')
      end

      path = ::Katello::Repository.repo_path_from_content_path(
        lifecycle_environment, content_path)
      "#{url}/pulp/content/#{path}"
    end
  end
end
