class CreateKatelloFlatpakTables < ActiveRecord::Migration[6.1]
  #rubocop:disable Metrics/MethodLength
  def change
    create_table :katello_flatpak_remotes do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.integer :organization_id, null: false
      t.text :description
      t.boolean :seeded, default: false, null: false
      t.string :username
      t.text :token
      t.timestamps
    end

    add_foreign_key :katello_flatpak_remotes, :taxonomies, name: 'katello_flatpak_remotes_organization_id', column: :organization_id

    create_table :katello_flatpak_remote_repositories do |t|
      t.string :name, null: false
      t.string :label, null: false
      t.integer :flatpak_remote_id, null: false
      t.timestamps
    end

    create_table :katello_flatpak_remote_repository_manifests do |t|
      t.integer :flatpak_remote_repository_id, null: false
      t.string :digest, null: false
      t.string :tags, array: true, default: []
      t.string :name, null: false
      t.boolean :application, default: true, null: false
      t.text :runtime
      t.string :flatpak_ref, null: false
      t.timestamps
    end

    add_index :katello_flatpak_remote_repository_manifests, :flatpak_ref, name: 'index_remote_repository_manifests_on_flatpak_ref'
    add_index :katello_flatpak_remote_repository_manifests, [:flatpak_remote_repository_id, :digest], unique: true, name: 'index_remote_repository_manifests_on_repo_id_and_digest'
    add_foreign_key :katello_flatpak_remote_repository_manifests, :katello_flatpak_remote_repositories, column: :flatpak_remote_repository_id
    add_foreign_key :katello_flatpak_remote_repositories, :katello_flatpak_remotes, column: :flatpak_remote_id
  end
  #rubocop:enable Metrics/MethodLength
end
