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
    end

    describe 'Repository Regenerate Applicability using Katello Applicability' do
      let(:action_class) { ::Actions::Katello::Applicability::Repository::Regenerate }

      it 'runs' do
        @repo.update(last_contents_changed: DateTime.now, last_applicability_regen: Time.at(0).to_datetime)
        Katello::RootRepository.stubs(:hosts_with_applicability).returns([@host])
        Katello::ApplicableHostQueue.expects(:push_hosts).with([@host.id])
        Katello::EventQueue.expects(:push_event).with(::Katello::Events::GenerateHostApplicability::EVENT_TYPE, 0)

        ForemanTasks.sync_task(action_class, :repo_ids => [@repo.id])
      end

      it 'runs on deb-repo' do
        repo = katello_repositories(:debian_10_amd64)
        repo.update(last_contents_changed: DateTime.now, last_applicability_regen: Time.at(0).to_datetime)
        Katello::RootRepository.stubs(:hosts_with_applicability).returns([@host])
        Katello::ApplicableHostQueue.expects(:push_hosts).with([@host.id])
        Katello::EventQueue.expects(:push_event).with(::Katello::Events::GenerateHostApplicability::EVENT_TYPE, 0)

        ForemanTasks.sync_task(action_class, :repo_ids => [repo.id])
      end

      it 'skips applicability triggering if not needed' do
        @repo.update(last_contents_changed: Time.at(0).to_datetime, last_applicability_regen: DateTime.now)
        Katello::RootRepository.stubs(:hosts_with_applicability).returns([@host])
        Katello::ApplicableHostQueue.expects(:push_hosts).never
        Katello::EventQueue.expects(:push_event).never

        ForemanTasks.sync_task(action_class, :repo_ids => [@repo.id])
      end
    end
  end
end
