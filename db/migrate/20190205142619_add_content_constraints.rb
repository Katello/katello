class AddContentConstraints < ActiveRecord::Migration[5.2]
  def up
    Katello::ProductContent.where(:content_id => nil).delete_all
    Katello::ProductContent.where(:product_id => nil).delete_all

    change_column :katello_product_contents, :content_id, :integer, :null => false
    change_column :katello_product_contents, :product_id, :integer, :null => false

    Katello::ProductContent.reset_column_information

    duplicates = Katello::Content.having('count(*) > 1').group(:cp_content_id, :organization_id).select(:cp_content_id, :organization_id)

    duplicates.each do |dup|
      contents = Katello::Content.where(organization_id: dup.organization_id, cp_content_id: dup.cp_content_id).to_a
      first = contents.pop
      content_to_delete = []
      contents.each do |content|
        content.product_contents.each do |pc|
          if !first.products.include?(pc.product)
            pc.content = first
            pc.save!
          else
            pc.delete
          end
        end
        content_to_delete << content.id
      end
      ::Katello::Content.where(id: content_to_delete).delete_all
    end

    add_index :katello_contents, [:cp_content_id, :organization_id], :unique => true, :name => :katello_contents_cpcid_orgid_uniq
  end

  def down
    change_column :katello_product_contents, :content_id, :integer, :null => true
    change_column :katello_product_contents, :product_id, :integer, :null => true
    remove_index :katello_contents, :name => :katello_contents_cpcid_orgid_uniq
  end
end
