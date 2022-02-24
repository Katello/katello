module Katello
  class ProductContent < Katello::Model
    belongs_to :product, :class_name => 'Katello::Product', :inverse_of => :product_contents
    belongs_to :content, :class_name => 'Katello::Content', :inverse_of => :product_contents

    default_scope { includes(:content) }

    delegate :content_type, to: :content

    scope :displayable, -> {
      joins(:content).where.not("#{content_table_name}.content_type IN (?)", Katello::Repository.undisplayable_types)
    }

    scope :redhat, -> {
      where(:product_id => Product.redhat.select(:id))
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

    def self.content_table_name
      Katello::Content.table_name
    end

    def self.enabled(organization)
      joins(:content).where("#{self.content_table_name}.cp_content_id" => Katello::RootRepository.in_organization(organization).select(:content_id))
    end

    def self.with_valid_subscription(organization)
      where(:product_id => Katello::PoolProduct.where(:pool_id => organization.pools).select(:product_id))
    end

    # used by Katello::Api::V2::RepositorySetsController#index
    def repositories
      Katello::Repository.in_default_view.where(:root_id => product.root_repositories.has_url.where(:content_id => content.cp_content_id))
    end
  end
end
