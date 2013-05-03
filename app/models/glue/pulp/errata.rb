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

module Glue::Pulp::Errata
  SECURITY = "security"
  BUGZILLA = "bugfix"
  ENHANCEMENT = "enhancement"

  def self.included(base)
    base.send :include, InstanceMethods

    base.class_eval do

      attr_accessor :id, :errata_id, :title, :description, :version, :release, :type, :status, :updated,  :issued, :from_str,
                    :reboot_suggested, :references, :pkglist, :severity, :repoids

      def self.errata_by_consumer(repos)
        errata = Runcible::Extensions::Consumer.applicable_errata([], repos.map(&:pulp_id), false)
        errata[:erratum] || []
      end

      def self.find(id)
        erratum_attrs = Runcible::Extensions::Errata.find_by_unit_id(id)
        ::Errata.new(erratum_attrs) if not erratum_attrs.nil?
      end

      def self.find_by_errata_id(id)
        erratum_attrs = Runcible::Extensions::Errata.find(id)
        ::Errata.new(erratum_attrs) if not erratum_attrs.nil?
      end

    end

  end

  module InstanceMethods

    def initialize(params = {}, options={})
      params['repoids'] = params.delete(:repository_memberships)
      params['errata_id'] = params['id']
      params['id'] = params.delete('_id')
      params.each_pair {|k,v| instance_variable_set("@#{k}", v) unless v.nil? }
    end

    def package_filenames
      self.pkglist.collect do |pkgs|
        pkgs['packages'].collect do |pk|
          pk["filename"]
        end
      end.flatten
    end

    def included_packages
      packages = []

      self.pkglist.each do |pack_list|
        packages += pack_list['packages'].collect do |err_pack|
          ::Package.new(err_pack)
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
