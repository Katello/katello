class RemoveDuplicateErrata < ActiveRecord::Migration[6.0]
  def up
    #Update all unique errata records to have pulp_id = errata_id
    ::Katello::Erratum.group(:errata_id).having("count(errata_id) = 1").pluck(:errata_id).each do |original_errata_id|
      erratum = ::Katello::Erratum.find_by(errata_id: original_errata_id)
      if (erratum.pulp_id != erratum.errata_id)
        erratum.pulp_id = erratum.errata_id
        erratum.save!
      end
    end

    #For duplicate errata,
    # a) update all RepositoryErrata to point to unique errata,
    # b) if repo-errata association for that combination exists, delete duplicate errata association
    # c) Delete all duplicate errata and child records
    ::Katello::Erratum.group(:errata_id).having("count(errata_id) > 1").pluck(:errata_id).each do |original_errata_id|
      errata_to_keep = ::Katello::Erratum.find_by(pulp_id: original_errata_id)
      errata_all = ::Katello::Erratum.where(errata_id: original_errata_id)
      dup_errata = errata_all - [errata_to_keep]
      ::Katello::RepositoryErratum.where(erratum_id: dup_errata&.map(&:id)).each do |repo_erratum|
        if ::Katello::RepositoryErratum.find_by(repository_id: repo_erratum.repository_id, erratum_id: errata_to_keep.id)
          repo_erratum.delete
        else
          repo_erratum.update(erratum_id: errata_to_keep.id)
        end
      end
      dup_errata_ids = dup_errata&.pluck(:id)
      if dup_errata_ids&.present?
        ::Katello::ErratumPackage.where(:erratum_id => dup_errata_ids).delete_all
        ::Katello::ErratumBugzilla.where(:erratum_id => dup_errata_ids).delete_all
        ::Katello::ErratumCve.where(:erratum_id => dup_errata_ids).delete_all
        ::Katello::Erratum.where(:id => dup_errata_ids).delete_all
      end
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
