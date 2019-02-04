class AddContentConstraints < ActiveRecord::Migration[5.2]
  def up
    Katello::ProductContent.where(:content_id => nil).delete_all
    Katello::ProductContent.where(:product_id => nil).delete_all

    change_column :katello_product_contents, :content_id, :integer, :null => false
    change_column :katello_product_contents, :product_id, :integer, :null => false

    Katello::ProductContent.reset_column_information

    duplicates = execute(
        'select  "katello_contents"."cp_content_id", "katello_contents"."organization_id"
          FROM "katello_contents"
          GROUP BY "katello_contents"."cp_content_id", "katello_contents"."organization_id"
          HAVING (count(*) > 1)')

    duplicates.each do |dup|
      contents = Katello::Content.where(dup).to_a
      first = contents.pop
      contents.each do |content|
        content.product_contents.each do |pc|
          unless first.products.include?(pc.product)
            pc.content = first
            pc.save!
          end
        end
        content.delete
      end
    end

    add_index :katello_contents, [:cp_content_id, :organization_id], :unique => true, :name => :katello_contents_cpcid_orgid_uniq
  end

  def down
    change_column :katello_product_contents, :content_id, :integer, :null => true
    change_column :katello_product_contents, :product_id, :integer, :null => true
    remove_index :katello_contents, :name => :katello_contents_cpcid_orgid_uniq
  end
end
