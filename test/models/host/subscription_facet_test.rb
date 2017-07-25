require 'katello_test_helper'

module Katello
  class SubscriptionFacetBase < ActiveSupport::TestCase
    let(:org) { taxonomies(:empty_organization) }
    let(:library) { katello_environments(:library) }
    let(:dev) { katello_environments(:dev) }
    let(:view)  { katello_content_views(:library_dev_view) }
    let(:activation_key) { katello_activation_keys(:simple_key) }
    let(:empty_host) { ::Host::Managed.create!(:name => 'foobar', :managed => false) }
    let(:basic_subscription) { katello_subscriptions(:basic_subscription) }
    let(:host_one) { hosts(:one) }
    let(:host) do
      FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => view,
                                     :lifecycle_environment => library, :organization => org)
    end
    let(:subscription_facet) { host.subscription_facet }
  end

  class SubscriptionFacetTest < SubscriptionFacetBase
    def test_sanitize_name
      assert_equal 'foo-bar', Host::SubscriptionFacet.sanitize_name('foo_bar')
      assert_equal 'foobar', Host::SubscriptionFacet.sanitize_name('foobar.')
      assert_equal 'foobar', Host::SubscriptionFacet.sanitize_name('FoOBar')
    end

    def test_search_release_version
      subscription_facet.update_attributes!(:release_version => '7Server')

      assert_includes ::Host.search_for("release_version = 7Server"), host
    end

    def test_search_autoheal
      subscription_facet.update_attributes!(:autoheal => 'true')

      assert_includes ::Host.search_for("autoheal = true"), host
    end

    def test_search_service_level
      subscription_facet.update_attributes!(:service_level => 'terrible')

      assert_includes ::Host.search_for("service_level = terrible"), host
    end

    def test_search_uuid
      subscription_facet.uuid = "kdjfkdjf"
      subscription_facet.save!

      assert_includes ::Host.search_for("subscription_uuid = kdjfkdjf"), host
    end

    def test_search_last_checkin
      subscription_facet.last_checkin = DateTime.now - 1.hour
      subscription_facet.save!

      assert_includes ::Host.search_for('last_checkin > "3 hours ago"'), host
      refute_includes ::Host.search_for('last_checkin < "3 hours ago"'), host
    end

    def test_create
      empty_host.subscription_facet = Katello::Host::SubscriptionFacet.create!(:host => empty_host)
    end

    def test_update_from_consumer_attributes
      params = { :lastCheckin => DateTime.now, :autoheal => true, :serviceLevel => "Premium", :releaseVer => "7Server" }
      subscription_facet.update_from_consumer_attributes(params.with_indifferent_access)

      assert_equal subscription_facet.last_checkin, params[:lastCheckin]
      assert_equal subscription_facet.autoheal, params[:autoheal]
      assert_equal subscription_facet.service_level, params[:serviceLevel]
      assert_equal subscription_facet.release_version, params[:releaseVer]
    end

    def test_update_from_consumer_attributes_release_version
      params = { :lastCheckin => DateTime.now, :autoheal => true, :serviceLevel => "Premium", :releaseVer => {'releaseVer' => "7Server" }}
      subscription_facet.update_from_consumer_attributes(params.with_indifferent_access)

      assert_equal '7Server', subscription_facet.release_version
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
      Katello::Host::SubscriptionFacet.update_facts(host, :rhsm_fact => 'rhsm_value')

      values = host.fact_values
      assert_equal 2, values.count
      assert_include values.map(&:value), 'rhsm_value'
      assert_includes values.map(&:name), 'rhsm_fact'
      assert_includes values.map(&:name), '_timestamp'
    end

    def test_find_host
      org2 = taxonomies(:organization2)
      assert_equal host, Katello::Host::SubscriptionFacet.find_host({'network.hostname' => host.name}, host.organization)
      assert_equal host, Katello::Host::SubscriptionFacet.find_host({'network.hostname' => host.name.upcase}, host.organization)
      assert_nil Host::SubscriptionFacet.find_host({'network.hostname' => "the hostest with the mostest"}, host.organization)
      assert_raises(RuntimeError) { Katello::Host::SubscriptionFacet.find_host({'network.hostname' => host.name.upcase}, org2) }
    end

    def test_find_or_create_host_with_org
      created_host = FactoryGirl.create(:host, :organization_id => org.id)
      host = Katello::Host::SubscriptionFacet.find_or_create_host(org, :facts => {'network.hostname' => created_host.name})

      assert_equal created_host, host
    end

    def test_find_or_create_host_no_org
      no_org_host = FactoryGirl.create(:host, :organization_id => nil)
      host = Katello::Host::SubscriptionFacet.find_or_create_host(org, :facts => {'network.hostname' => no_org_host.name})

      assert_equal org, host.organization
    end

    def test_subscription_status
      status = Katello::SubscriptionStatus.new(:host => host)
      status.status = Katello::SubscriptionStatus::INVALID
      status.reported_at = DateTime.now
      status.save!

      assert_includes ::Host::Managed.search_for("subscription_status = invalid"), host
    end

    def test_remove_subscriptions
      pool = katello_pools(:pool_one)
      pq = [PoolWithQuantities.new(pool, [1])]
      ForemanTasks.expects(:sync_task).with(Actions::Katello::Host::RemoveSubscriptions, host, pq)

      host.subscription_facet.remove_subscriptions(pq)
    end

    def test_backend_update_needed?
      refute subscription_facet.backend_update_needed?

      subscription_facet.service_level = 'terrible'
      assert subscription_facet.backend_update_needed?

      subscription_facet.reload
      refute subscription_facet.backend_update_needed?

      subscription_facet.host.content_facet.lifecycle_environment_id = dev.id
      assert subscription_facet.backend_update_needed?
    end

    def test_search_by_activation_key_id
      host.subscription_facet.activation_keys << activation_key
      assert_includes ::Host.search_for("activation_key_id = #{activation_key.id}"), host
    end

    def test_search_by_activation_key
      host.subscription_facet.activation_keys << activation_key
      assert_includes ::Host.search_for("activation_key = \"#{activation_key.name}\""), host
    end

    def test_search_by_subscription_name
      assert_includes ::Host.search_for("subscription_name = \"#{basic_subscription.name}\""), host_one
    end

    def test_search_by_subscription_id
      assert_includes ::Host.search_for("subscription_id = \"#{basic_subscription.pools.first.id}\""), host_one
    end

    def test_propose_name_from_facts
      facts = {'network.hostname' => 'foo'}
      assert_equal 'foo', Host::SubscriptionFacet.propose_name_from_facts(facts)

      facts['network.hostname-override'] = ''
      assert_equal 'foo', Host::SubscriptionFacet.propose_name_from_facts(facts)

      facts['network.hostname-override'] = 'foo.override'
      assert_equal 'foo.override', Host::SubscriptionFacet.propose_name_from_facts(facts)

      facts['network.fqdn'] = 'localhost'
      assert_equal 'foo.override', Host::SubscriptionFacet.propose_name_from_facts(facts)

      facts['network.fqdn'] = 'foo.domain.com'
      assert_equal 'foo.domain.com', Host::SubscriptionFacet.propose_name_from_facts(facts)

      Setting[:register_hostname_fact] = 'network.hostname'
      assert_equal 'foo', Host::SubscriptionFacet.propose_name_from_facts(facts)

      Setting[:register_hostname_fact] = 'trumpedupfact'
      assert_equal facts['network.fqdn'], Host::SubscriptionFacet.propose_name_from_facts(facts)
    end

    def test_duplicate_usernames
      host2 = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => view,
                                     :lifecycle_environment => library, :organization => org)
      user = User.first
      host.subscription_facet.update_attributes!(:user_id => user.id)
      host2.subscription_facet.update_attributes!(:user_id => user.id)

      assert ::Katello::Host::SubscriptionFacet.where(:user_id => user.id).count > 1
    end

    def test_propose_existing_hostname_fqdn_exists
      host = FactoryGirl.create(:host)
      host.update_attributes!(:name => 'foo.bar.com')

      facts = {'network.hostname' => 'foo'}
      assert_equal 'foo', Host::SubscriptionFacet.propose_existing_hostname(facts)

      facts = {'network.hostname' => 'foo', 'network.hostname-override' => 'foo.bar.com'}
      assert_equal 'foo.bar.com', Host::SubscriptionFacet.propose_existing_hostname(facts)

      facts = {'network.hostname' => 'foo', 'network.fqdn' => 'foo.bar.com'}
      assert_equal 'foo.bar.com', Host::SubscriptionFacet.propose_existing_hostname(facts)

      facts = {'network.hostname' => 'foo', 'network.hostname-override' => 'baz.com'}
      assert_equal 'foo', Host::SubscriptionFacet.propose_existing_hostname(facts)
    end

    def test_search_hypervisor
      subscription_facet.hypervisor = "true"
      subscription_facet.save!

      assert_includes ::Host.search_for("hypervisor = true"), host
    end

    def test_search_hypervisor_host
      subscription_facet.hypervisor = "true"
      subscription_facet.save!
      guest_host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => view,
                                      :lifecycle_environment => library, :organization => org)
      Resources::Candlepin::Consumer.expects(:virtual_guests).returns([{'uuid' => guest_host.subscription_facet.uuid}])
      #subscription_facet.candlepin_consumer.expects(:virtual_guests).returns(guest_host)
      subscription_facet.update_guests({})

      assert_includes ::Host.search_for("hypervisor_host = #{host.name}"), guest_host
    end

    def test_update_hypervisor_using_candlepin_type
      consumer_params = {'type' => {'label' => 'hypervisor'}}
      subscription_facet.update_hypervisor(consumer_params)

      assert subscription_facet.hypervisor
    end

    def test_update_hypervisor_using_guest_ids
      consumer_params = {'guestIds' => ['1']}
      subscription_facet.update_hypervisor(consumer_params)

      assert subscription_facet.hypervisor
    end

    def test_update_hypervisor_via_candlepin_api
      consumer_params = {}
      subscription_facet.candlepin_consumer.expects(:virtual_guests).returns(['1'])
      subscription_facet.update_hypervisor(consumer_params)

      assert subscription_facet.hypervisor
    end

    def test_update_guests_for_hypervisor
      guest_host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => view,
                                      :lifecycle_environment => library, :organization => org)
      subscription_facet.hypervisor = true
      Resources::Candlepin::Consumer.expects(:virtual_guests).returns([{'uuid' => guest_host.subscription_facet.uuid}])
      subscription_facet.update_guests({})

      assert_equal host, guest_host.subscription_facet.reload.hypervisor_host
    end

    def test_update_guests_for_guest
      virt_host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => view,
                                      :lifecycle_environment => library, :organization => org)
      subscription_facet.hypervisor = false
      subscription_facet.candlepin_consumer.expects(:virtual_host).returns(virt_host)
      subscription_facet.update_guests({})

      assert_equal virt_host, subscription_facet.hypervisor_host
    end

    def test_valid_content_override_label?
      subscription_facet.candlepin_consumer.expects(:available_product_content).returns([OpenStruct.new(:content => OpenStruct.new(:label => 'some-label'))]).at_least_once
      assert host.valid_content_override_label?('some-label')
      refute host.valid_content_override_label?('some-label1')
    end

    def test_not_all_available_product_content
      subscription_facet.candlepin_consumer.expects(:products).returns([]).at_least_once
      subscription_facet.candlepin_consumer.available_product_content(false, false)
    end

    def test_all_available_product_content
      subscription_facet.candlepin_consumer.expects(:all_products).returns([]).at_least_once
      subscription_facet.candlepin_consumer.available_product_content(true, false)
    end
  end
end
