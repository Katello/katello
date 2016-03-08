require "katello_test_helper"

module Katello
  class Api::V2::OstreeBranchesControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:ostree_rhel7))
      @branch = @repo.ostree_branches.create!(:name => "abc123", :uuid => "123xyz")
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

    def test_index_with_repository
      get :index, :repository_id => @repo.id
      assert_response :success
      assert_template "katello/api/v2/ostree_branches/index"
    end

    def test_index_with_organization
      get :index, :organization_id => @repo.organization.id
      assert_response :success
      assert_template "katello/api/v2/ostree_branches/index"
    end

    def test_index_with_content_view_version
      get :index, :content_view_version_id => ContentViewVersion.last
      assert_response :success
      assert_template "katello/api/v2/ostree_branches/index"
    end

    def test_show
      get :show, :repository_id => @repo.id, :id => @branch.uuid

      assert_response :success
      assert_template "katello/api/v2/ostree_branches/show"
    end
  end
end
