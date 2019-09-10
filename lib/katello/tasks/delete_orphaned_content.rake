namespace :katello do
  desc "Remove orphaned and unneeded content/repos from a smart proxy.\
        Run with SMART_PROXY_ID=1 to run for a single smart proxy."
  task :delete_orphaned_content => ["environment"] do
    User.current = User.anonymous_admin
    smart_proxy_id = ENV['SMART_PROXY_ID']
    if smart_proxy_id
      proxy = SmartProxy.find(smart_proxy_id)
      remove_orphan(proxy)
    else
      SmartProxy.with_content.uniq.reverse_each do |smart_proxy|
        remove_orphan(smart_proxy)
      end
    end
  end

  def remove_orphan(proxy)
    ForemanTasks.async_task(Actions::Katello::OrphanCleanup::RemoveOrphans, proxy)
    puts _("Orphaned content deletion started in background.")
  rescue RuntimeError => e
    Rails.logger.error "Smart proxy with ID #{proxy.id} may be down: #{e}"
    exit
  end
end
