module Katello
  module HostsAndHostgroupsHelper
    include ContentOptionsHelper
    include KickstartRepositoryHelper
    include HostDisplayHelper

    def kt_ak_label
      "kt_activation_keys"
    end

    def edit_action?
      params[:action] == 'edit'
    end

    def cv_lce_disabled?
      edit_action? && !using_discovered_hosts_page?
    end

    def content_source_inherited?(host)
      !using_hostgroups_page? && host&.content_source.blank? && host&.hostgroup&.content_source.present? && cv_lce_disabled?
    end

    def lifecycle_environment_inherited?(host)
      !using_hostgroups_page? && host&.lifecycle_environments&.empty? && host&.hostgroup&.lifecycle_environment.present? && cv_lce_disabled?
    end

    def content_view_inherited?(host)
      !using_hostgroups_page? && host&.content_views&.empty? && host&.hostgroup&.content_view.present? && cv_lce_disabled?
    end

    def kickstart_repo_inheritable?(host)
      host&.kickstart_repository_id.blank?
    end

    def using_discovered_hosts_page?
      controller.controller_name == "discovered_hosts"
    end

    def using_hostgroups_page?
      controller.controller_name == "hostgroups"
    end

    def organizations(host)
      if host.is_a?(::Hostgroup)
        host.organizations
      else
        host.organization ? [host.organization] : []
      end
    end

    def fetch_lifecycle_environment(host_or_hostgroup, options = {})
      return host_or_hostgroup.single_lifecycle_environment if host_or_hostgroup.try(:single_lifecycle_environment)
      return host_or_hostgroup.lifecycle_environment if host_or_hostgroup.try(:lifecycle_environment)
      if host_or_hostgroup.is_a?(::Hostgroup) && host_or_hostgroup.content_facet.present?
        # to handle cloned hostgroups that are new records
        return host_or_hostgroup.content_facet.lifecycle_environment
      end
      selected_host_group = options.fetch(:selected_host_group, nil)
      return selected_host_group.lifecycle_environment if selected_host_group.present?
    end

    def fetch_content_view(host_or_hostgroup, options = {})
      return host_or_hostgroup.single_content_view if host_or_hostgroup.try(:single_content_view)
      return host_or_hostgroup.content_view if host_or_hostgroup.try(:content_view)
      if host_or_hostgroup.is_a?(::Hostgroup) && host_or_hostgroup.content_facet.present?
        # to handle cloned hostgroups that are new records
        return host_or_hostgroup.content_facet.content_view
      end
      selected_host_group = options.fetch(:selected_host_group, nil)
      return selected_host_group.content_view if selected_host_group.present?
    end

    def fetch_content_view_environment(hostgroup, options = {})
      return hostgroup.content_facet.content_view_environment if hostgroup.content_facet.present?
      selected_host_group = options.fetch(:selected_host_group, nil)
      return selected_host_group.content_facet.content_view_environment if selected_host_group&.content_facet.present?
    end

    def fetch_content_source(host_or_hostgroup, options = {})
      return host_or_hostgroup.content_source if host_or_hostgroup.content_source_id&.present? && host_or_hostgroup.persisted?
      if host_or_hostgroup.is_a?(::Hostgroup) && host_or_hostgroup.content_facet.present?
        # to handle cloned hostgroups that are new records
        return host_or_hostgroup.content_facet.content_source
      end
      selected_host_group = options.fetch(:selected_host_group, nil)
      return selected_host_group.content_source if selected_host_group.present?
    end

    def accessible_lifecycle_environments(org, host_or_hostgroup)
      selected = if host_or_hostgroup.is_a?(::Host::Managed)
                   host_or_hostgroup.try(:single_lifecycle_environment)
                 else
                   host_or_hostgroup.lifecycle_environment
                 end
      envs = org.kt_environments.readable.order(:name)
      envs |= [selected] if selected.present? && org == selected.organization
      envs
    end

    def accessible_content_proxies(obj)
      list = accessible_resource_records(:smart_proxy).with_content.order(:name).to_a
      current = obj.content_source
      list |= [current] if current.present?
      list
    end

    def relevant_organizations(host)
      host_orgs = organizations(host)
      if Organization.current
        [Organization.current]
      elsif host_orgs.present?
        host_orgs
      else
        Organization.my_organizations
      end
    end

    def fetch_inherited_param(id, entity, parent_value)
      id.blank? ? parent_value : entity.find(id)
    end

    private

    def inherited_or_own_content_source_id(host_or_hostgroup, hostgroup)
      content_source_id = hostgroup.inherited_content_source_id
      if host_or_hostgroup.content_source_id && (hostgroup.inherited_content_source_id != host_or_hostgroup.content_source_id)
        content_source_id = host_or_hostgroup.content_source_id
      end
      content_source_id
    end

    def inherited_or_own_facet_attributes(host_or_hostgroup, hostgroup)
      lifecycle_environment_id = hostgroup.inherited_lifecycle_environment_id
      content_view_id = hostgroup.inherited_content_view_id
      case host_or_hostgroup
      when ::Hostgroup
        if host_or_hostgroup.lifecycle_environment_id && (hostgroup.inherited_lifecycle_environment_id != host_or_hostgroup.lifecycle_environment_id)
          lifecycle_environment_id = host_or_hostgroup.lifecycle_environment_id
        end
        if host_or_hostgroup.content_view_id && (hostgroup.inherited_content_view_id != host_or_hostgroup.content_view_id)
          content_view_id = host_or_hostgroup.content_view_id
        end
      when ::Host::Managed
        if host_or_hostgroup.single_lifecycle_environment && (hostgroup.inherited_lifecycle_environment_id != host_or_hostgroup.single_lifecycle_environment.id)
          lifecycle_environment_id = host_or_hostgroup.single_lifecycle_environment.id
        end
        if host_or_hostgroup.single_content_view && (hostgroup.inherited_content_view_id != host_or_hostgroup.single_content_view.id)
          content_view_id = host_or_hostgroup.single_content_view.id
        end
      end
      [lifecycle_environment_id, content_view_id]
    end

    def hostgroup_content_facet(hostgroup, param_host)
      lifecycle_environment_id, content_view_id = inherited_or_own_facet_attributes(param_host, hostgroup)
      content_source_id = inherited_or_own_content_source_id(param_host, hostgroup)
      facet = ::Katello::Host::ContentFacet.new(:content_source_id => content_source_id)
      if content_view_id && lifecycle_environment_id
        facet.assign_single_environment(
          :lifecycle_environment_id => lifecycle_environment_id,
          :content_view_id => content_view_id
        )
      end
      facet
    end
  end
end
