require 'katello_test_helper'

module ::Actions::Katello::Applicability::Repository
  class RepositoryRegenerateApplicabilityTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryBot.build(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                               :lifecycle_environment => katello_environments(:library))
      @host.save!
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      SETTINGS[:katello][:katello_applicability] = true
    end

    after :all do
      SETTINGS[:katello][:katello_applicability] = false
    end

    describe 'Repository Regenerate Applicability using Katello Applicability' do
      let(:action_class) { ::Actions::Katello::Applicability::Repository::Regenerate }

      it 'runs' do
        Katello::Repository.any_instance.stubs(:hosts_with_applicability).returns([@host])
        Katello::ApplicableHostQueue.expects(:push_host).with(@host.id)
        Katello::EventQueue.expects(:push_event).with(::Katello::Events::GenerateHostApplicability::EVENT_TYPE, 0)

        ForemanTasks.sync_task(action_class, :repo_id => @repo.id)
      end
    end
  end
end
