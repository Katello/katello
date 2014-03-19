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

module ::Actions::Katello::Provider

  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let( :action ) { create_action action_class }
  end

  class CreateTest < TestBase
    let( :action_class ) { ::Actions::Katello::Provider::Create }
    let( :action ) { create_action action_class }

    let( :provider ) do
      katello_providers( :fedora_hosted )
    end
  end

  it 'plans' do
    provider.expects( :disable_auto_reindex ).returns
    provider.expects( :save! ).returns( [] )
    action.stubs( :action_subject ).with( provider )
    plan_action( action, provider )
  end

end
