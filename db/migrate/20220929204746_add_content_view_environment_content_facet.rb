class AddContentViewEnvironmentContentFacet < ActiveRecord::Migration[6.1]
  class FakeContentFacet < ApplicationRecord
    self.table_name = 'katello_content_facets'
  end

  def up
    create_table :katello_content_view_environment_content_facets do |t|
      t.references :content_view_environment, :null => false, :index => false, :foreign_key => { :to_table => 'katello_content_view_environments' }
      t.references :content_facet, :null => false, :index => false, :foreign_key => { :to_table => 'katello_content_facets' }
    end
    ::Katello::Util::CvecfMigrator.new.execute!
    FakeContentFacet.all.each do |content_facet|
      cve_id = ::Katello::KTEnvironment.find(content_facet.lifecycle_environment_id)
          .content_view_environments
          .find_by(content_view_id: content_facet.content_view_id)
          &.id
      unless cve_id.present? && ::Katello::ContentViewEnvironmentContentFacet.create(
        content_facet_id: content_facet.id,
        content_view_environment_id: cve_id
      )
        Rails.logger.warn "Failed to create ContentViewEnvironmentContentFacet for content_facet #{content_facet.id}"
      end
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
      cve = cvecf.content_view_environment
      default_org = cve.environment&.organization
      default_cv_id = default_org&.default_content_view&.id
      default_lce_id = default_org&.library&.id
      cv_id = cvecf.content_view_environment.content_view_id || default_cv_id
      lce_id = cvecf.content_view_environment.environment_id || default_lce_id
      say "Updating content_facet #{content_facet.id} with cv_id #{cv_id} and lce_id #{lce_id}"
      content_facet.content_view_id = cv_id
      content_facet.lifecycle_environment_id = lce_id
      content_facet.save(validate: false)
    end

    ensure_no_null_cv_lce
    change_column :katello_content_facets, :content_view_id, :integer, :null => false
    change_column :katello_content_facets, :lifecycle_environment_id, :integer, :null => false

    drop_table :katello_content_view_environment_content_facets
  end

  def ensure_no_null_cv_lce
    # The following is to try to prevent PG::NotNullViolation: ERROR:  column "content_view_id" contains null values
    # since we add null constraints to the columns in the next step
    content_facets_without_cv = ::Katello::Host::ContentFacet.where(content_view_id: nil)
    if content_facets_without_cv.any?
      say "Found #{content_facets_without_cv.count} content_facets with nil content_view_id"
      content_facets_without_cv.each do |content_facet|
        say "reassigning bad content_facet #{content_facet.id} to default content view"
        content_facet.content_view_id = content_facet.host&.organization&.default_content_view&.id
        content_facet.save(validate: false)
      end
    end

    content_facets_without_lce = ::Katello::Host::ContentFacet.where(lifecycle_environment_id: nil)
    if content_facets_without_lce.any?
      say "Found #{content_facets_without_lce.count} content_facets with nil lifecycle_environment_id"
      content_facets_without_lce.each do |content_facet|
        say "reassigning bad content_facet #{content_facet.id} to default lifecycle environment"
        content_facet.lifecycle_environment_id = content_facet.host&.organization&.library&.id
        content_facet.save(validate: false)
      end
    end
  end
end
