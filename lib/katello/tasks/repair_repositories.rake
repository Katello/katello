namespace :katello do
  PULP_IDS_FILE = '/tmp/foreman_pulp_ids_to_fix'.freeze

  def find_ids_not_in_pulp
    Katello::Repository.pluck(:pulp_id) -
     Katello.pulp_server.extensions.repository.retrieve_all.map { |repo| repo["id"] }
  end

  def repository_info(repo)
    %(
       name: #{repo.name}
       pulp_id: #{repo.pulp_id}
       product: #{repo.product.name}
       organization: #{repo.organization.name}
    )
  end

  task :generate_repositories_to_fix => ["environment"] do
    User.current = User.anonymous_admin
    not_in_pulp = find_ids_not_in_pulp

    File.open(PULP_IDS_FILE, "w") do |file|
      file.write(not_in_pulp.join("\n"))
    end

    if not_in_pulp.empty?
      puts "All the syncable repositories in this satellite instance have a Pulp repository. No fixes necessary!."
    else
      puts %(
              The following repositories are not present in pulp. A file has been generated at #{PULP_IDS_FILE} containing the pulp ids to be fixed.
              Please verify the list below are indeed repositories you want and fixed. Update #{PULP_IDS_FILE} if anything needs to be changed.
              Then run 'foreman-rake katello:generate_pulp_repositories' to generate their equivalent in pulp.
      )
      not_in_pulp.each do |pulp_id|
        puts repository_info(::Katello::Repository.find_by_pulp_id(pulp_id))
      end
    end
  end

  task :generate_pulp_repositories => ["environment"] do
    User.current = User.anonymous_admin
    class RepoFixer
      def run(repo)
        ForemanTasks.sync_task(::Actions::Katello::Repository::Create, repo)
      end
    end

    def fix_repo(pulp_id)
      User.current = User.anonymous_admin
      repository = ::Katello::Repository.find_by_pulp_id(pulp_id)
      fail("Repository with pulp_id #{pulp_id} not found!") if repository.nil?
      repo_fixer = RepoFixer.new
      repo_fixer.run(repository)
      repository
    end

    if find_ids_not_in_pulp.empty?
      puts "All the syncable repositories in this satellite instance have a Pulp repository. No fixes necessary!."
    elsif File.exist?(PULP_IDS_FILE)
      pulp_ids_to_fix = IO.readlines(PULP_IDS_FILE).map { |line| line.strip }
      actual_ids = pulp_ids_to_fix & find_ids_not_in_pulp

      if pulp_ids_to_fix != actual_ids
        ignored_ids = pulp_ids_to_fix - actual_ids
        puts "Ignoring the following repositories since they are already in pulp. [#{ignored_ids}]"
      end
      actual_ids.each do |pulp_id|
        begin
          repository = fix_repo(pulp_id)
          puts "Completed generating pulp repo for the following repository"
          puts repository_info(repository)
          puts "You need to manually sync this repository in the specified organization before proceeding."
        rescue StandardError => e
          puts "Unable to fix repository with the pulp_id '#{pulp_id}'. Error => [#{e.message}]"
          puts e.backtrace.inspect
        end
      end
    else
      puts "#{PULP_IDS_FILE} does not exist. Please run 'foreman-rake katello:generate_repositories_to_fix' before proceeding with this call."
    end
  end
end
