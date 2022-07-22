class CleanMissingModuleStreamErratumPackages < ActiveRecord::Migration[6.0]
  def up
    dup_errata_ids = Katello::Erratum.having("count(errata_id) > 1").group(:errata_id).pluck(:errata_id)
    dup_errata_repos = ::Katello::Repository.joins(:errata).where('katello_errata.errata_id' => dup_errata_ids).in_default_view.distinct
    dup_errata_repos.each do |repo|
      if repo.module_streams.present? 
        repo.index_content
      end
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
