require 'katello_test_helper'

module Katello
  class RegistrationInterfaceFactsControllerTest < ActionController::TestCase
    tests ::Api::V2::RegistrationController

    include FactImporterIsolation
    allow_transactions_for_any_importer

    def test_registration_can_select_a_secondary_interface_imported_from_facts # rubocop:disable Metrics/MethodLength
      skip 'Requires foreman_remote_execution' unless
        Foreman::Plugin.installed?(:foreman_remote_execution)

      setup_controller_defaults(false)
      setup_foreman_routes
      login_user(User.find(users(:admin).id))

      Setting[:ignore_puppet_facts_for_provisioning] = false
      Setting[:ignored_interface_identifiers] = ['lo']
      Setting[:excluded_facts] = []

      cvenv = katello_content_view_environments(:library_dev_view_library)
      organization = cvenv.content_view.organization
      location = taxonomies(:location1)
      uuid = SecureRandom.uuid

      template = FactoryBot.create(
        :provisioning_template,
        template_kind: template_kinds(:host_init_config),
        template: 'echo registration complete',
        organizations: [organization],
        locations: [location]
      )

      # Template selection is independent of interface discovery.
      ::Host::Managed.any_instance.stubs(:initial_configuration_template).returns(template)
      ::Host::Managed.any_instance.stubs(:refresh_statuses)
      ::Katello::Host::SubscriptionFacet.any_instance.stubs(:update_hypervisor)
      ::Katello::Host::SubscriptionFacet.any_instance.stubs(:update_guests)

      ::Katello::Resources::Candlepin::Consumer.stubs(:create).returns(
        {'uuid' => uuid}.with_indifferent_access
      )
      ::Katello::Resources::Candlepin::Consumer.stubs(:update)
      Resolv::DNS.any_instance.stubs(:getnames).returns([])

      host = ::Host::Managed.new(
        name: 'registration-rex.example.com',
        organization: organization,
        location: location,
        managed: false,
        build: false
      )

      # Do not create NICs with factories: registration must discover them.
      ::Katello::RegistrationManager.register_host(
        host,
        {
          name: host.name,
          uuid: uuid,
          type: 'system',
          facts: {
            'distribution.name' => 'Red Hat Enterprise Linux',
            'distribution.version' => '10.0',
            'uname.machine' => 'x86_64',
            'net.interface.enp1s0.mac_address' => '02:00:00:00:00:10',
            'net.interface.enp1s0.ipv4_address' => '192.0.2.10',
            'net.interface.enp2s0.mac_address' => '02:00:00:00:00:20',
            'net.interface.enp2s0.ipv4_address' => '198.51.100.20',
          },
        }.with_indifferent_access,
        [cvenv]
      )

      # This is the subsequent request made by global registration.
      post :host,
        params: {
          uuid: uuid,
          host: {managed: false, build: false},
          remote_execution_interface: 'enp2s0',
        },
        session: set_session_user

      assert_response :success
      assert_equal 'echo registration complete', response.body

      host.reload
      assert_equal 'enp1s0', host.primary_interface.identifier
      assert_equal(
        %w[enp1s0 enp2s0],
        host.interfaces.order(:identifier).pluck(:identifier)
      )
      assert_equal(
        ['enp2s0'],
        host.interfaces.where(execution: true).pluck(:identifier)
      )
    end
  end     # rubocop:enable Metrics/MethodLength
end
