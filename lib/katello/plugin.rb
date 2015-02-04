Foreman::Plugin.register :katello do
  requires_foreman '> 1.3'

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

    menu :top_menu,
         :content_search,
         :caption => N_('Content Search'),
         :url_hash => {:controller => 'katello/content_search',
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

  menu :admin_menu,
       :notices,
       :caption => N_('Content Notices'),
       :url_hash => {:controller => 'katello/notices',
                     :action => 'show'},
       :engine => Katello::Engine,
       :parent => :administer_menu,
       :after => :organizations,
       :turbolinks => false

  allowed_template_helpers :subscription_manager_configuration_url

  search_path_override("Katello") do |resource|
    "/#{Katello::Util::Model.model_to_controller_path(resource)}/auto_complete_search"
  end
end
