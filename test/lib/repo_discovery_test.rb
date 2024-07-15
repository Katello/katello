require 'katello_test_helper'

module Katello
  class RepoDiscoveryTest < ActiveSupport::TestCase
    def setup
      @http_proxy = http_proxies(:myhttpproxy)
      @proxy_url = "proxys://mytest.com:443"
      @proxy_uri = URI(@proxy_url)
    end

    def test_run
      base_url = "file://#{Katello::Engine.root}/test/fixtures/"
      crawled = []
      found = []
      to_follow = [base_url]
      rd = RepoDiscovery.class_for('yum').new(base_url, crawled, found, to_follow)

      rd.run(to_follow.shift)
      assert_equal 1, rd.crawled.size
      refute_empty rd.to_follow
      assert_empty rd.found
      assert_equal rd.crawled.first, "#{Katello::Engine.root}/test/fixtures/"
    end

    def test_run_http_with_proxy
      base_url = "http://yum.theforeman.org/"
      crawled = []
      found = []
      to_follow = [base_url]
      rd = RepoDiscovery.class_for('yum').new(base_url, crawled, found, to_follow)
      rd.stubs(:proxy).returns(@http_proxy)

      expected_proxy_params = {
        host: "mytest.com",
        port: 443,
        user: nil,
        password: nil
      }

      Spidr.expects(:site).with(base_url, proxy: expected_proxy_params).returns

      rd.run(to_follow.shift)
    end

    def test_run_http
      base_url = "http://yum.theforeman.org/"
      crawled = []
      found = []
      to_follow = [base_url]
      rd = RepoDiscovery.class_for('yum').new(base_url, crawled, found, to_follow)
      Spidr.expects(:site).with(base_url, :proxy => {}).returns

      rd.run(to_follow.shift)
    end

    def test_docker_with_v1_search_no_proxy
      base_url = "https://docker.io/"
      crawled = []
      found = []
      to_follow = [base_url]
      upstream_credentials_and_search = {
        search: 'busybox'
      }

      RestClient::Request.expects(:execute)
        .with({ method: :get, url: base_url.to_s + "v1/search?q=busybox", headers: {:accept => :json} })
        .returns({results: ['busybox']}.to_json)

      rd = RepoDiscovery.class_for('docker').new(base_url, crawled, found, to_follow, upstream_credentials_and_search)
      rd.expects(:proxy).returns(nil)

      rd.run(to_follow.shift)
    end

    def test_docker_with_v1_search_with_proxy
      base_url = "https://docker.io/"
      crawled = []
      found = []
      to_follow = [base_url]
      upstream_credentials_and_search = {
        search: 'busybox'
      }

      RestClient::Request.expects(:execute)
        .with({ method: :get, url: base_url.to_s + "v1/search?q=busybox", proxy: @proxy_url, headers: {:accept => :json} })
        .returns({results: ['busybox']}.to_json)

      rd = RepoDiscovery.class_for('docker').new(base_url, crawled, found, to_follow, upstream_credentials_and_search)
      rd.stubs(:proxy).returns(@http_proxy)

      rd.run(to_follow.shift)
    end

    module MockHeaders
      def headers
        {}
      end
    end

    def test_docker_with_v2_search_with_proxy
      base_url = "https://docker.io/"
      crawled = []
      found = []
      to_follow = [base_url]
      upstream_credentials_and_search = {
        search: 'busybox'
      }

      RestClient::Request.expects(:execute)
        .with({ method: :get, url: base_url.to_s + "v1/search?q=busybox", proxy: @proxy_url, headers: {:accept => :json} })
        .returns({code: Net::HTTPNotFound}.to_json)

      RestClient::Request.expects(:execute)
        .with({ method: :get, url: base_url.to_s + "v2/_catalog", proxy: @proxy_url, headers: {:accept => :json} })
        .returns({'repositories' => ['busybox']}.to_json.extend(MockHeaders))

      rd = RepoDiscovery.class_for('docker').new(base_url, crawled, found, to_follow, upstream_credentials_and_search)
      rd.stubs(:proxy).returns(@http_proxy)

      rd.run(to_follow.shift)
    end
  end
end
