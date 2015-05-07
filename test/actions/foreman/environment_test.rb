require 'katello_test_helper'

module ::Actions::Foreman::Environment
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }

    before :all do
      @production = environments(:production)
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Foreman::Environment::Destroy }
    let(:product) do
      katello_products(:fedora)
    end

    it 'fails to destroy when there are hosts' do
      FactoryGirl.create(:host, :environment => @production)
      assert @production.hosts.count > 0

      @production.hostgroups = []
      assert_raises RuntimeError do
        plan_action(action, @production)
      end
    end

    it 'fails to destroy when there are host groups' do
      assert @production.hostgroups.count > 0

      @production.hosts = []
      assert_raises RuntimeError do
        plan_action(action, @production)
      end
    end

    it 'destroys the environment' do
      env = ::Environment.create(:name => "subdev")
      assert plan_action(action, env)
    end
  end
end
