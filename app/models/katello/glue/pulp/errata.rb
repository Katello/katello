#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'set'

module Katello
  module Glue::Pulp::Errata
    SECURITY = "security"
    BUGZILLA = "bugfix"
    ENHANCEMENT = "enhancement"

    TYPES = [SECURITY, BUGZILLA, ENHANCEMENT]

    # rubocop:disable MethodLength
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do

        attr_accessor :id, :errata_id, :title, :description, :version, :release, :type, :status, :updated,  :issued, :from_str,
          :reboot_suggested, :references, :pkglist, :severity, :repoids, :solution

        def self.new_from_search(params)
          params['_id'] = params['id']
          params['id'] = params['errata_id']
          self.new(params)
        end

        def self.errata_by_consumer(repos)
          errata = Katello.pulp_server.extensions.consumer.applicable_errata([], repos.map(&:pulp_id), false)
          errata[:erratum] || []
        end

        def self.find(id)
          erratum_attrs = Katello.pulp_server.extensions.errata.find_by_unit_id(id)
          Katello::Errata.new(erratum_attrs) if !erratum_attrs.nil?
        end

        def self.find_by_errata_id(id)
          erratum_attrs = Katello.pulp_server.extensions.errata.find(id)
          Katello::Errata.new(erratum_attrs) if !erratum_attrs.nil?
        end

        def self.applicable_for_consumers(uuids, type = nil)
          id_system_hash = Hash.new { |h, k| h[k] = [] }
          response = Katello.pulp_server.extensions.consumer.applicable_errata(uuids)

          #for each set of applicability, consumer_ids
          response.each do |item|
            (item['applicability']['erratum'] || []).each do |errata_id|
              id_system_hash[errata_id].concat(item['consumers'])
            end
          end

          return [] if id_system_hash.empty?
          filters = {:id => id_system_hash.keys}
          filters[:type] = type unless type.blank?

          found_errata = Katello::Errata.search("", :start => 0, :page_size => id_system_hash.size,
                                                :filters => filters, :fields => Katello::Errata::SHORT_FIELDS)
          found_errata.collect do |erratum|
            e = Katello::Errata.new_from_search(erratum.as_json)
            e.applicable_consumers = id_system_hash[e.id]
            e
          end
        end

        def self.list_by_filter_clauses(clauses)
          errata = Katello.pulp_server.extensions.errata.search(Katello::Errata::CONTENT_TYPE, :filters => clauses)
          if errata
            result = errata.collect do |attrs|
              Katello::Errata.new(attrs) if attrs
            end
            result.compact
          else
            []
          end
        end
      end

    end

    module InstanceMethods

      def initialize(params = {}, options = {})
        params['repoids'] = params.delete(:repository_memberships)
        params['errata_id'] = params['id']
        params['id'] = params.delete('_id')
        params['applicable_consumers'] ||= []
        params.each_pair {|k, v| instance_variable_set("@#{k}", v) unless v.nil? }
      end

      def package_filenames
        filenames = self.pkglist.collect do |pkgs|
          pkgs['packages'].collect do |pk|
            pk["filename"]
          end
        end
        filenames.flatten
      end

      def included_packages
        packages = []

        (self.pkglist || []).each do |pack_list|
          packages += pack_list['packages'].collect do |err_pack|
            Katello::Package.new(err_pack)
          end
        end

        packages
      end

      def products
        products = []

        self.repoids.each do |repoid|
          # there is a problem, that Pulp in versino <= 0.0.265-1 doesn't remove
          # repo frmo errata when deleting repository. Therefore there might be a
          # situation that repo is not in Pulp anymore, see BZ 790356
          if repo = Repository.where(:pulp_id => repoid)[0]
            products << repo.product
          end
        end

        products.uniq
      end

      def product_ids
        products.map(&:id)
      end

      def product_cp_ids
        products.map(&:cp_id)
      end
    end

  end
end
