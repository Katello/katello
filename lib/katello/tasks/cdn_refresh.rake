namespace :katello do
  desc "Check for new repositories on CDN and create repositories if needed for all the organizations"
  task :refresh_cdn => [:environment] do
    Rails.logger.info("Refreshing CDN products")
    User.current = User.hidden.first
    Organization.all.each do |org|
      Rails.logger.debug("CDN refresh for org #{org.name}")
      org.redhat_provider.refresh_products
    end
    Rails.logger.info("Refreshing CDN products finished")
  end
end
