task :regenerate_repo_metadata=>["environment"]  do
  User.current = User.first #set a user for orchestration
  tasks = []
  puts "Regenerating repository information for all repositories:\n"

  Repository.all.each_with_index do |repo, i|
    puts "Regenerating #{i+1}/#{repos.count} (#{repo.pulp_id})\n"
    PulpTaskStatus::wait_for_tasks(repo.generate_metadata(true))
  end
end


task :refresh_pulp_repo_details=>["environment"] do
  User.current = User.first
  Product.all.each do |product|
    product.update_repositories
  end
end


