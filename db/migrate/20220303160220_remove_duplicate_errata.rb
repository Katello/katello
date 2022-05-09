class RemoveDuplicateErrata < ActiveRecord::Migration[6.0]
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
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
      ::Katello::ContentFacetErratum.where(erratum_id: dup_errata&.map(&:id)).each do |host_erratum|
        if ::Katello::ContentFacetErratum.find_by(content_facet_id: host_erratum.content_facet_id, erratum_id: errata_to_keep.id)
          host_erratum.delete
        else
          host_erratum.update(erratum_id: errata_to_keep.id)
        end
      end
      dup_errata_ids = dup_errata&.pluck(:id)

      erratum_packages = ::Katello::ErratumPackage.where(:erratum_id => dup_errata_ids)
      erratum_packages.each do |dup_err_package|
        erratum_package_to_keep = ::Katello::ErratumPackage.find_by(erratum_id: errata_to_keep.id, nvrea: dup_err_package.nvrea)
        ::Katello::ModuleStreamErratumPackage.where(erratum_package_id: dup_err_package).each do |dup_mod_errata_package|
          if ::Katello::ModuleStreamErratumPackage.find_by(module_stream_id: dup_mod_errata_package.module_stream_id, erratum_package_id: erratum_package_to_keep&.id)
            dup_mod_errata_package.delete
          else
            begin
              dup_mod_errata_package.update(erratum_package_id: erratum_package_to_keep&.id)
            rescue
              dup_mod_errata_package.delete
            end
          end
        end
      end

      dup_errata_ids = dup_errata&.pluck(:id)
      if dup_errata_ids&.present?
        erratum_packages = ::Katello::ErratumPackage.where(:erratum_id => dup_errata_ids)
        ::Katello::ModuleStreamErratumPackage.where(erratum_package_id: erratum_packages).delete_all
        erratum_packages.delete_all
        ::Katello::ErratumBugzilla.where(:erratum_id => dup_errata_ids).delete_all
        ::Katello::ErratumCve.where(:erratum_id => dup_errata_ids).delete_all
        ::Katello::Erratum.where(:id => dup_errata_ids).delete_all
      end
    end
  end

  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
  def down
    #Don't do anything on reverse
  end
end
