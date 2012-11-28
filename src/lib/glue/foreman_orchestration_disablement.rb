#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Glue
  module ForemanOrchestrationDisablement
    def self.included base
      base::ClassMethods.send :include, ClassMethods
      base::InstanceMethods.send :include, InstanceMethods
    end

    module ClassMethods
      # @private
      def disable_foreman_orchestration!(value)
        raise ArgumentError unless [true, false].include? value
        @foreman_orchestration_disabled = value
      end

      # @private
      def foreman_orchestration_disabled?
        !!@foreman_orchestration_disabled
      end
    end

    module InstanceMethods
      # @private
      def disable_foreman_orchestration(&block)
        original = @disable_foreman_orchestration
        disable_foreman_orchestration! true
        block.call self
      ensure
        @disable_foreman_orchestration = original
      end

      # @private
      # @param [true, false, nil] value when nil is supplied, self.class.foreman_orchestration_disabled? is used
      def disable_foreman_orchestration!(value)
        raise ArgumentError unless [true, false, nil].include? value
        @foreman_orchestration_disabled = value
      end

      # @private
      def foreman_orchestration_disabled?
        if @foreman_orchestration_disabled.nil?
          self.class.foreman_orchestration_disabled?
        else
          @foreman_orchestration_disabled
        end
      end
    end
  end
end

