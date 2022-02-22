namespace :katello do
  desc "Marks corrupted or missing content as approved to be ignored during the migration"
  task :approve_corrupted_migration_content => ["dynflow:client"] do
    Katello::Pulp3::Migration::CORRUPTABLE_CONTENT_TYPES.each do |type|
      type.missing_migrated_content.update_all(:ignore_missing_from_migration => true)
    end
    puts "Any missing or corrupt content will be ignored on migration to Pulp 3.  This can be undone with 'foreman-rake katello:unapprove_corrupted_migration_content'"
  end

  task :unapprove_corrupted_migration_content => ["dynflow:client"] do
    Katello::Pulp3::Migration::CORRUPTABLE_CONTENT_TYPES.each do |type|
      type.ignored_missing_migrated_content.update_all(:ignore_missing_from_migration => false)
    end
    puts "Resetting approval on any corrupted or missing content, you may want to re-run the 'foreman-maintain content prepare' step to attempt re-migration."
  end
end
