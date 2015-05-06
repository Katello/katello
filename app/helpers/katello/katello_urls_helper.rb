require 'uri'
module Katello
  module KatelloUrlsHelper
    def host(url)
      URI(url).host unless url.nil?
    end

    def subscription_manager_configuration_url(host = nil)
      prefix = if host && host.content_source
                 "http://#{@host.content_source.hostname}"
               else
                 Setting[:foreman_url].sub(/\Ahttps/, 'http')
               end

      "#{prefix}/pub/#{Katello.config.consumer_cert_rpm}"
    end
  end
end
