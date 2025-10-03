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

    def test_show_manifest_list_children
      # Create a manifest list with child manifests
      manifest_list = FactoryBot.create(:docker_manifest_list)
      child_manifest1 = FactoryBot.create(:docker_manifest, :digest => "sha256:child1")
      child_manifest2 = FactoryBot.create(:docker_manifest, :digest => "sha256:child2")

      manifest_list.docker_manifests << child_manifest1
      manifest_list.docker_manifests << child_manifest2

      # Create a tag for the manifest list
      tag = @repo.docker_tags.create!(:name => "multiarch", :docker_taggable => manifest_list, :pulp_id => 'listpulpid')
      meta_tag = DockerMetaTag.create!(:name => tag.name, :schema2 => tag, :repositories => [@repo])

      get :show, params: { :repository_id => @repo.id, :id => meta_tag.id }

      assert_response :success
      body = JSON.parse(response.body)

      # Verify manifest type is 'list'
      assert_equal 'list', body['manifest']['manifest_type']

      # Verify children are included (factory creates 1 child + 2 we added = 3 total)
      assert_not_nil body['manifest']['manifests']
      assert_equal 3, body['manifest']['manifests'].length

      # Verify child manifest details
      child_digests = body['manifest']['manifests'].map { |m| m['digest'] }
      assert_includes child_digests, 'sha256:child1'
      assert_includes child_digests, 'sha256:child2'

      # Verify each child has required fields
      body['manifest']['manifests'].each do |child|
        assert_not_nil child['id']
        assert_not_nil child['digest']
        assert_not_nil child['schema_version']
        assert_equal 'image', child['manifest_type']
      end
    end

    def test_index_manifest_list_children
      # Create a manifest list with child manifests
      manifest_list = FactoryBot.create(:docker_manifest_list)
      child_manifest = FactoryBot.create(:docker_manifest, :digest => "sha256:indexchild1")
      manifest_list.docker_manifests << child_manifest

      # Create a tag for the manifest list
      tag = @repo.docker_tags.create!(:name => "multiarch-index", :docker_taggable => manifest_list, :pulp_id => 'listindexpulpid')
      DockerMetaTag.create!(:name => tag.name, :schema2 => tag, :repositories => [@repo])

      get :index, params: { :repository_id => @repo.id }

      assert_response :success
      body = JSON.parse(response.body)

      # Find the manifest list tag in results
      list_tag = body['results'].find { |t| t['name'] == 'multiarch-index' }
      assert_not_nil list_tag

      # Verify manifest children are present (factory creates 1 child + 1 we added = 2 total)
      assert_equal 'list', list_tag['manifest']['manifest_type']
      assert_not_nil list_tag['manifest']['manifests']
      assert_equal 2, list_tag['manifest']['manifests'].length
      child_digests = list_tag['manifest']['manifests'].map { |m| m['digest'] }
      assert_includes child_digests, 'sha256:indexchild1'
    end

    def test_show_non_list_manifest_has_no_children
      # Regular image manifests should not have children node
      get :show, params: { :repository_id => @repo.id, :id => @meta_tag.id }

      assert_response :success
      body = JSON.parse(response.body)

      # Verify it's an image type
      assert_equal 'image', body['manifest']['manifest_type']

      # Verify no manifests array for non-list types
      assert_nil body['manifest']['manifests']
    end
  end
end
