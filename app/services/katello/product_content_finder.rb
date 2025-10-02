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
      roots = roots.in_content_view_version(versions).distinct if versions.present?
      content_ids = roots.where.not(:content_type => ::Katello::Repository::DEB_TYPE).pluck(:content_id)
      deb_roots = roots.where(:content_type => ::Katello::Repository::DEB_TYPE)
      if deb_roots.any?
        # deb? roots need to be considered separately because they do not have content_ids on the root!
        deb_repos_query = Katello::Repository.where(root: deb_roots)
        deb_repos_library = Set.new
        deb_repos_batch = []
        if match_environment
          consumable.content_view_environments.each do |cve|
            deb_repos_batch = deb_repos_query.where("content_view_version_id = ? AND environment_id = ?", cve.content_view_version_id, cve.environment_id).where.not(library_instance_id: deb_repos_library.to_a)
            deb_repos_library.merge(deb_repos_batch.pluck(:library_instance_id))
            content_ids += deb_repos_batch.pluck(:content_id)
          end
        else
          content_ids += deb_repos_query.where(:library_instance_id => nil).pluck(:content_id)
        end
      end

      consumable.organization.enabled_product_content_for(content_ids)
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
