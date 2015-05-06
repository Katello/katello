require 'katello_test_helper'

class Actions::Pulp::UserTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction
  include VCR::TestCase

  def vcr_matches
    [:method, :path, :params]
  end

  def setup
    set_user
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
