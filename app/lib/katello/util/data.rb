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
  module Util
    module Data
      def self.array_with_indifferent_access(variable)
        variable.map { |x| x.with_indifferent_access }
      end

      def self.ostructize(obj, options = {})
        options[:prefix_keys] ||= []
        options[:prefix]      ||= '_'

        if obj.is_a? Hash

          ostructized_hash = {}
          obj.each do |key, value|
            if options[:prefix_keys].include? key
              new_key = (options[:prefix].to_s + key.to_s).to_sym
            else
              new_key = key
            end

            if Object.respond_to? new_key
              fail "Error occured while converting Hash to OpenStruct. Key '%s' conflicts with method OpenStruct#%s." % [new_key, new_key]
            end

            ostructized_hash[new_key] = ostructize(value, options)
          end
          return OpenStruct.new ostructized_hash

        elsif obj.is_a? Array

          return obj.map { |r| ostructize(r, options) }

        end
        return obj
      end
    end
  end
end
