require 'katello_test_helper'

module Actions
  describe Katello::Repository::CloneYumMetadata do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::CloneYumMetadata }
    let(:metadata_gen) { ::Actions::Katello::Repository::MetadataGenerate }
    let(:bulk_action) { ::Actions::BulkAction }
    let(:environment_repo) { katello_repositories(:rhel_6_x86_64_dev) }
    let(:archive_repo) { katello_repositories(:rhel_6_x86_64_dev_archive) }

    it 'plans to clone the metadata' do
      action = create_action(action_class)

      action.execution_plan.stub_planned_action(Katello::Repository::CheckMatchingContent) do |matching|
        matching.stubs(output: { :matching_content => false})
      end

      plan_action(action, archive_repo, environment_repo)

      matching_action = assert_action_planed_with(action, Katello::Repository::CheckMatchingContent,
                                :source_repo_id => archive_repo.id,
                                :target_repo_id => environment_repo.id)

      assert_action_planed_with(action, Katello::Repository::IndexContent, :id => environment_repo.id)

      assert_action_planed_with(action, Katello::Repository::MetadataGenerate, environment_repo,
                                :source_repository => archive_repo,
                                :matching_content => matching_action[0].output[:matching_content])
    end

    it 'plans to clone the metadata with force_yum_metadata_regeneration' do
      action = create_action(action_class)

      plan_action(action, archive_repo, environment_repo, :force_yum_metadata_regeneration => true)

      refute_action_planed(action, Katello::Repository::CheckMatchingContent)

      assert_action_planed_with(action, Katello::Repository::IndexContent, :id => environment_repo.id)

      assert_action_planed_with(action, Katello::Repository::MetadataGenerate, environment_repo,
                                :source_repository => archive_repo,
                                :matching_content => nil)
    end

    it 'plans to clone the metadata if unprotected changed' do
      action = create_action(action_class)
      environment_repo.update_attributes!(:unprotected => !environment_repo.unprotected)
      plan_action(action, archive_repo, environment_repo)

      refute_action_planed(action, Katello::Repository::CheckMatchingContent)

      assert_action_planed_with(action, Katello::Repository::IndexContent, :id => environment_repo.id)

      assert_action_planed_with(action, Katello::Repository::MetadataGenerate, environment_repo,
                                :source_repository => archive_repo,
                                :matching_content => nil)
    end
  end
end
