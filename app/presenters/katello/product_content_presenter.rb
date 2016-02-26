module Katello
  class ProductContentPresenter
    attr_accessor :product_content, :overrides
    delegate :content, :enabled, :product, :to => :product_content

    def initialize(product_content, overrides)
      @product_content = product_content
      @overrides = overrides
    end

    def enabled_override
      override = overrides.find { |pc| pc[:contentLabel] == content.label }
      override.nil? ? 'default' : override[:value]
    end
  end
end
