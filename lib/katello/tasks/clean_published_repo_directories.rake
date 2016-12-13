namespace :katello do
  desc "Cleans up obsolete directories and estimates time to republish current directories. Run with COMMIT=true to republish."
  task :clean_published_repo_directories => ['environment'] do
    User.current = User.anonymous_admin
    OLD_DIRECTORY = '/var/lib/pulp/published/yum/master'.freeze

    current_cv_directories = []
    Katello::ContentViewVersion.all.each do |cvv|
      cvv.repositories.each { |repository| current_cv_directories << repository.pulp_id }
    end

    yum_distributor_directory = Dir.glob "#{OLD_DIRECTORY}/yum_distributor/*"
    master_directory = Dir.glob "#{OLD_DIRECTORY}/*"
    master_directory.delete "#{OLD_DIRECTORY}/yum_distributor"

    republish = []
    delete = []
    master_directory.each do |directory|
      repo_name = directory.split('/').last
      (current_cv_directories.include?(repo_name) && yum_distributor_directory.exclude?(repo_name)) ? republish << repo_name : delete << directory
    end

    if republish.empty?
      puts "There are no directories to republish."
    elsif ENV['COMMIT'] == 'true'
      republish.each do |directory|
        puts "#{directory} is being published to #{OLD_DIRECTORY}/yum_distributor/#{directory}"
        ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, Katello::Repository.where(pulp_id: "#{directory}").first)
        delete << directory
      end
      puts "All relevant repositories have been republished."
    else
      min_time = republish.count * 1
      max_time = republish.count * 5
      if min_time < 60
        puts "It will take approximately #{min_time} to #{max_time} minutes to finish republishing all relevant repositories"
      else
        puts "It will take approximately #{min_time / 60} to #{max_time / 60} hours to finish republishing all relevant repositories"
      end
      puts "The republishing these repositories will not actually be performed. Rerun with COMMIT=true to republish these repositories."
    end

    if delete.empty?
      puts "There are no directories to delete."
    else
      open('/tmp/delete_repository_directories.sh', 'w') { |f| f << "rm -rf #{delete.join " \\\n "}" }
      puts "To clean up the directories, please run the following as root:\n#bash /tmp/delete_repository_directories.sh"
    end

    puts "Rake task completed."
  end
end
