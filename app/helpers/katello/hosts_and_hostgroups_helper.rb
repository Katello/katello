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

    def fetch_content_view_environment(host_or_hostgroup, options = {})
      if host_or_hostgroup&.content_facet.present?
        if host_or_hostgroup.is_a?(::Hostgroup)
          return host_or_hostgroup.content_facet.content_view_environment
        else
          return host_or_hostgroup.content_facet.content_view_environments.first
        end
      end
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

    def inherited_or_own_cve_id(host_or_hostgroup, hostgroup)
      inherited_cve_id = hostgroup.content_facet&.content_view_environment_id
      inherited_cve_id ||= hostgroup.send(:inherited_ancestry_attribute, :content_view_environment_id, :content_facet) if hostgroup.ancestry.present?

      case host_or_hostgroup
      when ::Hostgroup
        own_cve_id = host_or_hostgroup.content_facet&.content_view_environment_id
        own_cve_id && own_cve_id != inherited_cve_id ? own_cve_id : inherited_cve_id
      when ::Host::Managed
        own_cve = host_or_hostgroup.content_view_environments.first
        own_cve && own_cve.id != inherited_cve_id ? own_cve.id : inherited_cve_id
      else
        inherited_cve_id
      end
    end

    def hostgroup_content_facet(hostgroup, param_host)
      cve_id = inherited_or_own_cve_id(param_host, hostgroup)
      content_source_id = inherited_or_own_content_source_id(param_host, hostgroup)
      facet = ::Katello::Host::ContentFacet.new(:content_source_id => content_source_id)
      if cve_id
        cve = ::Katello::ContentViewEnvironment.find_by(id: cve_id)
        facet.content_view_environments = [cve] if cve
      end
      facet
    end
  end
end
