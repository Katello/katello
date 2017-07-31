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
      inherited_value  = f.object.send(attr).try(:id) || ''
      %(<option data-id="#{inherited_value}" value="">#{blank_or_inherit_f(f, attr)}</option>)
    end

    def content_view(host)
      if host.is_a?(Hostgroup)
        host.content_view
      else
        host.content_facet.try(:content_view)
      end
    end

    def organizations(host)
      if host.is_a?(Hostgroup)
        host.organizations
      else
        host.organization ? [host.organization] : []
      end
    end

    def lifecycle_environment(host)
      if host.is_a?(Hostgroup)
        host.lifecycle_environment
      else
        host.content_facet.try(:lifecycle_environment)
      end
    end

    def use_install_media(host, options = {})
      return true if host && host.errors && host.errors.include?(:medium_id)
      kickstart_repository_id(host, options).blank?
    end

    def host_hostgroup_kickstart_repository_id(host)
      return if host.blank?
      return host.kickstart_repository_id if host.is_a?(Hostgroup)
      host.content_facet.kickstart_repository_id if host.try(:content_facet).present?
    end

    def kickstart_repository_id(host, options = {})
      return if host.try(:medium_id).present?

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

    def fetch_lifecycle_environment(host, options = {})
      selected_host_group = options.fetch(:selected_host_group, nil)
      return lifecycle_environment(selected_host_group) if selected_host_group.present?
      selected_env = lifecycle_environment(host)
      return selected_env if selected_env.present?
    end

    def fetch_content_view(host, options = {})
      selected_host_group = options.fetch(:selected_host_group, nil)
      return content_view(selected_host_group) if selected_host_group.present?

      selected_content_view = content_view(host)
      selected_content_view if selected_content_view.present?
    end

    def accessible_lifecycle_environments(org, host)
      selected = lifecycle_environment(host)
      envs = org.kt_environments.readable
      envs |= [selected] if selected.present? && org == selected.organization
      envs
    end

    def accessible_content_proxies(obj)
      list = accessible_resource_records(:smart_proxy).with_content.to_a
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

    def lifecycle_environment_options(host, options = {})
      include_blank = options.fetch(:include_blank, nil)
      include_blank = '<option></option>' if include_blank == true #check for true specifically

      selected_id = fetch_lifecycle_environment(host, options).try(:id)
      orgs = relevant_organizations(host)
      all_options = []
      orgs.each do |org|
        env_options = ""
        accessible_lifecycle_environments(org, host).each do |env|
          selected = selected_id == env.id ? 'selected' : ''
          env_options << %(<option value="#{env.id}" class="kt-env" #{selected}>#{h(env.name)}</option>)
        end

        if orgs.count > 1
          all_options << %(<optgroup label="#{org.name}">#{env_options}</optgroup>)
        else
          all_options << env_options
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
      lifecycle_environment = fetch_lifecycle_environment(host, options)
      content_view = fetch_content_view(host, options)

      views = []
      if lifecycle_environment
        views = Katello::ContentView.in_environment(lifecycle_environment).readable
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
        return [] unless host.operatingsystem.is_a?(Redhat)

        new_host = ::Host.new
        new_host.operatingsystem = param_host.operatingsystem.present? ? param_host.operatingsystem : host.operatingsystem
        new_host.architecture = param_host.architecture.present? ? param_host.architecture : host.architecture

        if (host.is_a? Hostgroup)
          new_host.content_facet = ::Katello::Host::ContentFacet.new(:lifecycle_environment_id => host.inherited_lifecycle_environment_id,
                                                          :content_view_id => host.inherited_content_view_id,
                                                          :content_source_id => host.inherited_content_source_id)
        elsif host.content_facet.present?
          new_host.content_facet = ::Katello::Host::ContentFacet.new(:lifecycle_environment_id => host.content_facet.lifecycle_environment_id,
                                                          :content_view_id => host.content_facet.content_view_id,
                                                          :content_source_id => host.content_source_id)
        end
        new_host.operatingsystem.kickstart_repos(new_host).map { |repo| OpenStruct.new(repo) }
      else
        # case 2
        os_updated_kickstart_options(host)
      end
    end

    def os_updated_kickstart_options(host)
      # this method gets called in 1 place Once you chose a diff os/content source/arch/lifecycle env/cv
      # via the os_selected method.
      # In this case we want it play by the rules of "one of these params" and
      # need to figure out the available KS repos for the given params.
      os_selection_params = ["operatingsystem_id", 'content_view_id', 'lifecycle_environment_id',
                             'content_source_id', 'architecture_id']
      view_options = []
      host_params = params[:hostgroup] || params[:host]
      if host_params && os_selection_params.all? { |key| host_params[key].present? }
        if host.nil?
          host = ::Host.new
        end
        host.operatingsystem = Operatingsystem.find(host_params[:operatingsystem_id])
        host.architecture = Architecture.find(host_params[:architecture_id])

        lifecycle_env = Katello::KTEnvironment.find(host_params[:lifecycle_environment_id])
        content_view = Katello::ContentView.find(host_params[:content_view_id])
        host.content_facet = Host::ContentFacet.new(:lifecycle_environment_id => lifecycle_env.id,
                                                    :content_view_id => content_view.id,
                                                    :content_source => SmartProxy.find(host_params[:content_source_id]))
        if host.operatingsystem.is_a?(Redhat)
          view_options = host.operatingsystem.kickstart_repos(host).map { |repo| OpenStruct.new(repo) }
        end
      end
      view_options
    end
  end
end
