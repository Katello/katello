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
#
require 'active_support/core_ext/module/delegation'

AsyncOperation = Struct.new(:status_id, :username, :object, :method_name, :args) do
  #delegate :method, :to => :object

  def initialize(status_id, username, object, method_name, args)
    raise NoMethodError, "undefined method `#{method_name}' for #{object.inspect}" unless object.respond_to?(method_name, true)

    self.status_id    = status_id
    self.username     = username
    self.object       = object
    self.args         = args
    self.method_name  = method_name.to_sym
  end

  def display_name
    "#{object.class}##{method_name}"
  end

  def perform
    User.current = User.find_by_username(username)
    @result = object.send(method_name, *args) if object
  end

  def method_missing(symbol, *args)
    object.send(symbol, *args)
  end

  def respond_to?(symbol, include_private=false)
    super || object.respond_to?(symbol, include_private)
  end

  # limit to one failure
  def max_attempts
    1
  end

  #callbacks
  def before
    s = TaskStatus.find(status_id)
    s.update_attributes!(:state => TaskStatus::Status::RUNNING, :start_time => current_time)
  end

  def error(job, exception)
    s = TaskStatus.find(status_id)
    s.update_attributes!(
        :state => TaskStatus::Status::ERROR,
        :finish_time => current_time,
        :result => {:errors => [exception.message, exception.backtrace.join("/n")]}.to_json)
  end

  def success
    s = TaskStatus.find(status_id)
    s.update_attributes!(
        :state => TaskStatus::Status::FINISHED,
        :finish_time => current_time,
        :result => @result)
  end

  private
  def current_time
    (ActiveRecord::Base.default_timezone == :utc) ? Time.now.utc : Time.zone.now
    rescue NoMethodError
      Time.now
  end
end
