module Katello
  module Util
    module HttpProxy
      def proxy_uri
        URI("#{proxy_scheme}://#{proxy_user_info}@#{proxy_host}:#{proxy_port}").to_s if proxy_host
      end

      def proxy_user_info
        "#{proxy_config[:user]}:#{proxy_config[:password]}" if proxy_config && proxy_config[:user]
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
