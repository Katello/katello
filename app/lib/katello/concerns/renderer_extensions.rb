module Katello
  module Concerns
    module RendererExtensions
      extend ActiveSupport::Concern

      module Overrides
        def kickstart_attributes
          super

          content_view = host.try(:content_facet).try(:content_view) || host.try(:content_view)
          if content_view && host.operatingsystem.is_a?(Redhat) &&
                  host.operatingsystem.kickstart_repos(host).first.present?
            @mediapath ||= host.operatingsystem.mediumpath(host)
          end
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
