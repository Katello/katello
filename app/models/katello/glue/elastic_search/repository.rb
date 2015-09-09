module Katello
  module Glue::ElasticSearch::Repository
    extend ActiveSupport::Concern

    # TODO: break this up into modules
    # rubocop:disable MethodLength
    def indexed_package_ids
      Katello::Package.indexed_ids_for_repo(pulp_id)
    end

    def index_puppet_modules
      Tire.index Katello::PuppetModule.index do
        create :settings => Katello::PuppetModule.index_settings, :mappings => Katello::PuppetModule.index_mapping
      end
      puppet_modules = self.puppet_modules.collect { |puppet_module| puppet_module.as_json.merge(puppet_module.index_options) }
      puppet_modules.each_slice(Katello.config.pulp.bulk_load_size) do |sublist|
        Tire.index Katello::PuppetModule.index do
          import sublist
        end unless sublist.empty?
      end
    end

    def index_distributions
      #reindex all distributions, much simpler
      Tire.index(Katello::Distribution.index).delete
      Katello::Distribution.index_all
    end

    def indexed_puppet_module_ids
      Katello::PuppetModule.indexed_ids_for_repo(pulp_id)
    end

    def puppet_module_count
      results = Katello::PuppetModule.legacy_search('', :page_size => 1, :repoids => [self.pulp_id])
      results.empty? ? 0 : results.total
    end

    def index_content
      self.index_db_rpms
      self.index_db_errata
      self.index_db_docker_images
      self.index_puppet_modules
      self.index_distributions
      self.index_db_package_groups
      true
    end
  end
end
