task :reindex=>["environment", "clear_search_indices"]  do
  User.current = User.first #set a user for orchestration

  Dir.glob(Rails.root.to_s + '/app/models/*.rb').each { |file| require file }
  Util::Search.active_record_search_classes.each do |model|
    model.create_elasticsearch_index
    model.index.import(model.all) if model.count > 0
  end

  print "Re-indexing Repositories\n"

  Repository.enabled.each{ |repo| repo.index_content }

  print "Re-indexing Pools\n"
  cp_pools = Resources::Candlepin::Pool.all
  if cp_pools
    # Pool objects
    pools = cp_pools.collect{ |cp_pool| ::Pool.find_pool(cp_pool['id'], cp_pool) }
    # Index pools
    ::Pool.index_pools(pools) if pools.length > 0
  end

end
