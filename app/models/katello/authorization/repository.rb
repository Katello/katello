module Katello
  module Authorization::Repository
    extend ActiveSupport::Concern

    delegate :editable?, to: :product

    def deletable?(remove_from_content_view_versions = true)
      return false unless product.editable?
      remove_from_content_view_versions || !promoted? || (self.content_views_all(include_composite: true).exists? && !self.content_views_all(include_composite: true).generated_for_none.exists?)
    end

    def redhat_deletable?(remove_from_content_view_versions = false)
      return false unless product.editable?
      remove_from_content_view_versions || !self.promoted? || (self.content_views_all(include_composite: true).exists? && !self.content_views_all(include_composite: true).generated_for_none.exists?)
    end

    def readable?
      self.class.readable.where("#{self.class.table_name}.id" => self.id).any?
    end

    delegate :syncable?, to: :product

    module ClassMethods
      def readable
        in_products = Repository.in_product(Katello::Product.authorized(:view_products)).select(:id)
        in_environments = Repository.where(:environment_id => Katello::KTEnvironment.authorized(:view_lifecycle_environments)).select(:id)
        in_content_views = Repository.joins(:content_view_repositories).where("#{ContentViewRepository.table_name}.content_view_id" => Katello::ContentView.readable).select(:id)
        in_versions = Repository.joins(:content_view_version).where("#{Katello::ContentViewVersion.table_name}.content_view_id" => Katello::ContentView.readable).select(:id)
        joins(:root).where("#{Repository.table_name}.id in (?) or #{self.table_name}.id in (?) or #{self.table_name}.id in (?) or #{self.table_name}.id in (?)", in_products, in_content_views, in_versions, in_environments)
      end

      def readable_as(user)
        in_products = Repository.in_product(Katello::Product.authorized_as(user, :view_products)).select(:id)
        in_environments = Repository.where(:environment_id => Katello::KTEnvironment.authorized_as(user, :view_lifecycle_environments)).select(:id)
        in_content_views = Repository.joins(:content_view_repositories).where("#{ContentViewRepository.table_name}.content_view_id" => Katello::ContentView.readable_as(user)).select(:id)
        in_versions = Repository.joins(:content_view_version).where("#{Katello::ContentViewVersion.table_name}.content_view_id" => Katello::ContentView.readable_as(user)).select(:id)
        joins(:root).where("#{Repository.table_name}.id in (?) or #{self.table_name}.id in (?) or #{self.table_name}.id in (?) or #{self.table_name}.id in (?)", in_products, in_content_views, in_versions, in_environments)
      end

      def readable_docker_catalog(host = nil)
        #If host is identified in the request via certs or IP addr, and the host is registered (uuid != nil), show only
        # available repos in host's LCE scope
        if host && host&.content_facet&.uuid
          repo_ids = []
          if host&.content_view_environments&.any?
            repo_ids = host.content_view_environments.flat_map do |cve|
              cve&.content_view_version&.repositories&.where(environment_id: cve.environment)&.pluck(:id)
            end
            repo_ids = repo_ids.compact.uniq
          end

          base_scope = Katello::Repository.non_archived.docker_type
          return base_scope.where(id: repo_ids)
        end
        readable_docker_catalog_as(User.current)
      end

      def readable_docker_catalog_as(user)
        table_name = Repository.table_name
        in_unauth_environments = Repository.joins(:environment).where("#{Katello::KTEnvironment.table_name}.registry_unauthenticated_pull" => true).select(:id)
        Repository.readable_as(user).or(Repository.joins(:root).where("#{table_name}.id in (?)", in_unauth_environments)).non_archived.docker_type
      end

      def exportable
        in_product(Katello::Product.exportable)
      end

      def deletable
        in_product(Katello::Product.authorized(:destroy_products))
      end

      def syncable
        in_product(Katello::Product.authorized(:sync_products))
      end

      def editable
        in_product(Katello::Product.editable)
      end
    end
  end
end
