require 'katello_test_helper'

module Katello
  module Service
    class RegistrationManagerTestBase < ActiveSupport::TestCase
      def setup
        User.current = User.find(FIXTURES['users']['admin']['id'])

        VCR.insert_cassette('services/katello')
      end

      def teardown
        VCR.eject_cassette
      end
    end

    class RegistrationManager < RegistrationManagerTestBase
      include FactImporterIsolation
      allow_transactions_for_any_importer

      before :all do
        User.current = users(:admin)
        @content_view = katello_content_views(:library_dev_view)
        @library = katello_environments(:library)
        @content_view_environment = katello_content_view_environments(:library_dev_view_library)
        @activation_key = katello_activation_keys(:library_dev_staging_view_key)
        @host_collection = katello_host_collections(:simple_host_collection)
        @activation_key.host_collections << @host_collection
      end

      let(:rhsm_params) { {:name => 'foobar', :facts => {'a' => 'b'}, :type => 'system'} }

      def test_registration
        new_host = ::Host::Managed.new(:name => 'foobar', :managed => false, :organization => @library.organization)

        ::Katello::RegistrationManager.expects(:get_uuid).returns("fake-uuid-from-katello")

        ::Katello::Resources::Candlepin::Consumer.expects(:create).with(@content_view_environment.cp_id, rhsm_params, []).returns(:uuid => 'fake-uuid-from-katello')
        ::Katello::Resources::Candlepin::Consumer.expects(:get).twice.with('fake-uuid-from-katello').returns({})
        ::Runcible::Extensions::Consumer.any_instance.expects(:create).with('fake-uuid-from-katello', :display_name => 'foobar')

        ::Katello::RegistrationManager.register_host(new_host, rhsm_params, @content_view_environment)
      end

      def test_registration_activation_key
        new_host = ::Host::Managed.new(:name => 'foobar', :managed => false, :organization => @host_collection.organization)
        cvpe = Katello::ContentViewEnvironment.where(:content_view_id => @activation_key.content_view, :environment_id => @activation_key.environment).first

        ::Katello::RegistrationManager.expects(:get_uuid).returns("fake-uuid-from-katello")

        ::Katello::Resources::Candlepin::Consumer.expects(:create).with(cvpe.cp_id, rhsm_params, ["cp_name_baz"]).returns(:uuid => 'fake-uuid-from-katello')
        Katello::ActivationKey.any_instance.stubs(:cp_name).returns('cp_name_baz')
        ::Katello::Resources::Candlepin::Consumer.expects(:get).twice.with('fake-uuid-from-katello').returns({})
        ::Runcible::Extensions::Consumer.any_instance.expects(:create).with('fake-uuid-from-katello', :display_name => 'foobar')

        ::Katello::RegistrationManager.register_host(new_host, rhsm_params, cvpe, [@activation_key])

        assert_equal @activation_key.environment, new_host.content_facet.lifecycle_environment
        assert_equal @activation_key.content_view, new_host.content_facet.content_view

        assert_includes new_host.host_collections, @host_collection
      end

      def test_registration_existing_host
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        ::Katello::Resources::Candlepin::Consumer.expects(:destroy)
        ::Runcible::Extensions::Consumer.any_instance.expects(:delete)

        ::Katello::RegistrationManager.expects(:get_uuid).returns("fake-uuid-from-katello")

        ::Katello::Resources::Candlepin::Consumer.expects(:create).with(@content_view_environment.cp_id, rhsm_params, []).returns(:uuid => 'fake-uuid-from-katello')
        ::Katello::Resources::Candlepin::Consumer.expects(:get).twice.with('fake-uuid-from-katello').returns({})
        ::Runcible::Extensions::Consumer.any_instance.expects(:create)

        ::Katello::RegistrationManager.register_host(@host, rhsm_params, @content_view_environment)
      end

      def test_unregister_host
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        ::Katello::Resources::Candlepin::Consumer.expects(:destroy)
        ::Runcible::Extensions::Consumer.any_instance.expects(:delete)

        ::Katello::RegistrationManager.unregister_host(@host, :unregistering => true)
      end

      def test_destroy_host
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        ::Katello::Resources::Candlepin::Consumer.expects(:destroy)
        ::Runcible::Extensions::Consumer.any_instance.expects(:delete)

        @host.expects(:destroy).returns(true)

        ::Katello::RegistrationManager.unregister_host(@host)
      end

      def test_destroy_host_organization_delete
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        ::Katello::Resources::Candlepin::Consumer.expects(:destroy).never
        ::Runcible::Extensions::Consumer.any_instance.expects(:delete)

        @host.expects(:destroy).never

        ::Katello::RegistrationManager.unregister_host(@host, :organization_destroy => true)
      end

      def test_unregister_host_dead_candlepin
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        ::Katello::Resources::Candlepin::Consumer.expects(:destroy).raises(Exception)
        ::Runcible::Extensions::Consumer.any_instance.expects(:delete).never

        failed = lambda do
          ::Katello::RegistrationManager.unregister_host(@host, :unregistering => true)
        end

        failed.must_raise(Exception)
      end

      def test_unregister_host_dead_pulp
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        ::Katello::Resources::Candlepin::Consumer.expects(:destroy)
        ::Runcible::Extensions::Consumer.any_instance.expects(:delete).raises(Exception)

        failed = lambda do
          ::Katello::RegistrationManager.unregister_host(@host, :unregistering => true)
        end

        failed.must_raise(Exception)
      end

      def test_registration_dead_candlepin
        new_host = ::Host::Managed.new(:name => 'foobar', :managed => false, :organization => @library.organization)

        new_host.expects(:destroy!)
        ::Katello::Resources::Candlepin::Consumer.expects(:create).with(@content_view_environment.cp_id, rhsm_params, []).raises("uhoh!")
        ::Runcible::Extensions::Consumer.any_instance.expects(:create).with('fake-uuid', :display_name => 'foobar').never

        failed = lambda do
          ::Katello::RegistrationManager.register_host(new_host, rhsm_params, @content_view_environment)
        end

        failed.must_raise(Exception)
      end

      def test_registration_dead_pulp
        new_host = ::Host::Managed.new(:name => 'foobar', :managed => false, :organization => @library.organization)

        ::Katello::RegistrationManager.expects(:remove_host_artifacts).never
        ::Katello::RegistrationManager.expects(:remove_partially_registered_new_host)
        ::Katello::Resources::Candlepin::Consumer.expects(:create).with(@content_view_environment.cp_id, rhsm_params, []).returns(:uuid => 'fake-uuid')
        ::Katello::Resources::Candlepin::Consumer.expects(:destroy).with("fake-uuid")
        ::Runcible::Extensions::Consumer.any_instance.expects(:create).with('fake-uuid', :display_name => 'foobar').raises("uhoh!")

        failed = lambda do
          ::Katello::RegistrationManager.register_host(new_host, rhsm_params, @content_view_environment)
        end

        failed.must_raise(Exception)
      end

      # this case can only happen if candlepin/pulp dies after the host is unregistered, but before it's re-registered.
      def test_registration_existing_host_dead_backend_service
        @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                   :lifecycle_environment => @library, :organization => @content_view.organization)

        @host.content_facet.expects(:destroy).never
        @host.expects(:destroy).never
        ::Katello::RegistrationManager.expects(:remove_host_artifacts).twice # once on original unregister, once again after failure during re-reg
        ::Katello::RegistrationManager.expects(:remove_partially_registered_new_host).never
        ::Katello::Resources::Candlepin::Consumer.expects(:create).with(@content_view_environment.cp_id, rhsm_params, []).raises("uhoh!")
        ::Katello::Resources::Candlepin::Consumer.expects(:destroy)
        ::Runcible::Extensions::Consumer.any_instance.expects(:create).never
        ::Runcible::Extensions::Consumer.any_instance.expects(:delete)

        failed = lambda do
          ::Katello::RegistrationManager.register_host(@host, rhsm_params, @content_view_environment)
        end

        failed.must_raise(Exception)
      end
    end
  end
end
