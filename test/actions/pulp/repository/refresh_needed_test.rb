require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
  class RefreshNeededTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:action_class) { ::Actions::Pulp::Repository::RefreshNeeded }

    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)

      ping = {}
      [:pulp, :pulp_auth, :candlepin, :candlepin_auth, :foreman_tasks].each do |service|
        ping[service] = {}
        ping[service][:status] = ::Katello::Ping::OK_RETURN_CODE
      end

      ::Katello::Ping.stubs(:ping).returns(:services => ping)
    end

    describe 'Refresh Needed' do
      let(:planned_action) do
        create_and_plan_action action_class, SmartProxy.pulp_master
      end

      it 'runs' do
        ::Katello::Pulp::SmartProxyRepository.any_instance.expects(:repos_needing_updates).returns([repo])
        repo.backend_service(SmartProxy.pulp_master).expects(:refresh).once.returns([])
        run_action planned_action
      end
    end
  end
end
