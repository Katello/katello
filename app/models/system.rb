
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

class NonLockerEnvironmentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value
    record.errors[attribute] << N_("Cannot register a system with 'Locker' environment ") if record.environment != nil && record.environment.locker?
  end
end

class System < ActiveRecord::Base
  include Glue::Candlepin::Consumer
  include Glue::Pulp::Consumer
  include Glue
  include Authorization
  include AsyncOrchestration

  acts_as_reportable

  belongs_to :environment, :class_name => "KTEnvironment", :inverse_of => :systems
  belongs_to :system_template

  has_many :system_activation_keys, :dependent => :destroy
  has_many :activation_keys, :through => :system_activation_keys

  validates :environment, :presence => true, :non_locker_environment => true
  validates :name, :presence => true, :no_trailing_space => true, :uniqueness => true
  validates :description, :katello_description_format => true
  validates_length_of :location, :maximum => 255
  before_create  :fill_defaults

  scope :by_env, lambda { |env| where('environment_id = ?', env) unless env.nil?}
  scope :completer_scope, lambda { |options| readable(options[:organization_id])}

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :description, :complete_value => true
  scoped_search :on => :location, :complete_value => true
  scoped_search :on => :uuid, :complete_value => true
  scoped_search :on => :id, :complete_value => true

  class << self
    def architectures
      { 'x86' => :'i386', 'Itanium' => :'ia64', 'x86_64' => :x86_64, 'PowerPC' => :ppc,
      'IBM S/390' => :s390, 'IBM System z' => :s390x,  'SPARC Solaris' => :'sparc64' }
    end

    def virtualized
      { "physical" => N_("Physical"), "virtualized" => N_("Virtual") }
    end
  end

  def organization
    environment.organization
  end

  def consumed_pool_ids
    self.pools.collect {|t| t['id']}
  end

  def consumed_pool_ids=attributes
    attribs_to_unsub = consumed_pool_ids - attributes
   
    attribs_to_unsub.each do |id|
      self.unsubscribe id
    end
    
    attribs_to_sub = attributes - consumed_pool_ids
    attribs_to_sub.each do |id|
      self.subscribe id
    end
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def as_json(options)
    json = super(options)
    json['environment'] = environment.as_json unless environment.nil?
    json['activation_key'] = activation_keys.as_json unless activation_keys.nil?
    json
  end

  def self.any_readable? org
    org.systems_readable? ||
        User.allowed_to?(KTEnvironment::SYSTEMS_READABLE, :environments, org.environment_ids, org, true)
  end

  def self.readable org
      raise "scope requires an organization" if org.nil?
      if org.systems_readable?
         where(:environment_id => org.environment_ids) #list all systems in an org 
      else #just list for environments the user can access
        where("systems.environment_id in (#{User.allowed_tags_sql(KTEnvironment::SYSTEMS_READABLE, :environments, org)})")
      end    
  end

  def readable?
    environment.systems_readable?
  end

  def editable?
    environment.systems_editable?
  end

  def deletable?
    environment.systems_deletable?
  end

  def self.registerable? env, org
    org ||= env.organization if env
    ret = false
    ret ||= User.allowed_to?([:register_systems], :organizations, nil, org) if org
    ret ||= User.allowed_to?([:register_systems], :environments, env.id, org) if env
    ret
  end


  private
  
    def fill_defaults
      self.description = "Initial Registration Params" unless self.description
      self.location = "None" unless self.location
    end
end
