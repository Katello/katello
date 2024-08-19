class MigrateOffGeneratedContentViews < ActiveRecord::Migration[6.1]
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
      generated_content_views = Katello::ContentView.where(generated_for: 'repository_export')

      facets = Katello::Host::ContentFacet.joins(:content_view_environments)
      facets = facets.where(katello_content_view_environments: { content_view_id: generated_content_views })
      facets.find_each do |content_facet|
        offending_cves = content_facet.content_view_environments.select { |cve| generated_content_views.include?(cve.content_view) }
        valid_cves = content_facet.content_view_environments - offending_cves

        if valid_cves.empty?
          default_view = Katello::ContentView.find_by(name: "Default Organization View", organization: content_facet.host.organization)
          if default_view
            default_cve = default_view.content_view_environments.find_by(lifecycle_environment: content_facet.lifecycle_environments.first)
            content_facet.update!(content_view_environments: [default_cve])
            say "Replaced all content views with Default Organization View for host #{content_facet.host.name}", true
          else
            say "No Default Organization View found for host #{content_facet.host.name}. Skipping.", true
          end
        else
          content_facet.update!(content_view_environments: valid_cves)
          say "Removed offending content views for host #{content_facet.host.name}", true
        end
      end
    end
  end
end
