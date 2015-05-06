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

    def content_override(activation_key)
      override = activation_key.content_overrides.find { |pc| pc[:contentLabel] == content.label }
      override.nil? ? 'default' : override[:value]
    end
  end
end
