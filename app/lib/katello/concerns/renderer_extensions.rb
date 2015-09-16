module Katello
  module Concerns
    module RendererExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :kickstart_attributes, :katello
      end

      def kickstart_attributes_with_katello
        kickstart_attributes_without_katello

        if @host.content_aspect.try(:content_view) && @host.operatingsystem.is_a?(Redhat) &&
          !@host.operatingsystem.kickstart_repo(@host).blank?

          @mediapath ||= @host.operatingsystem.mediumpath(@host)
        end
      end
    end
  end
end
