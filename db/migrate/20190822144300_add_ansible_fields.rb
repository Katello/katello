class AddAnsibleFields < ActiveRecord::Migration[5.2]
  def change
    add_column :katello_ansible_collections, :description, :text

    create_table :katello_ansible_tags do |t|
      t.text :name, :null => false
    end

    create_table :katello_ansible_collection_tags do |t|
      t.references :ansible_tag
      t.references :ansible_collection
      t.index [:ansible_tag_id, :ansible_collection_id], :name => :index_katello_ans_coll_tags_on_ans_tag_id_and_ans_coll_id
    end

    add_foreign_key :katello_ansible_collection_tags, :katello_ansible_tags, column: :ansible_tag_id
    add_foreign_key :katello_ansible_collection_tags, :katello_ansible_collections, column: :ansible_collection_id
  end
end
