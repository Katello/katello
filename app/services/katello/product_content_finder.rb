module Katello
  class ProductContentFinder
    attr_accessor :match_environment, :match_subscription, :consumable

    # consumable must implement:
    #  content_view_environments
    #  organization
    #  products
    def initialize(params = {})
      self.match_subscription = false
      self.match_environment = false

      params.each_pair { |k, v| instance_variable_set("@#{k}", v) unless v.nil? }
    end

    def product_content
      if match_environment
        versions = consumable.content_view_environments.select(:content_view_version_id).map(&:content_view_version_id)
      end

      considered_products = match_subscription ? consumable.products : consumable.organization.products.enabled.uniq

      roots = Katello::RootRepository.where(:product_id => considered_products).subscribable
      roots = roots.in_content_view_version(versions) if versions.present?

      consumable.organization.enabled_product_content_for(roots)
    end

    def custom_content_labels
      product_content.custom.map { |pc| pc.product.root_repositories.map(&:custom_content_label) }.flatten.uniq
    end

    def self.wrap_with_overrides(product_contents:, overrides:, status: nil, repository_type: nil)
      pc_with_overrides = product_contents.map { |pc| ProductContentPresenter.new(pc, overrides) }
      if status
        pc_with_overrides.keep_if do |pc|
          if status == "overridden"
            pc.status[:overridden]
          else
            pc.status[:status] == status
          end
        end
      end
      if %w(custom redhat).include?(repository_type)
        pc_with_overrides.keep_if do |pc|
          pc.product.send("#{repository_type}?".to_sym) # pc.product.redhat? || pc.product.custom?
        end
      end
      pc_with_overrides
    end

    def presenter_with_overrides(overrides)
      product_content.map { |pc| ProductContentPresenter.new(pc, overrides) }
    end
  end
end
