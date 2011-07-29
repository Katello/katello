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
  has_and_belongs_to_many :users
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

  # relationship user-org is created for current user automatically
  after_create do |org|
    org.users << User.current if User.current
  end

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
end
