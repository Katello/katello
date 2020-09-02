namespace :katello do
  namespace :upgrades do
    namespace '3.12' do
      desc "removes the unused pulp2 notifier"
      task :remove_pulp2_notifier => %w(environment) do
        SmartProxy.pulp_primary!.pulp_api.resources.event_notifier.list.each do |notifier|
          Rails.logger.info("Deleting notifier #{notifier['id']}")
          SmartProxy.pulp_primary!.pulp_api.resources.event_notifier.delete(notifier['id'])
        end
      end
    end
  end
end
