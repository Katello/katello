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

require 'ldap'
require 'util/threadsession.rb'

class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  belongs_to :own_role, :class_name => 'Role'
  has_many :help_tips
  has_many :user_notices
  has_many :notices, :through => :user_notices
  has_many :search_favorites, :dependent => :destroy
  has_many :search_histories, :dependent => :destroy

  validates :username, :uniqueness => true, :presence => true, :username => true
  validates :password, :presence => true, :length=>{:within=>6..100}
  validate :own_role_included_in_roles

  # check if the role does not already exist for new username
  validates_each :username do |model, attr, value|
    if model.new_record? and Role.find_by_name(value)
      model.errors.add(:username, "role with the same name '#{value}' already exists")
    end
  end


  scoped_search :on => :username, :complete_value => true, :rename => :name
  scoped_search :in => :roles, :on => :name, :complete_value => true, :rename => :role

  # create own role for new user
  after_create do |u|
    if u.own_role.nil?
      r = Role.create!(:name => u.username.downcase + "_role")
      u.roles << r unless u.roles.include? r
      u.own_role = r
      u.save!
    end
  end

  # support for session (thread-local) variables
  include Katello::ThreadSession::UserModel
  include Ldap

  # return the special "nobody" user account
  def self.anonymous
    find_by_username('anonymous')
  end

  def self.authenticate!(username, password)
    User.where({:username => username, :password => password}).first
  end

  def self.authenticate_using_ldap!(username, password)
    if Ldap.valid_ldap_authentication? username, password
      User.new :username => username
    else
      nil
    end
  end

  # Return true if the user is allowed to do the specified action for a resource type
  # verb/action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  #
  # This method is called by every protected controller.
  def allowed_to?(verb, resource_type, tags = nil)
    return false if roles.empty?
    not roles.detect {|role| role.allowed_to?(verb, resource_type, tags)}.nil?
  end

  # Class method that has the same functionality as allowed_to? method but operates
  # on the current logged user. The class attributte User.current must be set!
  # If the current user is not set (is nil) it treats it like the 'anonymous' user.
  def self.allowed_to?(verb, resource_type = nil, tags = nil)
    u = User.current
    u = User.anonymous if u.nil?
    raise ArgumentError, "current user is not set" if u.nil? or not u.is_a? User
    u.allowed_to?(verb, resource_type, tags)
  end

  # Class method with the very same functionality as allowed_to? but throws
  # SecurityViolation exception leading to the denial page.
  def self.allowed_to_or_error?(verb, resource_type = nil, tags = nil)
    u = User.current
    raise ArgumentError, "current user is not set" if u.nil? or not u.is_a? User
    unless u.allowed_to?(verb, resource_type, tags)
      msg = "User #{u.username} is not allowed to #{verb} in #{resource_type} using #{tags}"
      Rails.logger.error msg
      raise Errors::SecurityViolation, msg
    end
  end

  # Create permission for the user's own role - for more info see Role.allow
  def allow(verb, resource_type, tags)
    raise ArgumentError, "user has no own role" if own_role.nil? or not own_role.is_a? Role
    own_role.allow(verb, resource_type, tags)
  end

  # Delete permission for the user's own role - for more info see Role.allow
  def disallow(verb, resource_type, tags)
    raise ArgumentError, "user has no own role" if own_role.nil? or not own_role.is_a? Role
    own_role.disallow(verb, resource_type, tags)
  end

  def disable_helptip(key)
    return if !self.helptips_enabled? #don't update helptips if user has it disabled
    return if not HelpTip.where(:key => key, :user_id => self.id).empty?
    help = HelpTip.new
    help.key = key
    help.user = self
    help.save
  end

  def enable_helptip(key)
    return if !self.helptips_enabled? #don't update helptips if user has it disabled
    help =  HelpTip.where(:key => key, :user_id => self.id).first
    return if help.nil?
    help.destroy
  end

  def clear_helptips
    HelpTip.destroy_all(:user_id=>self.id)
  end

  def helptip_enabled?(key)
    return self.helptips_enabled && HelpTip.where(:key => key, :user_id => self.id).first.nil?
  end

  def defined_roles
    self.roles - [self.own_role]
  end

  def defined_role_ids
    self.role_ids - [self.own_role_id]
  end

  def oauth_header
    { 'cp-user' => self.username }
  end

  protected

  def own_role_included_in_roles
    unless own_role.nil?
      errors.add(:own_role, 'own role must be included in roles') unless roles.include? own_role
    end
  end

end
