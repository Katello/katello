namespace :katello do
  task :reindex => ["environment", "katello:reset_backends:elasticsearch"]  do
    User.current = User.first #set a user for orchestration

    Dir.glob(Katello::Engine.root.to_s + '/app/models/katello/*.rb').each { |file| require file }

    Katello::Util::Search.active_record_search_classes.each do |model|
      print "Re-indexing #{model.name}\n"
      model.create_elasticsearch_index
      sub_classes = model.subclasses

      if sub_classes.empty? || !model.column_names.include?('type')
        objects = model.all
      else
        #Index STI subclasses separately
        objects = model.where(:type => ([nil, model.name]))
      end

      model.index.import(objects) if objects.count > 0
    end

    print "Re-indexing Repositories\n"

    Katello::Repository.enabled.each{ |repo| repo.index_content }

    print "Re-indexing Pools\n"
    cp_pools = Katello::Resources::Candlepin::Pool.all
    if cp_pools
      # Pool objects
      pools = cp_pools.collect{ |cp_pool| Katello::Pool.find_pool(cp_pool['id'], cp_pool) }
      # Index pools
      Katello::Pool.index_pools(pools) if pools.length > 0
    end

  end
end
