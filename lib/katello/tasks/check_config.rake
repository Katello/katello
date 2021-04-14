namespace :katello do
  task :check_config => ['environment'] do
    desc "Task that can be run before a content migration to check that the configuration valid"
    fail_msg = _("The system appears to already be using pulp3 with all content migrated.")

    puts "Checking for valid Katello configuraton."
    if SETTINGS[:katello][:use_pulp_2_for_content_type].nil?
      fail fail_msg
    end

    if !SETTINGS[:katello][:use_pulp_2_for_content_type][:docker] &&
      !SETTINGS[:katello][:use_pulp_2_for_content_type][:file] &&
      !SETTINGS[:katello][:use_pulp_2_for_content_type][:yum] &&
      !SETTINGS[:katello][:use_pulp_2_for_content_type][:deb]
      fail fail_msg
    end
  end
end
