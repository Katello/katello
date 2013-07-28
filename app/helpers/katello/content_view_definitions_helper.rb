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
  module ContentViewDefinitionsHelper
    def definition_type(definition)
      definition.composite? ? _('Composite View Definition') : _('View Definition')
    end

    def environments(view_version)
      _("Environment(s): %{environments}") % {:environments => view_version.environments.collect{|e| e.name}.join(', ')}
    end

    def content_view_search_link(view)
      # Build a link to the content search page to allow the user
      # to view details on all versions of the content view across
      # all environments.  This will allow the user to more easily
      # view the differences between environments/versions.
      content_search_index_path + search_string(view)
    end

    def search_string(view)
      views = {:autocomplete => {0 => {:id => view.id, :name => view.name}}}
      repos = {:search => ""}
      env_ids = view.environments.map(&:id)
      "#" + {:search => {:views => views, :repos => repos, :content_type => "repos"}, :envs => env_ids}.to_param
    end

    def unable_to_remove_view
      _("Before removing this view, all promoted versions must first be deleted from their "\
        "respective environments using a deletion changeset.")
    end

    def publish_button(definition)
      if definition.has_repo_conflicts?
        content_tag(:td,
                    tag(:input, {:type => 'button', :class => 'fr button',
                                  :value => _('Publish'), :disabled => true}),
                    :class => 'repo_conflict',
                    'original-title' => _("The definition consists of component content views that "\
                                          "share the same repository; therefore, it cannot be "\
                                          "published.  Please visit the Content pane to "\
                                          "resolve this issue."))

      else
        content_tag(:td,
                    tag(:input, {:type => 'button', :class => 'fr button subpanel_element publish',
                                  :value => _('Publish'),
                                  'data-url' => publish_setup_content_view_definition_path(definition.id)}))
      end
    end

    def refresh_link(version, task)
      if version.content_view.content_view_definition.has_repo_conflicts?
        content_tag(:a, _('Refresh'),
                    {:type => 'button', :href => '#', :class => 'repo_conflict disabled',
                     'original-title' => _("The definition consists of component content views "\
                                           "that share the same repository; therefore, views "\
                                           "cannot be refreshed.  Please visit the Content "\
                                           "pane to resolve this issue.")})
      else
        if version.environments.include?(version.content_view.organization.library)
          unless task && task.pending?
            content_tag(:a, task.nil? || task.error? ? _('Retry') : _('Refresh'),
                        {:type => 'button', :href => '#', :class => 'refresh_action tipsify',
                         'original-title' => _('Refresh'),
                         'data-url' => refresh_content_view_definition_content_view_path(
                             version.content_view.content_view_definition.id, version.content_view.id)})
          end
        end
      end
    end

    def view_checked?(view_id, views_hash=nil)
      return false if views_hash.nil?
      return views_hash.has_key?(view_id)
    end

    def view_repos(definitions)
      view_repos = {}
      definitions.each do |definition|
        definition.content_views.each do |view|
          view_repos[view.id] = {
              :name => view.name,
              :repos => view.repos(current_organization.library).collect{|repo| repo.library_instance_id}
          }
        end
      end
      view_repos
    end

  end
end
