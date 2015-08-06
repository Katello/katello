module Katello
  module Glue::ElasticSearch::ContentViewPuppetEnvironment
    # TODO: break this up into modules
    # rubocop:disable MethodLength
    def self.included(_base)
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

      def indexed_puppet_modules
        service = Glue::ElasticSearch::Items.new
        service.model = ::Katello::PuppetModule
        options = {:full_result => true,
                   :filters => {:term => {:repoids => self.pulp_id}}}
        results, _total = service.retrieve('', 0, options)
        results
      end

      def puppet_module_count
        results = Katello::PuppetModule.legacy_search('', :page_size => 1, :repoids => [self.pulp_id])
        results.empty? ? 0 : results.total
      end

      def index_content
        self.index_puppet_modules
        true
      end
    end
  end
end
