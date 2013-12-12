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

module Katello
module Ext
  module ActionSubject

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def available_locks
        [:read, :write]
      end
    end

    def action_input_key
      self.class.name.underscore[/\w*\Z/]
    end

    def to_action_input
      if self.new_record?
        raise "The resource needs to be saved first"
      end
      { id: id, name: name }.tap do |hash|
        hash.update(label: label) if self.respond_to? :label
      end
    end

    # @api override to return the objects that relate to this one, usually parent
    # objects, e.g. repository would return product it belongs to, product would return
    # provider etc.
    #
    # It's used to link a task running on top of this resource to it's related objects,
    # so that is't possible to see all the sync tasks for a product etc.
    def related_resources
    end

    # Recursively searches for related resources of this one, avoiding cycles
    def related_resources_recursive(result = [])
      Array(related_resources).each do |related_resource|
        unless result.include?(related_resource)
          result << related_resource
          if related_resource.respond_to?(:related_resources_recursive)
            related_resource.related_resources_recursive(result)
          end
        end
      end
      return result
    end

  end
end
end
