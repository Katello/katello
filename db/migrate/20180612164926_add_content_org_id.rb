class AddContentOrgId < ActiveRecord::Migration[5.1]
  class FakeContent < Katello::Model
    self.table_name = 'katello_contents'
    has_many :product_contents, :class_name => 'FakeProductContent', :dependent => :destroy, :foreign_key => 'content_id'
    has_many :products, :through => :product_contents
  end

  class FakeProductContent < Katello::Model
    self.table_name = 'katello_product_contents'
    belongs_to :product, :class_name => 'Katello::Product', :inverse_of => :product_contents
    belongs_to :content, :class_name => 'FakeContent', :inverse_of => :product_contents
  end

  class FakeProduct < Katello::Model
    self.table_name = 'katello_products'
  end

  def up
    add_column :katello_contents, :organization_id, :integer, :null => true
    add_foreign_key :katello_contents, :taxonomies, :column => :organization_id, :primary_key => :id

    Katello::Content.where(:organization_id => nil).find_each do |content|
      org_ids = content.products.pluck(:organization_id).uniq
      org_ids.each do |org_id|
        attrs = content.attributes.except('id')
        attrs['organization_id'] = org_id
        new_content = FakeContent.create!(attrs)
        new_content.products = content.products.where('katello_products.organization_id' => org_id)
      end
    end

    FakeContent.where(:organization_id => nil).destroy_all
    change_column :katello_contents, :organization_id, :integer, :null => false
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
