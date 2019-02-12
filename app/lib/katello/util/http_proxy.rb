require 'katello/util/proxy_uri'

module Katello
  module Util
    module HttpProxy
      def proxy_uri
        #Reset the scheme to proxy(s) based on http or https to handle cgi unescaping in rest-client
        # this relies on katello/util/proxy_uri
        if proxy_host
          scheme = 'proxy' if proxy_scheme == 'http'
          scheme = 'proxys' if proxy_scheme == 'https'

          uri = URI("#{scheme}://#{proxy_host}:#{proxy_port}")
          if proxy_config && proxy_config[:user]
            uri.user = CGI.escape(proxy_config[:user])
            uri.password = CGI.escape(proxy_config[:password])
          end

          uri.to_s
        end
      end

      def proxy_config
        SETTINGS[:katello][:cdn_proxy]
      end

      def proxy_host
        proxy_config && URI.parse(proxy_config[:host]).host
      end

      def proxy_scheme
        proxy_config && URI.parse(proxy_config[:host]).scheme
      end

      def proxy_port
        proxy_config && proxy_config[:port]
      end
    end # HttpProxy
  end # Util
end # Katello
