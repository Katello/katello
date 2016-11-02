class CreateContentViewDockerFilterRules < ActiveRecord::Migration
  def change
    create_table :katello_content_view_docker_filter_rules do |t|
      t.references :content_view_filter
      t.string :name, :limit => 255

      t.timestamps
    end

    add_foreign_key :katello_content_view_docker_filter_rules, :katello_content_view_filters,
                    :name => "katello_content_view_docker_filter_rules_filter_fk", :column => 'content_view_filter_id'
  end
end
