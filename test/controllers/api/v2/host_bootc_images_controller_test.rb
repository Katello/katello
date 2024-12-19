# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostBootcImagesControllerTest < ActionController::TestCase
    tests ::Katello::Api::V2::HostBootcImagesController

    def setup
      setup_controller_defaults_api
      setup_foreman_routes
      @host1 = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                                :lifecycle_environment => katello_environments(:library))
      @host2 = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                                :lifecycle_environment => katello_environments(:library))
      @host3 = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                                :lifecycle_environment => katello_environments(:library))
      @host1.content_facet.update!(bootc_booted_image: 'image1')
      @host1.content_facet.update!(bootc_booted_digest: 'sha256:dcfb2965cda67bd3731408ace23dd07ff3116168c2b832e16bba8234525724a3')
      @host2.content_facet.update!(bootc_booted_image: 'image1')
      @host2.content_facet.update!(bootc_booted_digest: 'sha256:dcfb2965cda67bd3731408ace23dd07ff3116168c2b832e16bba8234525724a3')
      @host3.content_facet.update!(bootc_booted_image: 'image2')
      @host3.content_facet.update!(bootc_booted_digest: 'sha256:dcfb2965cda67bc3731408aae23dd07ff3116168c2b832e16bba8234525724a5')
    end

    def test_bootc_images_counts_properly_no_paging
      get :bootc_images
      assert_response :success
      results = JSON.parse(@response.body)['bootc_images']
      assert_includes results, ["image1", [{"bootc_booted_digest" => "sha256:dcfb2965cda67bd3731408ace23dd07ff3116168c2b832e16bba8234525724a3", "host_count" => 2}]]
      assert_includes results, ["image2", [{"bootc_booted_digest" => "sha256:dcfb2965cda67bc3731408aae23dd07ff3116168c2b832e16bba8234525724a5", "host_count" => 1}]]
    end

    def test_bootc_images_pages
      @host2.content_facet.update!(bootc_booted_image: 'image3')
      @host2.content_facet.update!(bootc_booted_digest: 'sha256:dcfb2965cda67bd3731408ace93dd07ff3116168c2b832e16bba8234525724c9')
      get :bootc_images, params: { page: 1, per_page: 1 }
      page1 = @response.body
      get :bootc_images, params: { page: 2, per_page: 1 }
      page2 = @response.body
      get :bootc_images, params: { page: 3, per_page: 1 }
      page3 = @response.body
      get :bootc_images, params: { page: 4, per_page: 1 }
      page4 = @response.body

      assert_equal [["image1", [{"bootc_booted_digest" => "sha256:dcfb2965cda67bd3731408ace23dd07ff3116168c2b832e16bba8234525724a3", "host_count" => 1}]]], JSON.parse(page1)['bootc_images']
      assert_equal [["image2", [{"bootc_booted_digest" => "sha256:dcfb2965cda67bc3731408aae23dd07ff3116168c2b832e16bba8234525724a5", "host_count" => 1}]]], JSON.parse(page2)['bootc_images']
      assert_equal [["image3", [{"bootc_booted_digest" => "sha256:dcfb2965cda67bd3731408ace93dd07ff3116168c2b832e16bba8234525724c9", "host_count" => 1}]]], JSON.parse(page3)['bootc_images']
      assert_empty JSON.parse(page4)['bootc_images']
    end
  end
end
