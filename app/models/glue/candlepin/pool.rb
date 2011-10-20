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

require 'resources/candlepin'

module Glue::Candlepin::Pool

  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods

    base.class_eval do
      lazy_accessor :productName, :startDate, :endDate, :consumed, :quantity, :attrs,
        :initializer => lambda {
          json = Candlepin::Pool.get(cp_id)
          # symbol "attributes" is reserved by Rails and cannot be used
          json['attrs'] = json['attributes']
          json
        }

      alias_method :poolName, :productName
      alias_method :expires, :endDate
      alias_method :expires_as_datetime, :endDate_as_datetime
    end
  end

  module InstanceMethods

    def initialize(attrs = nil)
      if attrs.member? 'id'
        # initializing from candlepin json
        @productName = attrs["productName"]
        @startDate = attrs["startDate"]
        @endDate = attrs["endDate"]
        @consumed = attrs["consumed"]
        @quantity = attrs["quantity"]
        @attrs = attrs["attributes"]
        super(:cp_id => attrs['id'])
      else
        super
      end
    end

    def startDate_as_datetime
      DateTime.parse(startDate)
    end

    def endDate_as_datetime
      DateTime.parse(endDate)
    end

  end
end
