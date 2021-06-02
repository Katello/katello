class FixRedHatRootRepositoryArch < ActiveRecord::Migration[6.0]
  def up
    ::Katello::RootRepository.
      joins("INNER JOIN katello_contents ON katello_contents.cp_content_id = katello_root_repositories.content_id").
      where.not(arch: 'noarch').where.not("katello_contents.content_url ILIKE '%$basearch%'").update(arch: 'noarch')
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
