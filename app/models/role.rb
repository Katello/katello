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

class Role < ActiveRecord::Base
  include Authorization
  has_many :roles_users
  has_many :users, :through => :roles_users
  has_many :permissions, :dependent => :destroy,:inverse_of =>:role, :class_name=>"Permission"
  has_one :owner, :class_name => 'User', :foreign_key => "own_role_id"
  has_many :search_tags, :class_name => 'Tag'
  has_many :search_verbs, :class_name => 'Verb'
  has_many :resource_types, :through => :permissions

  # scope to facilitate retrieving roles that are 'non-self' roles... group() so that unique roles are returned
  scope :non_self, joins("left outer join users on users.own_role_id = roles.id").where('users.own_role_id'=>nil).order('name')

  validates :name, :uniqueness => true, :presence => true
  #validates_associated :permissions
  accepts_nested_attributes_for :permissions, :allow_destroy => true

  scoped_search :on => :name, :complete_value => true, :rename => :'role.name'
  scoped_search :in => :resource_types, :on => :name, :complete_value => true, :rename => :'permission.type'
  scoped_search :in => :search_verbs, :on => :verb, :complete_value => true, :ext_method => :search_by_verb, :only_explicit => true, :rename => :'permission.verb'
  scoped_search :in => :search_tags, :on => :name, :complete_value => true, :ext_method => :search_by_tag, :rename => :'permission.scope', :only_explicit => true

  def self.search_by_tag(key, operator, value)
    permissions = Permission.all(:conditions => "tags.name #{operator} '#{value_to_sql(operator, value)}'", :include => :tags)
    roles = permissions.map(&:role)
    opts  = roles.empty? ? "= 'nil'" : "IN (#{roles.map(&:id).join(',')})"

    return {:conditions => " roles.id #{opts} " }
  end


  def self.search_by_verb(key, operator, value)
    permissions = Permission.all(:conditions => "verbs.verb #{operator} '#{value_to_sql(operator, value)}'", :include => :verbs)
    roles = permissions.map(&:role)
    opts  = roles.empty? ? "= 'nil'" : "IN (#{roles.map(&:id).join(',')})"

    return {:conditions => " roles.id #{opts} " }
  end

  def self.value_to_sql(operator, value)
    return value if (operator !~ /LIKE/i)
    return (value =~ /%|\*/) ? value.tr_s('%*', '%') : "%#{value}%"
  end

  def self.non_self_roles
    #gotta be a better way to do this, but others wouldn't work
    Role.all(:conditions=>{"users.own_role_id"=>nil}, :include=> :owner)
  end

  def self_role_for_user
    User.where(:own_role_id => self.id).first
  end

  # returns the candlepin role (for RHSM)
  def self.candlepin_role
    Role.find_by_name('candlepin_role')
  end


  #permissions
  scope :readable, lambda {where("0 = 1")  unless User.allowed_all_tags?(READ_PERM_VERBS, :roles)}
  def self.creatable?
    User.allowed_to?([:create], :roles, nil)
  end

  def editable?
   User.allowed_to?([:update, :create], :roles, nil)
  end

  def deletable?
    User.allowed_to?([:delete, :create],:roles, nil)
  end

  def self.any_readable?
    User.allowed_to?(READ_PERM_VERBS, :roles, nil)
  end

  def readable?
    Role.any_readable?
  end

  def summary
    perms = permissions.collect{|perm| perm.to_abbrev_text}.join("\n")
    "Role: #{name}\nPermissions:\n#{perms}"
  end

  def self.list_verbs global = false
    {
    :create => N_("Create Roles"),
    :read => N_("Access Roles"),
    :update => N_("Update Roles"),
    :delete => N_("Delete Roles"),
    }.with_indifferent_access
  end

  def self.no_tag_verbs
    [:create]
  end

  private
  READ_PERM_VERBS = [:read,:update, :create,:delete]

end
