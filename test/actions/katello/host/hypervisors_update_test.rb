require 'katello_test_helper'

module Katello::Host
  class HypervisorsUpdateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
    include FactImporterIsolation
    allow_transactions_for_any_importer

    before :each do
      User.current = users(:admin)
      @organization = FactoryBot.build(:katello_organization)
      location = taxonomies(:location1)
      Setting[:default_location_puppet_content] = location.title
      Setting[:default_location_subscribed_hosts] = location.title

      @content_view = katello_content_views(:library_dev_view)
      @content_view_environment = katello_content_view_environments(:library_dev_view_library)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns(nil)

      @host = FactoryBot.create(:host, :with_subscription, :content_view => @content_view,
                                :lifecycle_environment => @content_view_environment, :organization => @organization)

      old_name = @host.name
      @hypervisor_name = "virt-who-#{@host.name}-#{@organization.id}"
      @host.update!(:name => @hypervisor_name)
      @hypervisor_results = [{ :name => old_name, :uuid => @host.subscription_facet.uuid, :organization_label => @organization.label }]
      @facts = {
        'hypervisor.type': 'VMware ESXi',
        'cpu.cpu_socket(s)' => '2',
        'hypervisor.version' => '6.7.0'
      }.with_indifferent_access
      @consumer = {
        uuid: @host.subscription_facet.uuid,
        entitlementStatus: Katello::SubscriptionStatus::UNKNOWN,
        guestIds: ['test-id-1'],
        entitlementCount: 0,
        facts: @facts,
        hypervisorId: {hypervisorId: old_name}
      }.with_indifferent_access
      ::Katello::Resources::Candlepin::Consumer.stubs(:get_all_with_facts).returns([@consumer])
    end

    let(:action_class) { ::Actions::Katello::Host::Hypervisors }

    describe 'Hypervisors Update' do
      it 'new hypervisor' do
        @host.subscription_facet.destroy!
        @host.destroy!

        ::Katello::Resources::Candlepin::Consumer.expects(:virtual_guests).never

        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)

        plan_action(action, :hypervisors => @hypervisor_results)
        action = run_action(action)

        assert_equal :success, action.state

        @host = Host.find_by(:name => @hypervisor_name)
        assert_not_nil @host.subscription_facet
        assert_equal @facts['hypervisor.type'], @host.facts['hypervisor::type']
      end

      it 'update guests hypervisor' do
        guests = []
        original_host = FactoryBot.create(:host, :with_subscription, :content_view => @content_view,
                                          :lifecycle_environment => @content_view_environment, :organization => @organization)

        3.times do
          guests << FactoryBot.create(:host, :with_subscription, :content_view => @content_view,
                                      :lifecycle_environment => @content_view_environment, :organization => @organization)
        end

        guests.first.subscription_facet.update!(:hypervisor_host_id => original_host.id)
        guests.sort!
        guest_uuids = guests.map { |guest| { 'uuid' => guest.subscription_facet.uuid } }

        # Delete :guestIds to make katello to fetch the virtual guests from Candlepin
        @consumer.delete(:guestIds)
        ::Katello::Resources::Candlepin::Consumer.expects(:virtual_guests).once.returns(guest_uuids)

        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)
        plan_action(action, :hypervisors => @hypervisor_results)
        action = run_action(action)

        assert_equal :success, action.state
        assert_equal guests, @host.subscription_facet.virtual_guests.sort
      end

      it 'existing hypervisor, no facet' do
        @host.subscription_facet.delete
        @host.save!
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)

        plan_action(action, :hypervisors => @hypervisor_results)
        action = run_action(action)

        assert_equal :success, action.state

        @host.reload
        assert_not_nil @host.subscription_facet
        assert_equal @facts['hypervisor.type'], @host.facts['hypervisor::type']
      end

      it 'existing hypervisor, renamed' do
        @hypervisor_results[0][:name] = 'hypervisor.renamed'
        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)

        plan_action(action, :hypervisors => @hypervisor_results)
        assert_difference('::Katello::Host::SubscriptionFacet.count', 0) do
          action = run_action(action)
        end

        assert_equal :success, action.state
      end

      it 'existing hypervisor, no org' do
        @host.organization = nil
        @host.save!

        action = create_action(::Actions::Katello::Host::HypervisorsUpdate)

        plan_action(action, :hypervisors => @hypervisor_results)
        exception = assert_raises(RuntimeError) do
          run_action(action)
        end

        assert_equal "Host '#{@host.name}' does not belong to an organization", exception.message
      end
    end
  end
end
