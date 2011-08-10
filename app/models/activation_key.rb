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

class ActivationKey < ActiveRecord::Base
  include Authorization

  belongs_to :organization
  belongs_to :environment, :class_name => "KPEnvironment"
  belongs_to :user
  belongs_to :system_template

  has_many :key_subscriptions
  has_many :subscriptions, :class_name => "KTSubscription", :through => :key_subscriptions


  scoped_search :on => :name, :complete_value => true, :default_order => true, :rename => :'key.name'
  scoped_search :on => :description, :complete_value => true, :rename => :'key.description'
  scoped_search :in => :environment, :on => :name, :complete_value => true, :rename => :'environment.name'

  validates :name, :presence => true, :katello_name_format => true
  validates_uniqueness_of :name, :scope => :organization_id
  validates :description, :katello_description_format => true
  validates :environment, :presence => true
  validate :environment_exists

  def environment_exists
    errors.add(:environment, _("id: #{environment_id} doesn't exist ")) if environment.nil?
  end

  # set's up system when registering with this activation key
  def apply_to_system(system)
    system.environment_id = self.environment_id if self.environment_id
    system.system_template_id = self.system_template_id if self.system_template_id
  end

end
