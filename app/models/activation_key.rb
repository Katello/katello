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
  belongs_to :environment, :class_name => "KTEnvironment"
  belongs_to :user
  belongs_to :system_template

  has_many :key_pools
  has_many :pools, :class_name => "KTPool", :through => :key_pools

  scope :readable, lambda {|org| where ("0 = 1") unless ActivationKey.readable?(org)}

  scope :completer_scope, lambda { |options| where('organization_id = ?', options[:organization_id])}
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
    system.system_activation_keys.build(:activation_key => self)
  end

  # subscribe to the pool which starts most recently (or with the least number available)
  def subscribe_system(system)
    sorted_kp = self.key_pools.sort { |a,b| (b.pool.startDate_as_datetime <=> a.pool.startDate_as_datetime).nonzero? || (a.pool.cp_id <=> b.pool.cp_id) }
    if (sorted_kp.count > 0)
      system.subscribe(sorted_kp.first.pool.cp_id, sorted_kp.first.allocated)
    else
      Rails.logger.warn "No available entitlements for activation key '#{self.name}'"
    end
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags organization_id
    [] #don't list tags for sync plans
  end

  def self.list_verbs global = false
    {
      :read_all => N_("Access all Activation Keys"),
      :manage_all => N_("Manage all Activation Keys")
    }.with_indifferent_access
  end

  def self.no_tag_verbs
    ActivationKey.list_verbs.keys
  end

  def self.readable? org
    User.allowed_to?([:read_all, :manage_all], :activation_keys, nil, org)
  end

  def self.manageable? org
    User.allowed_to?([:manage_all], :activation_keys, nil, org)
  end

  def as_json(*args)
    ret = super(*args)
    ret[:pools] = pools.map do |pool|
      pool.as_json
    end
    ret
  end
end
