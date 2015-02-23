#
# Copyright 2015 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Actions
  module ElasticSearch
    class ReindexOnAssociationChange < ElasticSearch::Abstract
      def plan(record)
        plan_self(id: record.id,
                  class_name: record.class.name)
      end

      input_format do
        param :id
        param :class_name
      end

      def finalize
        model_class = input[:class_name].constantize
        record      = model_class.find_by_id(input[:id])

        if record
          record.update_index if record.respond_to? :update_index
          record.class.index.refresh if record.class.respond_to? :index
        end
      end
    end
  end
end
