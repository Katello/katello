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


module AuthorizationSupportMethods


  def allow(*args)
    AuthorizationSupportMethods.allow(*args)
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
      ResourceType::TYPES[resource_type] = {:model => OpenStruct.new(:list_verbs => verbs_hash)}
    else
      model_verbs = rt[:model].list_verbs(true).merge(rt[:model].list_verbs(false))
      verbs_not_in = verbs.collect{|verb| verb.verb unless model_verbs[verb.verb]}.compact

      verbs_not_in.each{|verb| model_verbs[verb] = verb}

      #rt[:model].stub(:list_verbs).and_return(model_verbs.with_indifferent_access)
    end
    resource_type = ResourceType.find_or_create_by_name(resource_type)
    tags = [tags] unless Array === tags
    tags = [] unless tags

    role.permissions << Permission.create!(options.merge(:role => role, :name => name,
                                              :verbs => verbs, :resource_type => resource_type,
                                              :organization => org, :tag_values => tags))
    role.save!
  end
end


