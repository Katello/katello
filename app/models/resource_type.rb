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

class ResourceType < ActiveRecord::Base
  belongs_to :permission

  def display_name
    ResourceType::TYPES[name][:name]
  end

  def global?
    r = ResourceType::TYPES[name]
    return r[:global] if r && r[:global]
    false
  end

  def model
    ResourceType.model_for(name)
  end

  def self.global_types
    TYPES.collect{|key, value| key if value[:global]}.compact
  end

  def self.model_for resource_type
    check_type resource_type
    TYPES[resource_type][:model]
  end

  def self.check resource_type, verbs = []
    check_type resource_type

    model = model_for resource_type
    possible_verbs = (model.list_verbs(true).keys + model.list_verbs(false).keys).uniq
    verbs = [] if verbs.nil?
    verbs = [verbs] unless Array === verbs
    verbs.each { |verb|
      raise ArgumentError, "Invalid verb '#{verb}'. Verbs for resource type '#{resource_type}' can be one of #{possible_verbs.join(', ' )}} " unless possible_verbs.include? verb.to_s
    }

  end

  def self.check_type resource_type
    raise ArgumentError, "Invalid resource type '#{resource_type}'. Resource Types can be one of #{TYPES.keys.join(', ')}}  " unless TYPES.has_key? resource_type
  end


  TYPES = {
      :organizations => {:model => Organization, :name => N_("Organizations"), :global=>false},
      :environments => {:model => KPEnvironment, :name => N_("Environments"), :global=>false},
      :providers => { :model => Provider, :name => N_("Providers"), :global=>false},
      :sync_plans => { :model => SyncPlan, :name => N_("Sync Plans"), :global=>false},
      :users => { :model => User, :name => N_("Users"), :global=>true},
      :roles => { :model => Role, :name => N_("Roles"), :global=>true},
      :all => { :model => OpenStruct.new(:list_verbs =>{}, :list_tags=>[], :tags_for =>[], :no_tag_verbs =>[]), :name => N_("All"), :global => false}
  }.with_indifferent_access

end

