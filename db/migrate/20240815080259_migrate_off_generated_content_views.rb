class MigrateOffGeneratedContentViews < ActiveRecord::Migration[6.1]
  class FakeCVECF < ApplicationRecord
    self.table_name = 'katello_content_view_environment_content_facets'
  end

  def up
    say_with_time "Migrating hosts off generated content views" do
      migrate_hosts
    end
  end

  def down
    say "This migration cannot be reversed", true
  end

  private

  def migrate_hosts
    say_with_time "Migrating hosts..." do
      generated_content_views = Katello::ContentView.generated_for_repository

      facets = Katello::Host::ContentFacet.joins(:content_view_environments).
                where(content_view_environments: { content_view: generated_content_views })
      facets.all.each do |content_facet|
        valid_cves = content_facet.content_view_environments.where.not(content_view: generated_content_views)
        if valid_cves.empty?
          organization = content_facet.host.organization
          default_cve = organization.content_view_environments.find_by(lifecycle_environment: organization.library,
                                                                       content_view: organization.default_content_view)
          if default_cve
            FakeCVECF.where(content_facet_id: content_facet).delete_all
            FakeCVECF.create!(content_facet_id: content_facet.id,
                              content_view_environment_id: default_cve.id)
            say "Replaced all content views with Default Organization View for host #{content_facet.host.name}", true
          else
            say "No Default Organization View found for host #{content_facet.host.name}. Skipping.", true
          end
        else
          FakeCVECF.where(content_facet_id: content_facet).
                    where.not(content_view_environment_id: valid_cves).
                    delete_all
          say "Removed offending content views for host #{content_facet.host.name}", true
        end
      end
    end
  end
end
