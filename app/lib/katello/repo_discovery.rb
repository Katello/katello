require 'uri'

module Katello
  class RepoDiscovery
    include Katello::Util::HttpProxy

    def self.class_for(content_type)
      repo_discovery_class = RepositoryTypeManager.find_repository_type(content_type)&.repo_discovery_class
      fail _("Content type does not support repo discovery") unless repo_discovery_class
      repo_discovery_class
    end

    def uri(url)
      #add a / on the end, as directories require it or else
      #  They will get double slahes on them
      url += '/' unless url.ends_with?('/')
      URI(url)
    end
  end
end
