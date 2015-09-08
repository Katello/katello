module Katello
  module Authorization::Organization
    extend ActiveSupport::Concern

    include Authorizable

    def editable?
      authorized?(:edit_organizations)
    end

    def manifest_importable?
      authorized?(:import_manifest)
    end

    def readable_promotion_paths
      permissible_promotion_paths(KTEnvironment.readable)
    end

    def promotable_promotion_paths
      permissible_promotion_paths(KTEnvironment.promotable)
    end

    def permissible_promotion_paths(permissible_environments)
      promotion_paths.select do |promotion_path|
        # if at least one environment in the path is permissible
        # the path is deemed permissible.
        (promotion_path - permissible_environments).size != promotion_path.size
      end
    end

    def subscriptions_readable?
      User.current.can?(:view_subscriptions)
    end
  end
end
