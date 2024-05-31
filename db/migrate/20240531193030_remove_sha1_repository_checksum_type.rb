class RemoveSha1RepositoryChecksumType < ActiveRecord::Migration[6.1]
  def up
    ::Katello::Repository.where(saved_checksum_type: 'sha1').update(saved_checksum_type: nil)
    ::Katello::RootRepository.where(checksum_type: 'sha1').update(checksum_type: nil)
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
