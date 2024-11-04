require 'katello_test_helper'

module ::Actions::Katello::Flatpak
  class TestScanRemoteBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:action) { create_action action_class }
    let(:remote) { katello_flatpak_remotes(:redhat_flatpak_remote) }
  end

  class ScanRemoteTest < TestScanRemoteBase
    let(:action_class) { ::Actions::Katello::Flatpak::ScanRemote }
    let(:input) do
      {
        remote_id: remote.id,
        url: 'https://flatpaks.redhat.io/rhel//index/static?label%3Aorg.flatpak.ref%3Aexists=1&tag=latest'
      }
    end

    it 'plans_self' do
      action.expects(:plan_self).with(input)
      plan_action action, remote
    end
  end
end
