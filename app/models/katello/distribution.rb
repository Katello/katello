module Katello
  class Distribution
    include Glue::Pulp::Distribution if Katello.config.use_pulp
    include Glue::ElasticSearch::Distribution if Katello.config.use_elasticsearch
    CONTENT_TYPE = "distribution"

    def bootable?
      # Not every distribution from Pulp represents a bootable
      # repo. Determine based on the files in the repo.
      self.files.any? do |file|
        if file.is_a? Hash
          filename = file[:relativepath]
        else
          filename = file
        end
        filename.include?("vmlinuz") || filename.include?("pxeboot")
      end
    end
  end
end
