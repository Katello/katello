#
# Copyright 2014 Red Hat, Inc.
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
  module HostsAndHostgroupsHelper
    def kt_ak_label
      "kt_activation_keys"
    end

    def blank_or_inherit_with_id(f, attr)
      return true unless f.object.respond_to?(:parent_id) && f.object.parent_id
      inherited_value  = f.object.send(attr).try(:id) || ''
      %(<option data-id="#{inherited_value}" value="">#{blank_or_inherit_f(f, attr)}</option>)
    end

    def envs_by_kt_org
      ::Environment.all.find_all(&:katello_id).group_by do |env|
        if env.katello_id
          env.katello_id.split('/').first
        end
      end
    end

    def lifecycle_environment_options(host, options = {})
      include_blank = options.fetch(:include_blank, nil)
      if include_blank == true #check for true specifically
        include_blank = '<option></option>'
      end
      selected_id = host[:lifecycle_environment_id]
      orgs = Organization.current ? [Organization.current] : Organization.my_organizations
      all_options = []
      orgs.each do |org|
        env_options = ""
        org.kt_environments.each do |env|
          selected = selected_id == env.id ? 'selected' : ''
          env_options << %(<option value="#{env.id}" class="kt-env" #{selected}>#{h(env.name)}</option>)
        end

        if Organization.current
          all_options << env_options
        else
          all_options <<  %(<optgroup label="#{org.name}">#{env_options}</optgroup>)
        end
      end

      all_options = all_options.join
      all_options.insert(0, include_blank) if include_blank
      all_options.html_safe
    end

    def content_views_for_host(host, options)
      include_blank = options.fetch(:include_blank, nil)
      if include_blank == true #check for true specifically
        include_blank = '<option></option>'
      end

      views = []
      if host.lifecycle_environment
        views = Katello::ContentView.in_environment(host.lifecycle_environment)
      elsif host.content_view
        views = [host.content_view]
      end
      view_options = views.map do |view|
        selected = host[:content_view_id] == view.id ? 'selected' : ''
        %(<option #{selected} value="#{view.id}">#{h(view.name)}</option>)
      end
      view_options = view_options.join
      view_options.insert(0, include_blank) if include_blank
      view_options.html_safe
    end
  end
end
