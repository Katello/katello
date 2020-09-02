require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs a Pulp 3 migration of pulp3 hrefs to pulp ids for supported content types."
  task :pulp3_content_switchover => :environment do
    ActiveRecord::Base.transaction do
      switchover_service = Katello::Pulp3::MigrationSwitchover.new(SmartProxy.pulp_primary)
      switchover_service.run
    end
  rescue Katello::Pulp3::SwitchoverError => e
    $stderr.print(e.message)
    exit 1
  end
end
