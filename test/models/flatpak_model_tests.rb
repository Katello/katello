require 'katello_test_helper'

module Katello
  class FlatpakRemoteTest < ActiveSupport::TestCase
    def setup
      @redhat_remote = katello_flatpak_remotes(:redhat_flatpak_remote)
      @fedora_remote = katello_flatpak_remotes(:fedora_flatpak_remote)
    end

    should validate_presence_of(:name)
    should validate_presence_of(:url)
    should validate_presence_of(:organization_id)
    should have_many(:remote_repositories).dependent(:destroy).class_name('Katello::FlatpakRemoteRepository')
    should have_many(:remote_repository_manifests).through(:remote_repositories).source(:remote_repository_manifests)
    should belong_to(:organization).inverse_of(:flatpak_remotes)

    test 'flatpak remote fixtures are valid and creatable' do
      assert @redhat_remote.valid?
      assert @fedora_remote.valid?
      assert @redhat_remote.save!
      assert @fedora_remote.save!
    end
  end

  class FlatpakRemoteRepositoryTest < ActiveSupport::TestCase
    def setup
      @redhat_remote_runtime_repository = katello_flatpak_remote_repositories(:rhel9_flatpak_runtime)
      @fedora_remote_runtime_repository = katello_flatpak_remote_repositories(:f41_flatpak_runtime)
      @redhat_remote_firefox_repository = katello_flatpak_remote_repositories(:rhel9_firefox_flatpak)
      @fedora_remote_firefox_repository = katello_flatpak_remote_repositories(:firefox)
    end

    should validate_presence_of(:name)
    should validate_presence_of(:flatpak_remote_id)
    should have_many(:remote_repository_manifests).dependent(:destroy).class_name('Katello::FlatpakRemoteRepositoryManifest')
    should belong_to(:flatpak_remote).inverse_of(:remote_repositories)

    test 'flatpak remote repository fixtures are valid and creatable' do
      assert @redhat_remote_runtime_repository.valid?
      assert @fedora_remote_runtime_repository.valid?
      assert @redhat_remote_firefox_repository.valid?
      assert @fedora_remote_firefox_repository.valid?
      assert @redhat_remote_runtime_repository.save!
      assert @fedora_remote_runtime_repository.save!
      assert @redhat_remote_firefox_repository.save!
      assert @fedora_remote_firefox_repository.save!
    end
  end

  class FlatpakRemoteRepositoryManifestTest < ActiveSupport::TestCase
    def setup
      @redhat_runtime_manifest = katello_flatpak_remote_repository_manifests(:rhel9_runtime_manifest)
      @rhel9_firefox_manifest_x_86_84 = katello_flatpak_remote_repository_manifests(:rhel9_firefox_manifest_x86_84)
      @rhel9_firefox_manifest_s390x = katello_flatpak_remote_repository_manifests(:rhel9_firefox_manifest_s390x)
    end

    should validate_presence_of(:name)
    should validate_presence_of(:flatpak_remote_repository_id)
    should belong_to(:remote_repository).class_name('Katello::FlatpakRemoteRepository').inverse_of(:remote_repository_manifests)

    test 'flatpak remote repository manifest fixtures are valid and creatable' do
      assert @redhat_runtime_manifest.valid?
      assert @rhel9_firefox_manifest_x_86_84.valid?
      assert @rhel9_firefox_manifest_s390x.valid?

      assert @redhat_runtime_manifest.save!
      assert @rhel9_firefox_manifest_x_86_84.save!
      assert @rhel9_firefox_manifest_s390x.save!
    end
  end
end
