#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
