module Katello
  module ContentSearch
    class ProductRow < Row
      attr_accessor :product

      def initialize(options)
        super
        build_row
      end

      def build_row
        self.data_type ||= "product"
        self.cols ||= {}
        self.id ||= build_id
        self.name ||= product.name
      end

      def build_id
        [parent_id, data_type, product.id].select(&:present?).join("_")
      end
    end
  end
end
