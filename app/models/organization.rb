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


class Organization < ActiveRecord::Base
  include Glue::Candlepin::Owner if AppConfig.use_cp
  include Glue if AppConfig.use_cp
  include Authorization

  has_many :activation_keys, :dependent => :destroy
  has_many :providers
  has_many :environments, :class_name => "KTEnvironment", :conditions => {:locker => false}, :dependent => :destroy, :inverse_of => :organization
  has_one :locker, :class_name =>"KTEnvironment", :conditions => {:locker => true}, :dependent => :destroy
  has_many :filters, :dependent => :destroy, :inverse_of => :organization

  has_many :gpg_keys, :dependent => :destroy, :inverse_of => :organization

  attr_accessor :statistics

  scoped_search :on => :name, :complete_value => true, :rename => :'organization.name'
  scoped_search :on => :description, :complete_value => true, :rename => :'organization.description'
  scoped_search :in => :environments, :on => :name, :complete_value => true, :rename => :'environment.name'
  scoped_search :in => :environments, :on => :description, :complete_value => true, :rename => :'environment.description'
  scoped_search :in => :providers, :on => :name, :complete_value => true, :rename => :'provider.name'
  scoped_search :in => :providers, :on => :description, :complete_value => true, :rename => :'provider.description'
  scoped_search :in => :providers, :on => :provider_type, :complete_value => {:redhat => :'Red Hat', :custom => :'Custom'}, :rename => :'provider.type'
  scoped_search :in => :providers, :on => :repository_url, :complete_value => true, :rename => :'provider.url'

  before_create :create_locker
  before_create :create_redhat_provider
  validates :name, :uniqueness => true, :presence => true, :katello_name_format => true
  validates :description, :katello_description_format => true


  def systems
    System.where(:environment_id => environments)
  end

  def promotion_paths
    #I'm sure there's a better way to do this
    self.environments.joins(:priors).where("prior_id = #{self.locker.id}").collect do |env|
      env.path
    end
  end

  def redhat_provider
    self.providers.redhat.first
  end

  def create_locker
    self.locker = KTEnvironment.new(:name => "Locker", :locker => true, :organization => self)
  end

  def create_redhat_provider
    self.providers << ::Provider.new(:name => "Red Hat", :provider_type=> ::Provider::REDHAT, :organization => self)
  end

  #permissions
  scope :readable, lambda {authorized_items(READ_PERM_VERBS)}

  def self.creatable?
    User.allowed_to?([:create], :organizations)
  end

  def editable?
      User.allowed_to?([:update, :create], :organizations, nil, self)
  end

  def deletable?
    User.allowed_to?([:delete, :create], :organizations)
  end

  def readable?
    User.allowed_to?(READ_PERM_VERBS, :organizations,nil, self)
  end

  def self.any_readable?
    Organization.readable.count > 0
  end

  def environments_manageable?
    User.allowed_to?([:update, :create], :organizations, nil, self)
  end

  SYSTEMS_READABLE = [:read_systems, :register_systems, :update_systems, :delete_systems]

  def systems_readable?
    User.allowed_to?(SYSTEMS_READABLE, :organizations, nil, self)
  end

  def systems_readable?
    User.allowed_to?(SYSTEMS_READABLE, :organizations, nil, self)
  end

  def gpg_keys_manageable?
    User.allowed_to?([:gpg], :organizations, nil, self)
  end

  def self.list_verbs global = false
    org_verbs = {
      :update => N_("Manage Organization and Environments"),
      :read => N_("Access Organization"),
      :read_systems => N_("Access Systems"),
      :register_systems =>N_("Register Systems"),
      :update_systems => N_("Manage Systems"),
      :delete_systems => N_("Delete Systems"),
      :sync => N_("Sync Products"),
      :gpg => N_("Manage GPG Keys")
   }
    org_verbs.merge!({
    :create => N_("Create Organization"),
    :delete => N_("Delete Organization")
    }) if global

    org_verbs.with_indifferent_access

  end

  def self.no_tag_verbs
    [:create]
  end

  def syncable?
    User.allowed_to?(SYNC_PERM_VERBS, :organizations, nil, self)
  end

  private

  def self.authorized_items verbs, resource = :organizations
    if !User.allowed_all_tags?(verbs, resource)
      where("organizations.id in (#{User.allowed_tags_sql(verbs, resource)})")
    end
  end

  READ_PERM_VERBS = [:read, :create, :update, :delete]
  SYNC_PERM_VERBS = [:sync]

end
