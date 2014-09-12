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
  module Model
    # hardcoded model names (uses kp_ prefix)
    def self.table_to_model_hash
      {
        "kt_environment" => "KTEnvironment"
      }
    end

    # convert Rails Model name to Class or nil when no such table name exists
    def self.table_to_class(name)
      class_name = table_to_model_hash[name] || name.classify
      class_name.constantize
    rescue NameError
      # constantize throws NameError
      return nil
    end

    def self.labelize(name)
      if name
        (name.ascii_only? && name.length <= 128) ? name.gsub(/[^a-z0-9\-_]/i, "_") : uuid
      end
    end

    def self.uuid
      UUIDTools::UUID.random_create.to_s
    end

    def self.controller_path_to_model_hash
      {
        "katello/environments"  => "Katello::KTEnvironment",
        "katello/content_hosts" => "Katello::System"
      }
    end

    def self.controller_path_to_model(controller)
      if controller_path_to_model_hash.key? controller.to_s
        controller_path_to_model_hash[controller.to_s].constantize
      else
        controller.to_s.classify.constantize
      end
    end

    def self.model_to_controller_path_hash
      controller_path_to_model_hash.invert
    end

    def self.model_to_controller_path(model)
      if model_to_controller_path_hash.key? model.to_s
        model_to_controller_path_hash[model.to_s]
      else
        model.to_s.underscore.pluralize
      end
    end

  end
end
end
