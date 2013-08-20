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

require 'node_capability'

class Node < ActiveRecord::Base
  include Authorization::Node

  belongs_to :system
  has_many :capabilities, :class_name=>'NodeCapability', :dependent => :destroy
  has_and_belongs_to_many :environments, :class_name=>KTEnvironment, :join_table=>'nodes_environments',
                                          :association_foreign_key=>'environment_id'

  after_save :update_environments

  validates_presence_of :system_id

  def self.with_environment(env)
    joins(:environments).where(:environments=>{:id=>env})
  end

  def as_json(params)
    envs = self.environments.collect do |e|
      {:org_id => e.organization_id,
       :org_name => e.organization.name,
       :name => e.name,
       :id => e.id}
    end

    {:id => self.id,
     :system_id => self.system_id,
     :name => self.system.name,
     :environment_ids => self.environment_ids,
     :environments => envs}
  end


  def update_environments
    self.capabilities.each do |capability|
      capability.update_environments
    end
  end

  def sync(options = {})
    tasks = []
    self.capabilities.each do |capability|
      tasks << capability.sync(options)
    end
    tasks
  end
end
