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
require 'ostruct'

class SubscriptionsController < ApplicationController

  def index
    all_subs = Candlepin::Owner.pools current_organization.cp_key
    @subscriptions = []
    all_subs.each do |sub|
      sub['providedProducts'].each do |cp_product|
        product = Product.where(:cp_id =>cp_product["productId"]).first
        # Convert to OpenStruct so we can access fields with dot notation
        # in the haml. This reduces the code changes we pull in from headpin
        converted_sub = OpenStruct.new(sub)
        converted_sub.product = product
        @subscriptions << converted_sub if !@subscriptions.include? converted_sub
      end
    end
    @subscriptions
  end

end
