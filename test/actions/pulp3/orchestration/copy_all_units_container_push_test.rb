require 'katello_test_helper'

module ::Actions::Pulp3
  class CopyAllUnitsContainerPushTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:action_class) { ::Actions::Pulp3::Orchestration::Repository::CopyAllUnits }
    let(:action) { create_action action_class }
    let(:source) { katello_repositories(:busybox) }
    let(:target) { katello_repositories(:busybox_dev) }
    let(:proxy) { SmartProxy.pulp_primary }

    before do
      set_user
      source.root.stubs(:is_container_push).returns(true)
    end

    ['container-push', 'container'].each do |pulp_type|
      it "copies #{pulp_type} push content into the content view repository" do
        source.stubs(:version_href).returns("/pulp/api/v3/repositories/container/#{pulp_type}/source/versions/1/")
        target.expects(:update!).never

        plan_action action, target, proxy, [source]

        assert_action_planned_with action, ::Actions::Pulp3::Repository::CopyContent,
          source, proxy, target, copy_all: true
        assert_action_planned action, ::Actions::Pulp3::Repository::SaveVersion
        refute_action_planned action, ::Actions::Pulp3::Repository::CopyVersion
      end

      it "applies filters when publishing #{pulp_type} push content" do
        source.stubs(:version_href).returns("/pulp/api/v3/repositories/container/#{pulp_type}/source/versions/1/")
        filter = stub(id: 123)

        plan_action action, target, proxy, [source], filters: [filter]

        assert_action_planned_with action, ::Actions::Pulp3::Repository::CopyContent,
          source, proxy, target, filter_ids: [123], solve_dependencies: false,
          rpm_filenames: nil, remove_all: true
        assert_action_planned action, ::Actions::Pulp3::Repository::SaveVersion
      end
    end
  end
end
