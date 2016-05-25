require "katello_test_helper"

module Katello
  class Api::V2::DockerTagsControllerTest < ActionController::TestCase
    def models
      @redis = Repository.find(katello_repositories(:redis).id)
      @redis_manifest = @redis.docker_manifests.create!(:name => "abc123", :uuid => "123xyz")
      @redis_tag = @redis.docker_tags.create!(:name => "wat", :docker_manifest => @redis_manifest)

      @busybox = Repository.find(katello_repositories(:busybox_view1).id)
      @busybox_manifest = @busybox.docker_manifests.create!(:name => "xyz789", :uuid => "789abc")
      @busybox_tag = @busybox.docker_tags.create!(:name => "huh", :docker_manifest => @busybox_manifest)
    end

    def setup
      setup_controller_defaults_api
      models
    end

    def test_index
      get :index, :repository_id => @redis.id
      assert_response :success
      assert_template "katello/api/v2/docker_tags/index"

      get :index
      assert_response :success
      assert_template "katello/api/v2/docker_tags/index"

      get :index, :organization_id => @redis.organization.id
      assert_response :success
      assert_template "katello/api/v2/docker_tags/index"
    end

    def test_grouped_index
      organization = @redis.organization
      repos_stub = stub(:in_organization => [@redis])
      Repository.expects(:readable).returns(repos_stub)
      get :index, :organization_id => organization.id,
        :grouped => true

      assert_response :success
      assert_template 'api/v2/docker_tags/index'

      results = JSON.parse(response.body)["results"].map { |tag| tag["name"] }
      assert_equal ['wat'], results
    end

    def test_show
      get :show, :repository_id => @redis.id, :id => @redis_tag.id

      assert_response :success
      assert_template "katello/api/v2/docker_tags/show"
      assert_template :layout => 'katello/api/v2/layouts/resource'
    end

    def test_compare
      response = get :compare, :content_view_version_ids => [@redis.content_view_version_id, @busybox.content_view_version_id]
      results = JSON.parse(response.body)["results"]

      assert_response :success

      redis_tags = @redis.docker_tags.map(&:name)
      redis_results = results.select { |result| redis_tags.include?(result["item"]) }
      redis_results.each { |result| assert result["comparison"].include?(@redis.content_view_version_id) }

      busybox_tags = @busybox.docker_tags.map(&:name)
      busybox_results = results.select { |result| busybox_tags.include?(result["item"]) }
      busybox_results.each { |result| assert result["comparison"].include?(@busybox.content_view_version_id) }
    end
  end
end
