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

module Katello
  module BreadcrumbHelper

    def add_crumb_node! hash, id, url, name, trail, params={}, attributes ={}
      cache = false || params[:cache] #default to false
      hash[id] = {:name=>name, :url=>url, :trail=>trail, :cache=>cache}
      hash[id][:content] = params[:content] if params[:content]
      hash[id][:scrollable] = params[:scrollable] ? true : false
      hash[id][:client_render] = true if params[:client_render]
      hash[id][:searchable] = true if params[:searchable]
      hash[id][:product_id] = params[:product_id] if params[:product_id]
      hash[id] = hash[id].merge(attributes)
    end
  end
end

module Katello
  module ChangesetBreadcrumbs
    def generate_cs_breadcrumb changesets
      bc = {}
      add_crumb_node!(bc, "changesets", "", _("Changesets"), [], {:client_render => true})

      changesets.each{|cs|
        process_cs cs, bc
      } if changesets

      bc.to_json
    end

    def process_cs cs, bc
      cs_info = {:is_new=>cs.state == Changeset::NEW, :state=>cs.state}
      if (cs.state == Changeset::PROMOTING)
        prog = cs.task_status.progress
        if prog
          cs_info[:progress] =  cs.task_status.progress
        else
          cs_info[:progress] =  0
        end
      end
      add_crumb_node!(bc, changeset_bc_id(cs), "", cs.name, ['changesets'],
                    {:client_render => true}, cs_info)
    end

    def changeset_bc_id cs
      "changeset_#{cs.id}" if cs
    end
  end
end

module Katello
  module ContentBreadcrumbs
    #  Generates a json structure of the breadcrumb, consisting of a hash map of:
    #
    #     :id =>  {:url, :name, :trail} # where name is a human readable name, and :trail is
    #                                   # a list of other :ids creating the trail leading up to it
    #
    def generate_content_breadcrumb
     bc = {}
     content_crumb_id = "content"
     content_views_crumb_id = "content_views"

     #add_crumb_node!(bc, content_crumb_id, details_promotion_path(@environment.name) ,
     #    _("Content"), [], {:cache =>true, :content=>render(:partial=>"detail",
     #                              :locals=>{:environment_name => @environment.name,
     #                                        :read_contents => @environment.contents_readable?})})
     #
     #add_crumb_node!(bc, content_views_crumb_id, content_views_promotion_path(@environment.name), _("Content Views"),
     #               [content_crumb_id])


     view_versions = @environment.content_view_versions.non_default_view || []
     next_env_view_version_ids = @next_environment.nil? ? [].to_set :
         @next_environment.content_view_versions.non_default_view.
             pluck("content_view_versions.id").to_set

     add_crumb_node!(bc, content_crumb_id, details_promotion_path(@environment.name), _("Content"), [],
                     {:cache => true,
                      :content => render(:partial => "content_views",
                                         :locals => {:environment => @environment,
                                                     :content_view_versions => view_versions,
                                                     :next_env_view_version_ids => next_env_view_version_ids})})

     bc.to_json
    end

    def changeset_id cs
      return cs.id if cs
    end
  end
end

module Katello
  module RolesBreadcrumbs
    def generate_roles_breadcrumb
      bc = {}

      add_crumb_node!(bc, "roles", "", _(@role.name), [],
                      {:client_render => true},{:locked => @role.locked?})
      add_crumb_node!(bc, "role_permissions", "", _("Permissions"), ['roles'],
                      {:client_render => true})
      add_crumb_node!(bc, "role_users", "", _("Users"), ['roles'],
                      {:client_render => true})
      add_crumb_node!(bc, "role_ldap_groups", "", _("LDAP Groups"), ['roles'],
                      {:client_render => true}) if Katello.config.ldap_roles
      add_crumb_node!(bc, "global", "", _("Global Permissions"), ['roles', "role_permissions"],
                      {:client_render => true}, { :count => 0, :permission_details => get_global_verbs_and_tags })

      @organizations.each{|org|
        add_crumb_node!(bc, organization_bc_id(org), "", org.name, ['roles', 'role_permissions'],
                      {:client_render => true}, { :count => 0})
      } if @organizations

      User.visible.each{ |user|
        add_crumb_node!(bc, user_bc_id(user), "", user.username, ['roles', 'role_users'],
                      {:client_render => true}, { :has_role => false })
      }

      @role.ldap_group_roles.each do |group|
        add_group_to_bc(bc, group)
      end

      @role.users.each{ |user|
        bc[user_bc_id(user)][:has_role] = true
      }

      @role.permissions.each{ |perm|
        add_permission_bc(bc, perm, true)
      }

      bc.to_json
    end

    def add_group_to_bc(bc, group)
      add_crumb_node!(bc, "ldap_group_#{group.id}", '', group.ldap_group, ['roles', 'roles_ldap_groups'],
                    {:client_render => true}, { :has_role => false, :id => group.id })
    end

    def add_permission_bc bc, perm, adjust_count
      global = perm.resource_type.global?

      type = perm.resource_type
      type_name = type.display_name

      if perm.all_verbs
        verbs = 'all'
      else
        verbs = perm.verbs.collect {|verb| VirtualTag.new(verb.name, verb.all_display_names(perm.resource_type.name)) }
      end

      if perm.all_tags
        tags = 'all'
      else
        tags = perm.tag_values.collect { |t| Tag.formatted(perm.resource_type.name, t) }
      end

      if global
        add_crumb_node!(bc, permission_global_bc_id(perm), "", perm.id, ['roles', 'role_permissions', 'global'],
                    { :client_render => true },
                    { :global => global, :type => type.name, :type_name => type_name,
                      :name => _(perm.name), :description => _(perm.description),
                      :verbs => verbs,
                      :tags => tags })
        if adjust_count
          bc["global"][:count] += 1
        end
      else
        add_crumb_node!(bc, permission_bc_id(perm.organization, perm), "", perm.id, ['roles', 'role_permissions', organization_bc_id(perm.organization)],
                    { :client_render => true },
                    { :organization => "organization_#{perm.organization_id}",
                      :global => global, :type =>  type.name, :type_name => type_name,
                      :name => _(perm.name), :description => _(perm.description),
                      :verbs => verbs,
                      :tags => tags })
        if adjust_count
          bc[organization_bc_id(perm.organization)][:count] += 1
        end
        if type_name == "All"
          if !bc[organization_bc_id(perm.organization)].nil?
            bc[organization_bc_id(perm.organization)][:full_access] = true
          end
        end
      end
    end

    def get_global_verbs_and_tags
      details = {}

      resource_types.each do |type, value|
        details[type] = {}
        details[type][:verbs] = Verb.verbs_for(type, true).collect {|name, display_name| VirtualTag.new(name, display_name)}
        details[type][:verbs].sort! {|a,b| a.display_name <=> b.display_name}
        details[type][:global] = value["global"]
        details[type][:name] = value["name"]
      end

      return details
    end

    def organization_bc_id organization
      if organization
        "organization_#{organization.id}"
      else
        "global"
      end
    end

    def user_bc_id user
      "user_#{user.id}"
    end

    def permission_bc_id organization, permission
      if organization
        "permission_#{organization.id}_#{permission.id}"
      else
        "permission_global_#{permission.id}"
      end
    end

    def permission_global_bc_id permission
      "permission_global_#{permission.id}"
    end
  end
end
