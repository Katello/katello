module Katello
  module Concerns
    module Api::V2::HostgroupsControllerExtensions
      extend ActiveSupport::Concern

      included do
        def_param_group :hostgroup do
          param :hostgroup, Hash, :required => true, :action_aware => true do
            param :name, String, :required => true, :desc => N_('Name of the host group')
            param :parent_id, :number, :desc => N_('Parent ID of the host group')
            param :environment_id, :number, :desc => N_('Environment ID')
            param :compute_profile_id, :number, :desc => N_('Compute profile ID')
            param :operatingsystem_id, :number, :desc => N_('Operating system ID')
            param :architecture_id, :number, :desc => N_('Architecture ID')
            param :pxe_loader, Operatingsystem.all_loaders, :desc => N_("DHCP filename option (Grub2/PXELinux by default)")
            param :medium_id, :number, :desc => N_('Media ID')
            param :ptable_id, :number, :desc => N_('Partition table ID')
            param :puppet_ca_proxy_id, :number, :desc => N_('Puppet CA proxy ID')
            param :subnet_id, :number, :desc => N_('Subnet ID')
            param :domain_id, :number, :desc => N_('Domain ID')
            param :realm_id, :number, :desc => N_('Realm ID')
            param :puppet_proxy_id, :number, :desc => N_('Puppet proxy ID')
            param :root_pass, String, :desc => N_('Root password on provisioned hosts')
            param :content_source_id, :number, :desc => N_('Content source ID')
            param :content_view_id, :number, :desc => N_('Content view ID')
            param :lifecycle_environment_id, :number, :desc => N_('Lifecycle environment ID')
            param_group :taxonomies, ::Api::V2::BaseController
          end
        end

        api :POST, "/hostgroups/", N_("Create a host group")
        param_group :hostgroup, :as => :create
        def create
          @hostgroup = Hostgroup.new(hostgroup_params)
          process_response @hostgroup.save
        end

        api :PUT, "/hostgroups/:id/", N_("Update a host group")
        param :id, :identifier, :required => true
        param_group :hostgroup
        def update
          process_response @hostgroup.update_attributes(params[:hostgroup])
        end

        api :GET, "/hostgroups/:id", N_("Show a host group")
        param :id, :identifier, :required => true
        def show
          @render_template = 'katello/api/v2/hostgroups_extensions/show'
          render @render_template
        end
      end
    end
  end
end
