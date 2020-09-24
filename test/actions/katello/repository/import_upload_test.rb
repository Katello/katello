require 'katello_test_helper'

module Actions
  describe Katello::Repository::ImportUpload do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::ImportUpload }
    let(:pulp_import_class) { ::Actions::Pulp::Repository::ImportUpload }
    let(:repo) { katello_repositories(:fedora_17_x86_64) }

    before do
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
    end

    it 'plans' do
      upload = {'id' => '1', 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test'}
      action = create_action(action_class)
      action.expects(:action_subject).with(repo)
      plan_action(action, repo, [upload])
      import_upload_args = {
        pulp_id: repo.pulp_id,
        unit_type_id: repo.unit_type_id,
        unit_key: upload.except('id', 'name'),
        upload_id: '1',
        unit_metadata: nil
      }

      assert_action_planed_with(action, pulp_import_class,
                                repo, SmartProxy.pulp_primary,
                                import_upload_args)
    end
  end
end
