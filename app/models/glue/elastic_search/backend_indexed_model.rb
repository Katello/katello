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

module Glue::ElasticSearch::BackendIndexedModel


  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end

  module InstanceMethods

  end

  module ClassMethods
    def update_array object_ids, field, add_ids, remove_ids
      obj_class = self
      script = ""
      add_ids.each{ |add_id| script += "ctx._source.#{field}.add(\"#{add_id}\");" }
      remove_ids.each{ |remove_id| script +=  "ctx._source.#{field}.remove(\"#{remove_id}\");" }

      payload = {:script=>script}
      Tire.index obj_class.index do
        object_ids.each do |id|
          update obj_class.search_type, id, payload
        end

      end
      Tire.index(self.index).refresh
    end

    def create_index
      Tire.index self.index do
        create :settings => self.index_settings, :mappings => self.index_mapping
      end unless Tire.index(self.index).exists?
    end
  end

end
