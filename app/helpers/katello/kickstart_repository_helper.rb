module Katello
  module KickstartRepositoryHelper
    def use_install_media(host, options = {})
      return true if host&.errors && host.errors.include?(:medium_id) && host.medium.present?
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
        host = selected_host_group.presence || param_host

        new_host = ::Host.new
        new_host.operatingsystem = param_host.operatingsystem.presence || host.operatingsystem
        new_host.architecture = param_host.architecture.presence || host.architecture

        return [] unless new_host.operatingsystem.is_a?(Redhat)

        if (host.is_a? ::Hostgroup)
          new_host.content_facet = hostgroup_content_facet(host, param_host)
        elsif host.content_facet.present?
          new_host.content_facet = ::Katello::Host::ContentFacet.new(:content_source_id => host.content_source_id)
          if host.single_content_view_environment?
            # assign new_host the same CVEnv as host
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
  end
end
