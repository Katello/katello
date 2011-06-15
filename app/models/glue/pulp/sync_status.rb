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

module Glue::Pulp
  class SyncStatus
    attr_reader :sync_id, :state, :total_size, :size_left, :total_count, :items_left, :start_time, :finish_time, :error_details

    def initialize(attrs = {})
      @total_size = @size_left = @total_count = @items_left = 0

      @state = attrs[:state]
      ht = HashUtil.new
      if @state != "error"
        @total_size  = ht.null_safe_get(attrs, 0, ['progress','size_total'])
        @size_left   = ht.null_safe_get(attrs, 0, ['progress','size_left'])
        @total_count = ht.null_safe_get(attrs, 0, ['progress','details','rpm','total_count'])
        @items_left  = ht.null_safe_get(attrs, 0, ['progress','details','rpm','items_left'])
      end
      @start_time = Time.parse(attrs[:start_time]) unless attrs[:start_time].nil?
      @finish_time = Time.parse(attrs[:finish_time]) unless attrs[:finish_time].nil?
      @error_details = ht.null_safe_get(attrs, 0, ['progress', 'error_details'])
    end
  end
end
