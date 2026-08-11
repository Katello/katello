module Katello
  module Util
    module HttpProxy
      def proxy_uri
        #Reset the scheme to proxy(s) based on http or https to handle cgi unescaping in rest-client
        if proxy
          scheme = 'proxy' if proxy_scheme == 'http'
          scheme = 'proxys' if proxy_scheme == 'https'

          uri = URI("#{scheme}://#{proxy_host}:#{proxy_port}")
          if proxy && proxy.username.present?
            uri.user = CGI.escape(proxy.username)
            uri.password = CGI.escape(proxy.password)
          end

          uri.to_s
        end
      end

      def proxy
        ::HttpProxy.default_global_content_proxy
      end

      def proxy_host
        URI(proxy.url).hostname
      end

      def proxy_hostname
        URI(proxy.url).host
      end

      def proxy_scheme
        URI(proxy.url).scheme
      end

      def proxy_port
        URI(proxy.url).port
      end
    end # HttpProxy
  end # Util
end # Katello
