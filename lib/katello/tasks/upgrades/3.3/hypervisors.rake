namespace :katello do
  namespace :upgrades do
    namespace '3.3' do
      task :hypervisors => ["katello:update_subscription_facet_backend_data"]
    end
  end
end
