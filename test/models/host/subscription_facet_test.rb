require 'katello_test_helper'

module Katello
  class SubscriptionFacetBase < ActiveSupport::TestCase
    let(:org) { taxonomies(:empty_organization) }
    let(:library) { katello_environments(:library) }
    let(:dev) { katello_environments(:dev) }
    let(:view)  { katello_content_views(:library_dev_view) }
    let(:activation_key) { katello_activation_keys(:simple_key) }
    let(:empty_host) { ::Host::Managed.create!(:name => 'foobar.example.com', :managed => false) }
    let(:basic_subscription) { katello_subscriptions(:basic_subscription) }
    let(:host_one) { hosts(:one) }
    let(:host) do
      FactoryBot.create(:host, :with_content, :with_subscription, :content_view => view,
                                     :lifecycle_environment => library, :organization => org)
    end
    let(:subscription_facet) { host.subscription_facet }
    let(:centos_76) do
      FactoryBot.create(:operatingsystem,
        :with_associations,
        name: 'CentOS',
        major: 7,
        minor: 6,
        type: "Redhat",
        title: "CentOS 7.6")
    end

    def setup
      ::Host::Managed.any_instance.stubs(:update_candlepin_associations)
    end
  end

  class SubscriptionFacetSystemPurposeTest < SubscriptionFacetBase
    def test_search_role
      subscription_facet.update(purpose_role: 'satellite')
      assert_includes ::Host.search_for("role = satellite"), host
    end

    def test_convert2rhel_through_foreman_on_host
      subscription_facet.update(convert2rhel_through_foreman: 1)
      assert_equal 1, host.subscription_facet.convert2rhel_through_foreman
      assert_includes ::Host.search_for("convert2rhel_through_foreman = 1"), host
    end

    def test_convert2rhel_through_foreman_not_on_host
      # We want the value nil unless the custom fact is present otherwise we get a 0 in the database which if debugging
      # might make you think it was converted2rhel but not with satellite.
      assert_nil host.subscription_facet.convert2rhel_through_foreman
      refute_equal 0, host.subscription_facet.convert2rhel_through_foreman
    end

    def test_search_usage
      subscription_facet.update(purpose_usage: 'disaster recovery')
      assert_includes ::Host.search_for('usage = "disaster recovery"'), host
    end

    def test_update_from_consumer_attributes
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_guests).returns([])
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_host).returns(nil)

      # set intial values
      params = { role: 'satellite', usage: 'DR' }
      subscription_facet.update_from_consumer_attributes(params.with_indifferent_access)

      # purpose attributes are preserved when not sent to us
      subscription_facet.update_from_consumer_attributes({}.with_indifferent_access)

      assert_equal params[:role], subscription_facet.purpose_role
      assert_equal params[:usage], subscription_facet.purpose_usage

      # purpose attributes can be cleared
      subscription_facet.update_from_consumer_attributes({role: '', usage: ''}.with_indifferent_access)

      assert_empty subscription_facet.purpose_role
      assert_empty subscription_facet.purpose_usage
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
      subscription_facet.update!(:release_version => '7Server')

      assert_includes ::Host.search_for("release_version = 7Server"), host
    end

    def test_search_service_level
      subscription_facet.update!(:service_level => 'terrible')

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
      params = { :lastCheckin => Time.now, :serviceLevel => "Premium", :releaseVer => "7Server" }
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_guests).returns([])
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_host).returns(nil)
      subscription_facet.update_from_consumer_attributes(params.with_indifferent_access)

      assert_equal subscription_facet.last_checkin, params[:lastCheckin]
      assert_equal subscription_facet.service_level, params[:serviceLevel]
      assert_equal subscription_facet.release_version, params[:releaseVer]
    end

    def test_update_from_consumer_attributes_release_version
      params = { :lastCheckin => Time.now, :serviceLevel => "Premium", :releaseVer => {'releaseVer' => "7Server" }}
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
      assert_equal subscription_facet.candlepin_environments.first[:id], ContentViewEnvironment.where(:content_view_id => view, :environment_id => library).first.cp_id
    end

    def test_candlepin_environment_id_no_content
      subscription_facet.host.content_facet.destroy!
      assert_equal subscription_facet.reload.candlepin_environments.first[:id], ContentViewEnvironment.where(:content_view_id => org.default_content_view,
                                                                                               :environment_id => org.library).first.cp_id
    end

    def test_consumer_attributes
      attrs = subscription_facet.consumer_attributes
      # "environments"=>[{"id"=>"5"}]
      assert_equal subscription_facet.candlepin_environments.first[:id], attrs[:environments].first[:id]
    end

    def test_update_foreman_facts
      Katello::Host::SubscriptionFacet.update_facts(host, :rhsm_fact => 'rhsm_value')

      values = host.fact_values
      assert_equal 2, values.count
      assert_include values.map(&:value), 'rhsm_value'
      assert_includes values.map(&:name), 'rhsm_fact'
      assert_includes values.map(&:name), '_timestamp'
    end

    def test_update_facts_with_centos_no_minor_version
      host.operatingsystem = centos_76
      Katello::Host::SubscriptionFacet.update_facts(
        host,
        'distribution.name' => 'CentOS',
        'distribution.version' => '7')

      assert_equal 'CentOS', host.operatingsystem.name
      assert_equal '7', host.operatingsystem.major
      assert_equal '6', host.operatingsystem.minor
    end

    def test_update_foreman_facts_with_no_centos_different_major_and_no_minor_version
      host.operatingsystem = centos_76

      Katello::Host::SubscriptionFacet.update_facts(
        host,
        'distribution.name' => 'CentOS',
        'distribution.version' => '8')

      assert_equal 'CentOS', host.operatingsystem.name
      assert_equal '8', host.operatingsystem.major
      assert_equal "", host.operatingsystem.minor
    end

    def test_update_foreman_facts_with_os_version
      FactoryBot.create(:operatingsystem,
        :with_associations,
        name: 'Redhat',
        major: 8,
        minor: 2,
        type: "Redhat",
        title: "RHEL 8.2")
      host.operatingsystem = centos_76

      Katello::Host::SubscriptionFacet.update_facts(
        host,
        'distribution.name' => 'Redhat',
        'distribution.version' => '8.2')

      assert_equal 'RedHat', host.operatingsystem.name
      assert_equal '8', host.operatingsystem.major
      assert_equal '2', host.operatingsystem.minor
    end

    def test_update_foreman_facts_without_distribution_version
      host.operatingsystem = centos_76
      Katello::Host::SubscriptionFacet.update_facts(host, 'distribution.name' => 'Redhat')

      assert_equal 'CentOS', host.operatingsystem.name
      assert_equal '7', host.operatingsystem.major
      assert_equal "6", host.operatingsystem.minor
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
      host.subscription_facet.update!(:user_id => user.id)
      host2.subscription_facet.update!(:user_id => user.id)

      assert ::Katello::Host::SubscriptionFacet.where(:user_id => user.id).count > 1
    end

    def test_propose_existing_hostname_fqdn_exists
      host = FactoryBot.create(:host)
      host.update!(:name => 'foo.bar.com')

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
      sample_host = ::Host::Managed.create!(:name => 'foohost.example.com', :managed => false, :organization_id => org.id)
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
