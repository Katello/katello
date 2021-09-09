namespace :katello do
  task :check_config => ['environment'] do
    desc "Task that can be run before a content migration to check that the configuration valid"
    fail_msg = _("The system appears to already be using pulp3 with all content migrated.")

    puts "Checking for valid Katello configuration."
    if SETTINGS[:katello][:use_pulp_2_for_content_type].nil?
      fail fail_msg
    end
  end
end
