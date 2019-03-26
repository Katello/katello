require "katello_test_helper"

module Katello
  class Api::V2::OstreeBranchesControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:ostree).id)
      @branch = @repo.ostree_branches.create!(:name => "abc123", :pulp_id => "123xyz", :version => "1.1")
    end

    def setup
      setup_controller_defaults_api
      models
    end

    def test_index
      get :index
      assert_response :success
      assert_template "katello/api/v2/ostree_branches/index"
    end

    def test_index_sort
      response = get :index, params: {sort_by: 'version', sort_order: 'desc'}
      body = JSON.parse(response.body)

      assert_response :success
      assert_template "katello/api/v2/ostree_branches/index"
      assert_empty body['error']
    end

    def test_index_with_repository
      get :index, params: { :repository_id => @repo.id }
      assert_response :success
      assert_template "katello/api/v2/ostree_branches/index"
    end

    def test_index_with_organization
      get :index, params: { :organization_id => @repo.organization.id }
      assert_response :success
      assert_template "katello/api/v2/ostree_branches/index"
    end

    def test_index_with_content_view_version
      get :index, params: { :content_view_version_id => ContentViewVersion.last }
      assert_response :success
      assert_template "katello/api/v2/ostree_branches/index"
    end

    def test_show
      get :show, params: { :repository_id => @repo.id, :id => @branch.pulp_id }

      assert_response :success
      assert_template "katello/api/v2/ostree_branches/show"
    end

    def test_compare
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id] }
      assert_response :success
      assert_template "katello/api/v2/ostree_branches/compare"

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id], :repository_id => @lib_repo.id }
      assert_response :success
      assert_template "katello/api/v2/ostree_branches/compare"
    end

    def test_branch_order
      @repo.ostree_branches.create!(:name => "def456", :pulp_id => "456uvw", :version => "1.0")

      get :index
      tree_branch_uuid = JSON.parse(response.body)['results'][0]['uuid']
      assert_equal "123xyz", tree_branch_uuid
    end
  end
end
