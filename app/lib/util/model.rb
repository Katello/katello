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

module Util

  module Model

    # hardcoded model names (uses kp_ prefix)
    @@table_to_model_hash = {
      "kt_environment" => "KTEnvironment"
    }

    # convert Rails Model name to Class or nil when no such table name exists
    def self.table_to_class name
      class_name = @@table_to_model_hash[name] || name.classify
      class_name.constantize
    rescue NameError => e
      # constantize throws NameError
      return nil
    end

    def self.labelize(name)
      if name
        name.ascii_only? ? name.gsub(/[^a-z0-9\-_]/i,"_") : uuid
      end
    end

    def self.uuid
      UUIDTools::UUID.random_create.to_s
    end
  end

end
