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

class KTSubscription < ActiveRecord::Base
  include Authorization
  set_table_name "subscriptions"
  has_many :key_subscriptions, :foreign_key => "subscription_id"
  has_many :activation_keys, :through => :key_subscriptions

end
