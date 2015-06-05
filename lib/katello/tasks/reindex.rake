namespace :katello do
  class ReindexHelper
    LOG_FILE = "#{Rails.root}/log/reindex.log"

    attr_accessor :reindex_logger
    def get_logger
      unless self.reindex_logger
        self.reindex_logger = Logger.new(LOG_FILE)
        self.reindex_logger.formatter = Logger::Formatter.new
        self.reindex_logger.level = Logger::DEBUG
      end
      self.reindex_logger
    end

    def log(message, options = {})
      puts message if options[:console]
      if options[:error]
        get_logger.error(message)
      else
        get_logger.info("#{message}")
      end
    end

    def log_error(message)
      log(message, :error => true)
    end

    def fetch_resource
      return yield
    rescue RestClient::ResourceNotFound, RestClient::BadRequest => e
        #ignore
    end

    def index_objects(object_class)
      log("Re-indexing #{object_class.name}", :console => true)
      begin
        yield
      rescue Exception => e
          bad_objects = []
          object_class.each do |object|
            begin
              object.update_index
            rescue Exception => e
              bad_objects << [object, e]
            end
          end
          report_bad_objects(bad_objects, object_class.name)
      end
    end

    def report_bad_objects(bad_objects_exception_hash, model_name)
      User.current = User.anonymous_admin
      log("The following #{model_name} items could not be indexed due to various reasons.", :console => true)
      log("Please check #{ReindexHelper::LOG_FILE} for more detailed information.", :console => true)

      bad_objects_exception_hash.each do |object, exception|
        log("Object: #{object.inspect}", :console => true)
        log_error("Exception: #{exception.message}")
        if object.is_a? Katello::Repository
          notes = []
          notes << "Pulp Repository #{object.pulp_id} was not found." if object.pulp_repo_facts.nil?
          if object.content_id
            content = fetch_resource { object.content }
            notes << "Candlepin Content was not available for #{object.name}." if content.nil?
          end
          log_error "Notes:\n #{notes.join("\n")}" unless notes.empty?
        elsif object.is_a? Katello::System
          notes = []
          facts = fetch_resource { object.pulp_facts }
          notes << "Pulp Consumer #{object.uuid} was not found." if facts.nil?
          candlepin_consumer_info = fetch_resource { object.candlepin_consumer_info }
          notes << "Candlepin Consumer was not available for #{object.name}." if candlepin_consumer_info.nil?
          notes << "Foreman Host was not available for #{object.name}." if object.foreman_host.nil?

          log_error "Notes:\n #{notes.join("\n")}" unless notes.empty?
        end
        log_error "Stack Trace: \n #{exception.backtrace.join("\n")}"
      end
    end
  end

  desc "Runs a katello ping and prints out the statuses of each service"
  task :check_ping do
    User.current = User.anonymous_admin
    ping_results = Katello::Ping.ping
    if ping_results[:status] != "ok"
      pp ping_results
      fail("Not all the services have been started. Check the status report above and try again.")
    end
  end

  desc "Regenerates the search indicies for various Katello objects"
  task :reindex => ["environment", "katello:check_ping", "katello:reset_backends:elasticsearch"]  do
    User.current = User.anonymous_admin #set a user for orchestration

    Dir.glob(Katello::Engine.root.to_s + '/app/models/katello/*.rb').each { |file| require file }
    reindex_helper = ReindexHelper.new

    Katello::Util::Search.active_record_search_classes.each do |model|
      reindex_helper.log("Re-indexing #{model.name}", :console => true)
      model.create_elasticsearch_index
      sub_classes = model.subclasses

      if sub_classes.empty? || !model.column_names.include?('type')
        objects = model.all
      else
        #Index STI subclasses separately
        objects = model.where(:type => ([nil, model.name]))
      end

      begin
        model.index.import(objects) if objects.count > 0
      rescue Exception => e
        bad_objects = []
        objects.each do |object|
          begin
            object.update_index
          rescue Exception => e
            bad_objects << [object, e]
          end
        end
        reindex_helper.report_bad_objects(bad_objects, model.name)
      end
    end

    Katello::Util::Search.pulp_backend_search_classes.each do |object_class|
      reindex_helper.index_objects(object_class) do
        object_class.index_all
      end
    end

    reindex_helper.index_objects(Katello::Erratum) do
      Katello::Erratum.import_all
    end

    reindex_helper.log "Re-indexing Pools"
    Organization.all.each do |org|
      begin
        cp_pools = Katello::Resources::Candlepin::Pool.get_for_owner(org.label)
        if cp_pools
          # Pool objects
          pools = cp_pools.collect{ |cp_pool| Katello::Pool.find_pool(cp_pool['id'], cp_pool) }
          # Index pools
          Katello::Pool.index_pools(pools) if pools.length > 0
        end
      rescue Exception => e
        reindex_helper.log("Unable to index pools for Organization - '#{org.name}'. Check #{ReindexHelper::LOG_FILE} for more information.", :console => true)
        reindex_helper.log_error("Object: #{org.inspect}")
        reindex_helper.log_error("Exception: \n #{e.message}")
        reindex_helper.log_error("Stack Trace: \n #{e.backtrace.join("\n")}")
        owner_details = reindex_helper.fetch_resource { org.owner_details}
        reindex_helper.log_error("Candlepin owner not found for #{org.name}") if owner_details.nil?
      end
    end
  end
end
