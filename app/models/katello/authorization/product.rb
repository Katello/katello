module Katello
  module Authorization
    module Product
      extend ActiveSupport::Concern

      include Authorizable

      def readable?
        authorized?(:view_products)
      end

      def syncable?
        authorized?(:sync_products)
      end

      def editable?
        authorized?(:edit_products)
      end

      def deletable?
        promoted_repos = repositories.select { |repo| repo.promoted? }
        authorized?(:destroy_products) && (promoted_repos.empty? || Setting[:delete_repo_across_cv])
      end

      module ClassMethods
        def readable
          authorized(:view_products)
        end

        def editable
          authorized(:edit_products)
        end

        def deletable
          authorized(:destroy_products)
        end

        def syncable
          authorized(:sync_products)
        end

        def readable?
          ::User.current.can?(:view_products)
        end

        def readable_repositories(repo_ids = nil)
          query = Katello::Repository.all

          if repo_ids
            query = query.where(:id => repo_ids)
          end

          query.joins(:content_view_version)
               .where("#{::Katello::ContentViewVersion.table_name}.content_view_id" => Katello::ContentView.default.pluck(:id))
               .in_product(::Katello::Product.readable)
        end

        def syncable?
          ::User.current.can?(:sync_products)
        end
      end # ClassMethods
    end # Product
  end # Authorization
end # Katello
