task :reindex=>["environment", "clear_search_indices"]  do
  User.current = User.first #set a user for orchestration

  ignore_list = ["CpConsumerUser", "PulpSyncStatus", "PulpTaskStatus", "Hypervisor", "Pool"]

  Dir.glob(Rails.root.to_s + '/app/models/*.rb').each { |file| require file }
  models = ActiveRecord::Base.subclasses.sort{|a,b| a.name <=> b.name}
  models.each{|mod|
    if !ignore_list.include?(mod.name) && mod.respond_to?(:index)
       print "Re-indexing #{mod}\n"
       mod.index.import(mod.all) if mod.count > 0
    end
  }


  print "Re-indexing Repositories\n"

  #pulp_repos = Resources::Pulp::Repository.all
  #repos = Repository.all
  #repos.each{|r| r.populate_from pulp_repos}

  Repository.enabled.each{|repo|
    repo.index_content
  }

  print "Re-indexing Pools\n"
  cp_pools = Resources::Candlepin::Pool.all
  if cp_pools
    # Pool objects
    pools = cp_pools.collect{|cp_pool| ::Pool.find_pool(cp_pool['id'], cp_pool)}
    # Index pools
    ::Pool.index_pools(pools) if pools.length > 0
  end

end
