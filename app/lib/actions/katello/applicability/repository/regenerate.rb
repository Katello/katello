module Actions
  module Katello
    module Applicability
      module Repository
        class Regenerate < Actions::EntryAction
          input_format do
            param :repo_ids, Array
          end

          def run
            repos = ::Katello::Repository.where(:id => input[:repo_ids]).select do |repo|
              repo.last_contents_changed >= repo.last_applicability_regen
            end

            if repos.any?
              host_ids = ::Katello::RootRepository.where(:id => repos.map(&:root_id)).hosts_with_applicability.pluck(:id)
              ::Katello::Host::ContentFacet.trigger_applicability_generation(host_ids) unless host_ids.empty?

              ::Katello::Repository.where(:id => repos.map(&:id)).update_all(:last_applicability_regen => DateTime.now)
            end
            output[:regenerated => repos.map(&:id)]
          end

          def humanized_name
            _("Generate repository applicability")
          end
        end
      end
    end
  end
end
