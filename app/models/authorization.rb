#
# Copyright © 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.

module Authorization

  def self.included(base)
    base.class_eval do
      before_save    :enforce_update_permissions
      before_destroy :enforce_destroy_permissions
      before_create  :enforce_create_permissions
    end
  end

  # this method is hooked as a callback
  def enforce_update_permissions
    enforce_permissions(:update) if enforce?
  end

  # this method is hooked as a callback
  def enforce_destroy_permissions
    enforce_permissions(:destroy) if enforce?
  end

  # this method is hooked as a callback
  def enforce_create_permissions
    enforce_permissions(:create) if enforce?
  end

  # performs permission checks - do not override this method and
  # create check_permissions(operation) instead and return true if permission
  # is granted or call access_denied(operation) explicitely for an
  # intermediate denial
  def enforce_permissions operation
    # we get called again with the operation being set to create
    return true if operation == :update and new_record?

    # method A - developer defined permissions (can veto using SecurityViolation)
    if respond_to? :check_permissions
      return true if check_permissions operation
    end

    # method B - database (user) defined permissions
    return true if enforce_db_permissions operation

    # authorization unsuccessful
    access_denied operation
  end

  private

  def type_name
    "ar_#{self.class.table_name}"
  end

  # enforce permissions from database for regular users
  def enforce_db_permissions(operation)
    User.allowed_to?(operation, type_name, self.id.to_s) or User.allowed_to?(operation, type_name)
  end

  def access_denied(operation)
    strid = self.id ? "(id = #{self.id})" : ''
    struser = User.current.nil? ? "anonymous" : User.current.username
    msg = "User #{struser} doesn't have permission to #{operation} the #{type_name} #{strid}"
    Rails.logger.warn msg
    raise Errors::SecurityViolation, msg
  end

  def enforce?
    return false
    # TODO - do we want to introduce "superadmin" flag?
    #return false if (User.current and User.current.superadmin?)
    return false if Rails.env == "test"
    return false if defined?(Rake)
    true
  end

end

# This class is a "fake" model Tag. It is returned by model objects to the
# view layer to present possible tags which can be assigned to permissions.
class VirtualTag
  attr_accessor :name, :display_name

  def initialize(name, display_name)
    raise ArgumentError, "Name cannot be nil or empty" if name.nil? or name == ''
    raise ArgumentError, "Display name cannot be nil or empty" if display_name.nil? or display_name == ''
    self.name = name
    self.display_name = display_name
  end
end
