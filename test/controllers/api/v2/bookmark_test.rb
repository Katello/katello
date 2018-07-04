# encoding: utf-8

require "katello_test_helper"

module Foreman
  class Api::V2::BookmarksControllerTest < ActionController::TestCase
    test_attributes :pid => '6e7e4e9b-f12d-4e88-9d21-6c2f858e142b'
    def test_create_with_valid_katello_controller
      valid_attrs = {
        :public => false,
        :controller => "katello_host_collections",
        :name => "new-katello-controller-bookmark",
        :query => "name = my_collection"
      }
      assert_difference('Bookmark.count') do
        post :create, params: { :bookmark => valid_attrs }
      end
      assert_response :created
      result = JSON.parse(@response.body)
      assert_equal valid_attrs[:controller], result['controller']
      assert_equal valid_attrs[:name], result['name']
      assert_equal valid_attrs[:query], result['query']
    end
  end
end
