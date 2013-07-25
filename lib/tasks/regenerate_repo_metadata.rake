task :regenerate_repo_metadata=>["environment"]  do
  User.current = User.first #set a user for orchestration
  tasks = []
  puts "Regenerating repository information for all repositories:\n"
  repos = Repository.all
  repos.each_with_index do |repo, i|
    puts "Regenerating #{i+1}/#{repos.count} (#{repo.pulp_id})\n"
    PulpTaskStatus::wait_for_tasks(repo.generate_metadata)
  end

end


