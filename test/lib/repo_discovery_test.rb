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
      rd = RepoDiscovery.create_for('yum').new(base_url, nil, nil, crawled, found, to_follow)

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
      rd = RepoDiscovery.new(base_url, 'yum', nil, nil, crawled, found, to_follow)
      rd.stubs(:proxy).returns(@http_proxy)

      expected_proxy_params = {
        proxy_host: @proxy_uri.host,
        proxy_port: @proxy_uri.port,
        proxy_user: @http_proxy.username,
        proxy_password: @http_proxy.password
      }

      Anemone.expects(:crawl).with(rd.uri(base_url), expected_proxy_params).returns

      rd.run(to_follow.shift)
    end

    def test_run_http
      base_url = "http://yum.theforeman.org/"
      crawled = []
      found = []
      to_follow = [base_url]
      rd = RepoDiscovery.new(base_url, 'yum', nil, nil, crawled, found, to_follow)
      Anemone.expects(:crawl).with(rd.uri(base_url), {}).returns

      rd.run(to_follow.shift)
    end

    def test_docker_with_v1_search_no_proxy
      base_url = "https://docker.io/"
      crawled = []
      found = []
      to_follow = [base_url]
      search = 'busybox'

      RestClient::Request.expects(:execute)
        .with({ method: :get, url: base_url.to_s + "v1/search?q=#{search}", headers: {:accept => :json} })
        .returns({results: ['busybox']}.to_json)

      rd = RepoDiscovery.new(base_url, 'docker', nil, nil, search, crawled, found, to_follow)
      rd.expects(:proxy).returns(nil)

      rd.run(to_follow.shift)
    end

    def test_docker_with_v1_search_with_proxy
      base_url = "https://docker.io/"
      crawled = []
      found = []
      to_follow = [base_url]
      search = 'busybox'

      RestClient::Request.expects(:execute)
        .with({ method: :get, url: base_url.to_s + "v1/search?q=#{search}", proxy: @proxy_url, headers: {:accept => :json} })
        .returns({results: ['busybox']}.to_json)

      rd = RepoDiscovery.new(base_url, 'docker', nil, nil, search, crawled, found, to_follow)
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
      search = 'busybox'

      RestClient::Request.expects(:execute)
        .with({ method: :get, url: base_url.to_s + "v1/search?q=#{search}", proxy: @proxy_url, headers: {:accept => :json} })
        .returns({code: Net::HTTPNotFound}.to_json)

      RestClient::Request.expects(:execute)
        .with({ method: :get, url: base_url.to_s + "v2/_catalog", proxy: @proxy_url, headers: {:accept => :json} })
        .returns({'repositories' => ['busybox']}.to_json.extend(MockHeaders))

      rd = RepoDiscovery.new(base_url, 'docker', nil, nil, search, crawled, found, to_follow)
      rd.stubs(:proxy).returns(@http_proxy)

      rd.run(to_follow.shift)
    end
  end
end
