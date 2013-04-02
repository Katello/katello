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

module Glue::Pulp::PackageGroup

  def self.included(base)
    base.send :include, InstanceMethods

    base.class_eval do
      attr_accessor :name, :default_package_names, :id, :repoid, :conditional_package_names,
                      :mandatory_package_names, :description, :optional_package_names
    end

  end

  module InstanceMethods

    def initialize(params = {}, options={})
      params['id'] = params.delete('_id')
      params.each_pair {|k,v| instance_variable_set("@#{k}", v) unless v.nil? }

      [:default_package_names,:conditional_package_names,:optional_package_names,:mandatory_package_names].each do |attr|
        values = send(attr)
        values = values.collect do |v|
          v.split(",")
        end.flatten
        send(attr + "=", values)
      end

    end

    def package_names
      default_package_names + conditional_package_names + optional_package_names + mandatory_package_names
    end

  end

end
