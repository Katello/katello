# Provides a patch to https://github.com/chriskite/anemone/blob/next/lib/anemone/http.rb#L162
# to allow providing proxy user and password

module Anemone
  class HTTP
    #
    # The proxy user string
    #
    def proxy_user
      @opts[:proxy_user]
    end

    #
    # The proxy password
    #
    def proxy_password
      @opts[:proxy_password]
    end

    def refresh_connection(url)
      http = Net::HTTP.new(url.host, url.port, proxy_host, proxy_port, proxy_user, proxy_password)

      http.read_timeout = read_timeout if !!read_timeout

      if url.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      @connections[url.host][url.port] = http.start
    end
  end
end
