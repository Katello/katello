module Katello
  class Candlepin::ProductContent
    include ForemanTasks::Triggers

    attr_accessor :content, :enabled, :product

    def initialize(params = {}, product_id = nil)
      params = params.with_indifferent_access
      #controls whether repo is enabled in yum repo file on client
      #  unrelated to enable/disable from katello
      @enabled = params[:enabled]
      @content = Candlepin::Content.new(params[:content])
      @product_id = product_id
    end

    def create
      @content.create
    end

    def destroy
      @content.destroy
    end

    def product
      @product ||= Product.find(@product_id) if @product_id
      @product
    end

    def repositories
      @repos ||= self.product.repos(self.product.organization.library).where(:content_id => self.content.id)
    end

    def legacy_content_override(activation_key)
      override = activation_key.content_overrides.find { |pc| pc.content_label == content.label && pc.name == "enabled" }
      override.nil? ? 'default' : override.value
    end

    def content_overrides(activation_key)
      activation_key.content_overrides.select { |pc| pc.content_label == content.label }
    end

    def enabled_content_override(activation_key)
      activation_key.content_overrides.find { |pc| pc.content_label == content.label && pc.name == "enabled" }
    end

    def content_type
      self.content.type
    end

    def displayable?
      case content_type
      when ::Katello::Repository::CANDLEPIN_DOCKER_TYPE
        false
      when ::Katello::Repository::CANDLEPIN_OSTREE_TYPE
        ::Katello::RepositoryTypeManager.enabled?(Repository::OSTREE_TYPE)
      else
        true
      end
    end
  end
end
