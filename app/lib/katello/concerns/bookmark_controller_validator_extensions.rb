module Katello
  module Concerns
    module BookmarkControllerValidatorExtensions
      KATELLO_CONTROLLERS = %w[
        /katello/api/v2/host_bootc_images
        /katello/api/v2/flatpak_remotes
        /katello/api/v2/flatpak_remote_repositories
      ].freeze

      def valid_controllers_list
        super + KATELLO_CONTROLLERS
      end
    end
  end
end
