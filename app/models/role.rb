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


class LockValidator < ActiveModel::Validator
  def validate(record)
    if record.locked?
      if record.name_changed? || record.description_changed?
        record.errors[:base] << _("Cannot change the name or description of a locked role.")
      end
    end
  end
end

class Role < ActiveRecord::Base
  include Authorization
  include IndexedModel

  index_options :extended_json=>:extended_index_attrs,
                :display_attrs=>[:name, :permissions, :description]

  mapping do
    indexes :name, :type => 'string', :analyzer => :keyword
    indexes :name_sort, :type => 'string', :index => :not_analyzed
  end

  acts_as_reportable

  attr_accessor :self_role #used to indicate during user creation that a role is intended to be a self role
  has_many :roles_users
  has_many :users, :through => :roles_users, :before_remove =>:super_admin_check
  has_many :permissions, :dependent => :destroy,:inverse_of =>:role, :class_name=>"Permission"
  has_one :owner, :class_name => 'User', :foreign_key => "own_role_id"
  has_many :resource_types, :through => :permissions

  # scope to facilitate retrieving roles that are 'non-self' roles... group() so that unique roles are returned
  scope :non_self, joins("left outer join users on users.own_role_id = roles.id").where('users.own_role_id'=>nil).order('roles.name')
  validates :name, :uniqueness => true, :katello_name_format => true, :presence => true
  validates :description, :katello_description_format => true
  validates_with LockValidator, :on => :update

  #validates_associated :permissions
  accepts_nested_attributes_for :permissions, :allow_destroy => true


  def self.search_by_verb(key, operator, value)
    permissions = Permission.all(:conditions => "verbs.verb #{operator} '#{value_to_sql(operator, value)}'", :include => :verbs)
    roles = permissions.map(&:role)
    opts  = roles.empty? ? "= 'nil'" : "IN (#{roles.map(&:id).join(',')})"

    return {:conditions => " roles.id #{opts} " }
  end

  def self.search_by_type(key, operator, value)
    permissions = Permission.all(:conditions => "resource_types.name #{operator} '#{value_to_sql(operator, value)}'", :include => :resource_type)
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

  def self.make_readonly_role name, organization = nil
    #nil for organization implies all orgs
    role = Role.find_or_create_by_name(
            :name => name, :description => 'Read only role.')
    resource_perms = {}
    ResourceType::TYPES.keys.each do |key|
      resource_perms[key] = ResourceType.model_for(key).read_verbs if key.to_s != "all"
    end

    resource_perms.each_pair do |key, verbs|
      perm_name =  "Read #{key.to_s.capitalize}"
      unless Permission.where(:role_id => role, :name => perm_name).count > 0
        Permission.create!(:role => role,
                     :resource_type => ResourceType.find_or_create_by_name(key),
                     :all_tags => true,
                     :verbs => verbs.collect{|verb| Verb.find_or_create_by_verb(verb)},
                     :name => perm_name,
                     :organization=> organization,
                     :description => "Read #{key.to_s.capitalize} permission")
      end
    end

    role

  end


  ADMINISTRATOR = 'Administrator'

  def superadmin?
    name == ADMINISTRATOR
  end

  def self.make_super_admin_role
    # create basic roles
    superadmin_role = Role.find_or_create_by_name(
      :name => ADMINISTRATOR,
      :description => 'Super administrator with all access.')
    raise "Unable to create super-admin role: #{format_errors superadmin_role}" if superadmin_role.nil? or superadmin_role.errors.size > 0

    superadmin_role_perm = Permission.find_or_create_by_name(
      :name=> "super-admin-perm",
      :description => 'Super Admin permission',
      :role => superadmin_role, :all_types => true)
    raise "Unable to create super-admin role permission: #{format_errors superadmin_role_perm}" if superadmin_role_perm.nil? or superadmin_role_perm.errors.size > 0

    superadmin_role.update_attributes(:locked => true)
    superadmin_role
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

  def self.editable?
    User.allowed_to?([:update, :create], :roles, nil)
  end

  def self.deletable?
    User.allowed_to?([:delete, :create],:roles, nil)
  end

  def self.any_readable?
    User.allowed_to?(READ_PERM_VERBS, :roles, nil)
  end

  def self.readable?
    Role.any_readable?
  end

  def summary
    perms = permissions.collect{|perm| perm.to_abbrev_text}.join("\n")
    "Role: #{name}\nPermissions:\n#{perms}"
  end

  def self.list_verbs global = false
    {
    :create => _("Administer Roles"),
    :read => _("Read Roles"),
    :update => _("Modify Roles"),
    :delete => _("Delete Roles"),
    }.with_indifferent_access
  end

  def self.read_verbs
    [:read]
  end

  def self.no_tag_verbs
    [:create]
  end

  # Used when displaying the localized version of locked roles
  def i18n_name
    if locked
      case name
        when "Administrator"
          _("Administrator")
        when "Read Everything"
          _("Read Everything")
        else
          name
      end
    else
      name
    end
  end

  def i18n_description
    if locked
      case description
        when "Super administrator with all access."
          _("Super administrator with all access.")
        when "Read only role."
          _("Read only role.")
        else
          description
      end
    else
      description
    end
  end

  private
  READ_PERM_VERBS = [:read,:update, :create,:delete]

  def extended_index_attrs
    {:name_sort=>name.downcase,
     :permissions=>self.permissions.collect{|p| p.name},
     :self_role=>(self_role_for_user != nil || self.self_role == true)
    }
  end

  def super_admin_check user
    if superadmin? && users.length == 1
      message = _("Cannot dissociate user '%s' from '%s' role. Need at least one user in the '%s' role.") % [user.username,
                                                                                                              name,name]
      errors[:base] << message
      raise  ActiveRecord::RecordInvalid, self
    end
  end
end
