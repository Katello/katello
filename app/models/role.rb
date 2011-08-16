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
  
  # Is this role allowed to verb? or
  # is this role allowed to verb, type and tag(s) combination?
  #
  # @param [String or Hash] verb string or hash with two strings [:controller] and [:action]
  # @param [String] resource type
  # @param [String or Array] one or more tags
  def allowed_to?(verb, resource_type = nil, tags = nil)
    return true if superadmin
    allowed_to_tags? verb, resource_type, tags
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
  def allow(verb, resource_type, tags = nil)
    raise ArgumentError, "verb can't be nil" if verb.nil?
    raise ArgumentError, "Resource Type can't be nil" if verb.nil?

    #throw error if using old format, shouldn't overload methods like this
    raise ArgumentError, "Role#allow cannot take a hash as a verb" if verb.is_a? Hash

    verbs = verb.is_a?(Array) ? verb : [verb]


    resource_type = nil_to_string resource_type
    tags = [] if tags.nil?
    tags = [tags] unless tags.is_a? Array

    # create permissions
    Permission.transaction do
      p = Permission.create!(:role => self)
      verbs.each do |verb|
        p.verbs << Verb.find_or_create_by_verb(verb)
      end
      tags.each do |tag|
        p.tags << Tag.find_or_create_by_name(tag)
      end
      p.resource_type = ResourceType.find_or_create_by_name(resource_type)
      p.save!
      Rails.logger.info "Permission created: #{p.to_text}"
    end
  end

  def disallow(verb, resource_type, tags = nil)
    raise ArgumentError, "verb can't be nil" if verb.nil?
    raise ArgumentError, "tag(s) can't be nil" if tags.nil?
    raise ArgumentError, "Resource Type can't be nil" if verb.nil?
    
    verbs = verb.is_a?(Array) ? verb : [verb]
    resource_type = nil_to_string resource_type
    tags = nil_to_string tags

    # delete permissions
    Permission.transaction do
      Permission.select('DISTINCT(permissions.id)').joins(:resource_type, :verbs, :tags).where(
        :role_id => id,
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

  private
  
  # convert nil object to string "NIL"
  def nil_to_string(object)
    (object.nil? or object == '') ? 'NIL' : object
  end

  def allowed_to_tags?(verb, resource_type, tags)
    raise _("Resource type cannot be null") if resource_type.nil?
    Rails.logger.debug "Checking if role #{name} is allowed to #{verb.inspect} in #{resource_type.inspect} scoped #{tags.inspect}"
    return true unless Permission.joins(:resource_type).
      where(:role_id => id, :all_verbs=> true, :resource_types => { :name => resource_type }).count == 0

    verb = action_to_verb(verb, resource_type)

     return true unless Permission.joins(:verbs,:resource_type).
       where(:role_id => id, :verbs => { :verb => verb }, :all_tags=> true,
             :resource_types => { :name => resource_type }).count == 0

    tags = [] if tags.nil?
    tags = [tags] unless tags.is_a? Array
    query_hash = {:role_id => id,
      :resource_types => { :name => resource_type },
      :verbs => { :verb => verb }}
    query_hash[:tags] = {:name=> tags} if !tags.empty?

    if tags.empty?
      item_count = 1
      to_count = "verbs.verb"
    else
      item_count = tags.length
      to_count = "tags.name"
    end
    Permission.joins(:verbs, :resource_type).joins(
        "left outer join permissions_tags on permissions.id = permissions_tags.permission_id").joins(
        "left outer join tags on tags.id = permissions_tags.tag_id").where(query_hash).count(to_count, :distinct => true) == item_count
    # TODO - for now we just compare count - this is dangerous - we need to compare the content
  end

  DEFAULT_VERBS = {
    :edit => 'update', :update=> 'update',
    :new => 'create', :create => 'create', :create_favorite => 'create',
    :index => 'read', :show => 'read', :auto_complete_search => 'read',
    :destroy => 'delete', :destroy_favorite => 'delete',
    :items => 'read'
  }.with_indifferent_access

  ACTION_TO_VERB = {
    :certificates => {:serials => 'read'},
    :changesets => {:list=>'read', :edit=>'read', :object=>'read', :show=>'read', :packages=>'read', :repos=>'read',
                    :errata=>'read', :dependency_size=>'read', :dependency_list=>'read', :show_content=>'read'},
    :consumers => {:export_status => 'read'},
    :notices => {:get_new => 'read', :details => 'read', :note_count => 'read',
                 :destroy_all => 'delete'},
    :owners => {:import_status => 'read'},
    :promotions => {:products=>'read', :packages=>'read', :trees=>'read', :errata=>'read', :detail=>'read', :repos=>'read'},
    :providers => {:subscriptions=>'read', :products_repos=>'read'},
    :roles => {:verbs_and_scopes => 'read', :create_permission=>'update', :update_permission=>'update', :show_permission=>'read'},
    :sync_management => {:status => 'read',:product_status => 'read'},
    :systems=> {:packages=>'read', :subscriptions=>'read', :facts=>'read', :update_subscriptions=>'update'},
    :users => {:enable_helptip=>'update', :disable_helptip=>'update', :clear_helptips=>'update'},
    
  }.with_indifferent_access

  def action_to_verb(verb, type)
    return ACTION_TO_VERB[type][verb] if ACTION_TO_VERB[type] and ACTION_TO_VERB[type][verb]
    return DEFAULT_VERBS[verb] if DEFAULT_VERBS[verb]
    return verb
  end

end
