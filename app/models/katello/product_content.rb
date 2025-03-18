module Katello
  class ProductContent < Katello::Model
    belongs_to :product, :class_name => 'Katello::Product', :inverse_of => :product_contents
    belongs_to :content, :class_name => 'Katello::Content', :inverse_of => :product_contents

    validates :enabled, inclusion: { in: [true, false], message: N_("must be true or false") }

    default_scope { includes(:content) }

    delegate :content_type, to: :content

    scope :displayable, -> {
      joins(:content).where.not("#{content_table_name}.content_type IN (?)", Katello::Repository.undisplayable_types)
    }

    scope :redhat, -> {
      where(:product_id => Product.redhat.select(:id))
    }
    scope :custom, -> {
      where.not(:product_id => Product.redhat.select(:id))
    }

    scoped_search :on => :name, :relation => :content
    scoped_search :relation => :product, :on => :name, :rename => :product
    scoped_search :on => :content_type, :relation => :content, :complete_value => true
    scoped_search :on => :label, :relation => :content
    scoped_search :on => :content_url, :relation => :content, :rename => :path
    scoped_search :on => :enabled, :rename => :enabled_by_default, :complete_value => { :true => true, :false => false }
    scoped_search :on => :name, :relation => :product, :rename => :product_name
    scoped_search :on => :id, :relation => :product, :rename => :product_id, :only_explicit => true
    scoped_search :on => :label, :relation => :content, :rename => :content_label
    scoped_search :on => :id, :rename => :redhat, :ext_method => :search_by_redhat, :complete_value => { :true => true, :false => false }, :only_explicit => true

    def self.search_by_redhat(_key, _operator, value)
      conditions = Arel.sql(value == 'true' ? "#{Provider.table_name}.provider_type = 'Red Hat'" : "#{Provider.table_name}.provider_type != 'Red Hat'")
      {
        :conditions => conditions, :order => "#{Product.table_name}.name",
        :include => :product,
        :joins => {:product => :provider}
      }
    end

    def self.content_table_name
      Katello::Content.table_name
    end

    def self.enabled(organization)
      content_ids = Katello::RootRepository.in_organization(organization).where.not(content_id: nil).pluck(:content_id)
      structured_apt_content_ids = Katello::Repository.in_organization(organization).library.pluck(:content_id)
      joins(:content).where("#{self.content_table_name}.cp_content_id" => content_ids + structured_apt_content_ids)
    end

    def self.with_valid_subscription(organization)
      where(:product_id => Katello::PoolProduct.where(:pool_id => organization.pools).select(:product_id))
    end

    # following 4 methods used by Katello::Api::V2::RepositorySetsController#index
    def repositories
      Katello::Repository.in_default_view.where(:root_id => product.root_repositories.has_url.where(:content_id => content.cp_content_id))
    end

    def unfiltered_repositories
      # don't filter by url, as we want to show all repos in the product
      Katello::Repository.in_default_view.where(:root_id => product.root_repositories.where(:content_id => content.cp_content_id))
    end

    def arch
      unfiltered_repositories.first&.arch
    end

    def os_versions
      unfiltered_repositories.first&.os_versions || []
    end

    def enabled_value_from_candlepin
      cp_product = ::Katello::Resources::Candlepin::Product.get(product.organization.label, product.cp_id).first
      cp_content = cp_product['productContent'].find { |pc| pc['content']['id'] == content.cp_content_id }
      cp_content['enabled']
    end

    def set_enabled_from_candlepin!
      new_value = enabled_value_from_candlepin
      if self.enabled != new_value
        Rails.logger.info "Setting enabled to #{new_value} for Candlepin content #{content.cp_content_id}, ProductContent #{self.id}"
        self.update!(:enabled => new_value)
      else
        Rails.logger.info "No change in enabled value for Candlepin content #{content.cp_content_id}, ProductContent #{self.id}"
        false
      end
    end
  end
end
