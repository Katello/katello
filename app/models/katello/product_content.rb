module Katello
  class ProductContent < Katello::Model
    belongs_to :product, :class_name => 'Katello::Product', :foreign_key => 'product_id', :inverse_of => :product_contents
    belongs_to :content, :class_name => 'Katello::Content', :foreign_key => 'content_id', :inverse_of => :product_contents

    default_scope { includes(:content) }

    validates :content_id, :presence => true, :uniqueness => { :scope => :product_id }
    validates :product_id, :presence => true

    delegate :content_type, to: :content

    scope :displayable, -> {
      joins(:content).where.not("#{content_table_name}.content_type IN (?)", Katello::Repository.undisplayable_types)
      .order("LOWER(#{content_table_name}.name) ASC")
    }

    scope :redhat, -> {
      where(:product_id => Product.redhat.select(:id))
    }

    scoped_search :on => :name, :relation => :content
    scoped_search :on => :content_type, :relation => :content
    scoped_search :on => :label, :relation => :content
    scoped_search :on => :name, :relation => :product, :rename => :product_name

    def self.content_table_name
      Katello::Content.table_name
    end

    def self.enabled(organization)
      joins(:content).where("#{self.content_table_name}.cp_content_id" => Katello::Repository.in_organization(organization).select(:content_id))
    end

    # used by Katello::Api::V2::RepositorySetsController#index
    def repositories
      product.repositories.in_default_view.has_url.where(:content_id => content.cp_content_id)
    end
  end
end
