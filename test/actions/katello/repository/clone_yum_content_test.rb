require 'katello_test_helper'

module Actions
  describe Katello::Repository::CloneYumContent do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::CloneYumContent }
    let(:source_repo) { katello_repositories(:rhel_6_x86_64_dev_archive) }
    let(:target_repo) { katello_repositories(:rhel_6_x86_64_dev) }

    it 'plans to copy rpms' do
      action = create_action(action_class)
      source_repo = katello_repositories(:rhel_6_x86_64_dev_archive)
      target_repo = katello_repositories(:rhel_6_x86_64_dev)

      plan_action(action, source_repo, target_repo, [], :purge_empty_units => false)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopySrpm, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyRpm, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyYumMetadataFile, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyDistribution, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyModuleStream, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyModuleDefault, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
    end

    it 'plans to copy rpms with rpm_filenames' do
      action = create_action(action_class)
      source_repo = katello_repositories(:rhel_6_x86_64_dev_archive)
      source_repo.stubs(:rpms).returns([{ :filename => "rpm1.rpm" }, { :filename => "rpm2.rpm" }])
      target_repo = katello_repositories(:rhel_6_x86_64_dev)

      plan_action(action, source_repo, target_repo, [], :purge_empty_units => false, :rpm_filenames => ["rpm1.rpm", "rpm2.rpm"])

      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopySrpm, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyRpm, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => {"filename" => {"$in" => ["rpm1.rpm", "rpm2.rpm"]}})
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyYumMetadataFile, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyDistribution, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyModuleStream, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyModuleDefault, :source_pulp_id => source_repo.pulp_id, :target_pulp_id => target_repo.pulp_id, :clauses => nil)
    end
  end
end
