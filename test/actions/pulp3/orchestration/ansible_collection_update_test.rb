require 'katello_test_helper'

module ::Actions::Pulp3
  class AnsibleCollectionUpdateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:pulp3_ansible_collection_1)
      create_repo(@repo, @primary)
    end

    def teardown
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      @repo.reload
    end

    def test_invalid_update
      ::Katello::Pulp3::Repository::AnsibleCollection.any_instance.stubs(:test_remote_name).returns(:test_remote_name)

      bad_requirements = "---
collections:
  # Install a collection from Ansible Galaxy.
  - name: geerlingguy.php_roles
    version: 0.9.3
    source: ftp://foobar/path/tobaz"
      @repo.root.update(ansible_collection_requirements: bad_requirements)

      message = "Invalid URL ftp://foobar/path/tobaz. Ensure the URL ends '/'."
      assert_raises_with_message(::Katello::Errors::Pulp3Error, message) do
        ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Update, @repo, @primary)
      end
    end
  end
end
