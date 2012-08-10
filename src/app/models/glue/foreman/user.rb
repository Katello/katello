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

module Glue::Foreman::User
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      before_save :save_foreman_orchestration
      before_destroy :destroy_foreman_orchestration

      after_save do |user|
        raise 'user has to have foreman_id' unless user.foreman_id
      end
    end
  end

  module InstanceMethods
    def save_foreman_orchestration
      case orchestration_for
        when :create
          pre_queue.create :name   => "create foreman user: #{username}", :priority => 3,
                           :action => [self, :create_foreman_user]
        when :update
          pre_queue.create :name   => "update foreman user: #{username}", :priority => 3,
                           :action => [self, :update_foreman_user]
      end
    end

    def destroy_foreman_orchestration
      pre_queue.create(:name   => "destroy foreman user: #{username}", :priority => 3,
                       :action => [self, :destroy_foreman_user])
    end

    def create_foreman_user
      data, _         = Resources::Foreman::User.create(
          { :user => { :login     => username,
                       :mail      => email, :admin => true, :auth_source_id => 1,
                       :password  => password, :password_confirmation => password } },
          { :foreman_user => 'admin' })
      self.foreman_id = data['user']['id']
    end

    def update_foreman_user
      Resources::Foreman::User.update(
          foreman_id,
          { :user => { :password => password, :password_confirmation => password, :mail => email } },
          { :foreman_user => 'admin' })
    end

    def destroy_foreman_user
      Resources::Foreman::User.destroy(foreman_id, :foreman_user => 'admin')
    end

  end
end