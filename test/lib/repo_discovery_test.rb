require 'katello_test_helper'

module Katello
  class FileRepoDiscoveryTest < ActiveSupport::TestCase
    def test_run
      base_url = "file://#{Katello::Engine.root}/test/fixtures/"
      crawled = []
      found = []
      to_follow = [base_url]
      rd = RepoDiscovery.new(base_url, 'yum', nil, nil, {}, crawled, found, to_follow)

      rd.run(to_follow.shift)
      assert_equal 1, rd.crawled.size
      refute_empty rd.to_follow
      assert_empty rd.found
      assert_equal rd.crawled.first, "#{Katello::Engine.root}/test/fixtures/"
    end

    def test_docker_with_v1_search_no_proxy
      base_url = "https://docker.io/"
      crawled = []
      found = []
      to_follow = [base_url]
      proxy = {}
      search = 'busybox'

      RestClient::Request.expects(:execute)
        .with(method: :get, url: base_url.to_s + "v1/search?q=#{search}", headers: {:accept => :json})
        .returns({results: ['busybox']}.to_json)

      rd = RepoDiscovery.new(base_url, 'docker', nil, nil, search, proxy, crawled, found, to_follow)

      rd.run(to_follow.shift)
    end

    def test_docker_with_v1_search_with_proxy
      base_url = "https://docker.io/"
      crawled = []
      found = []
      to_follow = [base_url]
      proxy = {
        proxy_host: 'https://proxy.example.com',
        proxy_user: 'admin',
        proxy_password: 'redhat',
        proxy_port: 8888
      }
      search = 'busybox'

      expected_proxy_uri = URI(proxy[:proxy_host])
      expected_proxy_uri.user = proxy[:proxy_user]
      expected_proxy_uri.password = proxy[:proxy_password]
      expected_proxy_uri.port = proxy[:proxy_port]

      RestClient::Request.expects(:execute)
        .with(method: :get, url: base_url.to_s + "v1/search?q=#{search}", proxy: "https://admin:redhat@proxy.example.com:8888", headers: {:accept => :json})
        .returns({results: ['busybox']}.to_json)

      rd = RepoDiscovery.new(base_url, 'docker', nil, nil, search, proxy, crawled, found, to_follow)

      rd.run(to_follow.shift)
    end

    def test_docker_with_v2_search_with_proxy
      base_url = "https://docker.io/"
      crawled = []
      found = []
      to_follow = [base_url]
      proxy = {
        proxy_host: 'https://proxy.example.com',
        proxy_user: 'admin',
        proxy_password: 'redhat',
        proxy_port: 8888
      }
      search = 'busybox'

      expected_proxy_uri = URI(proxy[:proxy_host])
      expected_proxy_uri.user = proxy[:proxy_user]
      expected_proxy_uri.password = proxy[:proxy_password]
      expected_proxy_uri.port = proxy[:proxy_port]

      RestClient::Request.expects(:execute)
        .with(method: :get, url: base_url.to_s + "v1/search?q=#{search}", proxy: "https://admin:redhat@proxy.example.com:8888", headers: {:accept => :json})
        .returns({code: Net::HTTPNotFound}.to_json)

      RestClient::Request.expects(:execute)
        .with(method: :get, url: base_url.to_s + "v2/_catalog", proxy: "https://admin:redhat@proxy.example.com:8888", headers: {:accept => :json})
        .returns({'repositories' => ['busybox']}.to_json)

      rd = RepoDiscovery.new(base_url, 'docker', nil, nil, search, proxy, crawled, found, to_follow)

      rd.run(to_follow.shift)
    end
  end
end
