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
#
# based on delayed_job's DelayProxy
module AsyncOrchestration
  class AsyncOrchestrationProxy < ActiveSupport::BasicObject
    def initialize(target, options)
      @target = target

      raise ArgumentError, "Please pass in organization to which the sync job belongs to" unless options.has_key?(:organization)
      @organization = options.delete(:organization)

      @options = options
    end

    def method_missing(method, *args)
      t = TaskStatus.create!(:uuid => UUIDTools::UUID.random_create.to_s, :user_id=>User.current.id, :organization => @organization, :state => TaskStatus::Status::WAITING)
      Delayed::Job.enqueue({:payload_object => AsyncOperation.new(t.id, User.current.username, @target, method.to_sym, args)}.merge(@options))
      t
    end
  end

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end

  module InstanceMethods
    def async(options = {})
      AsyncOrchestrationProxy.new(self, options)
    end
  end

  module ClassMethods
    def async(options = {})
      AsyncOrchestrationProxy.new(self, options)
    end
  end
end
