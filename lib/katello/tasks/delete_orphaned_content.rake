namespace :katello do
  task :delete_orphaned_content => ["environment"] do
    User.current = User.hidden.first
    Katello::Repository.delete_orphaned_content
    puts _("Orphaned content deletion started in background.")
  end
end
