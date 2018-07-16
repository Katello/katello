module Katello
  class ManagedContentMediumProvider < ::MediumProviders::Provider
    def validate
      errors = []

      kickstart_repo = entity.try(:content_facet).try(:kickstart_repository) || entity.try(:kickstart_repository)

      errors << N_("Kickstart repository was not set for host '%{host}'") % { :host => entity } if kickstart_repo.nil?
      errors << N_("Content source was not set for host '%{host}'") % { :host => entity } if entity.content_source.nil?
      errors
    end

    def medium_uri(path = "")
      kickstart_repo = entity.try(:content_facet).try(:kickstart_repository) || entity.try(:kickstart_repository)
      url = kickstart_repo.full_path(entity.content_source)
      url += '/' + path unless path.empty?
      URI.parse(url)
    end

    def unique_id
      @unique_id ||= begin
        "#{entity.kickstart_repository.name.parameterize}-#{entity.kickstart_repository_id}"
      end
    end
  end
end
