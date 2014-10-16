#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  module Glue::ElasticSearch::ContentViewPuppetEnvironment

    # TODO: break this up into modules
    # rubocop:disable MethodLength
    def self.included(base)
      base.send :include, Ext::IndexedModel

      base.class_eval do
        index_options :extended_json => :extended_index_attrs,
                      :json => {:except => [:pulp_repo_facts, :feed_cert]}

        mapping do
          indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
          indexes :name_sort, :type => 'string', :index => :not_analyzed
          indexes :labels, :type => 'string', :index => :not_analyzed
        end
      end

      def extended_index_attrs
        {
          :environment => self.environment.try(:name),
          :archive => self.archive?,
          :environment_id => self.environment.try(:id),
          :name_sort => self.name
        }
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
