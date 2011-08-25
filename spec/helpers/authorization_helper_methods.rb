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


module AuthorizationHelperMethods
  def allow(*args)
    AuthorizationHelperMethods.allow(*args)
  end

  def self.allow role, verbs, resource_type, tags=[], org = nil
    role = Role.find_or_create_by_name(role) if String === role
    name = "role-#{role.id}-perm-#{rand 10**6}"
    verbs = [] if verbs.nil?
    verbs = [verbs] unless Array === verbs
    verbs = verbs.collect {|verb| Verb.find_or_create_by_verb(verb)}


    rt =  ResourceType::TYPES[resource_type]
    if rt.nil?
      verbs_hash = {}.with_indifferent_access
      verbs.each{|verb| verbs_hash[verb.verb] = verb.verb}
      ResourceType::TYPES[resource_type] = {:model => OpenStruct.new(:list_verbs => verbs_hash)}
    else
      model_verbs = rt[:model].list_verbs(true).merge(rt[:model].list_verbs(false))
      verbs_not_in = verbs.collect{|verb| verb.verb unless model_verbs[verb.verb]}.compact

      verbs_not_in.each{|verb| model_verbs[verb] = verb}

      rt[:model].stub(:list_verbs).and_return(model_verbs.with_indifferent_access)
    end
    resource_type = ResourceType.find_or_create_by_name(resource_type)
    tags = [tags] unless Array === tags
    tags = tags.collect{|tag| Tag.find_or_create_by_name(tag)}

    role.permissions << Permission.create!(:role => role, :name => name, :verbs => verbs, :resource_type => resource_type,
                                              :tags => tags, :organization => org)
    role.save!
  end

  class UserPermissionsGenerator
    def initialize(user)
      @user = user
    end

    def can(verb, resource_type, tags = nil, org = nil)
      AuthorizationHelperMethods.allow(@user.own_role, verb, resource_type, tags, org)
    end

  end

  def user_with_permissions
    @users_count ||= 0
    @users_count += 1
    user = User.create!(:username => "tmp#{@users_count}", :password => "tmp_password")
    yield UserPermissionsGenerator.new(user) if block_given?
    user
  end

  def user_without_permissions
    user_with_permissions
  end
end


