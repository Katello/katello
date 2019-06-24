require 'katello_test_helper'

module Katello
  module Util
    class HttpProxyTest < ActiveSupport::TestCase
      include Katello::Util::HttpProxy

      def setup_default_proxy(url, user, pass)
        proxy = ::HttpProxy.create!(:url => url, :username => user, :password => pass, :name => url)
        Setting[:content_default_http_proxy] = proxy.name
      end

      def test_handles_no_username_test
        setup_default_proxy('http://foobar.com', nil, nil)

        assert_equal 'proxy://foobar.com', proxy_uri
      end

      def test_properly_escapes_username
        setup_default_proxy('http://foobar.com', 'red!hat', 'red@hat')

        assert_equal 'proxy://red%21hat:red%40hat@foobar.com', proxy_uri

        uri = URI.parse(proxy_uri)
        assert_equal 'red!hat', uri.user
        assert_equal 'red@hat', uri.password
      end
    end
  end
end
