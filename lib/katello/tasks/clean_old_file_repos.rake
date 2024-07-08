namespace :katello do
  desc "Cleans up file repos that were moved to /pulp/isos/<org name>/"
  task :clean_old_file_repos => ['environment'] do
    User.current = User.anonymous_admin
    PUB_DIR = '/var/www/pub'.freeze
    SCRIPT_PATH = '/tmp/delete_old_file_repos.sh'.freeze
    delete = []

    %w(http https).each do |proto|
      dir = "#{PUB_DIR}/#{proto}/isos/"
      if File.directory?(dir)
        Dir.foreach(dir) do |entry|
          # If directory is a file repo, then it was published using
          # the UUID.  It's a target for deletion.
          if (repo = Katello::Repository.find_by(pulp_id: File.basename(entry))) && (repo.content_type == Katello::Repository::FILE_TYPE)
            delete << "#{dir}#{entry}"
          end
        end
      end
    end

    if delete.empty?
      puts "There are no directories to delete."
    else
      open(SCRIPT_PATH, 'w') { |f| f << "rm -rf #{delete.join " \\\n "}\n" }
      puts "To clean up the directories, please run the following as root:\n# bash #{SCRIPT_PATH}"
    end

    puts "Rake task completed."
  end
end
