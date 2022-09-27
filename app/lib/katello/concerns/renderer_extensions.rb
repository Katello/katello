module Katello
  module Concerns
    module RendererExtensions
      extend ActiveSupport::Concern

      module Overrides
        def kickstart_attributes
          super

          medium_provider = Katello::ManagedContentMediumProvider.new(host)
          content_view = host.try(:content_facet).try(:content_view) || host.try(:content_view)

          if content_view && host.operatingsystem.is_a?(Redhat) &&
                  host.operatingsystem.kickstart_repos(host).first.present? &&
                  host&.content_facet&.kickstart_repository.present?
            @mediapath ||= host.operatingsystem.mediumpath(medium_provider)
          end
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
