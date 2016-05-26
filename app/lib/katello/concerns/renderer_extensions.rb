module Katello
  module Concerns
    module RendererExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :kickstart_attributes, :katello
      end

      def kickstart_attributes_with_katello
        kickstart_attributes_without_katello

        content_view = @host.try(:content_facet).try(:content_view) || @host.try(:content_view)
        if content_view && @host.operatingsystem.is_a?(Redhat) &&
                @host.operatingsystem.kickstart_repos(@host).first.present?
          @mediapath ||= @host.operatingsystem.mediumpath(@host)
        end
      end
    end
  end
end
