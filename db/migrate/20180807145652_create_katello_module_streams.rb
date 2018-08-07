class CreateKatelloModuleStreams < ActiveRecord::Migration[5.1]
  #rubocop:disable Metrics/MethodLength
  def up
    create_table :katello_module_streams do |t|
      t.string :name
      t.string :uuid, null: false
      t.string :version
      t.string :context
      t.string :stream
      t.string :arch

      t.timestamps
    end

    create_table :katello_repository_module_streams do |t|
      t.references :repository, null: false, index: { name: :katello_repository_module_stream_repo_id }
      t.references :module_stream, null: false, index: { name: :katello_repository_module_stream_mod_id }

      t.timestamps
    end

    create_table :katello_module_profiles do |t|
      t.references :module_stream, null: false, index: { name: :katello_module_profile_mod_stream_idx }
      t.string :name, null: false

      t.timestamps
    end

    create_table :katello_module_profile_rpms do |t|
      t.references :module_profile, null: false, index: { name: :katello_mod_profile_rpms_mod_profile_idx }
      t.string :name, null: false

      t.timestamps
    end

    create_table :katello_module_stream_rpms do |t|
      t.references :module_stream, null: false, index: { name: :katello_mod_stream_rpms_mod_stream_idx }
      t.string :nvra

      t.timestamps
    end

    add_index :katello_repository_module_streams, [:repository_id, :module_stream_id],
              unique: true, name: :katello_module_streams_repo_stream_uniq

    add_index :katello_module_stream_rpms, [:module_stream_id, :nvra],
              unique: true, name: :katello_module_stream_rpms_nvra_mod_stream_id_uniq

    add_foreign_key :katello_repository_module_streams,
                    :katello_repositories,
                    column: :repository_id,
                    name: :katello_repo_mod_stream_repo_id_fk

    add_foreign_key :katello_repository_module_streams,
                    :katello_module_streams,
                    column: :module_stream_id,
                    name: :katello_repo_mod_stream_mod_stream_id_fk

    add_foreign_key :katello_module_profiles,
                    :katello_module_streams,
                    column: :module_stream_id,
                    name: :katello_mod_profile_mod_stream_id_fk

    add_foreign_key :katello_module_profile_rpms,
                    :katello_module_profiles,
                    column: :module_profile_id,
                    name: :katello_mod_profile_rpm_mod_profile_id_fk

    add_foreign_key :katello_module_stream_rpms,
                    :katello_module_streams,
                    column: :module_stream_id,
                    name: :katello_mod_stream_rpms_mod_stream_id_fk
  end

  def down
    remove_foreign_key :katello_repository_module_streams, name: :katello_repo_mod_stream_repo_id_fk
    remove_foreign_key :katello_repository_module_streams, name: :katello_repo_mod_stream_mod_stream_id_fk
    remove_foreign_key :katello_module_profiles, name: :katello_mod_profile_mod_stream_id_fk
    remove_foreign_key :katello_module_profile_rpms, name: :katello_mod_profile_rpm_mod_profile_id_fk
    remove_foreign_key :katello_module_stream_rpms, name: :katello_mod_stream_rpms_mod_stream_id_fk

    drop_table :katello_module_streams
    drop_table :katello_repository_module_streams
    drop_table :katello_module_profiles
    drop_table :katello_module_profile_rpms
    drop_table :katello_module_stream_rpms
  end
end
