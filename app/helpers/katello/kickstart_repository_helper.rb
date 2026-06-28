module Katello
  module KickstartRepositoryHelper
    def use_install_media(host, options = {})
      return true if host&.errors && host.errors.include?(:medium_id) && host.medium.present?
      if host.is_a?(::Hostgroup) && host.parent_id.present? && host.medium_id.blank? && host.kickstart_repository.present?
        return false
      end
      kickstart_repository_id(host, options).blank?
    end

    def host_hostgroup_kickstart_repository_id(host)
      return if host.blank?
      host.content_facet&.kickstart_repository_id
    end

    def kickstart_repository_id(host, options = {})
      host_ks_repo_id = host_hostgroup_kickstart_repository_id(host)
      selected_host_group = options.fetch(:selected_host_group, nil)

      # if the kickstart repo id is set in the host use that
      return host_ks_repo_id if host_ks_repo_id.present?

      # Child hostgroups should remain on true inheritance unless explicitly overridden.
      if host.is_a?(::Hostgroup) && host.parent_id.present?
        return nil
      end

      ks_repo_options = kickstart_repository_options(host, options)
      # if the kickstart repo id is set in the selected_hostgroup use that
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
        elsif host.content_facet.present? && host.content_facet.content_view_environments.any?
          new_host.content_facet = ::Katello::Host::ContentFacet.new(:content_source_id => host.content_source_id)
          if host.single_content_view_environment?
            cvenv = ::Katello::ContentViewEnvironment.find_by_cv_and_lce!(
              host.content_facet.single_content_view.id,
              host.content_facet.single_lifecycle_environment.id
            )
            new_host.content_facet.content_view_environments = [cvenv]
          end
        else
          return os_updated_kickstart_options(new_host)
        end
        new_host.operatingsystem.kickstart_repos(new_host).map { |repo| OpenStruct.new(repo) }
      else
        # case 2
        os_updated_kickstart_options
      end
    end

    def os_updated_kickstart_options(host = nil)
      os_selection_params = ["operatingsystem_id", 'content_view_environment_id',
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
        content_source = fetch_inherited_param(host_params[:content_source_id], ::SmartProxy, parent&.content_source)

        cvenv_id = host_params[:content_view_environment_id]
        cvenv = cvenv_id.present? ? ::Katello::ContentViewEnvironment.find_by(id: cvenv_id) : parent&.content_view_environment

        host.content_facet = Host::ContentFacet.new(:content_source => content_source)
        host.content_facet.content_view_environments = [cvenv] if cvenv
        if host.operatingsystem.is_a?(Redhat)
          view_options = host.operatingsystem.kickstart_repos(host).map { |repo| OpenStruct.new(repo) }
        end
      end
      view_options
    end
  end
end
