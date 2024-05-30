require 'uri'
require 'spidr'

module Katello
  class RepoDiscovery
    include Katello::Util::HttpProxy

    def self.create_for(content_type = 'yum')
      class_for(content_type)
    end

    def self.class_for(content_type)
      case content_type
      when 'file'
        FileDiscovery
      when 'yum'
        YumDiscovery
      when 'docker'
        ContainerDiscovery
      else
        fail _("Invalid content type '%{content_type}' provided. Content types can be one of %{content_types}") %
               { :content_type => content_type, :content_types => ["yum", "docker", "file"].join(", ") }
      end
    end

    def uri(url)
      #add a / on the end, as directories require it or else
      #  They will get double slahes on them
      url += '/' unless url.ends_with?('/')
      URI(url)
    end
  end
end
