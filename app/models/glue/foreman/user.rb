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

module Glue::Foreman::User
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.class_eval do
      before_save :save_foreman_orchestration
      before_destroy :destroy_foreman_orchestration

      after_save :foreman_consistency_check
    end
  end

  module ClassMethods
    # @api private
    def disable_foreman_orchestration!(value)
      raise ArgumentError unless [true, false].include? value
      @foreman_orchestration_disabled = value
    end

    # @api private
    def foreman_orchestration_disabled?
      !!@foreman_orchestration_disabled
    end
  end

  module InstanceMethods
    def foreman_user
      return nil unless foreman_id
      @foreman_user ||= ::Foreman::User.find! foreman_id
    end

    alias_method :foreman, :foreman_user

    def save_foreman_orchestration
      return if foreman_orchestration_disabled?
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
      return if foreman_orchestration_disabled?
      pre_queue.create(:name   => "destroy foreman user: #{username}", :priority => 3,
                       :action => [self, :destroy_foreman_user])
    end

    def create_foreman_user
      foreman_user = ::Foreman::User.new(
          :login    => username,
          :mail     => email,
          :admin    => true,
          :password => Katello.config.foreman.random_password ? Password.generate_random_string(25) : password)
      foreman_user.save!
      self.foreman_user = foreman_user
    end

    def update_foreman_user
      # get user by id or find a user by login in foreman
      foreman_user            = self.foreman_user
      foreman_user.attributes = { :mail => email, :password => password }
      foreman_user.save!
    end

    def destroy_foreman_user
      self.foreman_user.destroy!
    end

    # @api private
    def disable_foreman_orchestration(&block)
      original = @disable_foreman_orchestration
      disable_foreman_orchestration! true
      block.call self
    ensure
      @disable_foreman_orchestration = original
    end

    # @api private
    # @param [true, false, nil] value when nil is supplied, self.class.foreman_orchestration_disabled? is used
    def disable_foreman_orchestration!(value)
      raise ArgumentError unless [true, false, nil].include? value
      @foreman_orchestration_disabled = value
    end

    # @api private
    def foreman_orchestration_disabled?
      if @foreman_orchestration_disabled.nil?
        self.class.foreman_orchestration_disabled?
      else
        @foreman_orchestration_disabled
      end
    end

    private

    def foreman_consistency_check
      raise 'user has to have foreman_id' unless foreman_orchestration_disabled? || self.foreman_id
    end

    def foreman_user=(foreman_user)
      @foreman_user   = foreman_user
      self.foreman_id = foreman_user.try :id
    end

  end
end
