require 'katello_test_helper'

module Actions::Katello::Repository
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
  end

  class SyncDebErrataTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::SyncDebErrata }
    let(:action) { create_action action_class }

    let(:repository) do
      katello_repositories(:debian_10_amd64_dev)
    end

    before do
      action.stubs(:input).returns(repo_id: repository.id)
    end

    context 'is planned by repository sync' do
      let(:reposync_action_class) { ::Actions::Katello::Repository::Sync }
      before do
        repository.root.deb_errata_url = 'https://dep.example.com'
        repository.save!
      end
      it 'plans' do
        tree = plan_action_tree reposync_action_class, repository
        assert_tree_planned_with tree, action_class, { repo_id: repository.id, force_download: false }
      end
      it 'plans complete sync' do
        tree = plan_action_tree reposync_action_class, repository, skip_metadata_check: true
        assert_tree_planned_with tree, action_class, { repo_id: repository.id, force_download: true }
      end
      it 'does not plan w/o errata_url' do
        repository.root.deb_errata_url = nil
        repository.save!
        tree = plan_action_tree reposync_action_class, repository
        refute_tree_planned_steps tree, action_class
      end
    end

    context 'downloads erratum (run phase)' do
      let(:request) { RestClient::Request }
      it 'sends correct request' do
        repository.root.deb_errata_url = 'https://dep.example.com/'
        repository.root.save
        request.expects(:execute).with do |parameters|
          parameters[:method] == :get &&
            parameters[:url] == 'https://dep.example.com/' &&
            parameters[:headers][:params] == {
              'releases' => 'buster',
              'components' => 'main,contrib',
              'architectures' => 'amd64'
            }
        end
        action.run
      end
      it 'sends etag' do
        repository.root.deb_errata_url = 'https://dep.example.com/'
        repository.root.deb_errata_url_etag = 'IKnowWhatYouDownloadedLastTime'
        repository.root.save
        request.expects(:execute).with do |parameters|
          parameters[:headers]['If-None-Match'] == 'IKnowWhatYouDownloadedLastTime'
        end
        action.run
      end
      it 'ignores etag on force_download' do
        action.stubs(:input).returns(repo_id: repository.id, force_download: true)
        repository.root.deb_errata_url = 'https://dep.example.com/'
        repository.root.deb_errata_url_etag = 'IKnowWhatYouDownloadedLastTime'
        repository.root.save
        request.expects(:execute).with do |parameters|
          parameters[:headers]['If-None-Match'].nil?
        end
        action.run
      end
      # TODO: it 'uses http-proxy' do
    end

    context 'stores erratum (finalize phase)' do
      before do
        action.stubs(:input).returns(repo_id: repository.id)
      end
      it 'with packages in repo that solve erratum' do
        action.stubs(:output).returns(
          modified: true,
          data: JSON.dump(
            [{
              name: 'DEBERR-1-1',
              title: 'testpackage -- security update',
              issued: '27 Sep 2023',
              affected_source_package: 'testpackage',
              packages: [{
                name: 'uno',
                version: '1.0',
                architecture: 'amd64',
                component: 'main',
                release: 'buster'
              }]
            }]
          )
        )
        action.finalize
        assert_equal ['DEBERR-1-1'], repository.errata.pluck(:errata_id)
      end
      it 'not if packages in repo do not solve erratum' do
        action.stubs(:output).returns(
          modified: true,
          data: JSON.dump(
            [{
              name: 'DEBERR-1-1',
              title: 'testpackage -- security update',
              issued: '27 Sep 2023',
              affected_source_package: 'testpackage',
              packages: [{
                name: 'uno',
                version: '2.0',
                architecture: 'amd64',
                component: 'main',
                release: 'buster'
              }]
            }]
          )
        )
        action.finalize
        assert_empty repository.errata.pluck(:errata_id)
      end
      it 'ignores changes, if not modified' do
        action.stubs(:output).returns(modified: false)
        raises_exception = ->(_v) { fail NoMethodError, 'should not be called if modified is false' }
        JSON.stub(:parse, raises_exception) do
          action.finalize
        end
      end
      it 'removes old errata if mirror is set' do
        repository.root.mirroring_policy = ::Katello::RootRepository::MIRRORING_POLICY_CONTENT
        repository.root.save!
        action.stubs(:output).returns(
          modified: true,
          data: JSON.dump(
            [{
              name: 'DEBERR-1-1',
              title: 'testpackage -- security update',
              issued: '27 Sep 2023',
              affected_source_package: 'testpackage',
              packages: [{
                name: 'uno',
                version: '1.0',
                architecture: 'amd64',
                component: 'main',
                release: 'buster'
              }]
            }]
          )
        )
        e = katello_errata(:deb_1)
        e.repositories << repository
        assert_equal [e], repository.errata
        action.finalize
        repository.errata.reload # force a reload
        assert_equal ['DEBERR-1-1'], repository.errata.pluck(:errata_id)
      end
      it 'keeps old errata if mirror is not set' do
        repository.root.mirroring_policy = ::Katello::RootRepository::MIRRORING_POLICY_ADDITIVE
        repository.root.save!
        action.stubs(:output).returns(
          modified: true,
          data: JSON.dump(
            [{
              name: 'DEBERR-1-1',
              title: 'testpackage -- security update',
              issued: '27 Sep 2023',
              affected_source_package: 'testpackage',
              packages: [{
                name: 'uno',
                version: '1.0',
                architecture: 'amd64',
                component: 'main',
                release: 'buster'
              }]
            }]
          )
        )
        e = katello_errata(:deb_1)
        e.repositories << repository
        assert_equal [e], repository.errata
        action.finalize
        repository.errata.reload # force a reload
        assert_equal ['DEBIAN-1-1', 'DEBERR-1-1'], repository.errata.pluck(:errata_id)
      end
    end
  end
end
