class CreateKatelloProductContent < ActiveRecord::Migration[4.2]
  def change
    create_table :katello_product_contents do |t|
      t.integer :product_id, :required => true
      t.integer :content_id, :required => true
      t.boolean :enabled

      t.index [:product_id, :content_id], unique: true
    end
    add_foreign_key "katello_product_contents", "katello_products",
                    :name => "katello_product_content_product_id_fk", :column => "product_id"

    add_foreign_key "katello_product_contents", "katello_contents",
                    :name => "katello_product_content_content_id_fk", :column => "content_id"
  end
end
