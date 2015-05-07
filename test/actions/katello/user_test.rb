require 'katello_test_helper'

module ::Actions::Katello::User
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    actions = [Create, Destroy]

    actions.each do |action_class|
      describe action_class.to_s.demodulize do
        let(:action_class) { action_class }

        it 'plans' do
          user   = stub('cp',
                        remote_id:             'stubbed_user',
                        disable_auto_reindex!: true)
          action = create_action action_class
          action.stubs(:action_subject).with(user)
          plan_action(action, user)

          case action_class
          when Create
            assert_action_planed_with(action,
                                      ::Actions::Pulp::User::Create,
                                      remote_id: 'stubbed_user')
            assert_action_planed_with(action,
                                      ::Actions::Pulp::Superuser::Add,
                                      remote_id: 'stubbed_user')
          when Destroy
            assert_action_planed_with(action,
                                      ::Actions::Pulp::User::Destroy,
                                      remote_id: 'stubbed_user')
            assert_action_planed_with(action,
                                      ::Actions::Pulp::Superuser::Remove,
                                      remote_id: 'stubbed_user')
          end
        end
      end
    end
  end
end
