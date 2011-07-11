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

AsyncOperation = Struct.new(:username, :object, :method_name, :args) do
  delegate :method, :to => :object

  def initialize(username, object, method_name, args)
    raise NoMethodError, "undefined method `#{method_name}' for #{object.inspect}" unless object.respond_to?(method_name, true)

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
    object.send(method_name, *args) if object
  end

  def method_missing(symbol, *args)
    object.send(symbol, *args)
  end

  def respond_to?(symbol, include_private=false)
    super || object.respond_to?(symbol, include_private)
  end
end
