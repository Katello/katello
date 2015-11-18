require 'katello_test_helper'

class Dynflow::Testing::DummyPlannedAction
  attr_accessor :error
end

module ::Actions::Katello::Repository
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
    let(:repository) { katello_repositories(:rhel_6_x86_64) }
    let(:custom_repository) { katello_repositories(:fedora_17_x86_64) }
    let(:puppet_repository) { katello_repositories(:p_forge) }
    let(:docker_repository) { katello_repositories(:redis) }

    before(:all) do
      set_user
    end
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Create }

    it 'plans' do
      repository.expects(:save!)
      action.expects(:action_subject).with(repository)
      action.execution_plan.stub_planned_action(::Actions::Katello::Product::ContentCreate) do |content_create|
        content_create.stubs(input: { content_id: 123 })
      end
      plan_action action, repository
    end
  end

  class CreateFailTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Create }
    before do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns("ERROR")
    end

    it 'fails to plan' do
      repository.expects(:save!).never
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Destroy }
    let(:pulp_action_class) { ::Actions::Pulp::Repository::Destroy }
    let(:unpublished_repository) { katello_repositories(:fedora_17_unpublished) }
    let(:published_repository) { katello_repositories(:rhel_6_x86_64) }

    it 'plans' do
      action = create_action action_class
      action.stubs(:action_subject).with(unpublished_repository)
      action.expects(:plan_self)
      plan_action action, unpublished_repository
      assert_action_planed_with action, pulp_action_class, pulp_id: unpublished_repository.pulp_id
      assert_action_planed_with action, ::Actions::Katello::Product::ContentDestroy, unpublished_repository
    end

    it "plan fails if repository is not deletable" do
      action = create_action action_class
      action.stubs(:action_subject).with(published_repository)
      assert_raises(RuntimeError) do
        plan_action action, published_repository
      end
    end
  end

  class DyscoverTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Discover }
    let(:action_planned) { create_and_plan_action action_class, 'http://' }

    it 'plans' do
      assert_run_phase action_planned
    end

    it 'runs' do
      ::Katello::RepoDiscovery.
          expects(:new).
          returns(mock('discovery', run: nil))

      run_action action_planned
    end
  end

  class RemoveContentTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::RemoveContent }

    it 'plans' do
      to_remove = custom_repository.rpms
      uuids = to_remove.map(&:uuid)
      action.expects(:action_subject).with(custom_repository)
      plan_action action, custom_repository, to_remove

      assert_action_planed_with action, ::Actions::Pulp::Repository::RemoveRpm,
        pulp_id: custom_repository.pulp_id, clauses: {:association => {'unit_id' => {'$in' => uuids}}}
      assert_empty custom_repository.reload.rpms
    end
  end

  class RemoveDockerImagesTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::RemoveContent }
    let(:docker_repo) { katello_repositories(:redis) }
    let(:uuids) { ["abc123", "def123", "ghi123"] }

    it 'plans' do
      uuids.each do |str|
        docker_repo.docker_images.create!(:image_id => str) do |image|
          image.uuid = str
        end
      end

      action.expects(:action_subject).with(docker_repo)
      plan_action action, docker_repo, docker_repo.docker_images
      assert_empty docker_repo.docker_images.reload
    end
  end

  class UploadFilesTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::UploadFiles }

    it 'plans' do
      file = File.join(::Katello::Engine.root, "test", "fixtures", "files", "puppet_module.tar.gz")
      action.expects(:action_subject).with(custom_repository)
      action.execution_plan.stub_planned_action(::Actions::Pulp::Repository::CreateUploadRequest) do |content_create|
        content_create.stubs(output: { upload_id: 123 })
      end

      plan_action action, custom_repository, [file]
      assert_action_planed(action, ::Actions::Pulp::Repository::CreateUploadRequest)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::UploadFile,
                                upload_id: 123, file: File.join(Rails.root, 'tmp', 'uploads', 'puppet_module.tar.gz'))
      assert_action_planed_with(action, ::Actions::Pulp::Repository::DeleteUploadRequest,
                                upload_id: 123)
      assert_action_planed_with(action, ::Actions::Katello::Repository::FinishUpload,
                                custom_repository)
    end
  end

  class FinishUploadTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::FinishUpload }

    it 'plans' do
      plan_action action, custom_repository
      assert_action_planed(action, ::Actions::Katello::Repository::MetadataGenerate)
    end

    it "doesn't plan metadata generate for puppet repository" do
      plan_action action, puppet_repository
      refute_action_planed(action, ::Actions::Katello::Repository::MetadataGenerate)
    end
  end

  class SyncTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Sync }
    let(:pulp_action_class) { ::Actions::Pulp::Repository::Sync }

    it 'plans' do
      action       = create_action action_class
      action.stubs(:action_subject).with(repository)
      plan_action action, repository

      assert_action_planed_with(action, pulp_action_class,
                                pulp_id: repository.pulp_id, task_id: nil)
      assert_action_planed action, ::Actions::Katello::Repository::IndexContent
      assert_action_planed_with action, ::Actions::Katello::Repository::ErrataMail do |repo, _task_id, contents_changed|
        contents_changed.must_be_kind_of Dynflow::ExecutionPlan::OutputReference
        repo.id.must_equal repository.id
      end
    end

    it 'passes the task id to pulp sync action when provided' do
      action       = create_action action_class
      action.stubs(:action_subject).with(repository)
      plan_action action, repository, '123'

      assert_action_planed_with(action, pulp_action_class,
                                pulp_id: repository.pulp_id, task_id: '123')
    end

    describe 'progress' do
      let :action do
        create_action(action_class).tap do |action|
          action.stubs(planned_actions: [pulp_action])
        end
      end

      let(:pulp_action) { fixture_action(pulp_action_class, input: {pulp_id: repository.pulp_id}, output: fixture_variant) }

      describe 'successfully synchronized' do
        let(:fixture_variant) { :success }

        specify do
          action.humanized_output.must_equal "New packages: 32 (76.7 KB)."
        end
      end

      describe 'successfully synchronized without new packages' do
        let(:fixture_variant) { :success_no_packages }

        specify do
          action.humanized_output.must_equal "No new packages."
        end
      end

      describe 'syncing packages in progress' do
        let(:fixture_variant) { :progress_packages }

        specify do
          action.humanized_output.must_equal "New packages: 20/32 (48 KB/76.7 KB)."
        end

        specify do
          pulp_action.run_progress.must_be_within_delta 0.6256
        end
      end

      describe 'downloading metadata in progress' do
        let(:fixture_variant) { :progress_metadata }

        specify do
          action.humanized_output.must_equal "Processing metadata"
        end
      end
    end
  end

  class CloneDockerContentTest  < TestBase
    let(:action_class) { ::Actions::Katello::Repository::CloneDockerContent }
    let(:source_repo) { katello_repositories(:redis) }
    let(:target_repo) { katello_repositories(:busybox) }

    it 'plans' do
      action = create_action action_class
      plan_action(action, source_repo, target_repo)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyDockerImage,
                                source_pulp_id: source_repo.pulp_id,
                                target_pulp_id: target_repo.pulp_id)

      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyDockerTag,
                                source_pulp_id: source_repo.pulp_id,
                                target_pulp_id: target_repo.pulp_id)

      assert_action_planed_with(action, ::Actions::Katello::Repository::MetadataGenerate, target_repo)
    end
  end

  class CloneDockerContentEnvironmentTest  < TestBase
    let(:action_class) { ::Actions::Katello::Repository::CloneToEnvironment }
    let(:source_repo) { katello_repositories(:redis) }

    it 'plans' do
      action = create_action action_class
      env = mock
      clone = mock
      action.expects(:find_or_build_environment_clone).returns(clone)
      clone.expects(:new_record?).returns(false)
      plan_action(action, source_repo, env)
      assert_action_planed_with(action, ::Actions::Katello::Repository::Clear, clone)
      assert_action_planed_with(action, ::Actions::Katello::Repository::CloneDockerContent, source_repo, clone)
    end
  end

  class CapsuleGenerateAndSyncTest < TestBase
    include Support::CapsuleSupport

    let(:action_class) { ::Actions::Katello::Repository::CapsuleGenerateAndSync }

    before do
      capsule_content.add_lifecycle_environment(repository.environment)
    end

    it 'plans' do
      plan_action(action, repository)
      assert_action_planed_with(action, ::Actions::Katello::Repository::NodeMetadataGenerate, repository)
      assert_action_planed_with(action, ::Actions::Katello::CapsuleContent::Sync, capsule_content, :repository => repository)
    end
  end
end
