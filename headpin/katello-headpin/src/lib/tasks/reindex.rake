task :reindex=>["environment", "clear_search_indices"]  do
  User.current = User.first #set a user for orchestration

  ignore_list = ["CpConsumerUser", "PulpSyncStatus", "PulpTaskStatus", "Hypervisor"]

  Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
  models = ActiveRecord::Base.subclasses.sort{|a,b| a.name <=> b.name}
  models.each{|mod|
    if !ignore_list.include?(mod.name) && mod.respond_to?(:index)
       print "Re-indexing #{mod}\n"
       mod.index.import(mod.all) if mod.count > 0
    end
  }


  print "Re-indexing Repositories\n"
  
  #pulp_repos = Pulp::Repository.all
  #repos = Repository.all
  #repos.each{|r| r.populate_from pulp_repos}

  Repository.enabled.each{|repo|
    repo.index_packages
    repo.index_errata
  }

end
