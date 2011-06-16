#
# Copyright © 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.

# based on delayed_job's DelayProxy
module AsyncOrchestration
  class AsyncOrchestrationProxy < ActiveSupport::BasicObject
    def initialize(target, options)
      @target = target
      @options = options
    end

    def method_missing(method, *args)
      Delayed::Job.enqueue({:payload_object => AsyncOperation.new(User.current.username, @target, method.to_sym, args)}.merge(@options))
    end
  end

  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def async(options = {})
      AsyncOrchestrationProxy.new(self, options)
    end
  end
end