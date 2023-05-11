module Katello
  module HostsAndHostgroupsHelper
    def kt_ak_label
      "kt_activation_keys"
    end

    def using_hostgroups_page?
      controller.controller_name == "hostgroups"
    end

    def blank_or_inherit_with_id(f, attr)
      return true unless f.object.respond_to?(:parent_id) && f.object.parent_id
      inherited_value = f.object.send(attr).try(:id) || ''
      %(<option data-id="#{inherited_value}" value="">#{blank_or_inherit_f(f, attr)}</option>)
    end

    def organizations(host)
      if host.is_a?(::Hostgroup)
        host.organizations
      else
        host.organization ? [host.organization] : []
      end
    end

    def use_install_media(host, options = {})
      return true if host&.errors && host.errors.include?(:medium_id)
      kickstart_repository_id(host, options).blank?
    end

    def host_hostgroup_kickstart_repository_id(host)
      return if host.blank?
      host.content_facet&.kickstart_repository_id
    end

    def kickstart_repository_id(host, options = {})
      host_ks_repo_id = host_hostgroup_kickstart_repository_id(host)
      ks_repo_options = kickstart_repository_options(host, options)
      # if the kickstart repo id is set in the selected_hostgroup use that
      selected_host_group = options.fetch(:selected_host_group, nil)
      if selected_host_group.try(:kickstart_repository_id).present?
        ks_repo_ids = ks_repo_options.map(&:id)

        if ks_repo_ids.include?(selected_host_group.kickstart_repository_id)
          return selected_host_group.kickstart_repository_id
        elsif host_ks_repo_id && ks_repo_ids.include?(host_ks_repo_id)
          return host_ks_repo_id
        else
          return ks_repo_options.first.try(:id)
        end
      end

      # if the kickstart repo id is set in the host use that
      return host_ks_repo_id if host_ks_repo_id.present?

      if selected_host_group.try(:medium_id).blank? && host.try(:medium_id).blank?
        ks_repo_options.first.try(:id)
      end
    end

    def fetch_lifecycle_environment(host_or_hostgroup, options = {})
      return host_or_hostgroup.single_lifecycle_environment if host_or_hostgroup.try(:single_lifecycle_environment)
      return host_or_hostgroup.lifecycle_environment if host_or_hostgroup.try(:lifecycle_environment)
      selected_host_group = options.fetch(:selected_host_group, nil)
      return selected_host_group.lifecycle_environment if selected_host_group.present?
    end

    def fetch_content_view(host_or_hostgroup, options = {})
      return host_or_hostgroup.single_content_view if host_or_hostgroup.try(:single_content_view)
      return host_or_hostgroup.content_view if host_or_hostgroup.try(:content_view)
      selected_host_group = options.fetch(:selected_host_group, nil)
      return selected_host_group.content_view if selected_host_group.present?
    end

    def fetch_content_source(host, options = {})
      return host.content_source if host.try(:content_source_id)
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

    # Generic method to provide a list of options in the UI
    def content_options(host, selected_id, object_type, options = {})
      include_blank = options.fetch(:include_blank, nil)
      include_blank = '<option></option>' if include_blank == true #check for true specifically
      orgs = relevant_organizations(host)
      all_options = []
      orgs.each do |org|
        content_object_options = ""
        accessible_content_objects = if object_type == :lifecycle_environment
                                       accessible_lifecycle_environments(org, host)
                                     elsif object_type == :content_source
                                       accessible_content_proxies(host)
                                     end
        accessible_content_objects.each do |content_object|
          selected = selected_id == content_object.id ? 'selected' : ''
          content_object_options << %(<option value="#{content_object.id}" class="kt-env" #{selected}>#{h(content_object.name)}</option>)
        end

        if orgs.count > 1
          all_options << %(<optgroup label="#{org.name}">#{content_object_options}</optgroup>)
        else
          all_options << content_object_options
        end
      end

      all_options = all_options.join
      all_options.insert(0, include_blank) if include_blank
      all_options.html_safe
    end

    def lifecycle_environment_options(host, options = {})
      content_options(
        host,
        fetch_lifecycle_environment(host, options).try(:id),
        :lifecycle_environment,
        options
      )
    end

    def content_source_options(host, options = {})
      content_options(
        host,
        fetch_content_source(host, options).try(:id),
        :content_source,
        options
      )
    end

    def content_views_for_host(host, options)
      include_blank = options.fetch(:include_blank, nil)
      if include_blank == true #check for true specifically
        include_blank = '<option></option>'
      end
      lifecycle_environment = fetch_lifecycle_environment(host, options)
      content_view = fetch_content_view(host, options)

      views = []
      if lifecycle_environment
        views = Katello::ContentView.in_environment(lifecycle_environment).readable.order(:name)
        views |= [content_view] if content_view.present? && content_view.in_environment?(lifecycle_environment)
      elsif content_view
        views = [content_view]
      end
      view_options = views.map do |view|
        selected = content_view.try(:id) == view.id ? 'selected' : ''
        %(<option #{selected} value="#{view.id}">#{h(view.name)}</option>)
      end
      view_options = view_options.join
      view_options.insert(0, include_blank) if include_blank
      view_options.html_safe
    end

    def view_to_options(view_options, selected_val, include_blank = false)
      if include_blank == true #check for true specifically
        include_blank = '<option></option>'
      end
      views = view_options.map do |view|
        selected = selected_val == view.id ? 'selected' : ''
        %(<option #{selected} value="#{view.id}">#{h(view.name)}</option>)
      end
      views = views.join
      views.insert(0, include_blank) if include_blank
      views.html_safe
    end

    def kickstart_repository_options(param_host, options = {})
      # this method gets called in 2 places
      # 1) On initial page load or a host group selection. At that point the host object is already
      #  =>  populated and we should just use that.
      # 2) Once you chose a diff os/content source/arch/lifecycle env/cv via the os_selected method.
      #   In case 2 we want it to play by the rules of "one of these params" and
      #   in case 1 we want it to behave as if everything is already set right and
      # We need to figure out the available KS repos in both cases.
      if param_host.present?
        # case 1
        selected_host_group = options.fetch(:selected_host_group, nil)
        host = selected_host_group.present? ? selected_host_group : param_host

        new_host = ::Host.new
        new_host.operatingsystem = param_host.operatingsystem.present? ? param_host.operatingsystem : host.operatingsystem
        new_host.architecture = param_host.architecture.present? ? param_host.architecture : host.architecture

        if (host.is_a? ::Hostgroup)
          new_host.content_facet = hostgroup_content_facet(host, param_host)
        elsif host.content_facet.present?
          new_host.content_facet = ::Katello::Host::ContentFacet.new(:content_source_id => host.content_source_id)
          if host.single_content_view_environment?
            # assign new_host the same CVE as host
            new_host.content_facet.assign_single_environment(
              :lifecycle_environment => host.content_facet.single_lifecycle_environment,
              :content_view => host.content_facet.single_content_view
            )
          end
        end
        new_host.operatingsystem.kickstart_repos(new_host).map { |repo| OpenStruct.new(repo) }
      else
        # case 2
        os_updated_kickstart_options
      end
    end

    def fetch_inherited_param(id, entity, parent_value)
      id.blank? ? parent_value : entity.find(id)
    end

    def os_updated_kickstart_options(host = nil)
      # this method gets called in 1 place Once you chose a diff os/content source/arch/lifecycle env/cv
      # via the os_selected method.
      # In this case we want it play by the rules of "one of these params" and
      # need to figure out the available KS repos for the given params.
      os_selection_params = ["operatingsystem_id", 'content_view_id', 'lifecycle_environment_id',
                             'content_source_id', 'architecture_id']
      view_options = []

      host_params = params[:hostgroup] || params[:host]
      parent = ::Hostgroup.find(host_params[:parent_id]) unless host_params.blank? || host_params[:parent_id].blank?
      if host_params && (parent || os_selection_params.all? { |key| host_params[key].present? })
        if host.nil?
          host = ::Host.new
        end
        host.operatingsystem = fetch_inherited_param(host_params[:operatingsystem_id], ::Operatingsystem, parent&.os)
        host.architecture = fetch_inherited_param(host_params[:architecture_id], ::Architecture, parent&.architecture)
        lifecycle_env = fetch_inherited_param(host_params[:lifecycle_environment_id], ::Katello::KTEnvironment, parent&.lifecycle_environment)
        content_view = fetch_inherited_param(host_params[:content_view_id], ::Katello::ContentView, parent&.content_view)
        content_source = fetch_inherited_param(host_params[:content_source_id], ::SmartProxy, parent&.content_source)

        host.content_facet = Host::ContentFacet.new(:content_source => content_source)
        host.content_facet.assign_single_environment(
          :lifecycle_environment_id => lifecycle_env.id,
          :content_view_id => content_view.id
        )
        if host.operatingsystem.is_a?(Redhat)
          view_options = host.operatingsystem.kickstart_repos(host).map { |repo| OpenStruct.new(repo) }
        end
      end
      view_options
    end

    def content_host_overview_button(host)
      return [] unless host.content_facet || host.subscription_facet
      [{
        :button => link_to(
          _('Content'),
          "/content_hosts/#{host.id}",
          :title => _("Host content and subscription details"),
          :class => 'btn btn-default'),
        :priority => 900
      }]
    end

    def hosts_change_content_source
      [{ action: [_('Change Content Source'), '/change_host_content_source', false], priority: 100 }]
    end

    def host_status_icon(status)
      colours = [:green, :yellow, :red]

      colour = colours[status] || :red

      icons = {
        green: "#{colour} host-status pficon pficon-ok status-ok",
        yellow: "#{colour} host-status pficon pficon-info status-warn",
        red: "#{colour} host-status pficon pficon-error-circle-o status-error"
      }

      "<span class=\"#{icons[colour]}\"></span>".html_safe
    end

    def errata_counts(host)
      counts = host.content_facet_attributes&.errata_counts || {}
      render partial: 'katello/hosts/errata_counts', locals: { counts: counts, host: host }
    end

    def host_registered_time(host)
      return ''.html_safe unless host.subscription_facet_attributes&.registered_at

      date_time_relative_value(host.subscription_facet_attributes.registered_at)
    end

    def host_checkin_time(host)
      return ''.html_safe unless host.subscription_facet_attributes&.last_checkin

      date_time_relative_value(host.subscription_facet_attributes.last_checkin)
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
