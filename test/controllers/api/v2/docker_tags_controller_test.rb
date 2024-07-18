require "katello_test_helper"

module Katello
  class Api::V2::DockerTagsControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:redis).id)
      @manifest = @repo.docker_manifests.create!(:digest => "abc123", :pulp_id => "123xyz")
      @tag = @repo.docker_tags.create!(:name => "wat", :docker_taggable => @manifest, :pulp_id => 'randompulpid')
      @meta_tag = DockerMetaTag.create!(:name => @tag.name, :schema1 => @tag, :repositories => [@repo])
    end

    def setup
      setup_controller_defaults_api
      models
    end

    def test_autocomplete_name
      response = get :auto_complete_name, params: { :repoids => [@repo.id], :term => @tag.name }

      assert_response :success
      assert_includes JSON.parse(response.body), @tag.name
    end

    def test_index
      get :index, params: { :repository_id => @repo.id }
      assert_response :success
      assert_template "katello/api/v2/docker_tags/index"

      get :index
      assert_response :success
      assert_template "katello/api/v2/docker_tags/index"

      get :index, params: { :organization_id => @repo.organization.id }
      assert_response :success
      assert_template "katello/api/v2/docker_tags/index"
    end

    def test_grouped_index
      organization = @repo.organization
      repos_stub = stub(:in_organization => [@repo])
      ::Katello::Repository.expects(:readable).returns(repos_stub)

      get :index, params: { :organization_id => organization.id, :grouped => true }

      assert_response :success
      assert_template 'api/v2/docker_tags/index'

      results = JSON.parse(response.body)["results"].map { |tag| tag["name"] }
      assert_equal ['wat'], results
    end

    def test_index_equal_digest
      organization = @repo.organization
      ENV['test'] =  'foo'
      get :index, params: { :organization_id => organization.id, :search => "digest=abc123" }

      assert_response :success
      assert_template 'api/v2/docker_tags/index'

      results = JSON.parse(response.body)["results"].map { |tag| tag["name"] }
      assert_equal ['wat'], results
    end

    def test_index_no_match_digest
      organization = @repo.organization
      get :index, params: { :organization_id => organization.id, :search => "digest=xyz" }

      assert_response :success
      assert_template 'api/v2/docker_tags/index'

      results = JSON.parse(response.body)["results"].map { |tag| tag["name"] }
      assert_empty results
    end

    def test_show
      get :show, params: { :repository_id => @repo.id, :id => @meta_tag.id }

      assert_response :success
      assert_template "katello/api/v2/docker_tags/show"
      assert_template :layout => 'katello/api/v2/layouts/resource'
    end

    def test_show_related_tags
      get :show, params: { :repository_id => @repo.id, :id => @meta_tag.id }

      related_tag = JSON.parse(response.body)['related_tags'].first
      refute_nil related_tag['id']
      assert_equal 'wat', related_tag['name']
    end

    def test_compare
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id] }
      assert_response :success
      assert_template "katello/api/v2/docker_tags/compare"

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id], :repository_id => @lib_repo.id }
      assert_response :success
      assert_template "katello/api/v2/docker_tags/compare"
    end
  end
end
