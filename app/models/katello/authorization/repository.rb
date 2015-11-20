module Katello
  module Authorization::Repository
    extend ActiveSupport::Concern

    include Authorizable

    delegate :editable?, to: :product

    def deletable?
      product.editable? && !promoted?
    end

    def redhat_deletable?
      !self.promoted? && self.product.editable?
    end

    def readable?
      self.class.readable.where("#{self.class.table_name}.id" => self.id).any?
    end

    delegate :syncable?, to: :product

    module ClassMethods
      def readable
        in_products = Repository.where(:product_id => Katello::Product.authorized(:view_products))
        in_content_views = Repository.joins(:content_view_repositories).where("#{ContentViewRepository.table_name}.content_view_id in (?)", ContentView.readable)
        in_versions = Repository.joins(:content_view_version).where("#{Katello::ContentViewVersion.table_name}.content_view_id" => ContentView.readable)
        where("#{self.table_name}.id in (?) or #{self.table_name}.id in (?) or #{self.table_name}.id in (?)", in_products, in_content_views, in_versions)
      end

      def deletable
        where(:product_id => Katello::Product.authorized(:destroy_products))
      end

      def syncable
        where(:product_id => Katello::Product.authorized(:sync_products))
      end

      def libraries_content_readable(_org)
        repos = Repository.readable
        lib_ids = []
        repos.each { |r|  lib_ids << (r.library_instance_id || r.id) }
        where(:id => lib_ids)
      end

      def content_readable(org)
        prod_ids = Katello::Product.readable.collect { |p| p.id }
        env_ids = KTEnvironment.content_readable(org)
        where(environment_id: env_ids, product_id: prod_ids)
      end

      def readable_in_org(org, *skip_library)
        if (skip_library.empty? || skip_library.first.nil?)
          # 'skip library' not included, so retrieve repos in library in the result
          where(environment_id: KTEnvironment.content_readable(org))
        else
          where(environment_id: KTEnvironment.content_readable(org).non_library)
        end
      end
    end
  end
end
