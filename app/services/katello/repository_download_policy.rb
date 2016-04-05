module Katello
  class RepositoryDownloadPolicy
    class << self
      def policies
        if !::Foreman.in_rake? && Setting[:enable_deferred_download_policies]
          ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES
        else
          ["immediate"]
        end
      end

      def default
        if policies.include?(Setting[:default_download_policy])
          Setting[:default_download_policy]
        else
          policies.first
        end
      end
    end
  end
end
