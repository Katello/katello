require 'katello_test_helper'

module Katello
  module Util
    class HttpProxyTest < ActiveSupport::TestCase
      include Katello::Util::HttpProxy

      def test_handles_no_username_test
        SETTINGS[:katello][:cdn_proxy] = {
          host: 'http://foobar.com',
          username: nil,
          password: nil
        }
        assert_equal 'proxy://foobar.com', proxy_uri
      end

      def test_properly_escapes_username
        SETTINGS[:katello][:cdn_proxy] = {
          host: 'http://foobar.com',
          user: 'red!hat',
          password: 'red@hat'
        }
        assert_equal 'proxy://red%21hat:red%40hat@foobar.com', proxy_uri

        uri = URI.parse(proxy_uri)
        assert_equal 'red!hat', uri.user
        assert_equal 'red@hat', uri.password
      end
    end
  end
end
