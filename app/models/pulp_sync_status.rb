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

class PulpSyncProgress
  attr_reader :total_size, :size_left, :total_count, :items_left, :error_details

  def initialize(progress_attrs = {})
    @total_size = @size_left = @total_count = @items_left = 0

    unless progress_attrs.nil?
      ht = HashUtil.new
      @total_size  = ht.null_safe_get(progress_attrs, 0, ['size_total'])
      @size_left   = ht.null_safe_get(progress_attrs, 0, ['size_left'])
      @total_count = ht.null_safe_get(progress_attrs, 0, ['details','rpm','total_count'])
      @items_left  = ht.null_safe_get(progress_attrs, 0, ['details','rpm','items_left'])
      @error_details = ht.null_safe_get(progress_attrs, 0, ['error_details'])
    end
  end
end

class PulpSyncStatus < PulpTaskStatus
  class Status < ::TaskStatus::Status
    NOT_SYNCED = :not_synced
  end

  def progress
    PulpSyncProgress.new(attributes['progress'])
  end
end
