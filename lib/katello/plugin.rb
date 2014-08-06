Foreman::Plugin.register :katello do
  requires_foreman '>= 1.9'

  test_task 'test:katello'

  sub_menu :top_menu, :content_menu, :caption => N_('Content'), :after => :monitor_menu do
    menu :top_menu,
         :environments,
         :caption => N_('Lifecycle Environments'),
         :url => '/lifecycle_environments',
         :url_hash => {:controller => 'katello/api/v2/environments',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false
    menu :top_menu,
         :red_hat_subscriptions,
         :caption => N_('Red Hat Subscriptions'),
         :url => '/subscriptions',
         :url_hash => {:controller => 'katello/api/v2/subscriptions',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false
    # TODO
    # Refs http://projects.theforeman.org/issues/4883
    # menu :top_menu,
    #      :subscription_manager_applications,
    #      :caption => N_('Subscription Manager Applications'),
    #      :url_hash => {:controller => 'katello/distributors',
    #                    :action => 'index'},
    #      :engine => Katello::Engine
    menu :top_menu,
         :activation_keys,
         :url => '/activation_keys',
         :url_hash => {:controller => 'katello/api/v2/activation_keys',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    divider :top_menu, :parent => :content_menu
    menu :top_menu,
         :redhat_provider,
         :caption => N_('Red Hat Repositories'),
         :url_hash => {:controller => 'katello/providers',
                       :action => 'redhat_provider'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :products,
         :caption => N_('Products'),
         :url => '/products',
         :url_hash => {:controller => 'katello/api/v2/products',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :gpg_keys,
         :caption => N_('GPG keys'),
         :url => '/gpg_keys',
         :url_hash => {:controller => 'katello/api/v2/gpg_keys',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    divider :top_menu, :parent => :content_menu
    menu :top_menu,
         :sync_status,
         :caption => N_('Sync Status'),
         :url_hash => {:controller => 'katello/sync_management',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :sync_plans,
         :caption => N_('Sync Plans'),
         :url => '/sync_plans',
         :url_hash => {:controller => 'katello/api/v2/sync_plans',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    divider :top_menu, :parent => :content_menu
    menu :top_menu,
         :content_views,
         :caption => N_('Content Views'),
         :url => '/content_views',
         :url_hash => {:controller => 'katello/api/v2/content_views',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    divider :top_menu, :parent => :content_menu
    menu :top_menu,
         :errata,
         :caption => N_('Errata'),
         :url => '/errata',
         :url_hash => {:controller => 'katello/api/v2/errata',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :docker_tags,
         :caption => N_('Docker Tags'),
         :url => '/docker_tags',
         :url_hash => {:controller => 'katello/api/v2/docker_tags',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false
  end

  menu :top_menu,
       :content_hosts,
       :caption => N_('Content Hosts'),
       :url => '/content_hosts',
       :url_hash => {:controller => 'katello/api/v2/systems',
                     :action => 'index'},
       :engine => Katello::Engine,
       :parent => :hosts_menu,
       :after => :hosts,
       :turbolinks => false

  menu :top_menu,
       :host_collections,
       :caption => N_('Host Collections'),
       :url => '/host_collections',
       :url_hash => {:controller => 'katello/api/v2/host_collections',
                     :action => 'index'},
       :engine => Katello::Engine,
       :parent => :hosts_menu,
       :after => :content_hosts,
       :turbolinks => false

  menu :top_menu,
       :content_dashboard,
       :caption => N_('Content Dashboard'),
       :url_hash => {:controller => 'katello/dashboard',
                     :action => 'index'},
       :engine => Katello::Engine,
       :parent => :monitor_menu,
       :after => :dashboard,
       :turbolinks => false

  allowed_template_helpers :subscription_manager_configuration_url
  search_path_override("Katello") do |resource|
    "/#{Katello::Util::Model.model_to_controller_path(resource)}/auto_complete_search"
  end
  apipie_documented_controllers ["#{Katello::Engine.root}/app/controllers/katello/api/v2/*.rb"]
  apipie_ignored_controllers %w(::Api::V2::OrganizationsController)

  logger :glue, :enabled => true
  logger :pulp_rest, :enabled => true
  logger :cp_rest, :enabled => true
  logger :cp_proxy, :enabled => true
  logger :action, :enabled => true
  logger :tire_rest, :enabled => false
  logger :manifest_import_logger, :enabled => true

  tests_to_skip(
    # This block is skipped due to Katello disabling nested organizations
    "LocationTest" => [
      "selected_or_inherited_ids",
      "used_and_selected_or_inherited_ids"
    ],
    "OrganizationTest" => [
      "my_organizations returns user's associated orgs and children",
      "name can be the same if parent is different"
    ],
    "TaxonomixTest" => [
      ".used_organization_ids can work with array of organizations"
    ],
    "UserTest" => [
      "return organization and child ids for non-admin user"
    ],

    # This block is skipped due to Katello extending Host::Managed with dynflow hooks
    "Api::V2::HostsControllerTest" => [
      "destroy hosts",
      "allow destroy for restricted user who owns the hosts"
    ],
    "Api::V2::LocationsControllerTest" => [
      "destroy location if hosts do not use it"
    ],
    "HostsControllerTest" => [
      "should destroy host"
    ],

    "LocationsControllerTest" => [
      "should clone location with assocations"
    ],

    # This block is skipped due to Katello needing to hook into the Organization create/update/delete workflow
    "OrganizationsControllerTest" => [
      "should get edit",
      "should delete null organization",
      "should clear the session if the user deleted their current organization",
      "should clone organization with assocations"
    ],
    "MenuItemTest::MenuItem" => [
      "caption",
      "html_options"
    ],
    "AccessPermissionsTest" => [
      "route operatingsystems/available_kickstart_repo should have a permission that grants access",
      "route hosts/puppet_environment_for_content_view should have a permission that grants access",
      "route bastion/bastion/index should have a permission that grants access",
      "route bastion/bastion/index_ie should have a permission that grants access"
    ],

    # foreman_docker tests
    "Containers::StepsControllerTest" => [
      "image show doesnot load katello"
    ]
  )
end
