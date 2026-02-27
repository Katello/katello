module Actions
  module Katello
    module Repository
      class FetchPxeFiles < Actions::EntryAction
        input_format do
          param :id, Integer
          param :capsule_id, Integer
        end

        def run
          repository = ::Katello::Repository.find(input[:id])
          return unless needs_download?(repository)

          capsule = if input[:capsule_id].present?
                      SmartProxy.unscoped.find(input[:capsule_id])
                    else
                      SmartProxy.pulp_primary!
                    end

          downloader = ::Katello::PxeFilesDownloader.new(repository, capsule)
          downloader.download_files
        end

        private

        def needs_download?(repository)
          repository.distribution_bootable? &&
             repository.download_policy == ::Katello::RootRepository::DOWNLOAD_ON_DEMAND
        end
      end
    end
  end
end
