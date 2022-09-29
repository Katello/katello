class AddContentViewEnvironmentContentFacet < ActiveRecord::Migration[6.1]
  class FakeContentFacet < ApplicationRecord
    self.table_name = 'katello_content_facets'
  end

  def up
    create_table :katello_content_view_environment_content_facets do |t|
      t.references :content_view_environment, :null => false, :index => false, :foreign_key => { :to_table => 'katello_content_view_environments' }
      t.references :content_facet, :null => false, :index => false, :foreign_key => { :to_table => 'katello_content_facets' }
    end
    FakeContentFacet.all.each do |content_facet|
      cve_id = ::Katello::KTEnvironment.find(content_facet.lifecycle_environment_id)
          .content_view_environments
          .find_by(content_view_id: content_facet.content_view_id)
          .id
      ::Katello::ContentViewEnvironmentContentFacet.create(
        content_facet_id: content_facet.id,
        content_view_environment_id: cve_id
      )
    end

    remove_column :katello_content_facets, :content_view_id
    remove_column :katello_content_facets, :lifecycle_environment_id
  end

  def down
    add_column :katello_content_facets, :content_view_id, :integer, :index => true
    add_column :katello_content_facets, :lifecycle_environment_id, :integer, :index => true

    add_foreign_key "katello_content_facets", "katello_content_views",
                    :name => "katello_content_facets_content_view_id", :column => "content_view_id"

    add_foreign_key "katello_content_facets", "katello_environments",
                    :name => "katello_content_facets_life_environment_id", :column => "lifecycle_environment_id"

    ::Katello::Host::ContentFacet.reset_column_information

    ::Katello::ContentViewEnvironmentContentFacet.all.each do |cvecf|
      content_facet = cvecf.content_facet
      content_facet.content_view_id = cvecf.content_view_environment.content_view_id
      content_facet.lifecycle_environment_id = cvecf.content_view_environment.environment_id
      content_facet.save(validate: false)
    end

    change_column :katello_content_facets, :content_view_id, :integer, :null => false
    change_column :katello_content_facets, :lifecycle_environment_id, :integer, :null => false

    drop_table :katello_content_view_environment_content_facets
  end
end
