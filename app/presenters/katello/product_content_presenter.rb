module Katello
  class ProductContentPresenter < SimpleDelegator
    attr_accessor :product_content, :overrides

    def initialize(product_content, overrides)
      @product_content = product_content
      @overrides = overrides
      super(@product_content)
    end

    def override
      override = overrides.find { |pc| pc.content_label == content.label && pc.name == "enabled" }
      override.nil? ? 'default' : override.value
    end

    def enabled_content_override
      overrides.find { |pc| pc.content_label == content.label && pc.name == "enabled" }
    end

    def content_overrides
      overrides.select { |pc| pc.content_label == content.label }
    end

    def legacy_content_override
      override = @overrides.find { |pc| pc.content_label == content.label && pc.name == "enabled" }
      override.nil? ? 'default' : override.value
    end
  end
end
