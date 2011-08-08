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

  def rules
    {
      :index => lambda{current_organization.readable?}
    }
  end


  def index
    all_subs = Candlepin::Owner.pools current_organization.cp_key
    @subscriptions = reformat_subscriptions(all_subs)
  end

  # Reformat the subscriptions from our API to a format that the headpin HAML expects
  def reformat_subscriptions(all_subs)
    subscriptions = []
    org_stats = Candlepin::Owner.statistics current_organization.cp_key
    converted_stats = []
    org_stats.each do |stat|
      converted_stats << OpenStruct.new(stat)
    end
    all_subs.each do |sub|
      product = Product.where(:cp_id =>sub["productId"]).first
      converted_product = OpenStruct.new
      converted_product.id = product.id
      converted_product.support_level = product.support_level
      converted_product.arch = product.arch
      # Convert to OpenStruct so we can access fields with dot notation
      # in the haml. This reduces the code changes we pull in from headpin
      converted_sub = OpenStruct.new(sub)
      converted_sub.consumed_stats = converted_stats
      converted_sub.product = converted_product
      converted_sub.startDate = Date.parse(converted_sub.startDate)
      converted_sub.endDate = Date.parse(converted_sub.endDate)
      subscriptions << converted_sub if !subscriptions.include? converted_sub
    end
    subscriptions
  end

end
