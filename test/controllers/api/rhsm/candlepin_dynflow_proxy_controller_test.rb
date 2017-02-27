# encoding: utf-8

require "katello_test_helper"

module Katello
  describe Api::Rhsm::CandlepinDynflowProxyController do
    include Katello::AuthorizationSupportMethods
    include Support::ForemanTasks::Task

    before do
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))

      @content_view = katello_content_views(:acme_default)
      @environment = katello_environments(:library)

      @host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                 :lifecycle_environment => @environment, :organization => @content_view.organization)
    end

    it "test_upload_package_profile_protected" do
      Resources::Candlepin::Consumer.stubs(:get)
      assert_protected_action(:upload_package_profile, :edit_hosts) do
        put :upload_package_profile, :id => @host.subscription_facet.uuid
      end
    end
  end
end
