require 'katello_test_helper'

module Katello::Host
  class HypervisorsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @content_view = katello_content_views(:library_dev_view)
      @content_view_environment = katello_content_view_environments(:library_dev_view_library)
      @hypervisor_params = { 'hypervisor' => ['guest-1', 'guest-2'] }
      @hypervisor_response = {
        'created' => [{'uuid' => 1, 'name' => 'foo', 'extra' => 'stranger', 'owner' => {'key' => 'org-label'}}]
      }
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns(nil)
    end

    describe 'Hypervisors' do
      it 'plans' do
        action = create_action(::Actions::Katello::Host::Hypervisors)
        ::Katello::Resources::Candlepin::Consumer.expects(:register_hypervisors).with(@hypervisor_params).returns(@hypervisor_response)

        plan_action(action, @hypervisor_params)
        assert_action_planed_with(action, ::Actions::Katello::Host::HypervisorsUpdate) do |results, *_|
          results.must_equal(:hypervisors => [{:uuid => 1, :name => 'foo', :organization_label => 'org-label'}])
        end
      end

      it 'properly parses hypervisor response' do
        action = create_action(::Actions::Katello::Host::Hypervisors)
        owner = {'key' => 'org-label'}
        json = {
          'created' => [{'uuid' => 1, 'name' => 'foo1', 'extra' => 'stranger', 'owner' => owner}],
          'updated' => [{'uuid' => 2, 'name' => 'foo2', 'owner' => owner}],
          'unchanged' => [{'uuid' => 3, 'name' => 'foo3', 'owner' => owner}]
        }
        expected = [{:uuid => 1, :name => 'foo1', :organization_label => 'org-label'},
                    {:uuid => 2, :name => 'foo2', :organization_label => 'org-label'},
                    {:uuid => 3, :name => 'foo3', :organization_label => 'org-label'}]
        assert_equal expected, action.class.parse_hypervisors(json)
        assert_equal [], action.class.parse_hypervisors({})
      end
    end
  end

  class HypervisorsVcrTest < ActiveSupport::TestCase
    include VCR::TestCase

    def setup
      FactImporter.any_instance.stubs(:ensure_no_active_transaction).returns(true)
      Setting[:default_location_subscribed_hosts] = taxonomies(:location1).name
    end

    def org_exists(label)
      ::Katello::Resources::Candlepin::Owner.find(label)
    rescue
      false
    end

    def create_org(org_label)
      org = Organization.find_by(:label => org_label) || Organization.new(:name => org_label, :label => org_label)
      ForemanTasks.sync_task(::Actions::Candlepin::Owner::Destroy, :label => org_label) if org_exists(org_label)
      ForemanTasks.sync_task(::Actions::Katello::Organization::Create, org)
    end

    def test_duplicate_hostname
      org_label = 'duplicate_hostname_test'
      data = JSON.parse(File.read(File.join(Katello::Engine.root, 'test/fixtures/files/virt_who_duplicate_host.json')))
      data['owner'] = org_label
      data = data.with_indifferent_access
      create_org(org_label)
      org = Organization.find_by(label: org_label)

      assert_equal 0, org.hosts.count
      task = Katello::Resources::Candlepin::Consumer.async_hypervisors(org_label, data.to_json)
      action = ForemanTasks.sync_task(::Actions::Katello::Host::Hypervisors, nil, task_id: task['id'])

      assert_equal 'success', action.result
      assert_equal 2, org.reload.hosts.count
    end
  end
end
