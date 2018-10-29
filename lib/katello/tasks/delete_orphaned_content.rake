namespace :katello do
  task :delete_orphaned_content => ["environment"] do
    User.current = User.anonymous_admin
    SmartProxy.with_content.reverse_each do |proxy|
      begin
        ForemanTasks.async_task(Actions::Katello::CapsuleContent::RemoveOrphans,
                                :capsule_id => proxy.id)
      rescue RuntimeError => e
        Rails.logger.error "Smart proxy with ID #{proxy.id} may be down: #{e}"
      end
    end
    puts _("Orphaned content deletion started in background.")
  end
end
