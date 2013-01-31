#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require "util/search"
require 'util/package_util'

module Glue::Pulp::Package
  def self.included(base)
    base.send :include, InstanceMethods

    base.class_eval do

      attr_accessor :_id, :download_url, :checksum, :license, :group, :filename, :requires,  :provides, :description,
                    :size, :buildhost, :repository_memberships, :name, :arch

      alias_method 'id=', '_id='
      alias_method 'id', '_id'
      alias_method 'repoids', 'repository_memberships'

      def self.find(id)
        package_attrs = Runcible::Extensions::Rpm.find_by_unit_id(id)
        return if package_attrs.nil?
        Package.new(package_attrs) if package_attrs
      rescue RestClient::ResourceNotFound => exception
        Rails.logger.error "Failed to find pulp package #{id}: #{exception}, #{exception.backtrace.join("\n")}"
        raise exception
      end
    end
  end

  module InstanceMethods

    def initialize(params = {})
      params.each_pair {|k,v| instance_variable_set("@#{k}", v) unless v.nil? }
    end

    def nvrea
      Katello::PackageUtils::build_nvrea(self.as_json.with_indifferent_access, false)
    end
  end

end
