module Katello
  class ProductContentFinder
    attr_accessor :match_environment, :match_subscription, :consumable

    #consumable must implement:
    #  content_view
    #  lifecycle_environment
    #  organization
    #  products
    def initialize(params = {})
      self.match_subscription = false
      self.match_environment = false

      params.each_pair { |k, v| instance_variable_set("@#{k}", v) unless v.nil? }
    end

    def product_content
      if match_environment
        environment = consumable.lifecycle_environment
        view = consumable.content_view
        return [] unless environment && view
        version = ContentViewVersion.in_environment(environment).where(:content_view_id => view).first
      end

      considered_products = match_subscription ? consumable.products : consumable.organization.products.enabled.uniq

      repositories = Katello::Repository.where(:product_id => considered_products).subscribable
      repositories = repositories.where(:content_view_version_id => version .id) if version

      consumable.organization.enabled_product_content_for(repositories)
    end

    def presenter_with_overrides(overrides)
      product_content.map { |pc| ProductContentPresenter.new(pc, overrides) }
    end
  end
end
