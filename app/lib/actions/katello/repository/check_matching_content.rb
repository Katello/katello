module Actions
  module Katello
    module Repository
      class CheckMatchingContent < Actions::Base
        input_format do
          param :source_repo
          param :target_repo
        end

        # Check if content in the repositories has changed. We can use
        # this info to skip regenerating metadata in pulp, keeping the
        # revision number on the repo the same
        def run
          source_repo = ::Katello::Repository.find(input[:source_repo_id])
          target_repo = ::Katello::Repository.find(input[:target_repo_id])
          target_repo_published = target_repo.backend_service(SmartProxy.pulp_primary).published?

          if source_repo.content_type == ::Katello::Repository::YUM_TYPE
            srpms_match = srpms_match?(source_repo, target_repo)
            rpms = rpms_match?(source_repo, target_repo)
            errata = errata_match?(source_repo, target_repo)
            package_groups = package_groups_match?(source_repo, target_repo)
            distributions = distributions_match?(source_repo, target_repo)
            checksum_match = (target_repo.saved_checksum_type == source_repo.saved_checksum_type)

            output[:checksum_match] = checksum_match
            output[:matching_content] = srpms_match && rpms && errata && package_groups && distributions && target_repo_published && checksum_match
          end

          if source_repo.deb?
            debs = debs_match?(source_repo, target_repo)

            output[:matching_content] = debs && target_repo_published
          end
        end

        def debs_match?(source_repo, target_repo)
          source_repo.deb_ids.sort == target_repo.deb_ids.sort
        end

        def srpms_match?(source_repo, target_repo)
          source_repo_ids = source_repo.srpm_ids.sort.uniq
          target_repo_ids = target_repo.srpm_ids.sort.uniq
          source_repo_ids == target_repo_ids
        end

        def rpms_match?(source_repo, target_repo)
          source_repo_ids = source_repo.rpm_ids.sort.uniq
          target_repo_ids = target_repo.rpm_ids.sort.uniq
          source_repo_ids == target_repo_ids
        end

        def errata_match?(source_repo, target_repo)
          source_repo_ids = source_repo.erratum_ids.sort.uniq
          target_repo_ids = target_repo.erratum_ids.sort.uniq
          source_repo_ids == target_repo_ids
        end

        def package_groups_match?(source_repo, target_repo)
          source_repo_ids = source_repo.package_groups.order(:name).pluck(:name).uniq
          target_repo_ids = target_repo.package_groups.order(:name).pluck(:name).uniq
          source_repo_ids == target_repo_ids
        end

        def distributions_match?(source_repo, target_repo)
          source_repo.distribution_information == target_repo.distribution_information
        end
      end
    end
  end
end
