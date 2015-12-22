require 'katello_test_helper'

module Katello
  class SubscriptionFacetBase < ActiveSupport::TestCase
    let(:org) { taxonomies(:empty_organization) }
    let(:library) { katello_environments(:library) }
    let(:view)  { katello_content_views(:library_dev_view) }
    let(:empty_host) { ::Host::Managed.create!(:name => 'foobar', :managed => false) }
    let(:host) do
      FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => view,
                                     :lifecycle_environment =>  library, :organization => org)
    end
    let(:subscription_facet) { host.subscription_facet }
  end

  class SubscriptionFacetTest < SubscriptionFacetBase
    def test_create
      empty_host.subscription_facet = Katello::Host::SubscriptionFacet.create!(:uuid => 'asdfasdf', :host => empty_host)
    end

    def test_update_from_consumer_attributes
      params = { :lastCheckin => DateTime.now, :autoheal => true, :serviceLevel => "Premium", :releaseVer => "7Server" }
      subscription_facet.update_from_consumer_attributes(params.with_indifferent_access)

      assert_equal subscription_facet.last_checkin, params[:lastCheckin]
      assert_equal subscription_facet.autoheal, params[:autoheal]
      assert_equal subscription_facet.service_level, params[:serviceLevel]
      assert_equal subscription_facet.release_version, params[:releaseVer]
    end

    def test_candlepin_environment_id
      assert_equal subscription_facet.candlepin_environment_id, ContentViewEnvironment.where(:content_view_id => view, :environment_id => library).first.cp_id
    end

    def test_candlepin_environment_id_no_content
      subscription_facet.host.content_facet.destroy!
      assert_equal subscription_facet.reload.candlepin_environment_id, ContentViewEnvironment.where(:content_view_id => org.default_content_view,
                                                                                               :environment_id => org.library).first.cp_id
    end

    def test_consumer_attributes
      attrs = subscription_facet.consumer_attributes

      assert_equal subscription_facet.candlepin_environment_id, attrs[:environment][:id]
    end

    def test_update_foreman_facts
      subscription_facet.update_facts(:rhsm_fact => 'rhsm_value')

      values = subscription_facet.host.fact_values
      assert_equal 2, values.count
      assert_include values.map(&:value), 'rhsm_value'
      assert_includes values.map(&:name), 'rhsm_fact'
      assert_includes values.map(&:name), '_timestamp'
    end

    def test_find_or_create_host_with_org
      created_host = FactoryGirl.create(:host, :organization_id => org.id)
      host = Katello::Host::SubscriptionFacet.find_or_create_host(created_host.name, org, 'facts' => {'network.hostname' => created_host.name})

      assert_equal created_host, host
    end

    def test_find_or_create_host_no_org
      no_org_host = FactoryGirl.create(:host, :organization_id => nil)
      host = Katello::Host::SubscriptionFacet.find_or_create_host(no_org_host.name, org, 'facts' => {'network.hostname' => no_org_host.name})

      assert_equal org, host.organization
    end
  end
end
