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
    let(:host_without_org) { hosts(:without_organization) }
    let(:host) do
      FactoryBot.create(:host, :with_content, :with_subscription, :content_view => view,
                                     :lifecycle_environment => library, :organization => org)
    end
    let(:subscription_facet) { host.subscription_facet }
    let(:uuid_fact_name) { RhsmFactName.create(name: 'dmi::system::uuid') }
    let(:find_host_error) { "Please unregister or remove hosts which match this host before registering: %s" }
  end

  class SubscriptionFacetSystemPurposeTest < SubscriptionFacetBase
    def test_update_addons
      subscription_facet.purpose_addons = %w(EUS AUS)
      assert_valid subscription_facet
      assert subscription_facet.backend_update_needed?
    end

    def test_update_addons_nil
      subscription_facet.update_attributes(purpose_addons: ['EUS'])
      subscription_facet.purpose_addons = nil
      assert_valid subscription_facet
      assert subscription_facet.backend_update_needed?
    end

    def test_search_role
      subscription_facet.update_attributes(purpose_role: 'satellite')
      assert_includes ::Host.search_for("role = satellite"), host
    end

    def test_search_addon
      subscription_facet.update_attributes(purpose_addons: ['EUS'])
      assert_includes ::Host.search_for("addon ~ EUS"), host
    end

    def test_search_usage
      subscription_facet.update_attributes(purpose_usage: 'disaster recovery')
      assert_includes ::Host.search_for('usage = "disaster recovery"'), host
    end

    def test_update_from_consumer_attributes
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_guests).returns([])
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_host).returns(nil)

      # set intial values
      params = { role: 'satellite', addOns: %w(one two), usage: 'DR' }
      subscription_facet.update_from_consumer_attributes(params.with_indifferent_access)

      # purpose attributes are preserved when not sent to us
      subscription_facet.update_from_consumer_attributes({}.with_indifferent_access)

      assert_equal params[:role], subscription_facet.purpose_role
      assert_equal params[:usage], subscription_facet.purpose_usage
      assert_equal params[:addOns], subscription_facet.purpose_addons

      # purpose attributes can be cleared
      subscription_facet.update_from_consumer_attributes({role: '', addOns: [], usage: ''}.with_indifferent_access)

      assert_empty subscription_facet.purpose_role
      assert_empty subscription_facet.purpose_usage
      assert_empty subscription_facet.purpose_addons
    end

    def test_purpose_status_search
      searches = {
        Katello::PurposeSlaStatus => "sla_status",
        Katello::PurposeAddonsStatus => "addons_status",
        Katello::PurposeRoleStatus => "role_status",
        Katello::PurposeUsageStatus => "usage_status",
        Katello::PurposeStatus => "purpose_status"
      }

      searches.each do |status_class, query|
        status = status_class.new(host: host)
        status.status = Katello::PurposeStatus::MISMATCHED
        status.reported_at = Time.now
        status.save!

        assert_includes ::Host::Managed.search_for("#{query} = mismatched"), host
      end
    end

    def test_update_purpose_status
      subscription_facet.update_purpose_status(sla_status: :mismatched,
                                               role_status: :unknown,
                                               usage_status: :not_specified,
                                               addons_status: :matched,
                                               purpose_status: :matched
                                              )

      assert_equal host.purpose_sla_status, Katello::PurposeStatus::MISMATCHED
      assert_equal host.purpose_role_status, Katello::PurposeStatus::UNKNOWN
      assert_equal host.purpose_usage_status, Katello::PurposeStatus::NOT_SPECIFIED
      assert_equal host.purpose_addons_status, Katello::PurposeStatus::MATCHED
      assert_equal host.purpose_status, Katello::PurposeStatus::MATCHED
    end
  end

  class SubscriptionFacetTest < SubscriptionFacetBase
    include FactImporterIsolation
    allow_transactions_for_any_importer

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
      subscription_facet.last_checkin = Time.now - 1.hour
      subscription_facet.save!

      assert_includes ::Host.search_for('last_checkin > "3 hours ago"'), host
      refute_includes ::Host.search_for('last_checkin < "3 hours ago"'), host
    end

    def test_create
      empty_host.subscription_facet = Katello::Host::SubscriptionFacet.create!(:host => empty_host)
    end

    def test_update_from_consumer_attributes
      params = { :lastCheckin => Time.now, :autoheal => true, :serviceLevel => "Premium", :releaseVer => "7Server" }
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_guests).returns([])
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_host).returns(nil)
      subscription_facet.update_from_consumer_attributes(params.with_indifferent_access)

      assert_equal subscription_facet.last_checkin, params[:lastCheckin]
      assert_equal subscription_facet.autoheal, params[:autoheal]
      assert_equal subscription_facet.service_level, params[:serviceLevel]
      assert_equal subscription_facet.release_version, params[:releaseVer]
    end

    def test_update_from_consumer_attributes_release_version
      params = { :lastCheckin => Time.now, :autoheal => true, :serviceLevel => "Premium", :releaseVer => {'releaseVer' => "7Server" }}
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_guests).returns([])
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_host).returns(nil)
      subscription_facet.update_from_consumer_attributes(params.with_indifferent_access)

      assert_equal '7Server', subscription_facet.release_version
    end

    def test_update_installed_products
      assert_empty subscription_facet.installed_products
      subscription_facet.update_installed_products([{
                                                     :arch => 'x86_64',
                                                     :version => '77.7',
                                                     :productName => 'super great enterprise os/2',
                                                     :productId => '108' }])
      refute_empty subscription_facet.installed_products
    end

    def test_update_compliance_reasons
      reason_one = {'message' => 'b', 'attributes' => {'name' => 'a'}}
      reason_two = {'message' => 'd', 'attributes' => {'name' => 'c'}}
      assert_empty subscription_facet.compliance_reasons.pluck(:reason)

      subscription_facet.update_compliance_reasons([reason_one])
      assert_equal ['a: b'], subscription_facet.compliance_reasons.pluck(:reason)

      subscription_facet.update_compliance_reasons([reason_one, reason_two])
      assert_equal ['a: b', 'c: d'].sort, subscription_facet.compliance_reasons.pluck(:reason).sort

      subscription_facet.update_compliance_reasons([reason_two])
      assert_equal ['c: d'], subscription_facet.compliance_reasons.pluck(:reason)
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
      host = FactoryBot.create(:host, organization: org)
      PuppetFactName.where(:name => 'dmi::system::uuid').first_or_create
      org2 = taxonomies(:organization2)
      assert_equal host, Katello::Host::SubscriptionFacet.find_host({'network.hostname' => host.name}, host.organization)
      assert_equal host, Katello::Host::SubscriptionFacet.find_host({'network.hostname' => host.name.upcase}, host.organization)

      Organization.current = org # simulate user setting default org
      assert_equal host_without_org, Katello::Host::SubscriptionFacet.find_host({'network.hostname' => host_without_org.name.upcase}, org)

      Organization.current = nil
      assert_nil Host::SubscriptionFacet.find_host({'network.hostname' => "the hostest with the mostest"}, host.organization)
      error = assert_raises(Katello::Errors::RegistrationError) { Katello::Host::SubscriptionFacet.find_host({'network.hostname' => host.name.upcase}, org2) }
      assert_equal "Host with name %s is currently registered to a different org, please migrate host to %s." % [host.name, org2.name], error.message
    end

    def test_find_host_existing_uuid
      # find host by dmi.system.uuid, no hostname match
      FactValue.create(value: "existing_system_uuid", host: host, fact_name: uuid_fact_name)

      facts = {'dmi.system.uuid' => 'existing_system_uuid', 'network.hostname' => 'inexistent'}

      error = assert_raises(Katello::Errors::RegistrationError) { Katello::Host::SubscriptionFacet.find_host(facts, org) }
      assert_equal find_host_error % host.name, error.message
    end

    def test_find_host_nil_uuid
      # hostname does not match existing record, and the dmi.system.uuid is nil.
      fv = FactValue.create(value: nil, host: host, fact_name: uuid_fact_name)
      assert_nil Katello::Host::SubscriptionFacet.find_host({'network.hostname' => 'inexistent'}, org)

      # hostname matches existing record, but existing has a UUID and we passed nothing
      fv.value = "something"
      fv.save!
      error = assert_raises(Katello::Errors::RegistrationError) { Katello::Host::SubscriptionFacet.find_host({'network.hostname' => host.name, 'dmi.system.uuid' => nil}, org) }
      assert_equal find_host_error % host.name, error.message
    end

    def test_find_host_existing_uuid_and_name_multiple
      host2 = FactoryBot.create(:host, organization: org)

      FactValue.create(value: "existing_system_uuid", host: host2, fact_name: uuid_fact_name)

      facts = {'dmi.system.uuid' => 'existing_system_uuid', 'network.hostname' => host.name}

      # if we get two matches, raise an error
      error = assert_raises(Katello::Errors::RegistrationError) { Katello::Host::SubscriptionFacet.find_host(facts, org) }
      expected = find_host_error % [host.name, host2.name].sort.join(', ')
      assert_equal expected, error.message
    end

    def test_find_host_existing_name_new_uuid
      # make sure existing host has a UUID
      FactValue.create(value: "existing_system_uuid", host: host, fact_name: uuid_fact_name)

      facts = {'dmi.system.uuid' => 'inexistent_uuid', 'network.hostname' => host.name}

      error = assert_raises(Katello::Errors::RegistrationError) { Katello::Host::SubscriptionFacet.find_host(facts, org) }
      assert_equal find_host_error % host.name, error.message
    end

    def test_find_host_existing_uuid_and_name
      # if we get a single match uuid + hostname, return it
      host3 = FactoryBot.create(:host, organization: org)

      FactValue.create(value: 'host3-uuid', host: host3, fact_name: uuid_fact_name)
      facts = {'dmi.system.uuid' => 'host3-uuid', 'network.hostname' => host3.name}

      assert_equal host3, Katello::Host::SubscriptionFacet.find_host(facts, org)
    end

    def test_find_host_multiple_existing_empty_uuid
      allowed_dups = ['', 'Not Settable', 'Not Present']
      allowed_dups.each do |dup|
        host = FactoryBot.create(:host, organization: org)
        FactValue.create(value: dup, host: host, fact_name: uuid_fact_name)

        facts = {'network.hostname' => 'inexistent_hostname', 'dmi.system.uuid' => dup}

        assert_nil Katello::Host::SubscriptionFacet.find_host(facts, org)
      end
    end

    def test_find_host_build_matching_hostname_new_uuid
      host = FactoryBot.create(:host, :managed, organization: org, build: true)
      FactValue.create(value: SecureRandom.uuid, host: host, fact_name: uuid_fact_name)

      facts = {'network.hostname' => host.name, 'dmi.system.uuid' => SecureRandom.uuid}
      assert_equal host, Katello::Host::SubscriptionFacet.find_host(facts, org)
    end

    def test_find_or_create_host_with_org
      created_host = FactoryBot.create(:host, :organization_id => org.id)
      host = Katello::Host::SubscriptionFacet.find_or_create_host(org, :facts => {'network.hostname' => created_host.name})

      assert_equal created_host, host
    end

    def test_find_or_create_host_no_org
      no_org_host = FactoryBot.create(:host, :organization_id => nil)
      host = Katello::Host::SubscriptionFacet.find_or_create_host(org, :facts => {'network.hostname' => no_org_host.name})

      assert_equal org, host.organization
    end

    def test_subscription_status
      status = Katello::SubscriptionStatus.new(:host => host)
      status.status = Katello::SubscriptionStatus::INVALID
      status.reported_at = Time.now
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
      host2 = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => view,
                                     :lifecycle_environment => library, :organization => org)
      user = User.first
      host.subscription_facet.update_attributes!(:user_id => user.id)
      host2.subscription_facet.update_attributes!(:user_id => user.id)

      assert ::Katello::Host::SubscriptionFacet.where(:user_id => user.id).count > 1
    end

    def test_propose_existing_hostname_fqdn_exists
      host = FactoryBot.create(:host)
      host.update_attributes!(:name => 'foo.bar.com')

      facts = {'network.hostname' => 'foo'}
      assert_equal 'foo', Host::SubscriptionFacet.propose_existing_hostname(facts)

      facts = {'network.hostname' => 'foo', 'network.hostname-override' => 'foo.bar.com'}
      assert_equal 'foo.bar.com', Host::SubscriptionFacet.propose_existing_hostname(facts)

      facts = {'network.hostname' => 'foo', 'network.fqdn' => 'foo.bar.com'}
      assert_equal 'foo.bar.com', Host::SubscriptionFacet.propose_existing_hostname(facts)

      facts = {'network.hostname' => 'foo', 'network.hostname-override' => 'baz.com'}
      assert_equal 'foo', Host::SubscriptionFacet.propose_existing_hostname(facts)

      facts = {'network.hostname' => 'foo.bar.com', 'foo.override' => 'does_not_exist'}
      Setting[:register_hostname_fact] = 'foo.override'
      assert_equal 'foo.bar.com', Host::SubscriptionFacet.propose_existing_hostname(facts)

      Setting[:register_hostname_fact_strict_match] = true
      assert_equal 'does_not_exist', Host::SubscriptionFacet.propose_existing_hostname(facts)
    end

    def test_search_hypervisor
      subscription_facet.hypervisor = "true"
      subscription_facet.save!

      assert_includes ::Host.search_for("hypervisor = true"), host
    end

    def test_search_hypervisor_host
      subscription_facet.hypervisor = "true"
      subscription_facet.save!
      guest_host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => view,
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
      guest_host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => view,
                                      :lifecycle_environment => library, :organization => org)
      subscription_facet.hypervisor = true
      Resources::Candlepin::Consumer.expects(:virtual_guests).returns([{'uuid' => guest_host.subscription_facet.uuid}])
      subscription_facet.update_guests({})

      assert_equal host, guest_host.subscription_facet.reload.hypervisor_host
    end

    def test_update_guests_for_guest
      virt_host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => view,
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

    def test_host_type
      kvm = "kvm"
      host = FactoryBot.create(:host, :with_content, :with_subscription, content_view: view,
                               lifecycle_environment: library, organization: org)
      host.expects(:facts).returns("virt::host_type" => kvm)

      assert_equal host.subscription_facet.host_type, kvm
    end

    def test_host_type_hypervisor
      qemu = "QEMU"
      hypervisor = FactoryBot.create(:host, :with_content, :with_subscription, content_view: view,
                                     lifecycle_environment: library, organization: org)
      hypervisor.expects(:facts).returns("hypervisor::type" => qemu)

      assert_equal hypervisor.subscription_facet.host_type, qemu
    end

    def test_host_type_nil
      host = FactoryBot.create(:host, :with_content, :with_subscription, content_view: view,
                               lifecycle_environment: library, organization: org)

      assert_nil host.subscription_facet.host_type
    end

    def test_audit_for_subscription_facet
      sample_host = ::Host::Managed.create!(:name => 'foohost', :managed => false, :organization_id => org.id)
      subfacet1 = Katello::Host::SubscriptionFacet.create!(:host => sample_host)

      recent_audit = Audit.where(auditable_id: subfacet1.id).last
      assert recent_audit, "No audit record for subscription_facet"
      assert_equal 'create', recent_audit.action
      assert_includes recent_audit.organization_ids, org.id

      subscription_facet_rec = sample_host.associated_audits.where(auditable_id: subfacet1.id)
      assert subscription_facet_rec, "No associated audit record for subscription_facet"
    end
  end
end
