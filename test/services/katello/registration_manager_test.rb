require 'katello_test_helper'

module Katello
  module Service
    class RegistrationManagerTestBase < ActiveSupport::TestCase
      include VCR::TestCase
    end

    class RegistrationManager < RegistrationManagerTestBase
      include FactImporterIsolation
      allow_transactions_for_any_importer

      before :all do
        set_user
        @content_view = katello_content_views(:library_dev_view)
        @library = katello_environments(:library)
        @content_view_environment = katello_content_view_environments(:library_dev_view_library)
        @activation_key = katello_activation_keys(:library_dev_staging_view_key)
        @host_collection = katello_host_collections(:simple_host_collection)
        @one_host_limit_host_collection = katello_host_collections(:one_host_limit_host_collection)
        @activation_key.host_collections << @host_collection
        @org = @library.organization
        @facts = {'network.hostname' => 'foo.example.com'}
        @host = FactoryBot.create(:host, organization: @org)
      end

      after :all do
        @activation_key.host_collections.delete_all
      end

      let(:rhsm_params) { {:name => 'foobar.example.com', :facts => @facts, :type => 'system'} }

      class ValidateHostsTest < ActiveSupport::TestCase
        def setup
          @org = get_organization
          @klass = Katello::RegistrationManager
          @host = FactoryBot.create(:host, :with_subscription, organization: @org)
        end

        let(:hosts) { ::Host.where(id: [@host.id]) }

        def test_different_org
          org2 = taxonomies(:organization2)

          error = assert_raises(Katello::Errors::RegistrationError) { @klass.validate_hosts(hosts, org2, nil, nil) }

          assert_match(/different org/, error.message)
        end

        def test_multiple_hosts
          assert ::Host.all.size > 1
          error = assert_raises(Katello::Errors::RegistrationError) { @klass.validate_hosts(::Host.all, @org, nil, nil) }
          assert_match(/matches other registered/, error.message)
        end

        def test_new_host_existing_uuid
          existing_uuid = 'existing_system_uuid'
          @host.subscription_facet.update(dmi_uuid: existing_uuid)

          error = assert_raises(Katello::Errors::RegistrationError) { @klass.validate_hosts(hosts, @org, 'new_host_name', existing_uuid) }
          assert_match(/matches other registered/, error.message)
        end

        def test_existing_host_mismatch_uuid
          @host.subscription_facet.update(dmi_uuid: 'existing_system_uuid')
          Setting[:host_profile_assume] = false

          error = assert_raises(Katello::Errors::RegistrationError) { @klass.validate_hosts(hosts, @org, @host.name, 'different-uuid') }
          assert_match(/DMI UUID that differs/, error.message)

          # if a registering client is matched by hostname to an existing profile
          # but its UUID has changed *and* is still unique, allow the registration when enabled
          Setting[:host_profile_assume] = true

          assert @klass.validate_hosts(hosts, @org, @host.name, 'different-uuid')
        end

        def test_host_profile_assume_build_mode_only_not_in_build
          @host.subscription_facet.update(dmi_uuid: 'existing_system_uuid')
          Setting[:host_profile_assume] = false
          Setting[:host_profile_assume_build_can_change] = true
          refute @host.build
          error = assert_raises(Katello::Errors::RegistrationError) { @klass.validate_hosts(hosts, @org, @host.name, 'different-uuid') }
          assert_match(/DMI UUID that differs/, error.message)
        end

        def test_host_profile_assume_build_mode_only_in_build
          Setting[:host_profile_assume] = false
          Setting[:host_profile_assume_build_can_change] = true
          @host = FactoryBot.create(:host, :with_subscription, :managed, organization: @org, build: true)
          @host.subscription_facet.update(dmi_uuid: 'existing_system_uuid')
          # if a registering client is matched by hostname to an existing profile
          # but its UUID has changed *and* is still unique, also it is in build mode
          # then allow the registration when enabled
          assert @klass.validate_hosts(hosts, @org, @host.name, 'different-uuid')
        end

        def test_re_register_build_mode
          @host = FactoryBot.create(:host, :with_subscription, :managed, organization: @org)
          @host.subscription_facet.update(dmi_uuid: 'existing_system_uuid')
          refute @host.build
          Setting[:host_re_register_build_only] = true

          error = assert_raises(Katello::Errors::RegistrationError) { @klass.validate_hosts(hosts, @org, @host.name, nil) }
          assert_match(/currently registered/, error.message)

          @host.update(build: true)
          assert @klass.validate_hosts(hosts, @org, @host.name, 'existing_system_uuid')
        end

        def test_existing_uuid_and_name
          @host.subscription_facet.update(dmi_uuid: 'host3-uuid')

          assert @klass.validate_hosts(hosts, @org, @host.name, 'host3-uuid')
        end

        def test_build_matching_hostname_new_uuid
          @host = FactoryBot.create(:host, :with_subscription, :managed, organization: @org, build: true)
          @host.subscription_facet.update(dmi_uuid: SecureRandom.uuid)

          assert @klass.validate_hosts(hosts, @org, @host.name, 'different-uuid')
        end

        def test_existing_host_null_uuid
          # this test case is critical for bootstrap.py which creates a host via API (which lacks the dmi uuid fact)
          # and *then* registers to it with subscription-manager
          assert_empty @host.fact_values

          assert @klass.validate_hosts(hosts, @org, @host.name, 'different-uuid')
        end
      end

      def test_determine_host_dmi_uuid_unique
        result = Katello::RegistrationManager.determine_host_dmi_uuid(facts: {'dmi.system.uuid' => 'unique-dmi-uuid'})

        assert_equal ['unique-dmi-uuid', false], result
      end

      def test_determine_host_dmi_uuid_duplicate
        Setting[:host_dmi_uuid_duplicates] = ['duplicate-dmi-uuid']

        SecureRandom.stubs(:uuid).returns('generated-uuid')

        result = Katello::RegistrationManager.determine_host_dmi_uuid(facts: {'dmi.system.uuid' => 'duplicate-dmi-uuid'})

        assert_equal ['generated-uuid', true], result
      end

      def test_find_existing_hosts
        fact_host = FactoryBot.create(:host, :with_subscription)

        # matching dmi.system.uuid OR hostname
        fact_host.subscription_facet.update(dmi_uuid: 'some-uuid')
        result = Katello::RegistrationManager.find_existing_hosts(@host.name, 'some-uuid')

        assert_equal [@host, fact_host].sort, result.sort

        # nil & allowed duplicate uuids
        [nil] + Katello::Host::SubscriptionFacet::DMI_UUID_ALLOWED_DUPS.each do |dup|
          fact_host.subscription_facet.update(dmi_uuid: dup)
          result = Katello::RegistrationManager.find_existing_hosts('inexistent_host', dup)
          assert_empty result
        end
      end

      def test_process_registration_activation_keys
        Location.expects(:default_host_subscribe_location!).returns(nil)
        host = mock(organization: @org)
        ::Katello::RegistrationManager.expects(:new_host_from_facts).with(rhsm_params[:facts], @org, nil).returns(host)
        ::Katello::RegistrationManager.expects(:register_host).with(host, rhsm_params, nil, [@activation_key])

        ::Katello::RegistrationManager.process_registration(rhsm_params, nil, [@activation_key])
      end

      def test_process_registration_new_host
        Location.expects(:default_host_subscribe_location!).returns(nil)
        host = mock(organization: @org)
        ::Katello::RegistrationManager.expects(:new_host_from_facts).with(rhsm_params[:facts], @org, nil).returns(host)
        ::Katello::RegistrationManager.expects(:register_host).with(host, rhsm_params, [@content_view_environment], [])

        ::Katello::RegistrationManager.process_registration(rhsm_params, [@content_view_environment])
      end

      def test_process_registration_existing_host
        host = FactoryBot.create(:host, :with_content, :organization_id => @org.id)
        @facts = {'network.hostname' => host.name}
        ::Host::Managed.any_instance.stubs(:refresh_statuses)

        ::Katello::RegistrationManager.expects(:register_host).with(host, rhsm_params, [@content_view_environment], [])

        ::Katello::RegistrationManager.process_registration(rhsm_params, [@content_view_environment])
      end

      def test_process_registration_uuid_override
        host = FactoryBot.create(:host, :with_subscription, :organization_id => @org.id)
        @facts = {'network.hostname' => host.name, 'dmi.system.uuid' => 'duplicate-dmi-uuid'}

        Setting[:host_dmi_uuid_duplicates] = ['duplicate-dmi-uuid']

        ::Katello::RegistrationManager.expects(:register_host).with(host, rhsm_params, [@content_view_environment], [])

        ::Katello::RegistrationManager.process_registration(rhsm_params, [@content_view_environment])

        assert host.subscription_facet.dmi_uuid_override
      end

      def test_registration
        new_host = ::Host::Managed.new(:name => 'foobar.example.com', :managed => false, :organization => @library.organization)

        ::Katello::RegistrationManager.expects(:get_uuid).returns("fake-uuid-from-katello")

        ::Katello::Resources::Candlepin::Consumer.expects(:create).with([@content_view_environment.cp_id], rhsm_params, [], @library.organization).returns(:uuid => 'fake-uuid-from-candlepin')
        ::Katello::Resources::Candlepin::Consumer.expects(:get).once.with('fake-uuid-from-candlepin').returns({})
        ::Katello::Host::SubscriptionFacet.any_instance.expects(:update_hypervisor).twice
        ::Katello::Host::SubscriptionFacet.any_instance.expects(:update_guests).twice
        ::Organization.any_instance.stubs(:simple_content_access?).returns(false)

        ::Host::Managed.any_instance.stubs(:refresh_statuses)
        ::Katello::RegistrationManager.register_host(new_host, rhsm_params, [@content_view_environment])

        assert_equal new_host.subscription_facet.uuid, 'fake-uuid-from-candlepin'
      end

      def test_registration_activation_key
        new_host = ::Host::Managed.new(:name => 'foobar.example.com', :managed => false, :organization => @host_collection.organization)
        cvpe = Katello::ContentViewEnvironment.where(:content_view_id => @activation_key.content_view, :environment_id => @activation_key.environment).first

        ::Katello::RegistrationManager.expects(:get_uuid).returns("fake-uuid-from-katello")

        ::Katello::Resources::Candlepin::Consumer.expects(:create).with([cvpe.cp_id], rhsm_params, ["cp_name_baz"], @host_collection.organization).returns(:uuid => 'fake-uuid-from-katello')
        Katello::ActivationKey.any_instance.stubs(:cp_name).returns('cp_name_baz')
        ::Katello::Resources::Candlepin::Consumer.expects(:get).once.with('fake-uuid-from-katello').returns({})
        ::Katello::Host::SubscriptionFacet.any_instance.expects(:update_hypervisor).twice
        ::Katello::Host::SubscriptionFacet.any_instance.expects(:update_guests).twice
        ::Host::Managed.any_instance.stubs(:refresh_statuses)

        ::Organization.any_instance.stubs(:simple_content_access?).returns(false)

        ::Katello::RegistrationManager.register_host(new_host, rhsm_params, [cvpe], [@activation_key])

        new_host_cve = new_host.content_facet.content_view_environments.first
        assert_equal @activation_key.environment, new_host_cve.lifecycle_environment
        assert_equal @activation_key.content_view, new_host_cve.content_view

        assert_includes new_host.host_collections, @host_collection
      end

      def test_registration_with_host_collection_max_hosts_exceeded
        @activation_key.host_collections << @one_host_limit_host_collection
        existing_host = ::Host::Managed.create(:name => 'alreadyhere.example.com', :managed => false, :organization => @one_host_limit_host_collection.organization)
        new_host = ::Host::Managed.new(:name => 'foobar.example.com', :managed => false, :organization => @one_host_limit_host_collection.organization)
        cvpe = Katello::ContentViewEnvironment.where(:content_view_id => @activation_key.content_view, :environment_id => @activation_key.environment).first
        @one_host_limit_host_collection.hosts << existing_host
        assert_equal 1, @one_host_limit_host_collection.hosts.count
        assert_equal 1, @one_host_limit_host_collection.max_hosts

        assert_raises(RuntimeError, "Host collection 'Single-host Collection' exceeds maximum usage limit of '1'") do
          ::Katello::RegistrationManager.register_host(new_host, rhsm_params, [cvpe], [@activation_key])
        end

        refute_includes new_host.host_collections, @host_collection
      end

      def test_registration_existing_host
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)
        @host.expects(:update_candlepin_associations)
        ::Katello::Resources::Candlepin::Consumer.expects(:destroy)
        ::Katello::Host::SubscriptionFacet.any_instance.expects(:update_hypervisor).twice
        ::Katello::Host::SubscriptionFacet.any_instance.expects(:update_guests).twice
        ::Katello::RegistrationManager.expects(:get_uuid).returns("fake-uuid-from-katello")
        ::Host::Managed.any_instance.stubs(:refresh_statuses)

        ::Katello::Resources::Candlepin::Consumer.expects(:create).with([@content_view_environment.cp_id], rhsm_params, [], @content_view.organization).returns(:uuid => 'fake-uuid-from-katello')
        ::Katello::Resources::Candlepin::Consumer.expects(:get).once.with('fake-uuid-from-katello').returns({})

        ::Organization.any_instance.stubs(:simple_content_access?).returns(false)

        ::Katello::RegistrationManager.register_host(@host, rhsm_params, [@content_view_environment])
      end

      def test_unregister_host
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)
        ::Host::Managed.any_instance.stubs(:refresh_statuses)
        ::Katello::Resources::Candlepin::Consumer.expects(:destroy)
        ::Katello::EventQueue.expects(:push_event).never
        ::Katello::RegistrationManager.unregister_host(@host, :unregistering => true)
      end

      def test_destroy_host
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        ::Host.expects(:find).returns(@host)
        ::Katello::Resources::Candlepin::Consumer.expects(:destroy)

        @host.expects(:destroy).returns(true)

        ::Katello::RegistrationManager.unregister_host(@host)
      end

      def test_unregister_host_rhsm_facts
        FactValue.create!(value: 'something', host: @host, fact_name: RhsmFactName.create(name: 'some-fact'))

        ::Katello::RegistrationManager.unregister_host(@host, unregistering: true)

        assert_empty @host.rhsm_fact_values
      end

      def test_unregister_host_resets_content_source
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                    :lifecycle_environment => @library, :organization => @content_view.organization)
        pulp3_proxy = FactoryBot.create(:smart_proxy, :with_pulp3)
        @host.content_facet.update(:content_source_id => pulp3_proxy.id)
        ::Katello::Resources::Candlepin::Consumer.expects(:destroy)

        ::Katello::RegistrationManager.unregister_host(@host, unregistering: true)

        refute_nil @host.content_facet.content_source
        assert_equal ::SmartProxy.pulp_primary, @host.content_facet.content_source
      end

      def test_destroy_host_not_found
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        ::Host.expects(:find).returns(@host)
        ::Katello::Resources::Candlepin::Consumer.expects(:destroy).raises(RestClient::ResourceNotFound)

        @host.expects(:destroy).returns(true)

        ::Katello::RegistrationManager.unregister_host(@host)
      end

      def test_destroy_host_organization_delete
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        ::Katello::Resources::Candlepin::Consumer.expects(:destroy).never

        @host.expects(:destroy).never

        ::Katello::RegistrationManager.unregister_host(@host, :organization_destroy => true)
      end

      def test_unregister_host_dead_candlepin
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        ::Katello::Resources::Candlepin::Consumer.expects(:destroy).raises(Exception)

        assert_raises(Exception) do
          ::Katello::RegistrationManager.unregister_host(@host, :unregistering => true)
        end
      end

      def test_registration_dead_candlepin
        new_host = ::Host::Managed.new(:name => 'foobar.example.com', :managed => false, :organization => @library.organization)

        ::Host.expects(:find).returns(new_host)
        new_host.expects(:destroy)
        new_host.organization.stubs(:simple_content_access?).returns(false)
        ::Katello::Resources::Candlepin::Consumer.expects(:create).with([@content_view_environment.cp_id], rhsm_params, [], @library.organization).raises("uhoh!")

        assert_raises(Exception) do
          ::Katello::RegistrationManager.register_host(new_host, rhsm_params, [@content_view_environment])
        end
      end

      # this case can only happen if candlepin/pulp dies after the host is unregistered, but before it's re-registered.
      def test_registration_existing_host_dead_backend_service
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)
        @host.expects(:update_candlepin_associations)
        @host.content_facet.expects(:destroy).never
        @host.expects(:destroy).never

        ::Katello::RegistrationManager.expects(:remove_host_artifacts).twice # once on original unregister, once again after failure during re-reg
        ::Katello::RegistrationManager.expects(:remove_partially_registered_new_host).never
        ::Katello::Resources::Candlepin::Consumer.expects(:create).with([@content_view_environment.cp_id], rhsm_params, [], @content_view.organization).raises("uhoh!")
        ::Katello::Resources::Candlepin::Consumer.expects(:destroy)

        ::Organization.any_instance.stubs(:simple_content_access?).returns(false)

        assert_raises(Exception) do
          ::Katello::RegistrationManager.register_host(@host, rhsm_params, [@content_view_environment])
        end
      end
    end
  end
end
