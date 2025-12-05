module Katello
  module ErrataMailerHelper
    def content_host_errata_path(host)
      "#{Setting[:foreman_url]}#{Rails.application.routes.url_helpers.host_details_page_path(host.name)}#/Content/errata"
    end

    def content_view_environment_errata_path(content_view, environment)
      version = Katello::ContentViewEnvironment.find_by(:content_view_id => content_view.id, :environment_id => environment.id).content_view_version_id
      "#{Setting[:foreman_url]}/content_views/#{content_view.id}/versions/#{version}/errata"
    end

    def content_view_path(content_view)
      "#{Setting[:foreman_url]}/content_views/#{content_view.id}/versions"
    end

    def erratum_path(erratum)
      "#{Setting[:foreman_url]}/errata/#{erratum.id}"
    end

    def repository_erratum_path(repository, type = nil)
      url = "#{Setting[:foreman_url]}/errata?repositoryId=#{repository.id}"
      url += "&search=type%3D#{type}" if type
      url
    end

    def errata_count(host, errata_type)
      available = host.content_facet.installable_errata.send(errata_type.to_sym).count
      applicable = host.content_facet.applicable_errata.send(errata_type.to_sym).count - available
      "#{available} (#{applicable})"
    end

    def format_summary(summary)
      summary.blank? ? summary : summary.gsub(/\n\n/, '<p>').gsub(/\n/, ' ').html_safe
    end

    def host_count(hosts, errata_type)
      hosts.to_a.count { |host| host.content_facet.installable_errata.send(errata_type.to_sym).any? }
    end
  end
end
