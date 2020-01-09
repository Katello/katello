require 'katello_test_helper'

class Dynflow::Testing::DummyPlannedAction
  attr_accessor :error
end

module ::Actions::Katello::Repository
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action) { create_action action_class }
    let(:repository) { katello_repositories(:rhel_6_x86_64) }
    let(:repository_pulp3) { katello_repositories(:pulp3_file_1) }
    let(:repository_ansible_collection_pulp3) { katello_repositories(:pulp3_ansible_collection_1) }
    let(:custom_repository) { katello_repositories(:fedora_17_x86_64) }
    let(:puppet_repository) { katello_repositories(:p_forge) }
    let(:docker_repository) { katello_repositories(:redis) }
    let(:proxy) { smart_proxies(:one) }
    let(:capsule_content) { ::Katello::Pulp::SmartProxyRepository.new(proxy) }

    before(:all) do
      set_user
      ::Katello::Product.any_instance.stubs(:certificate).returns(nil)
      ::Katello::Product.any_instance.stubs(:key).returns(nil)
      SmartProxy.stubs(:pulp_master).returns(proxy)
    end
  end

  class UpdateHttpProxyTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::UpdateHttpProxyDetails }

    it 'plans' do
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      plan_action action, repository
      assert_action_planned_with action,
        ::Actions::Pulp::Orchestration::Repository::Refresh,
        repository, proxy
    end
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Create }
    let(:candlepin_action_class) { ::Actions::Candlepin::Environment::AddContentToEnvironment }

    before do
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      repository.expects(:save!)
      action.expects(:action_subject).with(repository)
      action.execution_plan.stub_planned_action(::Actions::Katello::Product::ContentCreate) do |content_create|
        content_create.stubs(input: { content_id: 123 })
      end
    end

    it 'plans' do
      plan_action action, repository
      assert_action_planed_with action, candlepin_action_class, view_env_cp_id: "1", content_id: "69"
    end

    it 'no clone flag means generate metadata in run phase' do
      plan = plan_action action, repository
      run_action plan
      plan.run.label.must_equal "Actions::Katello::Repository::MetadataGenerate"
    end

    it 'clone flag disables metadata generation' do
      plan = plan_action action, repository, true
      run_action plan
      assert_nil plan.run
      refute_action_planed action, candlepin_action_class
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

  class UpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Update }
    let(:pulp_action_class) { ::Actions::Pulp::Orchestration::Repository::Refresh }
    let(:candlepin_action_class) { ::Actions::Candlepin::Product::ContentUpdate }
    let(:repository) { katello_repositories(:fedora_17_unpublished) }
    let(:pulp3_action_class) { ::Actions::Pulp3::Orchestration::Repository::Update }
    def setup
      content = FactoryBot.create(:katello_content, cp_content_id: repository.content_id, organization_id: repository.product.organization_id)
      Katello::ProductContent.create!(:content_id => content.id, :product_id => repository.product_id)
      super
    end

    it 'plans' do
      action = create_action action_class
      action.stubs(:action_subject).with(repository)

      plan_action action, repository.root, :unprotected => true
      assert_action_planed_with action, pulp_action_class,
        repository, proxy
      assert_action_planed action, candlepin_action_class
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Destroy }
    let(:pulp_action_class) { ::Actions::Pulp::Orchestration::Repository::Delete }
    let(:pulp3_action_class) { ::Actions::Pulp3::Orchestration::Repository::Delete }
    let(:unpublished_repository) { katello_repositories(:fedora_17_unpublished) }
    let(:in_use_repository) { katello_repositories(:fedora_17_no_arch) }
    let(:published_repository) { katello_repositories(:rhel_6_x86_64) }
    let(:published_fedora_repository) { katello_repositories(:fedora_17_x86_64) }

    it 'plans' do
      action = create_action action_class
      action.stubs(:action_subject).with(in_use_repository)
      in_use_repository.stubs(:assert_deletable).returns(true)
      in_use_repository.stubs(:destroyable?).returns(true)
      in_use_repository.stubs(:pulp_scratchpad_checksum_type).returns(nil)
      clone = in_use_repository.build_clone(:environment => katello_environments(:dev), :content_view => katello_content_views(:library_dev_view))
      clone.save!

      action.expects(:plan_self)
      plan_action action, in_use_repository
      assert_action_planed_with action, pulp_action_class,
        in_use_repository, proxy

      refute_action_planed action, ::Actions::Katello::Product::ContentDestroy
    end

    it 'plans when custom and no clones' do
      action = create_action action_class
      action.stubs(:action_subject).with(unpublished_repository)
      action.expects(:plan_self)
      plan_action action, unpublished_repository

      assert_action_planed_with action, ::Actions::Katello::Product::ContentDestroy, unpublished_repository.root
    end

    it 'does not plan content destroy when custom and 1 clone with planned destroy' do
      clones = published_fedora_repository.clones
      clone = clones.first
      clones.where.not(id: clone.id).destroy_all

      action = create_action action_class
      action.stubs(:action_subject).with(clone)
      action.expects(:plan_self)
      plan_action action, clone

      refute_action_planed action, ::Actions::Katello::Product::ContentDestroy
    end

    it 'plan fails if repository is not deletable' do
      action = create_action action_class
      action.stubs(:action_subject).with(published_repository)

      assert_raises(RuntimeError) do
        plan_action action, published_repository
      end
    end
  end

  class DiscoverTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Discover }
    let(:action_planned) { create_and_plan_action action_class, 'http://', 'yum', nil, nil, '*' }

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
    let(:capsule_generate_action_class) { ::Actions::Katello::Repository::CapsuleSync }

    it 'plans' do
      to_remove = custom_repository.rpms
      uuids = to_remove.map(&:id)
      action.expects(:action_subject).with(custom_repository)
      plan_action action, custom_repository, to_remove

      assert_action_planed_with action, ::Actions::Pulp::Orchestration::Repository::RemoveUnits,
        custom_repository, proxy,
        contents: uuids, content_unit_type: "rpm"
    end

    it "does run capsule sync for custom repository" do
      action.expects(:action_subject).with(custom_repository)
      plan_action action, custom_repository, custom_repository.rpms

      assert_action_planned_with(action, capsule_generate_action_class, custom_repository)
    end

    it "does not run capsule sync for custom repository" do
      action.expects(:action_subject).with(custom_repository)
      plan_action action, custom_repository, custom_repository.rpms, sync_capsule: false

      refute_action_planned(action, capsule_generate_action_class)
    end
  end

  class RemoveDockerManifestsTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::RemoveContent }
    let(:docker_repo) { katello_repositories(:redis) }
    let(:uuids) { ["abc123", "def123", "ghi123"] }

    it 'plans' do
      uuids.each do |str|
        docker_repo.docker_manifests.create!(:digest => str) do |manifest|
          manifest.pulp_id = str
        end
      end

      action.expects(:action_subject).with(docker_repo)
      plan_action action, docker_repo, docker_repo.docker_manifests

      assert_action_planed_with action,
       Actions::Pulp::Orchestration::Repository::RemoveUnits,
       docker_repo, proxy,
       contents: docker_repo.docker_manifests.pluck(:id), content_unit_type: "docker_manifest"
    end
  end

  class UploadFilesTest < TestBase
    setup { FactoryBot.create(:smart_proxy, :default_smart_proxy) }
    let(:pulp2_action_class) { ::Actions::Pulp::Orchestration::Repository::UploadContent }
    let(:pulp3_action_class) { ::Actions::Pulp3::Orchestration::Repository::UploadContent }
    it 'plans for Pulp' do
      action = create_action pulp2_action_class
      file = File.join(::Katello::Engine.root, "test", "fixtures", "files", "puppet_module.tar.gz")
      action.execution_plan.stub_planned_action(::Actions::Pulp::Repository::CreateUploadRequest) do |content_create|
        content_create.stubs(output: { upload_id: 123 })
      end

      plan_action action, puppet_repository, proxy, {:path => file, :filename => 'puppet_module.tar.gz'}, 'puppet_module'
      assert_action_planed(action, ::Actions::Pulp::Repository::CreateUploadRequest)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::UploadFile,
                                upload_id: 123, file: file)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::ImportUpload,
                                puppet_repository, proxy,
                  pulp_id: puppet_repository.pulp_id,
                  unit_type_id: "puppet_module",
                  unit_key: {},
                  upload_id: 123)
      assert_action_planed_with(action, ::Actions::Pulp::Repository::DeleteUploadRequest,
                                upload_id: 123)
    end

    it 'plans for Pulp3 without duplicate' do
      proxy.stubs(:content_service).returns(stub(:content_api => stub(:list => stub(:results => nil))))
      action = create_action pulp3_action_class
      file = File.join(::Katello::Engine.root, "test", "fixtures", "files", "puppet_module.tar.gz")
      action.execution_plan.stub_planned_action(::Actions::Pulp3::Repository::UploadFile) do |content_create|
        content_create.stubs(output: { pulp_tasks: [{href: "demo_task/href"}] })
      end
      action.execution_plan.stub_planned_action(::Actions::Pulp3::Repository::SaveArtifact) do |save_artifact|
        save_artifact.stubs(output: { pulp_tasks: [{href: "demo_task/artifact_href"}] })
      end
      action.execution_plan.stub_planned_action(::Actions::Pulp3::Repository::ImportUpload) do |import_upload|
        import_upload.stubs(output: { pulp_tasks: [{href: "demo_task/version_href"}] })
      end

      plan_action action, repository_pulp3, proxy, {:path => file, :filename => 'puppet_module.tar.gz'}, 'file'
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::UploadFile,
                                repository_pulp3, proxy, file)
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::SaveArtifact,
                                {:path => file, :filename => 'puppet_module.tar.gz'},
                                repository_pulp3, proxy,
                                [{href: "demo_task/href"}],
                                "file")
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::ImportUpload,
                                [{href: "demo_task/artifact_href"}], repository_pulp3, proxy)
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::SaveVersion,
                                repository_pulp3,
                                tasks: [{href: "demo_task/version_href"}])
    end

    it 'plans for Pulp3 with duplicate' do
      proxy.stubs(:content_service).returns(stub(:content_api => stub(:list => stub(:results => [stub(:pulp_href => "demo_content/href")]))))
      action = create_action pulp3_action_class
      file = File.join(::Katello::Engine.root, "test", "fixtures", "files", "puppet_module.tar.gz")
      action.execution_plan.stub_planned_action(::Actions::Pulp3::Repository::ImportUpload) do |import_upload|
        import_upload.stubs(output: { pulp_tasks: [{href: "demo_task/version_href"}] })
      end

      plan_action action, repository_pulp3, proxy, {:path => file, :filename => 'puppet_module.tar.gz'}, 'file'
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::ImportUpload,
                                "demo_content/href", repository_pulp3, proxy)
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::SaveVersion,
                                repository_pulp3,
                                tasks: [{href: "demo_task/version_href"}])
    end
  end

  class UploadErrataTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::UploadErrata }

    it 'plans' do
      action.expects(:action_subject).with(custom_repository)
      action.execution_plan.stub_planned_action(::Actions::Pulp::Repository::CreateUploadRequest) do |content_create|
        content_create.stubs(output: { upload_id: 123 })
      end

      errata = [{:unit_metadata => "our-metadata", :unit_key => "our-key"}]

      plan_action action, custom_repository, errata

      assert_action_planed(action, ::Actions::Pulp::Repository::CreateUploadRequest)

      assert_action_planed(action, ::Actions::Pulp::Repository::ImportUpload) do |(inputs)|
        inputs[:unit_type_id].must_equal 'erratum'
        inputs[:unit_metadata].must_equal 'our-metadata'
        inputs[:unit_key].must_equal "our-key"
        inputs[:upload_id].must_equal 123
      end

      assert_action_planed_with(action, ::Actions::Pulp::Repository::DeleteUploadRequest,
                                upload_id: 123)
    end
  end

  class UploadDockerTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::ImportUpload }
    setup { SmartProxy.stubs(:pulp_master).returns(SmartProxy.new) }
    it 'plans' do
      action.expects(:action_subject).with(docker_repository)

      uploads = [{'id' => 1, 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test'}]

      plan_action action, docker_repository, uploads,
              generate_metadata: true, sync_capsule: true

      import_upload_args = {
        pulp_id: docker_repository.pulp_id,
        unit_type_id: 'docker_manifest',
        unit_key: {'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test'},
        upload_id: 1,
        unit_metadata: nil
      }
      assert_action_planned_with(action, ::Actions::Pulp::Repository::ImportUpload,
                                 docker_repository, SmartProxy.pulp_master,
                                 import_upload_args
                                )
    end

    it 'plans' do
      action.expects(:action_subject).with(docker_repository)

      uploads = [{'id' => 1, 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test', 'digest' => 'sha256:1234'}]

      unit_keys = uploads.map { |u| u.except('id') }

      plan_action action, docker_repository, uploads,
              generate_metadata: true, sync_capsule: true, content_type: 'docker_tag'

      import_upload_args = {
        pulp_id: docker_repository.pulp_id,
        unit_type_id: 'docker_tag',
        unit_key: unit_keys[0],
        upload_id: 1,
        unit_metadata: unit_keys[0]
      }
      assert_action_planned_with(action, ::Actions::Pulp::Repository::ImportUpload,
                                 docker_repository, SmartProxy.pulp_master,
                                 import_upload_args
                                )
    end
  end

  class FinishUploadTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::FinishUpload }

    it 'plans' do
      plan_action action, custom_repository, :content_type => 'rpm'
      assert_action_planed(action, ::Actions::Katello::Repository::MetadataGenerate)
    end

    it "does plan metadata generate for puppet repository" do
      plan_action action, puppet_repository, :content_type => 'puppet_module'
      assert_action_planed(action, ::Actions::Katello::Repository::MetadataGenerate)
    end

    it "does not plan metadata generate for puppet repository" do
      plan_action action, puppet_repository, :generate_metadata => false, :content_type => 'puppet_module'
      refute_action_planed(action, ::Actions::Katello::Repository::MetadataGenerate)
    end
  end

  class SyncTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Sync }
    let(:pulp2_action_class) { ::Actions::Pulp::Orchestration::Repository::Sync }
    let(:pulp3_action_class) { ::Actions::Pulp3::Orchestration::Repository::Sync }
    let(:pulp3_metadata_generate_action_class) { ::Actions::Pulp3::Orchestration::Repository::GenerateMetadata }

    it 'plans' do
      action = create_action action_class
      action.stubs(:action_subject).with(repository)
      plan_action action, repository
      assert_action_planed_with(action, pulp2_action_class, repository, proxy,
                                smart_proxy_id: proxy.id, repo_id: repository.id, source_url: nil, options: {})
      assert_action_planed action, ::Actions::Katello::Repository::IndexContent
      assert_action_planed action, ::Actions::Pulp::Repository::RegenerateApplicability
      assert_action_planed action, ::Actions::Katello::Repository::ImportApplicability
      assert_action_planed_with action, ::Actions::Katello::Repository::ErrataMail do |repo, _task_id, contents_changed|
        contents_changed.must_be_kind_of Dynflow::ExecutionPlan::OutputReference
        repo.id.must_equal repository.id
      end
    end

    it 'skips applicability if non-yum' do
      action = create_action action_class
      docker_repository.root.url = 'http://foo.com/foo'
      action.stubs(:action_subject).with(docker_repository)
      plan_action action, docker_repository

      refute_action_planed action, ::Actions::Pulp::Repository::RegenerateApplicability
      refute_action_planed action, ::Actions::Katello::Repository::ImportApplicability
    end

    it 'passes the source URL to pulp sync action when provided' do
      action = create_action action_class
      action.stubs(:action_subject).with(repository)
      plan_action action, repository, nil, :source_url => 'file:///tmp/'

      assert_action_planed_with(action, pulp2_action_class, repository, proxy,
                                smart_proxy_id: proxy.id, repo_id: repository.id,
                                source_url: 'file:///tmp/', options: {})
    end

    it 'passes force_full when skip_metadata_check is nil' do
      action = create_action action_class
      action.stubs(:action_subject).with(repository)
      plan_action action, repository, nil, :skip_metadata_check => true

      assert_action_planed_with(action, pulp2_action_class, repository, proxy,
                                smart_proxy_id: proxy.id, repo_id: repository.id,
                                source_url: nil, options: {force_full: true})
      assert_action_planed_with(action, Actions::Katello::Repository::MetadataGenerate, repository, :force => true)
    end

    it 'calls download action when validate_contents is passed' do
      action = create_action action_class
      action.stubs(:action_subject).with(repository)
      plan_action action, repository, nil, :validate_contents => true

      assert_action_planed_with(action, pulp2_action_class, repository, proxy,
                                smart_proxy_id: proxy.id, repo_id: repository.id,
                                source_url: nil, options: {download_policy: 'on_demand', force_full: true})

      assert_action_planed_with(action, Actions::Pulp::Repository::Download, pulp_id: repository.pulp_id,
                                options: {:verify_all_units => true})
      assert_action_planed_with(action, Actions::Katello::Repository::MetadataGenerate, repository, :force => true)
    end

    it 'plans pulp3 orchestration actions with file repo' do
      action = create_action pulp3_action_class
      action.stubs(:action_subject).with(repository_pulp3)
      plan_action action, repository_pulp3, proxy, {}
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::Sync, repository_pulp3, proxy, {})
      assert_action_planed action, ::Actions::Pulp3::Repository::SaveVersion
      assert_action_planed action, ::Actions::Pulp3::Orchestration::Repository::GenerateMetadata
    end

    it 'plans pulp3 metadata generate with contents_changed' do
      action = create_action pulp3_metadata_generate_action_class
      action.stubs(:action_subject).with(repository_pulp3)
      plan_action action, repository_pulp3, proxy, :contents_changed => true
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::CreatePublication, repository_pulp3, proxy, :contents_changed => true)
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::RefreshDistribution, repository_pulp3, proxy, :contents_changed => true)
    end

    it 'plans pulp3 ansible collection metadata generate without publication ' do
      action = create_action pulp3_metadata_generate_action_class
      action.stubs(:action_subject).with(repository_ansible_collection_pulp3)
      plan_action action, repository_ansible_collection_pulp3, proxy, :contents_changed => true
      refute_action_planed action, ::Actions::Pulp3::Repository::CreatePublication
      assert_action_planed_with(action, ::Actions::Pulp3::Repository::RefreshDistribution, repository_ansible_collection_pulp3, proxy, :contents_changed => true)
    end

    describe 'progress' do
      let(:pulp_action_class) { ::Actions::Pulp::Repository::Sync }
      let(:pulp_action) { fixture_action(pulp_action_class, input: {repo_id: repository.id}, output: fixture_variant) }
      let :action do
        create_action(action_class).tap do |action|
          action.stubs(all_planned_actions: [pulp_action])
        end
      end

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

    describe 'pulp3 progress' do
      let(:pulp3_action_class) { ::Actions::Pulp3::Repository::Sync }
      let(:pulp3_action) { fixture_action(pulp3_action_class, input: {repo_id: repository.id}, output: fixture_variant) }
      let :action do
        create_action(action_class).tap do |action|
          action.stubs(all_planned_actions: [pulp3_action])
        end
      end

      describe 'successfully synchronized pulp3 file' do
        let(:fixture_variant) { :success_file }

        specify do
          action.humanized_output.must_equal "Total tasks: : 5/5\n"\
                                             "--------------------------------\n"\
                                             "Associating Content: 1/1\n"\
                                             "Downloading Artifacts: 0/0\n"\
                                             "Downloading Metadata: 1/1\n"\
                                             "Parsing Metadata Lines: 3/3"
        end

        specify do
          pulp3_action.run_progress.must_be_within_delta 1
        end
      end

      describe 'successfully synchronized pulp3 ansible collection' do
        let(:fixture_variant) { :success_ansible_collection }

        specify do
          action.humanized_output.must_equal "Total tasks: : 2/2\n"\
                                             "--------------------------------\n"\
                                             "Downloading Collections: 1/1\n"\
                                             "Importing Collections: 1/1"
        end

        specify do
          pulp3_action.run_progress.must_be_within_delta 1
        end
      end

      describe 'successfully synchronized pulp3 docker repo' do
        let(:fixture_variant) { :success_docker }

        specify do
          action.humanized_output.must_equal "Total tasks: : 1192/1192\n"\
                                             "--------------------------------\n"\
                                             "Associating Content: 641/641\n"\
                                             "Downloading Artifacts: 415/415\n"\
                                             "Downloading tag list: 1/1\n"\
                                             "Processing Tags: 135/135"
        end

        specify do
          pulp3_action.run_progress.must_be_within_delta 1
        end
      end

      describe 'syncing files in progress' do
        let(:fixture_variant) { :progress_units_file }

        specify do
          action.humanized_output.must_equal "Total tasks: : 15/30\n"\
                                             "--------------------------------\n"\
                                             "Associating Content: 5/10\n"\
                                             "Downloading Artifacts: 5/10\n"\
                                             "Downloading Metadata: 5/10"\
        end

        specify do
          pulp3_action.run_progress.must_be_within_delta 0.50
        end
      end

      describe 'syncing ansible collections in progress' do
        let(:fixture_variant) { :progress_units_ansible_collection }

        specify do
          action.humanized_output.must_equal "Total tasks: : 1/2\n"\
                                             "--------------------------------\n"\
                                             "Downloading Collections: 1/2"
        end

        specify do
          pulp3_action.run_progress.must_be_within_delta 0.5
        end
      end
    end
  end

  class CapsuleSyncTest < TestBase
    include Support::CapsuleSupport

    let(:action_class) { ::Actions::Katello::Repository::CapsuleSync }

    it 'plans' do
      smart_proxy_service_1 = new_capsule_content(:three)
      smart_proxy_service_2 = new_capsule_content(:four)
      smart_proxy_service_1.smart_proxy.add_lifecycle_environment(repository.environment)
      smart_proxy_service_2.smart_proxy.add_lifecycle_environment(repository.environment)

      plan_action(action, repository)
      assert_action_planned_with(action, ::Actions::BulkAction) do |action, proxy_list, options|
        assert_equal ::Actions::Katello::CapsuleContent::Sync, action
        assert_equal 2, proxy_list.length
        assert_include proxy_list, smart_proxy_service_1.smart_proxy
        assert_include proxy_list, smart_proxy_service_2.smart_proxy
        assert_equal repository.id, options[:repository_id]
      end
    end
  end

  class ImportApplicabilityTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::ImportApplicability }

    it 'runs' do
      host =  FactoryBot.build(:host, :id => 343)
      ::Katello::Repository.any_instance.stubs(:hosts_with_applicability).returns([host])
      Katello::EventQueue.expects(:push_event).with(::Katello::Events::ImportHostApplicability::EVENT_TYPE, host.id)

      ForemanTasks.sync_task(action_class, :repo_id => repository.id, :contents_changed => true)
    end
  end

  class ExportRepositoryTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Export }
    let(:repository) { katello_repositories(:rhel_6_x86_64) }

    it 'plans' do
      # required for export pre-run validation to succeed
      Setting['pulp_export_destination'] = '/tmp'

      action.stubs(:action_subject)
      plan_action(action, [repository], false, nil, 0, "8")

      # ensure arguments get transformed and bubble through to pulp actions.
      # Org label defaults to blank for this test, hence the group ID starts
      # with '-'.
      assert_action_planed_with(action, ::Actions::Pulp::RepositoryGroup::Create,
                                :id => "8",
                                :pulp_ids => [repository.pulp_id])
      assert_action_planed_with(action, ::Actions::Pulp::RepositoryGroup::Export) do |(inputs)|
        inputs[:id].must_equal "8"
        inputs[:export_to_iso].must_equal false
        # NB: the pulp export task writes to /v/l/p, not to a katello-owned dir
        inputs[:export_directory].must_include '/var/lib/pulp/published'
      end
      assert_action_planed_with(action, ::Actions::Pulp::RepositoryGroup::Delete,
                                :id => "8")
    end

    it 'plans with unit copy if needed' do
      # required for export pre-run validation to succeed
      Setting['pulp_export_destination'] = '/tmp'

      action.stubs(:action_subject)
      repository.stubs(:link?).returns(true)
      repository.stubs(:target_repository).returns(custom_repository)

      plan_action(action, [repository], false, nil, 0, "8")
      assert_action_planed_with(action, ::Actions::Pulp::Repository::Clear,
                                repository, SmartProxy.pulp_master)

      assert_action_planed_with(action, Actions::Pulp::Repository::CopyAllUnits, custom_repository, repository)
    end

    it 'plans without export destination' do
      action.stubs(:action_subject)

      assert_raises(Foreman::Exception) do
        plan_action(action, [repository], false, nil, 0, "8")
      end
    end

    it 'plans without writable destination' do
      Setting['pulp_export_destination'] = '/'
      action.stubs(:action_subject)

      assert_raises(Foreman::Exception) do
        plan_action(action, [repository], false, nil, 0, repository.pulp_id)
      end
    end
  end

  class CloneContentsFinalizeTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::CloneContents }

    it 'plans' do
      custom_repository.saved_checksum_type = "sha1"
      repository.saved_checksum_type = "sha256"
      planned_action = plan_action action, [repository], custom_repository, :copy_contents => false

      assert_equal planned_action.execution_plan.planned_finalize_steps.first.class, ::Actions::Katello::Repository::CloneContents
      assert_equal planned_action.execution_plan.planned_finalize_steps.first.input, "source_checksum_type" => "sha256", "target_repo_id" => custom_repository.id
    end
  end
end
