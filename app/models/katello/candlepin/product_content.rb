module Katello
  class Candlepin::ProductContent
    include ForemanTasks::Triggers

    attr_accessor :content, :enabled, :product, :product_id

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

    # rubocop:disable Lint/DuplicateMethods
    def product
      @product ||= Product.find(@product_id) if @product_id
      @product
    end

    def repositories
      @repos ||= self.product.repos(self.product.organization.library).where(:content_id => self.content.id)
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
