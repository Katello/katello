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

# this forces loading of glue.rb and its methods
# otherwise we end up with an empty Glue module
# when caching of classes is Rails is on
#
# PLEASE DO NOT REMOVE WITHOUT TESTING WITH
# config.cache_classes = true
#

# represents tasks queue for glue
module Katello
  module Glue
    class Queue

      attr_reader :items
      STATUS = %w[ pending running failed completed rollbacked ]

      # we can put more queues sequentially. E.g. on queue before saving a record,
      # another after saving. If something in later queue fails we roll-back also
      # everything in previous queues.
      def initialize(previous_queue = nil)
        @previous_queue = previous_queue
        @items          = []
      end

      def create options
        options[:status] ||= default_status
        Task.new(options).tap { |t| items << t }
      end

      def delete item
        @items.delete item
      end

      def find_by_name name
        items.each { |task| return task if task.name == name }
      end

      def all
        ret = []
        ret.concat(@previous_queue.all) if @previous_queue
        ret.concat(items.sort)
        ret
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

      def to_log
        all.collect(&:to_log).join ", "
      end

      STATUS.each do |s|
        define_method s do
          all.find_all { |t| t.status == s }
        end
      end

      private

      def default_status
        "pending"
      end

    end
  end
end
