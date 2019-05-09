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
      master = smart_proxies(:one)
      master.expects(:pulp_master?).returns(true)

      mirror = smart_proxies(:two)
      mirror.expects(:pulp_master?).returns(false)

      SmartProxy.expects(:with_repo).with(repo).returns([master, mirror])
      plan_action(action, repo)

      # master capsule sync should get ignored
      assert_action_planed_with(action, capsule_sync_class, mirror, repository_id: repo.id)
      assert_action_planed_with(action, metadata_generate_class, repo)
    end
  end
end
