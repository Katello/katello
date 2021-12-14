require 'katello_test_helper'

module Actions
  describe Katello::Repository::BulkMetadataGenerate do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::BulkMetadataGenerate }
    let(:metadata_gen) { ::Actions::Katello::Repository::MetadataGenerate }
    let(:bulk_action) { ::Actions::BulkAction }
    let(:yum_repo) { katello_repositories(:rhel_6_x86_64_dev) }
    let(:yum_repo2) { katello_repositories(:rhel_6_x86_64_dev_archive) }

    it 'plans a yum refresh' do
      action = create_action(action_class)
      query = ::Katello::Repository.where(:id => [yum_repo.id, yum_repo2.id])

      plan_action(action, query, :force => true)

      assert_action_planned_with(action, bulk_action, metadata_gen, query.archived, :force => true)
      assert_action_planned_with(action, bulk_action, metadata_gen, query.in_published_environments, :force => true)
    end
  end
end
