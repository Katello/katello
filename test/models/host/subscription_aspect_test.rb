require 'katello_test_helper'

module Katello
  class SubscriptionAspectBase < ActiveSupport::TestCase
    let(:org) { taxonomies(:empty_organization) }
    let(:library) { katello_environments(:library) }
    let(:view)  { katello_content_views(:library_dev_view) }
    let(:empty_host) { ::Host::Managed.create!(:name => 'foobar', :managed => false) }
    let(:host) do
      FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => view,
                                     :lifecycle_environment =>  library, :organization => org)
    end
    let(:subscription_aspect) { host.subscription_aspect }
  end

  class SubscriptionAspectTest < SubscriptionAspectBase
    def test_create
      empty_host.subscription_aspect = Katello::Host::SubscriptionAspect.create!(:uuid => 'asdfasdf', :host => empty_host)
    end

    def test_update_from_consumer_attributes
      params = { :lastCheckin => DateTime.now, :autoheal => true, :serviceLevel => "Premium", :releaseVer => "7Server" }
      subscription_aspect.update_from_consumer_attributes(params.with_indifferent_access)

      assert_equal subscription_aspect.last_checkin, params[:lastCheckin]
      assert_equal subscription_aspect.autoheal, params[:autoheal]
      assert_equal subscription_aspect.service_level, params[:serviceLevel]
      assert_equal subscription_aspect.release_version, params[:releaseVer]
    end

    def test_candlepin_environment_id
      assert_equal subscription_aspect.candlepin_environment_id, ContentViewEnvironment.where(:content_view_id => view, :environment_id => library).first.cp_id
    end

    def test_candlepin_environment_id_no_content
      subscription_aspect.host.content_aspect.destroy!
      assert_equal subscription_aspect.reload.candlepin_environment_id, ContentViewEnvironment.where(:content_view_id => org.default_content_view,
                                                                                               :environment_id => org.library).first.cp_id
    end

    def test_consumer_attributes
      attrs = subscription_aspect.consumer_attributes

      assert_equal subscription_aspect.candlepin_environment_id, attrs[:environment][:id]
    end
  end
end
