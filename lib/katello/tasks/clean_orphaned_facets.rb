namespace :katello do
  desc "Remove orphaned and unneeded content/subscription facets."
  task :clean_orphaned_facets => ["environment"] do
    User.current = User.anonymous_admin
    remove_orphan_facets
  end

  def remove_orphan_facets
    ::Katello::Host::ContentFacet.select { |c| c.host.nil? }&.each do |content_facet|
      Rails.logger.info "Deleting content facet with id: #{content_facet.id}\n"
      content_facet.destroy
    end
    Katello::Host::SubscriptionFacet.select { |s| s.host.nil? }&.each do |subscription_facet|
      Rails.logger.info "Deleting subscription facet with id: #{subscription_facet.id}\n"
      subscription_facet.destroy
    end
  rescue RuntimeError => e
    Rails.logger.error "Task failed: #{e}"
  end
end
