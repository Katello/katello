require 'katello_test_helper'

module ::Actions::Katello::Flatpak
  class MirrorRemoteRepositoryTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:action) { create_action action_class }
    let(:remote_repository) { katello_flatpak_remote_repositories(:rhel9_flatpak_runtime) }
    let(:product) { katello_products(:empty_product) }
    let(:random_root) { katello_root_repositories(:busybox_root) }
    let(:success_task) { ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good") }

    class MirrorRemoteRepositoryTest < MirrorRemoteRepositoryTest
      let(:action_class) { ::Actions::Katello::Flatpak::MirrorRemoteRepository }
      let(:input) do
        {
          remote_repository: remote_repository,
          product: product,
        }
      end

      it 'plans' do
        action = create_action(action_class)
        action.stubs(:task).returns(success_task)
        ::Katello::Product.any_instance.expects(:add_repo).with(
                                                                 {
                                                                   name: remote_repository.name,
                                                                   label: remote_repository.label,
                                                                   url: remote_repository.flatpak_remote&.registry_url,
                                                                   description: 'Mirrored from: ' + remote_repository.flatpak_remote.name,
                                                                   product_id: product.id,
                                                                   content_type: 'docker',
                                                                   docker_upstream_name: "rhel9/flatpak-runtime",
                                                                   include_tags: ["latest"],
                                                                   upstream_username: nil,
                                                                   upstream_password: nil,
                                                                   unprotected: true,
                                                                   mirroring_policy: Setting[:default_non_yum_mirroring_policy],
                                                                 }).returns(random_root)
        plan_action action, remote_repository, product.id
        assert_action_planned_with(action, ::Actions::Katello::Repository::CreateRoot, random_root)
      end
    end
  end
end
