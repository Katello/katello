require 'katello_test_helper'

module Katello
  class SwitchoverBase < ActiveSupport::TestCase
    def setup
      @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
    end

    def teardown
      SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = nil
      SETTINGS[:katello][:use_pulp_2_for_content_type][:docker] = nil
      SETTINGS[:katello][:use_pulp_2_for_content_type][:yum] = nil
    end
  end

  class ContentSwitchoverCleanOrphansTest < SwitchoverBase
    def setup
      super
      SETTINGS[:katello][:use_pulp_2_for_content_type] = {:yum => true, :file => false, :docker => false}
    end

    def test_cleans_rpms
      rpm = katello_rpms(:one)
      rpm.repositories = []

      switchover = Katello::Pulp3::MigrationSwitchover.new(SmartProxy.pulp_primary, repository_types: ['yum'])
      switchover.remove_orphaned_content

      refute Katello::Rpm.find_by(id: rpm.id)
    end
  end

  class Pulp3YumContentSwitchoverTest < SwitchoverBase
    def setup
      super
      SETTINGS[:katello][:use_pulp_2_for_content_type] = {:yum => true, :file => false, :docker => false}

      @fake_pulp3_href = 'fake_pulp3_href'
      @another_fake_pulp3_href = 'another_fake_pulp3_href'

      migration_service = Katello::Pulp3::Migration.new(SmartProxy.pulp_primary, repository_types: ['yum'])
      migration_service.content_types_for_migration.each do |content_type|
        unless content_type.model_class == Katello::Erratum
          content_type.model_class.all.each do |record|
            record.update(:migrated_pulp3_href => @fake_pulp3_href + record.id.to_s)
          end
        end
        Katello::RepositoryErratum.update_all(erratum_pulp3_href: @fake_pulp3_href)
      end

      @switchover = Katello::Pulp3::MigrationSwitchover.new(SmartProxy.pulp_primary, repository_types: ['yum'])
    end

    def test_rpm_ignored_missing_gets_deleted
      rpm = katello_rpms(:one)
      rpm.update(migrated_pulp3_href: nil, missing_from_migration: true, ignore_missing_from_migration: true)

      @switchover.run
      refute Katello::Rpm.find_by(:id => rpm.id)
    end

    def test_rpm_corrupted_throws_error
      rpm = katello_rpms(:one)
      rpm.update(migrated_pulp3_href: nil, missing_from_migration: true, ignore_missing_from_migration: false)

      assert_raises do
        @switchover.run
      end
    end

    def test_rpm_nil_href
      rpm = katello_rpms(:one)
      rpm.update(migrated_pulp3_href: nil, missing_from_migration: false, ignore_missing_from_migration: false)

      assert_raises do
        @switchover.run
      end
    end
  end

  class Pulp3ContentSwitchoverTest < SwitchoverBase
    def setup
      super
      SETTINGS[:katello][:use_pulp_2_for_content_type] = {:file => true, :docker => true}

      @fake_pulp3_href = 'fake_pulp3_href'
      @another_fake_pulp3_href = 'another_fake_pulp3_href'

      migration_service = Katello::Pulp3::Migration.new(SmartProxy.pulp_primary, repository_types: ['file', 'docker'])
      migration_service.content_types_for_migration.each do |content_type|
        content_type.model_class.all.each do |record|
          record.update(:migrated_pulp3_href => @fake_pulp3_href + record.id.to_s)
        end
      end

      @switchover = Katello::Pulp3::MigrationSwitchover.new(SmartProxy.pulp_primary, repository_types: ['file', 'docker'])
    end

    def test_file_unit_pulp_ids_updated
      file_unit = katello_files(:one)

      file_unit.update(:migrated_pulp3_href => @another_fake_pulp3_href)
      refute_equal @another_fake_pulp3_href, file_unit.reload.pulp_id

      @switchover.run

      assert_equal @another_fake_pulp3_href, file_unit.reload.pulp_id
    end

    def test_file_unit_with_null_migrated_pulp3_href_throws_an_error
      file_unit = katello_files(:two)
      file_unit.update(:migrated_pulp3_href => nil)

      assert_raises Katello::Pulp3::SwitchOverError do
        @switchover.run
      end
    end

    def test_docker_manifest_pulp_ids_updated
      manifest = FactoryBot.create(:docker_manifest)
      manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href)
      refute_equal @another_fake_pulp3_href, manifest.reload.pulp_id

      @switchover.run

      assert_equal @another_fake_pulp3_href, manifest.reload.pulp_id
    end

    def test_docker_manifest_with_null_migrated_pulp3_href_is_ignored
      item = Katello::DockerManifest.first
      item.update(:migrated_pulp3_href => nil)

      @switchover.run

      refute Katello::DockerManifest.find_by(:id => item.id)
    end

    def test_docker_manifest_list_pulp_ids_updated
      manifest_list = FactoryBot.create(:docker_manifest_list)
      manifest_list.update(:migrated_pulp3_href => @another_fake_pulp3_href)
      docker_manifest = manifest_list.docker_manifests.first
      docker_manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href + docker_manifest.id.to_s)
      refute_equal @another_fake_pulp3_href, manifest_list.reload.pulp_id

      @switchover.run

      assert_equal @another_fake_pulp3_href, manifest_list.reload.pulp_id
    end

    def test_docker_manifest_list_with_null_migrated_pulp3_href_is_not_migrated
      manifest_list = FactoryBot.create(:docker_manifest_list)
      manifest_list.update(:migrated_pulp3_href => nil)

      @switchover.run

      refute Katello::DockerManifestList.find_by(:id => manifest_list.id)
    end

    def test_docker_tag_pulp_ids_updated
      repo = Repository.find(katello_repositories(:busybox).id)
      tag = create(:docker_tag, :repositories => [repo])
      tag.update(:migrated_pulp3_href => @another_fake_pulp3_href)
      tag.update(:pulp_id => "areallyfakepulpid")
      docker_manifest = tag.docker_taggable
      docker_manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href + docker_manifest.id.to_s)

      refute_equal @another_fake_pulp3_href, tag.reload.pulp_id

      ::Katello::Pulp3::MigrationSwitchover.any_instance.expects(:correct_docker_meta_tags).returns(true)
      @switchover.run
      assert_equal @another_fake_pulp3_href, tag.reload.pulp_id
    end

    def test_docker_manifest_tag_with_null_migrated_pulp3_href_is_removed
      repo = Repository.find(katello_repositories(:busybox).id)
      tag = create(:docker_tag, :repositories => [repo])
      tag.update(:migrated_pulp3_href => nil)
      docker_manifest = tag.docker_taggable
      docker_manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href + docker_manifest.id.to_s)

      ::Katello::Pulp3::MigrationSwitchover.any_instance.expects(:correct_docker_meta_tags).returns(true)
      @switchover.run

      refute Katello::DockerTag.find_by(:id => tag.id)
    end

    def test_rpm_pulp_ids_not_updated
      rpm = katello_rpms(:one)
      pulp_id = rpm.pulp_id

      @switchover.run
      assert_equal pulp_id, rpm.reload.pulp_id
    end
  end

  class Pulp3ContentSwitchoverDuplicateDockerTest < SwitchoverBase
    def setup
      super
      SETTINGS[:katello][:use_pulp_2_for_content_type] = {:file => true, :docker => true}

      @repo = katello_repositories(:busybox)
      @cv_archive_repo = katello_repositories(:busybox_view1)

      Katello::RootRepository.docker_type.where.not(:id => @repo.root_id).destroy_all
      @switchover_service = Katello::Pulp3::MigrationSwitchover.new(@primary, repository_types: ['docker'])

      Katello::DockerTag.destroy_all
      Katello::DockerManifest.destroy_all
      @tag1 = FactoryBot.create(:docker_tag, :latest)
      @tag1.update(:migrated_pulp3_href => "/foo/bar")
      @tag1.docker_manifest_list.update(:migrated_pulp3_href => "/foo/manifest")
      @repo.docker_tags << @tag1

      @tag2 = FactoryBot.create(:docker_tag, :latest)
      @tag2.update(:migrated_pulp3_href => "/foo/bar")
      @tag2.docker_manifest_list.update(:migrated_pulp3_href => "/foo/manifest2")
      @cv_archive_repo.docker_tags << @tag2
    end

    def test_docker_tag_cleanup
      assert_equal 2, Katello::DockerTag.count
      ::Katello::Pulp3::MigrationSwitchover.any_instance.expects(:correct_docker_meta_tags).returns(true)
      @switchover_service.run
      assert_equal 1, Katello::DockerTag.count
      tag = Katello::DockerTag.first
      assert_include tag.repositories, @repo
      assert_include tag.repositories, @cv_archive_repo
    end
  end
end
