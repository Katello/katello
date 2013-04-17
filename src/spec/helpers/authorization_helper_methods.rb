#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'models/model_spec_helper'

module AuthorizationHelperMethods
  include OrchestrationHelper

  def self.included(base)
    #Have to backup and restore the TYPES list, otherwise other tests will hit our fake ones
    types_backup = nil
    base.class_eval do
      before(:all) do
        Katello.config[:ldap_roles] = false
        Katello.config[:validate_ldap] = false
        types_backup = ResourceType::TYPES.clone
      end

      after(:all) do
        ResourceType::TYPES.clear
        ResourceType::TYPES.merge!(types_backup)
      end
    end
  end

  # for simplified testing without authorization (makes stubbing much more easier)
  def disable_authorization_rules
    controller.stub(:authorize).and_return(true)
  end

  def allow(*args)
    AuthorizationHelperMethods.allow(*args)
  end

  def self.allow role, verbs, resource_type, tags=[], org = nil, options = {}
    tags ||= []
    role = Role.find_or_create_by_name(role) if String === role
    name = "role-#{role.id}-perm-#{rand 10**6}"
    verbs = [] if verbs.nil?
    verbs = [verbs] unless Array === verbs
    verbs = verbs.collect {|verb| Verb.find_or_create_by_verb(verb)}


    rt =  ResourceType::TYPES[resource_type]
    if rt.nil?
      verbs_hash = {}.with_indifferent_access
      verbs.each{|verb| verbs_hash[verb.verb] = verb.verb}

      ResourceType::TYPES[resource_type] = { :model =>
        OpenStruct.new(:verbs_hash => verbs_hash).tap do |os|
          def os.list_verbs(global=false); verbs_hash; end
        end
      }
    else
      model_verbs = rt[:model].list_verbs(true).merge(rt[:model].list_verbs(false))
      verbs_not_in = verbs.collect{|verb| verb.verb unless model_verbs[verb.verb]}.compact

      verbs_not_in.each{|verb| model_verbs[verb] = verb}

      rt[:model].stub(:list_verbs).and_return(model_verbs.with_indifferent_access)
    end
    resource_type = ResourceType.find_or_create_by_name(resource_type)
    tags = [tags] unless Array === tags
    tags = [] unless tags

    role.permissions << Permission.create!(options.merge(:role => role, :name => name,
                                              :verbs => verbs, :resource_type => resource_type,
                                              :organization => org, :tag_values => tags))
    role.save!
  end

  class UserPermissionsGenerator
    def initialize(user)
      @user = user
    end

    def can(verb, resource_type, tags = nil, org = nil, options = {} )
      AuthorizationHelperMethods.allow(@user.own_role, verb, resource_type, tags, org, options)
    end

  end

  def user_with_permissions
    disable_user_orchestration

    @users_count ||= 0
    @users_count += 1
    user = User.create!(:username => "tmp#{@users_count}", :password => "tmp_password", :email => "tmp#{@users_count}@someserver.com")
    yield UserPermissionsGenerator.new(user) if block_given?
    user
  end

  def user_without_permissions
    user_with_permissions
  end

  def superadmin
    disable_user_orchestration
    user = user_with_permissions
    permission = Permission.create!(:role =>user.own_role, :all_types => true, :name => "superadmin")
    return user
  end

end


