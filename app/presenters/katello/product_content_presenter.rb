module Katello
  class ProductContentPresenter
    attr_accessor :product_content, :overrides
    delegate :content, :enabled, :product, :to => :product_content

    def initialize(product_content, overrides)
      @product_content = product_content
      @overrides = overrides
    end

    def override
      override = overrides.find { |pc| pc.content_label == content.label && pc.name == "enabled" }
      override.nil? ? 'default' : override.value
    end

    def enabled_content_override
      overrides.find { |pc| pc.content_label == content.label && pc.name == "enabled" }
    end

    def content_overrides
      overrides.find { |pc| pc.content_label == content.label }
    end
  end
end
