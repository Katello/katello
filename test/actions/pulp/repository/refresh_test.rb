require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
  class RefreshTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:action_class) { ::Actions::Pulp::Repository::Refresh }

    def setup
      FactoryGirl.create(:smart_proxy, :default_smart_proxy)

      ping = {}
      [:pulp, :pulp_auth, :candlepin, :candlepin_auth, :foreman_tasks].each do |service|
        ping[service] = {}
        ping[service][:status] = ::Katello::Ping::OK_RETURN_CODE
      end

      ::Katello::Ping.stubs(:ping).returns(:services => ping)
    end

    def test_with_no_capsule_id
      pulp_repo = {
        :importers => [{}],
        :distributors => []
      }.with_indifferent_access

      Runcible::Extensions::Repository.any_instance.expects(:retrieve_with_details).twice.returns(pulp_repo)

      create_and_plan_action(action_class, repo)
    end
  end
end
