namespace :katello do
  namespace :upgrades do
    namespace '3.4' do
      task :disable_dynflow do
        ForemanTasks.dynflow.config.remote = true
      end

      desc "Remove orphaned products that are no longer part of the organization after upgrade to candlepin 2.0"
      task :remove_unused_products => ["environment", "disable_dynflow", "check_ping"] do
        User.current = User.anonymous_admin

        Organization.all.each do |org|
          org.products.redhat.each do |product|
            begin
              product.multiplier
            rescue RestClient::ResourceNotFound
              if product.repositories.any?
                Rails.logger.warn("Unexpected upgrade issue: Cannot remove product #{product.name}")
              else
                product.destroy!
              end
            end
          end
        end
      end
    end
  end
end
