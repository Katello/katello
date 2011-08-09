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
  has_many :environments, :class_name => "KPEnvironment", :conditions => {:locker => false}, :dependent => :destroy, :inverse_of => :organization
  has_one :locker, :class_name =>"KPEnvironment", :conditions => {:locker => true}, :dependent => :destroy
  
  attr_accessor :parent_id,:pools,:statistics

  scoped_search :on => :name, :complete_value => true, :default_order => true, :rename => :'organization.name'
  scoped_search :on => :description, :complete_value => true, :rename => :'organization.description'
  scoped_search :in => :environments, :on => :name, :complete_value => true, :rename => :'environment.name'
  scoped_search :in => :environments, :on => :description, :complete_value => true, :rename => :'environment.description'
  scoped_search :in => :providers, :on => :name, :complete_value => true, :rename => :'provider.name'
  scoped_search :in => :providers, :on => :description, :complete_value => true, :rename => :'provider.description'
  scoped_search :in => :providers, :on => :provider_type, :complete_value => {:redhat => :'Red Hat', :custom => :'Custom'}, :rename => :'provider.type'
  scoped_search :in => :providers, :on => :repository_url, :complete_value => true, :rename => :'provider.url'

  before_create :create_locker
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

  def create_locker
    self.locker = KPEnvironment.new(:name => "Locker", :locker => true, :organization => self)
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
  end


  #permissions
  def self.creatable?
    User.allowed_to?([:create], :organizations)
  end

  def editable?
      User.allowed_to?([:update, :create], :organizations, self.id)
  end

  def deletable?
    User.allowed_to?([:delete, :create], :organizations)
  end

  def readable?
    User.allowed_to?([:read,:update, :create], :organizations, self.id)
  end

  def environments_manageable?
    User.allowed_to?([:update], :organizations, self.id)
  end
  

  def self.list_verbs
    {
      :create => N_("Create Organization"),
      :read => N_("Access Organization"),
      :update => N_("Manage Organization and Environments"),
      :delete => N_("Delete Organization"),
      :read_systems => N_("Access Systems"),
      :create_systems =>N_("Register Systems"),
      :update_systems => N_("Manage Systems"),
      :delete_systems => N_("Delete Systems")
   }.with_indifferent_access
  end

  def self.no_tag_verbs
    [:create]
  end
end
