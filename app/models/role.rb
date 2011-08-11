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
  has_and_belongs_to_many :users
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

  # Create permission for given role - for more info see allow
  #
  # @param [Role or Array] one or more roles to allow (accepts also String for role name)
  def self.allow(role, verb, resource_type, tags = nil)
    raise ArgumentError, "role can't be nil" if role.nil?
    raise ArgumentError, "verb can't be nil" if verb.nil?
    raise ArgumentError, "Resource Type can't be nil" if verb.nil?
    
    roles = role.is_a?(Array) ? role : [role]

    roles.each do |r|
      allow_role = r.is_a?(String)? Role.find_or_create_by_name(r) : r
      allow_role.allow(verb, resource_type, tags)
    end
  end

  def self.non_self_roles
    #gotta be a better way to do this, but others wouldn't work
    Role.all(:conditions=>{"users.own_role_id"=>nil}, :include=> :owner)
  end

  def self_role_for_user
    User.where(:own_role_id => self.id).first
  end

  # create permission with verb for the role or
  # create permission with verb, type and tag(s) for the role
  def allow(verb, resource_type, tags = nil, org = nil)
    raise ArgumentError, "verb can't be nil" if verb.nil?
    raise ArgumentError, "Resource Type can't be nil" if verb.nil?

    #throw error if using old format, shouldn't overload methods like this
    raise ArgumentError, "Role#allow cannot take a hash as a verb" if verb.is_a? Hash

    verbs = verb.is_a?(Array) ? verb : [verb]


    #resource_type = nil_to_string resource_type
    tags = [] if tags.nil?
    tags = [tags] unless tags.is_a? Array

    # create permissions
    Permission.transaction do
      p = Permission.create!(:role => self, :organization => org)
      verbs.each do |verb|
        p.verbs << Verb.find_or_create_by_verb(verb)
      end
      tags.each do |tag|
        p.tags << Tag.find_or_create_by_name(tag)
      end
      p.resource_type = ResourceType.find_or_create_by_name(resource_type) unless resource_type.nil?
      p.save!
      Rails.logger.info "Permission created: #{p.to_text}"
    end
  end

  def disallow(verb, resource_type, tags = nil, org = nil)
    raise ArgumentError, "verb can't be nil" if verb.nil?
    raise ArgumentError, "tag(s) can't be nil" if tags.nil?
    raise ArgumentError, "Resource Type can't be nil" if verb.nil?
    
    verbs = verb.is_a?(Array) ? verb : [verb]

    #tags = nil_to_string tags

    # delete permissions
    Permission.transaction do
      Permission.select('DISTINCT(permissions.id)').joins(:resource_type, :verbs, :tags).where(
        :role_id => id, :organization_id => (org && org.id),
        :resource_types => { :name => resource_type },
        :tags => { :name => tags },
        :verbs => { :verb => verbs }).find_each do |p|
          Permission.destroy(p.id)
      end
    end
  end

  # returns the candlepin role (for RHSM)
  def self.candlepin_role
    Role.find_by_name('candlepin_role')
  end


  #permissions
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
    User.allowed_to?([:read,:update, :create], :roles, nil)
  end

  def readable?
    Role.any_readable?
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

end
