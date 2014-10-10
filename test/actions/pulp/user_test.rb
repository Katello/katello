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

class Actions::Pulp::UserTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction
  include VCR::TestCase

  def vcr_matches
    [:method, :path, :params]
  end

  def setup
    planned_action = create_and_plan_action ::Actions::Pulp::User::Create,
      remote_id: 'user_id'

    response = run_action planned_action
    assert_equal :success, response.state
  end

  def teardown
    configure_runcible
    ::Katello.pulp_server.resources.user.delete('user_id')
  rescue RestClient::ResourceNotFound => e
    puts "Failed to delete user #{e.message}"
  end

  def test_create
    configure_runcible
    user = ::Katello.pulp_server.resources.user.retrieve('user_id')
    refute_nil user
    assert_equal 'user_id', user[:login]
  end

  [::Actions::Pulp::Superuser::Add,
   ::Actions::Pulp::Superuser::Remove
  ].each do |action|
    method = action.to_s.demodulize.downcase
    define_method("test_super_user_#{method}") do
      planned_action = create_and_plan_action action,
        remote_id: 'user_id'

      response = run_action planned_action
      assert_equal :success, response.state
    end
  end
end
