require 'katello_test_helper'

module Actions
  describe Katello::Repository::UpdateMetadataSync do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::UpdateMetadataSync }
    let(:metadata_generate_class) { ::Actions::Katello::Repository::MetadataGenerate }
    let(:capsule_sync_class) { ::Actions::Katello::CapsuleContent::Sync }
    let(:repo) { katello_repositories(:fedora_17_x86_64) }

    it 'plans' do
      action = create_action(action_class)
      primary = smart_proxies(:one)
      primary.expects(:pulp_primary?).returns(true)

      mirror = smart_proxies(:two)
      mirror.expects(:pulp_primary?).returns(false)

      SmartProxy.expects(:with_repo).with(repo).returns([primary, mirror])
      plan_action(action, repo)

      # primary capsule sync should get ignored
      assert_action_planned_with(action, capsule_sync_class, mirror, repository_id: repo.id)
      assert_action_planned_with(action, metadata_generate_class, repo)
    end
  end
end
