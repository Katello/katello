namespace :katello do
  task :check_config => ['environment'] do
    desc "Task that can be run before a content migration to check that the configuration valid"

    puts "Checking for valid Katello configuraton."
    if SETTINGS[:katello][:use_pulp_2_for_content_type].nil?
      fail _("Invalid Katello configuration: 'use_pulp_2_for_content_type' is missing. ")
    end

    if !SETTINGS[:katello][:use_pulp_2_for_content_type][:docker] &&
      !SETTINGS[:katello][:use_pulp_2_for_content_type][:file] &&
      !SETTINGS[:katello][:use_pulp_2_for_content_type][:yum] &&
      !SETTINGS[:katello][:use_pulp_2_for_content_type][:deb]
      fail _("Invalid Katello configuration: no content types in 'use_pulp_2_for_content_type' section are set to 'true'. ")
    end
  end
end
