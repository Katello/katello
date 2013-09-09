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

module Authorization::Enforcement

  def self.included(base)
    base.class_eval do
      # Class method that has the same functionality as allowed_all_tags? method but operates
      # on the current logged user. The class attribute User.current must be set!
      def self.allowed_all_tags?(verb, resource_type = nil, org = nil)
        u = User.current
        raise Errors::UserNotSet, "current user is not set" if u.nil? || !u.is_a?(User)
        u.allowed_all_tags?(verb, resource_type, org)
      end

      # Class method that has the same functionality as allowed_tags_sql method but operates
      # on the current logged user. The class attribute User.current must be set!
      def self.allowed_tags_sql(verb, resource_type = nil, org = nil)
        ResourceType.check resource_type, verb
        u = User.current
        raise Errors::UserNotSet, "current user is not set" if u.nil? || !u.is_a?(User)
        u.allowed_tags_sql(verb, resource_type, org)
      end

      # Class method that has the same functionality as allowed_to? method but operates
      # on the current logged user. The class attribute User.current must be set!
      def self.allowed_to?(verb, resource_type, tags = nil, org = nil, any_tags = false)
        u = User.current
        raise Errors::UserNotSet, "current user is not set" if u.nil? || !u.is_a?(User)
        u.allowed_to?(verb, resource_type, tags, org, any_tags)
      end

      # Class method with the very same functionality as allowed_to? but throws
      # SecurityViolation exception leading to the denial page.
      def self.allowed_to_or_error?(verb, resource_type, tags = nil, org = nil, any_tags = false)
        u = User.current
        raise Errors::UserNotSet, "current user is not set" if u.nil? || !u.is_a?(User)
        unless u.allowed_to?(verb, resource_type, tags, org, any_tags)
          msg = "User #{u.username} is not allowed to #{verb} in #{resource_type} using #{tags}"
          Rails.logger.error msg
          raise Errors::SecurityViolation, msg
        end
      end

    end
  end

 # Returns true if for a given verbs, resource_type org combination
  # the user has access to all the tags
  # This is used extensively in many of the model permission scope queries.
  def allowed_all_tags?(verbs, resource_type, org = nil)
    ResourceType.check resource_type, verbs
    verbs = [] if verbs.nil?
    verbs = verbs.is_a?(Array) ? verbs.clone : [verbs]
    org = Organization.find(org) if org.is_a?(Numeric)

    log_roles(verbs, resource_type, nil, org)

    org_permissions = org_permissions_query(org, resource_type == :organizations)
    org_permissions = org_permissions.where(:organization_id => nil) if resource_type == :organizations

    no_tag_verbs = ResourceType::TYPES[resource_type][:model].no_tag_verbs.clone rescue []
    no_tag_verbs ||= []
    no_tag_verbs.delete_if { |verb| !verbs.member? verb }
    verbs.delete_if { |verb| no_tag_verbs.member? verb }

    all_tags_clause = ""
    unless resource_type == :organizations || ResourceType.global_types.include?(resource_type.to_s)
      all_tags_clause = " AND (permissions.all_tags = :true)"
    end

    clause_all_resources_or_tags = <<-SQL.split.join(" ")
        permissions.resource_type_id =
          (select id from resource_types where resource_types.name = :all) OR
          (permissions.resource_type_id =
            (select id from resource_types where resource_types.name = :resource_type) AND
            (verbs.verb in (:no_tag_verbs) OR
              (permissions.all_verbs=:true OR verbs.verb in (:verbs) #{all_tags_clause})))
    SQL
    clause_params = { :true => true, :all => "all", :resource_type => resource_type, :verbs => verbs }
    org_permissions.where(clause_all_resources_or_tags,
                          { :no_tag_verbs => no_tag_verbs }.merge(clause_params)).count > 0
  end

  # Return the sql that shows all the allowed tags for a given verb, resource_type, org
  # combination .
  # Note: one needs generally check for "allowed_all_tags?" before executing this
  # Note: This returns the SQL not result of the query
  #
  # This method is called by every Model's list method
  def allowed_tags_sql(verbs = nil, resource_type  =  nil, org  =  nil)
    select_on = "DISTINCT(permission_tags.tag_id)"
    select_on = "DISTINCT(permissions.organization_id)" if resource_type == :organizations

    allowed_tags_query(verbs, resource_type, org, false).select(select_on).to_sql
  end

  # Return true if the user is allowed to do the specified action for a resource type
  # verb/action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  #
  # This method is called by every protected controller.
  def allowed_to?(verbs, resource_type, tags = nil, org = nil, any_tags = false)
    tags = [] if tags.nil?
    tags = tags.is_a?(Array) ? tags.clone : [tags]
    if tags.detect { |tag| !(tag.is_a?(Numeric) || (tag.is_a?(String) && tag.to_s =~ /^\d+$/)) }
      raise ArgumentError, "Tags need to be integers - #{tags} are not."
    end
    ResourceType.check resource_type, verbs
    verbs = [] if verbs.nil?
    verbs = verbs.is_a?(Array) ? verbs.clone : [verbs]
    log_roles(verbs, resource_type, tags, org, any_tags)

    return true if allowed_all_tags?(verbs, resource_type, org)

    tags_query = allowed_tags_query(verbs, resource_type, org)

    if tags.empty? || resource_type == :organizations
      to_count = "permissions.id"
    else
      to_count = "permission_tags.tag_id"
    end

    tags_query = tags_query.where("permission_tags.tag_id in (:tags)", :tags => tags) unless tags.empty?
    count = tags_query.count(to_count, :distinct => true)
    if tags.empty? || any_tags
      count > 0
    else
      tags.length == count
    end
  end

  private

  # TODO: break up method
  # rubocop:disable MethodLength
  def allowed_tags_query(verbs, resource_type, org = nil, allowed_to_check = true)
    ResourceType.check resource_type, verbs
    verbs = [] if verbs.nil?
    verbs = verbs.is_a?(Array) ? verbs.clone : [verbs]
    log_roles(verbs, resource_type, nil, org)
    org = Organization.find(org) if org.is_a?(Numeric)
    org_permissions = org_permissions_query(org, resource_type == :organizations)

    clause        = ""
    clause_params = { :all => "all", :true => true, :resource_type => resource_type, :verbs => verbs }

    if resource_type != :organizations
      clause = <<-SQL.split.join(" ")
                permissions.resource_type_id =
                  (select id from resource_types where resource_types.name = :resource_type) AND
                  (permissions.all_verbs=:true OR verbs.verb in (:verbs))
      SQL

      org_permissions = org_permissions.joins(
          "left outer join permission_tags on permissions.id = permission_tags.permission_id")
    else
      if allowed_to_check
        org_clause = "permissions.organization_id is null"
        org_clause = org_clause + " OR permissions.organization_id = :organization_id " if org
        org_hash = { }
        org_hash = { :organization_id => org.id } if org
        org_permissions = org_permissions.where(org_clause, org_hash)
      else
        org_permissions = org_permissions.where("permissions.organization_id is not null")
      end

      clause = <<-SQL.split.join(" ")
                permissions.resource_type_id =
                  (select id from resource_types where resource_types.name = :all) OR
                  (permissions.resource_type_id =
                    (select id from resource_types where resource_types.name = :resource_type) AND
                    (permissions.all_verbs=:true OR verbs.verb in (:verbs)))
      SQL
    end
    org_permissions.where(clause, clause_params)
  end

  def org_permissions_query(org, exclude_orgs_clause = false)
    org_clause = "permissions.organization_id is null"
    org_clause = org_clause + " OR permissions.organization_id = :organization_id " if org
    org_hash = { }
    org_hash = { :organization_id => org.id } if org
    query = Permission.joins(:role).joins(
        "INNER JOIN roles_users ON roles_users.role_id = roles.id").joins(
        "left outer join permissions_verbs on permissions.id = permissions_verbs.permission_id").joins(
        "left outer join verbs on verbs.id = permissions_verbs.verb_id").where({ "roles_users.user_id" => id })
    return query.where(org_clause, org_hash) unless exclude_orgs_clause
    query
  end

end
