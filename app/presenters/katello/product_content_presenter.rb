module Katello
  class ProductContentPresenter < SimpleDelegator
    attr_accessor :product_content, :overrides

    def initialize(product_content, overrides)
      @product_content = product_content
      @overrides = overrides
      super(@product_content)
    end

    def override
      return 'default' if overrides.blank?
      override = overrides.find { |pc| pc.content_label == content.label && pc.name == "enabled" }
      override.nil? ? 'default' : override.value
    end

    def enabled_content_override
      return nil if overrides.blank?
      overrides.find { |pc| pc.content_label == content.label && pc.name == "enabled" }
    end

    def content_overrides
      return [] if overrides.blank?
      overrides.select { |pc| pc.content_label == content.label }
    end

    def status
      overidden_value = enabled_content_override&.computed_value
      if overidden_value.nil?
        {
          status: enabled ? "enabled" : "disabled",
          overridden: false
        }
      else
        {
          status: overidden_value ? "enabled" : "disabled",
          overridden: true
        }
      end
    end
  end
end
