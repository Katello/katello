require 'katello_test_helper'
require Katello::Engine.root.join('db/migrate/20211220185935_clean_duplicate_content_units')

module Katello
  class CleanDuplicateContentUnitsTest < ActiveSupport::TestCase
    let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths + [Katello::Engine.root.join('db/migrate/').to_s] }
    #let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths, ActiveRecord::SchemaMigration).migrations }

    let(:previous_version) { '20211208034230'.to_i }
    let(:current_version) { '20211220185935'.to_i }

    #only load the two migrations we care about (previous one and current one)
    let(:migrations) do
      [
        ActiveRecord::MigrationProxy.new("AddContentViewAndLifecycleEnvironment", previous_version, "#{Katello::Engine.root}/db/migrate//20211208034230_add_content_view_and_lifecycle_environment.rb", ""),
        ActiveRecord::MigrationProxy.new("CleanDuplicateContentUnits", current_version, "#{Katello::Engine.root}/db/migrate/20211220185935_clean_duplicate_content_units.rb", ""),
      ]
    end

    def migrate_up
      ActiveRecord::Migrator.new(:up, migrations, ActiveRecord::SchemaMigration, current_version).migrate
    end

    def setup
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:down, migrations, ActiveRecord::SchemaMigration, previous_version).migrate
      end
    end

    def test_duplicates_module_stream
      original_stream = katello_module_streams(:river)
      stream = Katello::ModuleStream.create!(:pulp_id => original_stream.pulp_id) #associated_to_repo
      Katello::ModuleStream.create!(:pulp_id => original_stream.pulp_id) #not associated to repo

      Katello::ContentViewModuleStreamFilterRule.create!(module_stream_id: stream.id, content_view_filter_id: katello_content_view_filters(:populated_module_stream_filter).id)
      Katello::ContentFacetApplicableModuleStream.create!(module_stream_id: stream.id, content_facet_id: katello_content_facets(:content_facet_one).id)
      Katello::ModuleProfile.create!(module_stream_id: stream.id, name: 'foobar')
      Katello::ModuleStreamArtifact.create!(module_stream_id: stream.id, name: 'the one artifact')
      Katello::ModuleStreamErratumPackage.create!(module_stream_id: stream.id, erratum_package_id: Katello::ErratumPackage.first.id)
      Katello::ModuleStreamRpm.create!(module_stream_id: stream.id, rpm_id: katello_rpms(:one).id)

      katello_repositories(:fedora_17_x86_64).module_streams << stream

      assert_equal 3, Katello::ModuleStream.where(:pulp_id => original_stream.pulp_id).count
      migrate_up
      assert_equal 1, Katello::ModuleStream.where(:pulp_id => original_stream.pulp_id).count
    end

    def test_delete_all_module_profiles
      stream = katello_module_streams(:river)

      dup_profile = Katello::ModuleProfile.create!(module_stream_id: stream.id, name: stream.profiles.first.name)
      Katello::ModuleProfileRpm.create!(module_profile_id: dup_profile.id, name: 'abacadaba')

      assert_equal 2, Katello::ModuleProfile.where(module_stream_id: stream.id, name: stream.profiles.first.name).count
      migrate_up
      assert_equal 0, Katello::ModuleProfile.all.count
    end

    def test_delete_all_module_profile_rpms
      profile_rpm = Katello::ModuleProfileRpm.first
      Katello::ModuleProfileRpm.create!(name: profile_rpm.name, module_profile_id: profile_rpm.module_profile_id)

      assert_equal 2, Katello::ModuleProfileRpm.where(name: profile_rpm.name, module_profile_id: profile_rpm.module_profile_id).count
      migrate_up
      assert_equal 0, Katello::ModuleProfileRpm.all.count
    end

    def test_ansible_tag
      name = 'ansible-tag-1'
      collection = Katello::AnsibleCollection.create!(:pulp_id => 'my_pulp_id')
      tag1 = Katello::AnsibleTag.create(name: name)
      tag2 = Katello::AnsibleTag.create(name: name)
      Katello::AnsibleCollectionTag.create!(ansible_collection_id: collection.id, ansible_tag_id: tag1.id)
      Katello::AnsibleCollectionTag.create!(ansible_collection_id: collection.id, ansible_tag_id: tag2.id)

      assert_equal 2, Katello::AnsibleTag.where(name: name).count
      migrate_up
      assert_equal 1, Katello::AnsibleTag.where(name: name).count
    end

    def test_ansible_collection_tags
      collection = Katello::AnsibleCollection.create!(:pulp_id => 'my_pulp_id')
      tag1 = Katello::AnsibleTag.create(name: name)

      Katello::AnsibleCollectionTag.create!(ansible_collection_id: collection.id, ansible_tag_id: tag1.id)
      Katello::AnsibleCollectionTag.create!(ansible_collection_id: collection.id, ansible_tag_id: tag1.id)

      assert_equal 2, Katello::AnsibleCollectionTag.where(ansible_collection_id: collection.id, ansible_tag_id: tag1.id).count
      migrate_up
      assert_equal 1, Katello::AnsibleCollectionTag.where(ansible_collection_id: collection.id, ansible_tag_id: tag1.id).count
    end

    def test_generic_content_units
      unit = katello_generic_content_units(:one)
      dup = Katello::GenericContentUnit.create!(pulp_id: unit.pulp_id)

      unit.repositories.first.generic_content_units << dup

      assert_equal 2, Katello::GenericContentUnit.where(pulp_id: unit.pulp_id).count
      migrate_up
      assert_equal 1, Katello::GenericContentUnit.where(pulp_id: unit.pulp_id).count
    end

    def test_docker_manifest_list
      pulp_id = 'list-id'
      list = Katello::DockerManifestList.create(pulp_id: pulp_id)
      dup = Katello::DockerManifestList.create(pulp_id: pulp_id)
      _dup2 = Katello::DockerManifestList.create(pulp_id: pulp_id)

      manifest = katello_docker_manifests(:one)
      manifest.docker_manifest_lists << list
      manifest.docker_manifest_lists << dup

      repo = katello_repositories(:busybox)
      repo.docker_manifests << manifest
      repo.docker_manifest_lists << list
      repo.docker_manifest_lists << dup

      assert_equal 3, Katello::DockerManifestList.where(pulp_id: pulp_id).count
      migrate_up
      assert_equal 1, Katello::DockerManifestList.where(pulp_id: pulp_id).count
    end

    def test_docker_manifest
      list = Katello::DockerManifestList.create(pulp_id: 'mymanifest')

      manifest = katello_docker_manifests(:one)
      dup = Katello::DockerManifest.create!(pulp_id: manifest.pulp_id)

      manifest.docker_manifest_lists << list
      dup.docker_manifest_lists << list

      repo = katello_repositories(:busybox)
      repo.docker_manifests << manifest
      repo.docker_manifests << dup

      assert_equal 2, Katello::DockerManifest.where(pulp_id: manifest.pulp_id).count
      migrate_up
      assert_equal 1, Katello::DockerManifest.where(pulp_id: manifest.pulp_id).count
    end
  end
end
