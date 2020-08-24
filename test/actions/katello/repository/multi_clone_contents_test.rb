require 'katello_test_helper'

module Actions
  describe Katello::Repository::MultiCloneContents do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
    include ::Katello::Pulp3Support

    let(:action_class) { ::Actions::Katello::Repository::MultiCloneContents }

    def setup
      get_organization #ensure we have an org label
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)

      ensure_creatable(@repo, @master)
      create_repo(@repo, @master)
      ensure_creatable(@repo_clone, @master)
      create_repo(@repo_clone, @master)

      @repo.reload

      @repo_mapping = { [@repo] => { :dest_repo => @repo_clone, :filters => [] } }
    end

    def test_metadata_generation_with_changed_checksum_type
      @repo.update(saved_checksum_type: "sha1")
      @repo_clone.update(saved_checksum_type: "sha256")
      task = ForemanTasks.sync_task(action_class, @repo_mapping, copy_contents: false)
      assert_equal "success", task.result
    end
  end
end
