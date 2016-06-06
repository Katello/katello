namespace :katello do
  class ReindexHelper
    LOG_FILE = "#{Rails.root}/log/reindex.log".freeze

    attr_accessor :reindex_logger

    def reindex_logger
      unless @reindex_logger
        @reindex_logger = Logger.new(LOG_FILE)
        @reindex_logger.formatter = Logger::Formatter.new
        @reindex_logger.level = Logger::DEBUG
      end
      @reindex_logger
    end

    def log(message, options = {})
      puts message if options[:console]
      if options[:error]
        reindex_logger.error(message)
      else
        reindex_logger.info("#{message}")
      end
    end

    def log_error(message)
      log(message, :error => true)
    end

    def fetch_resource
      return yield
    rescue RestClient::ResourceNotFound, RestClient::BadRequest => _ # rubocop:disable Lint/HandleExceptions
      # ignore
    end

    def index_objects(object_class)
      log("Re-indexing #{object_class.name}", :console => true)
      begin
        yield
      rescue => _
        if object_class.ancestors.include?(Katello::Glue::Pulp::PulpContentUnit)
          report_bad_backend_class(object_class.name)
        else
          bad_objects = []
          object_class.each do |object|
            begin
              object.update_index
            rescue => e
              bad_objects << [object, e]
            end
          end
          report_bad_objects(bad_objects, object_class.name)
        end
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
          candlepin_consumer_info = fetch_resource { Katello::Resources::Candlepin::Consumer.get(object.uuid) }
          notes << "Candlepin Consumer was not available for #{object.name}." if candlepin_consumer_info.nil?
          notes << "Foreman Host was not available for #{object.name}." if object.foreman_host.nil?

          log_error "Notes:\n #{notes.join("\n")}" unless notes.empty?
        end
        log_error "Stack Trace: \n #{exception.backtrace.join("\n")}"
      end
    end
  end

  def report_bad_backend_class(model_name)
    log("The following #{model_name} items could not be indexed due to various reasons.", :console => true)
    log("Please check #{ReindexHelper::LOG_FILE} for more detailed information.", :console => true)
    log_error("Exception: #{exception.message}")
    log_error "Stack Trace: \n #{exception.backtrace.join("\n")}"
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
  task :reindex => ["environment", "katello:check_ping"] do
    User.current = User.anonymous_admin #set a user for orchestration

    Dir.glob(Katello::Engine.root.to_s + '/app/models/katello/*.rb').each { |file| require file }
    reindex_helper = ReindexHelper.new

    Katello::Util::Search.active_record_search_classes.each do |model|
      reindex_helper.log("Re-indexing #{model.name}", :console => true)
      sub_classes = model.subclasses

      if sub_classes.empty? || !model.column_names.include?('type')
        objects = model.all
      else
        #Index STI subclasses separately
        objects = model.where(:type => ([nil, model.name]))
      end

      begin
        model.index.import(objects) if objects.count > 0
      rescue => e
        bad_objects = []
        objects.each do |object|
          begin
            object.update_index
          rescue => e
            bad_objects << [object, e]
          end
        end
        reindex_helper.report_bad_objects(bad_objects, model.name)
      end
    end

    Katello::Erratum.import_all
    Katello::PackageGroup.import_all
    Katello::PuppetModule.import_all
    Katello::OstreeBranch.import_all if Katello::RepositoryTypeManager.find(Katello::Repository::OSTREE_TYPE).present?
    Katello::Subscription.import_all
    Katello::Pool.import_all

    Katello::ActivationKey.all.each do |ack_key|
      ack_key.import_pools
    end

    reindex_helper.index_objects(Katello::Rpm) do
      Katello::Rpm.import_all
    end

    # For docker repositories, index all associated manifests and tags
    Katello::Repository.docker_type.each do |docker_repo|
      docker_repo.index_db_docker_manifests
    end
  end
end
