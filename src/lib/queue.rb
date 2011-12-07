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

require 'task'
# represents tasks queue for glue
class Queue

  attr_reader :items
  STATUS = %w[ pending running failed completed rollbacked ]

  def initialize
    @items = []
  end

  def create options
    options[:status] ||= default_status
    items << Task.new(options)
  end

  def delete item
    @items.delete item
  end

  def find_by_name name
    items.each {|task| return task if task.name == name}
  end

  def all
    items.sort
  end

  def count
    items.count
  end

  def empty?
    items.empty?
  end

  def clear
    @items = [] && true
  end

  STATUS.each do |s|
    define_method s do
      all.delete_if {|t| t.status != s}.sort
    end
  end

  private

  def default_status
    "pending"
  end

end
