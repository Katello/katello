namespace :katello do
  namespace :upgrades do
    namespace '3.0' do
      task :update_subscription_facet_backend_data => ["environment", "katello:update_subscription_facet_backend_data"] do
        #noop task
      end
    end
  end
end
