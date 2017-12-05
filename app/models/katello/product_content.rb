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

    def self.content_table_name
      Katello::Content.table_name
    end

    # used by Katello::Api::V2::RepositorySetsController#index
    def repositories
      product.repositories.in_default_view.has_url.where(:content_id => content.cp_content_id)
    end
  end
end
