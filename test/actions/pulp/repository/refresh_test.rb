require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
  class RefreshTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:action_class) { ::Actions::Pulp::Repository::Refresh }

    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)

      ping = {}
      [:pulp, :pulp_auth, :candlepin, :candlepin_auth, :foreman_tasks].each do |service|
        ping[service] = {}
        ping[service][:status] = ::Katello::Ping::OK_RETURN_CODE
      end

      ::Katello::Ping.stubs(:ping).returns(:services => ping)
    end

    describe 'Refresh' do
      let(:planned_action) do
        create_and_plan_action action_class, repo, :capsule_id => SmartProxy.pulp_primary.id
      end

      let(:planned_action_without_capsule_id) do
        create_and_plan_action action_class, repo
      end

      it 'runs' do
        ::Katello::Repository.expects(:find_by).returns repo
        repo.backend_service(SmartProxy.pulp_primary).expects(:refresh_if_needed).once.returns([])
        run_action planned_action
      end

      it 'runs without a capsule ID (uses default proxy)' do
        ::Katello::Repository.expects(:find_by).returns repo
        repo.backend_service(SmartProxy.pulp_primary).expects(:refresh_if_needed).once.returns([])
        run_action planned_action_without_capsule_id
      end
    end
  end
end
