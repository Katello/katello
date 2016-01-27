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
        in_products = Repository.where(:product_id => Katello::Product.authorized(:view_products)).pluck(:id)
        in_content_views = Repository.joins(:content_view_repositories).where("#{ContentViewRepository.table_name}.content_view_id" => Katello::ContentView.readable).pluck(:id)
        in_versions = Repository.joins(:content_view_version).where("#{Katello::ContentViewVersion.table_name}.content_view_id" => Katello::ContentView.readable).pluck(:id)
        where("#{self.table_name}.id in (?) or #{self.table_name}.id in (?) or #{self.table_name}.id in (?)", in_products, in_content_views, in_versions)
      end

      def deletable
        where(:product_id => Katello::Product.authorized(:destroy_products))
      end

      def syncable
        where(:product_id => Katello::Product.authorized(:sync_products))
      end
    end
  end
end
