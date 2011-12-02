(function(){

  var Utils = {

    serialize: function(obj){
      if (obj === null) {return '';}
      var s = [];
      for (prop in obj){
        s.push(prop + "=" + obj[prop]);
      }
      if (s.length === 0) {
        return '';
      }
      return "?" + s.join('&');
    },

    clean_path: function(path) {
      return path.replace(/\/+/g, "/").replace(/[\)\(]/g, "").replace(/\.$/m, '').replace(/\/$/m, '');
    },

    extract_format: function(options) {
      var format =  options.hasOwnProperty("format") ? options.format : window.KT.routes.options.default_format;
      delete options.format;
      return format ? "." + format : "";
    },

    extract_options: function(number_of_params, args) {
      if (args.length >= number_of_params) {
        return typeof(args[args.length-1]) == "object" ?  args.pop() : {};
      } else {
        return {};
      }
    },

    path_identifier: function(object) {
      if (!object) {
        return "";
      }
      if (typeof(object) == "object") {
        return (object.to_param || object.id).toString();
      } else {
        return object.toString();
      }
    },

    build_path: function(number_of_params, parts, args) {
      args = Array.prototype.slice.call(args);
      result = Utils.get_prefix();
      var opts = Utils.extract_options(number_of_params, args);
      for (var i=0; i < parts.length; i++) {
        value = args.shift();
        part = parts[i];
        if (Utils.specified(value)) {
          result += part;
          result += Utils.path_identifier(value);
        } else if (!Utils.optional_part(part)) {
          //TODO: make it strict
          //throw new Error("Can not build path: required parameter is null or undefined.");
          result += part;
        }
      }
      var format = Utils.extract_format(opts);
      return Utils.clean_path(result + format) + Utils.serialize(opts);
    },

    specified: function(value) {
      return !(value === undefined || value === null);
    },

    optional_part: function(part) {
      return part.match(/\(/);
    },

    get_prefix: function(){
      var prefix = window.KT.routes.options.prefix;

      if( prefix !== "" ){
        prefix = prefix.match('\/$') ? prefix : ( prefix + '/');
      }
      
      return prefix;
    }

  };

  window.KT.routes = {
// edit_api_activation_key => /api/activation_keys/:id/edit(.:format)
  edit_api_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/api/activation_keys/", "/edit"], arguments)
  },
// enable_api_repository => /api/repositories/:id/enable(.:format)
  enable_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/enable"], arguments)
  },
// new_api_template_parameter => /api/templates/:template_id/parameters/new(.:format)
  new_api_template_parameter_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/parameters/new"], arguments)
  },
// notices_details => /notices/:id/details(.:format)
  notices_details_path: function(_id, options) {
  return Utils.build_path(2, ["/notices/", "/details"], arguments)
  },
// role => /roles/:id(.:format)
  role_path: function(_id, options) {
  return Utils.build_path(2, ["/roles/"], arguments)
  },
// edit_user_session => /user_session/edit(.:format)
  edit_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/edit"], arguments)
  },
// auto_complete_search_organizations => /organizations/auto_complete_search(.:format)
  auto_complete_search_organizations_path: function(options) {
  return Utils.build_path(1, ["/organizations/auto_complete_search"], arguments)
  },
// gpg_keys => /gpg_keys(.:format)
  gpg_keys_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys"], arguments)
  },
// products => /products(.:format)
  products_path: function(options) {
  return Utils.build_path(1, ["/products"], arguments)
  },
// report_api_users => /api/users/report(.:format)
  report_api_users_path: function(options) {
  return Utils.build_path(1, ["/api/users/report"], arguments)
  },
// api_environment_products => /api/environments/:environment_id/products(.:format)
  api_environment_products_path: function(_environment_id, options) {
  return Utils.build_path(2, ["/api/environments/", "/products"], arguments)
  },
// api_template_package_group_categories => /api/templates/:template_id/package_group_categories(.:format)
  api_template_package_group_categories_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/package_group_categories"], arguments)
  },
// history_search_index => /search/history(.:format)
  history_search_index_path: function(options) {
  return Utils.build_path(1, ["/search/history"], arguments)
  },
// dependencies_changeset => /changesets/:id/dependencies(.:format)
  dependencies_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/dependencies"], arguments)
  },
// rails_info_properties => /rails/info/properties(.:format)
  rails_info_properties_path: function(options) {
  return Utils.build_path(1, ["/rails/info/properties"], arguments)
  },
// new_api_template_distribution => /api/templates/:template_id/distributions/new(.:format)
  new_api_template_distribution_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/distributions/new"], arguments)
  },
// new_sync_plan => /sync_plans/new(.:format)
  new_sync_plan_path: function(options) {
  return Utils.build_path(1, ["/sync_plans/new"], arguments)
  },
// items_changesets => /changesets/items(.:format)
  items_changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets/items"], arguments)
  },
// roles => /roles(.:format)
  roles_path: function(options) {
  return Utils.build_path(1, ["/roles"], arguments)
  },
// edit_system_template => /system_templates/:id/edit(.:format)
  edit_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/edit"], arguments)
  },
// discovery_api_organization_repositories => /api/organizations/:organization_id/repositories/discovery(.:format)
  discovery_api_organization_repositories_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/repositories/discovery"], arguments)
  },
// repositories_api_organization_product => /api/organizations/:organization_id/products/:id/repositories(.:format)
  repositories_api_organization_product_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/products/", "/repositories"], arguments)
  },
// errata_dashboard_index => /dashboard/errata(.:format)
  errata_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/errata"], arguments)
  },
// package => /packages/:id(.:format)
  package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/"], arguments)
  },
// subscriptions_activation_keys => /activation_keys/subscriptions(.:format)
  subscriptions_activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/subscriptions"], arguments)
  },
// edit_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/edit(.:format)
  edit_provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/providers/", "/products/", "/repositories/", "/edit"], arguments)
  },
// edit_api_organization => /api/organizations/:id/edit(.:format)
  edit_api_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/edit"], arguments)
  },
// role_permission_update => /roles/:role_id/permission/:permission_id/update_permission(.:format)
  role_permission_update_path: function(_role_id, _permission_id, options) {
  return Utils.build_path(3, ["/roles/", "/permission/", "/update_permission"], arguments)
  },
// organization_providers => /organizations/:organization_id/providers(.:format)
  organization_providers_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/organizations/", "/providers"], arguments)
  },
// items_providers => /providers/items(.:format)
  items_providers_path: function(options) {
  return Utils.build_path(1, ["/providers/items"], arguments)
  },
// remove_system_system_packages => /systems/:system_id/system_packages/remove(.:format)
  remove_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/remove"], arguments)
  },
// repos_promotion => /promotions/:id/repos(.:format)
  repos_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/repos"], arguments)
  },
// organizations => /organizations(.:format)
  organizations_path: function(options) {
  return Utils.build_path(1, ["/organizations"], arguments)
  },
// clear_helptips_user => /users/:id/clear_helptips(.:format)
  clear_helptips_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/clear_helptips"], arguments)
  },
// api_consumer => /api/consumers/:id(.:format)
  api_consumer_path: function(_id, options) {
  return Utils.build_path(2, ["/api/consumers/"], arguments)
  },
// api_product_filters => /api/products/:product_id/filters(.:format)
  api_product_filters_path: function(_product_id, options) {
  return Utils.build_path(2, ["/api/products/", "/filters"], arguments)
  },
// filelist_package => /packages/:id/filelist(.:format)
  filelist_package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/", "/filelist"], arguments)
  },
// sync_plans => /sync_plans(.:format)
  sync_plans_path: function(options) {
  return Utils.build_path(1, ["/sync_plans"], arguments)
  },
// update_subscriptions_system => /systems/:id/update_subscriptions(.:format)
  update_subscriptions_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/update_subscriptions"], arguments)
  },
// auto_complete_search_sync_plans => /sync_plans/auto_complete_search(.:format)
  auto_complete_search_sync_plans_path: function(options) {
  return Utils.build_path(1, ["/sync_plans/auto_complete_search"], arguments)
  },
// providers => /providers(.:format)
  providers_path: function(options) {
  return Utils.build_path(1, ["/providers"], arguments)
  },
// update_content_system_template => /system_templates/:id/update_content(.:format)
  update_content_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/update_content"], arguments)
  },
// env_items_systems => /systems/env_items(.:format)
  env_items_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/env_items"], arguments)
  },
// products_repos_gpg_key => /gpg_keys/:id/products_repos(.:format)
  products_repos_gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/gpg_keys/", "/products_repos"], arguments)
  },
// activation_keys => /activation_keys(.:format)
  activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys"], arguments)
  },
// sync_schedules_index => /sync_schedules/index(.:format)
  sync_schedules_index_path: function(options) {
  return Utils.build_path(1, ["/sync_schedules/index"], arguments)
  },
// api_system_subscription => /api/systems/:system_id/subscriptions/:id(.:format)
  api_system_subscription_path: function(_system_id, _id, options) {
  return Utils.build_path(3, ["/api/systems/", "/subscriptions/"], arguments)
  },
// api_organization_environment_changesets => /api/organizations/:organization_id/environments/:environment_id/changesets(.:format)
  api_organization_environment_changesets_path: function(_organization_id, _environment_id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/environments/", "/changesets"], arguments)
  },
// product_create_api_provider => /api/providers/:id/product_create(.:format)
  product_create_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/product_create"], arguments)
  },
// packages_filter => /filters/:id/packages(.:format)
  packages_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/packages"], arguments)
  },
// erratum => /errata/:id(.:format)
  erratum_path: function(_id, options) {
  return Utils.build_path(2, ["/errata/"], arguments)
  },
// sync_management_product_status => /sync_management/product_status(.:format)
  sync_management_product_status_path: function(options) {
  return Utils.build_path(1, ["/sync_management/product_status"], arguments)
  },
// api_organization_providers => /api/organizations/:organization_id/providers(.:format)
  api_organization_providers_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/providers"], arguments)
  },
// import_api_templates => /api/templates/import(.:format)
  import_api_templates_path: function(options) {
  return Utils.build_path(1, ["/api/templates/import"], arguments)
  },
// auto_complete_search_providers => /providers/auto_complete_search(.:format)
  auto_complete_search_providers_path: function(options) {
  return Utils.build_path(1, ["/providers/auto_complete_search"], arguments)
  },
// edit_api_template_product => /api/templates/:template_id/products/:id/edit(.:format)
  edit_api_template_product_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/products/", "/edit"], arguments)
  },
// promotion_details_system_template => /system_templates/:id/promotion_details(.:format)
  promotion_details_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/promotion_details"], arguments)
  },
// new_api_activation_key => /api/activation_keys/new(.:format)
  new_api_activation_key_path: function(options) {
  return Utils.build_path(1, ["/api/activation_keys/new"], arguments)
  },
// package_group_categories_api_repository => /api/repositories/:id/package_group_categories(.:format)
  package_group_categories_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/package_group_categories"], arguments)
  },
// api_template_parameter => /api/templates/:template_id/parameters/:id(.:format)
  api_template_parameter_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/parameters/"], arguments)
  },
// password_resets => /password_resets(.:format)
  password_resets_path: function(options) {
  return Utils.build_path(1, ["/password_resets"], arguments)
  },
// api_distribution => /api/distributions/:id(.:format)
  api_distribution_path: function(_id, options) {
  return Utils.build_path(2, ["/api/distributions/"], arguments)
  },
// repositories_api_environment_product => /api/environments/:environment_id/products/:id/repositories(.:format)
  repositories_api_environment_product_path: function(_environment_id, _id, options) {
  return Utils.build_path(3, ["/api/environments/", "/products/", "/repositories"], arguments)
  },
// edit_api_template_package_group => /api/templates/:template_id/package_groups/:id/edit(.:format)
  edit_api_template_package_group_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/package_groups/", "/edit"], arguments)
  },
// users => /users(.:format)
  users_path: function(options) {
  return Utils.build_path(1, ["/users"], arguments)
  },
// search_index => /search(.:format)
  search_index_path: function(options) {
  return Utils.build_path(1, ["/search"], arguments)
  },
// name_changeset => /changesets/:id/name(.:format)
  name_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/name"], arguments)
  },
// system_templates_organization_environment => /organizations/:organization_id/environments/:id/system_templates(.:format)
  system_templates_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/", "/system_templates"], arguments)
  },
// api_task => /api/tasks/:id(.:format)
  api_task_path: function(_id, options) {
  return Utils.build_path(2, ["/api/tasks/"], arguments)
  },
// api_template_distribution => /api/templates/:template_id/distributions/:id(.:format)
  api_template_distribution_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/distributions/"], arguments)
  },
// new_system_template => /system_templates/new(.:format)
  new_system_template_path: function(options) {
  return Utils.build_path(1, ["/system_templates/new"], arguments)
  },
// notices_get_new => /notices/get_new(.:format)
  notices_get_new_path: function(options) {
  return Utils.build_path(1, ["/notices/get_new"], arguments)
  },
// list_changesets => /changesets/list(.:format)
  list_changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets/list"], arguments)
  },
// api_organization_activation_keys => /api/organizations/:organization_id/activation_keys(.:format)
  api_organization_activation_keys_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/activation_keys"], arguments)
  },
// api_template => /api/templates/:id(.:format)
  api_template_path: function(_id, options) {
  return Utils.build_path(2, ["/api/templates/"], arguments)
  },
// user_session_logout => /user_session/logout(.:format)
  user_session_logout_path: function(options) {
  return Utils.build_path(1, ["/user_session/logout"], arguments)
  },
// items_activation_keys => /activation_keys/items(.:format)
  items_activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/items"], arguments)
  },
// new_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/new(.:format)
  new_provider_product_repository_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/repositories/new"], arguments)
  },
// notices_dashboard_index => /dashboard/notices(.:format)
  notices_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/notices"], arguments)
  },
// product => /products/:id(.:format)
  product_path: function(_id, options) {
  return Utils.build_path(2, ["/products/"], arguments)
  },
// organization => /organizations/:id(.:format)
  organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/"], arguments)
  },
// api_status_memory => /api/status/memory(.:format)
  api_status_memory_path: function(options) {
  return Utils.build_path(1, ["/api/status/memory"], arguments)
  },
// new_api_organization => /api/organizations/new(.:format)
  new_api_organization_path: function(options) {
  return Utils.build_path(1, ["/api/organizations/new"], arguments)
  },
// add_system_system_packages => /systems/:system_id/system_packages/add(.:format)
  add_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/add"], arguments)
  },
// set_org_user_session => /user_session/set_org(.:format)
  set_org_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/set_org"], arguments)
  },
// disable_helptip_users => /users/disable_helptip(.:format)
  disable_helptip_users_path: function(options) {
  return Utils.build_path(1, ["/users/disable_helptip"], arguments)
  },
// organization_environment => /organizations/:organization_id/environments/:id(.:format)
  organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/"], arguments)
  },
// provider_product => /providers/:provider_id/products/:id(.:format)
  provider_product_path: function(_provider_id, _id, options) {
  return Utils.build_path(3, ["/providers/", "/products/"], arguments)
  },
// edit_api_consumer => /api/consumers/:id/edit(.:format)
  edit_api_consumer_path: function(_id, options) {
  return Utils.build_path(2, ["/api/consumers/", "/edit"], arguments)
  },
// api_product_sync_index => /api/products/:product_id/sync(.:format)
  api_product_sync_index_path: function(_product_id, options) {
  return Utils.build_path(2, ["/api/products/", "/sync"], arguments)
  },
// changelog_package => /packages/:id/changelog(.:format)
  changelog_package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/", "/changelog"], arguments)
  },
// subscriptions => /subscriptions(.:format)
  subscriptions_path: function(options) {
  return Utils.build_path(1, ["/subscriptions"], arguments)
  },
// subscriptions_system => /systems/:id/subscriptions(.:format)
  subscriptions_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/subscriptions"], arguments)
  },
// items_systems => /systems/items(.:format)
  items_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/items"], arguments)
  },
// environments => /environments(.:format)
  environments_path: function(options) {
  return Utils.build_path(1, ["/environments"], arguments)
  },
// logout => /logout(.:format)
  logout_path: function(options) {
  return Utils.build_path(1, ["/logout"], arguments)
  },
// edit_account => /account/edit(.:format)
  edit_account_path: function(options) {
  return Utils.build_path(1, ["/account/edit"], arguments)
  },
// packages_promotion => /promotions/:id/packages(.:format)
  packages_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/packages"], arguments)
  },
// system_templates => /system_templates(.:format)
  system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates"], arguments)
  },
// download_system_template => /system_templates/:id/download(.:format)
  download_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/download"], arguments)
  },
// api_system_subscriptions => /api/systems/:system_id/subscriptions(.:format)
  api_system_subscriptions_path: function(_system_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/subscriptions"], arguments)
  },
// items_gpg_keys => /gpg_keys/items(.:format)
  items_gpg_keys_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys/items"], arguments)
  },
// import_manifest_api_provider => /api/providers/:id/import_manifest(.:format)
  import_manifest_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/import_manifest"], arguments)
  },
// packages_erratum => /errata/:id/packages(.:format)
  packages_erratum_path: function(_id, options) {
  return Utils.build_path(2, ["/errata/", "/packages"], arguments)
  },
// items_filters => /filters/items(.:format)
  items_filters_path: function(options) {
  return Utils.build_path(1, ["/filters/items"], arguments)
  },
// api_organization_tasks => /api/organizations/:organization_id/tasks(.:format)
  api_organization_tasks_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/tasks"], arguments)
  },
// api_provider => /api/providers/:id(.:format)
  api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/"], arguments)
  },
// owner => /owners/:id(.:format)
  owner_path: function(_id, options) {
  return Utils.build_path(2, ["/owners/"], arguments)
  },
// new_api_template_product => /api/templates/:template_id/products/new(.:format)
  new_api_template_product_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/products/new"], arguments)
  },
// sync_management_sync => /sync_management/sync(.:format)
  sync_management_sync_path: function(options) {
  return Utils.build_path(1, ["/sync_management/sync"], arguments)
  },
// system => /systems/:id(.:format)
  system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/"], arguments)
  },
// edit_gpg_key => /gpg_keys/:id/edit(.:format)
  edit_gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/gpg_keys/", "/edit"], arguments)
  },
// environment => /environments/:id(.:format)
  environment_path: function(_id, options) {
  return Utils.build_path(2, ["/environments/"], arguments)
  },
// api_activation_keys => /api/activation_keys(.:format)
  api_activation_keys_path: function(options) {
  return Utils.build_path(1, ["/api/activation_keys"], arguments)
  },
// package_groups_api_repository => /api/repositories/:id/package_groups(.:format)
  package_groups_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/package_groups"], arguments)
  },
// api_template_parameters => /api/templates/:template_id/parameters(.:format)
  api_template_parameters_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/parameters"], arguments)
  },
// distributions_promotion => /promotions/:id/distributions(.:format)
  distributions_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/distributions"], arguments)
  },
// changesets => /changesets(.:format)
  changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets"], arguments)
  },
// api_erratum => /api/errata/:id(.:format)
  api_erratum_path: function(_id, options) {
  return Utils.build_path(2, ["/api/errata/"], arguments)
  },
// api_environment_systems => /api/environments/:environment_id/systems(.:format)
  api_environment_systems_path: function(_environment_id, options) {
  return Utils.build_path(2, ["/api/environments/", "/systems"], arguments)
  },
// new_api_template_package_group => /api/templates/:template_id/package_groups/new(.:format)
  new_api_template_package_group_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/package_groups/new"], arguments)
  },
// verbs_and_scopes => /roles/:organization_id/resource_type/verbs_and_scopes(.:format)
  verbs_and_scopes_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/roles/", "/resource_type/verbs_and_scopes"], arguments)
  },
// download_debug_certificate_organization => /organizations/:id/download_debug_certificate(.:format)
  download_debug_certificate_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/download_debug_certificate"], arguments)
  },
// api_user => /api/users/:id(.:format)
  api_user_path: function(_id, options) {
  return Utils.build_path(2, ["/api/users/"], arguments)
  },
// pools_api_activation_key => /api/activation_keys/:id/pools(.:format)
  pools_api_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/api/activation_keys/", "/pools"], arguments)
  },
// api_template_distributions => /api/templates/:template_id/distributions(.:format)
  api_template_distributions_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/distributions"], arguments)
  },
// auto_complete_search_changesets => /changesets/auto_complete_search(.:format)
  auto_complete_search_changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets/auto_complete_search"], arguments)
  },
// edit_api_template => /api/templates/:id/edit(.:format)
  edit_api_template_path: function(_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/edit"], arguments)
  },
// provider_product_repositories => /providers/:provider_id/products/:product_id/repositories(.:format)
  provider_product_repositories_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/repositories"], arguments)
  },
// sync_dashboard_index => /dashboard/sync(.:format)
  sync_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/sync"], arguments)
  },
// jammit => /assets/:package.:extension(.:format)
  jammit_path: function(_package, _extension, options) {
  return Utils.build_path(3, ["/assets/", "."], arguments)
  },
// api_organizations => /api/organizations(.:format)
  api_organizations_path: function(options) {
  return Utils.build_path(1, ["/api/organizations"], arguments)
  },
// enable_helptip_users => /users/enable_helptip(.:format)
  enable_helptip_users_path: function(options) {
  return Utils.build_path(1, ["/users/enable_helptip"], arguments)
  },
// add_subscriptions_activation_key => /activation_keys/:id/add_subscriptions(.:format)
  add_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/add_subscriptions"], arguments)
  },
// edit_organization_environment => /organizations/:organization_id/environments/:id/edit(.:format)
  edit_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/", "/edit"], arguments)
  },
// edit_provider_product => /providers/:provider_id/products/:id/edit(.:format)
  edit_provider_product_path: function(_provider_id, _id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/edit"], arguments)
  },
// dashboard_index => /dashboard(.:format)
  dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard"], arguments)
  },
// new_api_consumer => /api/consumers/new(.:format)
  new_api_consumer_path: function(options) {
  return Utils.build_path(1, ["/api/consumers/new"], arguments)
  },
// repositories_api_product => /api/products/:id/repositories(.:format)
  repositories_api_product_path: function(_id, options) {
  return Utils.build_path(2, ["/api/products/", "/repositories"], arguments)
  },
// user => /users/:id(.:format)
  user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/"], arguments)
  },
// edit_system => /systems/:id/edit(.:format)
  edit_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/edit"], arguments)
  },
// edit_changeset => /changesets/:id/edit(.:format)
  edit_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/edit"], arguments)
  },
// favorite_search_index => /search/favorite(.:format)
  favorite_search_index_path: function(options) {
  return Utils.build_path(1, ["/search/favorite"], arguments)
  },
// new_account => /account/new(.:format)
  new_account_path: function(options) {
  return Utils.build_path(1, ["/account/new"], arguments)
  },
// auto_complete_search_activation_keys => /activation_keys/auto_complete_search(.:format)
  auto_complete_search_activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/auto_complete_search"], arguments)
  },
// auto_complete_search_systems => /systems/auto_complete_search(.:format)
  auto_complete_search_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/auto_complete_search"], arguments)
  },
// pools_api_system => /api/systems/:id/pools(.:format)
  pools_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/pools"], arguments)
  },
// auto_complete_search_gpg_keys => /gpg_keys/auto_complete_search(.:format)
  auto_complete_search_gpg_keys_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys/auto_complete_search"], arguments)
  },
// account => /account(.:format)
  account_path: function(options) {
  return Utils.build_path(1, ["/account"], arguments)
  },
// api => /api(.:format)
  api_path: function(options) {
  return Utils.build_path(1, ["/api"], arguments)
  },
// promotions => /promotions(.:format)
  promotions_path: function(options) {
  return Utils.build_path(1, ["/promotions"], arguments)
  },
// import_products_api_provider => /api/providers/:id/import_products(.:format)
  import_products_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/import_products"], arguments)
  },
// owners => /owners(.:format)
  owners_path: function(options) {
  return Utils.build_path(1, ["/owners"], arguments)
  },
// products_organization_environment => /organizations/:organization_id/environments/:id/products(.:format)
  products_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/", "/products"], arguments)
  },
// auto_complete_products_repos_filters => /filters/auto_complete_products_repos(.:format)
  auto_complete_products_repos_filters_path: function(options) {
  return Utils.build_path(1, ["/filters/auto_complete_products_repos"], arguments)
  },
// api_organization_environment => /api/organizations/:organization_id/environments/:id(.:format)
  api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/environments/"], arguments)
  },
// edit_api_provider => /api/providers/:id/edit(.:format)
  edit_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/edit"], arguments)
  },
// update_products_filter => /filters/:id/update_products(.:format)
  update_products_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/update_products"], arguments)
  },
// root => /(.:format)
  root_path: function(options) {
  return Utils.build_path(1, ["/"], arguments)
  },
// api_template_product => /api/templates/:template_id/products/:id(.:format)
  api_template_product_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/products/"], arguments)
  },
// new_gpg_key => /gpg_keys/new(.:format)
  new_gpg_key_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys/new"], arguments)
  },
// login => /login(.:format)
  login_path: function(options) {
  return Utils.build_path(1, ["/login"], arguments)
  },
// api_repository_distributions => /api/repositories/:repository_id/distributions(.:format)
  api_repository_distributions_path: function(_repository_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/distributions"], arguments)
  },
// edit_api_template_package => /api/templates/:template_id/packages/:id/edit(.:format)
  edit_api_template_package_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/packages/", "/edit"], arguments)
  },
// enable_repo => /repositories/:id/enable_repo(.:format)
  enable_repo_path: function(_id, options) {
  return Utils.build_path(2, ["/repositories/", "/enable_repo"], arguments)
  },
// api_errata => /api/errata(.:format)
  api_errata_path: function(options) {
  return Utils.build_path(1, ["/api/errata"], arguments)
  },
// report_api_environment_systems => /api/environments/:environment_id/systems/report(.:format)
  report_api_environment_systems_path: function(_environment_id, options) {
  return Utils.build_path(2, ["/api/environments/", "/systems/report"], arguments)
  },
// api_template_package_group => /api/templates/:template_id/package_groups/:id(.:format)
  api_template_package_group_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/package_groups/"], arguments)
  },
// edit_provider => /providers/:id/edit(.:format)
  edit_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/edit"], arguments)
  },
// sync_schedules_apply => /sync_schedules/apply(.:format)
  sync_schedules_apply_path: function(options) {
  return Utils.build_path(1, ["/sync_schedules/apply"], arguments)
  },
// events_organization => /organizations/:id/events(.:format)
  events_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/events"], arguments)
  },
// edit_user => /users/:id/edit(.:format)
  edit_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/edit"], arguments)
  },
// edit_organization => /organizations/:id/edit(.:format)
  edit_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/edit"], arguments)
  },
// edit_api_user => /api/users/:id/edit(.:format)
  edit_api_user_path: function(_id, options) {
  return Utils.build_path(2, ["/api/users/", "/edit"], arguments)
  },
// api_environment => /api/environments/:id(.:format)
  api_environment_path: function(_id, options) {
  return Utils.build_path(2, ["/api/environments/"], arguments)
  },
// edit_api_template_package_group_category => /api/templates/:template_id/package_group_categories/:id/edit(.:format)
  edit_api_template_package_group_category_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/package_group_categories/", "/edit"], arguments)
  },
// promotion_progress_changeset => /changesets/:id/promotion_progress(.:format)
  promotion_progress_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/promotion_progress"], arguments)
  },
// errata_promotion => /promotions/:id/errata(.:format)
  errata_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/errata"], arguments)
  },
// new_api_template => /api/templates/new(.:format)
  new_api_template_path: function(options) {
  return Utils.build_path(1, ["/api/templates/new"], arguments)
  },
// update_repo_gpg_key_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/update_gpg_key(.:format)
  update_repo_gpg_key_provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/providers/", "/products/", "/repositories/", "/update_gpg_key"], arguments)
  },
// api_organization_filter => /api/organizations/:organization_id/filters/:id(.:format)
  api_organization_filter_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/filters/"], arguments)
  },
// items_users => /users/items(.:format)
  items_users_path: function(options) {
  return Utils.build_path(1, ["/users/items"], arguments)
  },
// remove_subscriptions_activation_key => /activation_keys/:id/remove_subscriptions(.:format)
  remove_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/remove_subscriptions"], arguments)
  },
// new_organization_environment => /organizations/:organization_id/environments/new(.:format)
  new_organization_environment_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments/new"], arguments)
  },
// new_provider_product => /providers/:provider_id/products/new(.:format)
  new_provider_product_path: function(_provider_id, options) {
  return Utils.build_path(2, ["/providers/", "/products/new"], arguments)
  },
// subscriptions_dashboard_index => /dashboard/subscriptions(.:format)
  subscriptions_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/subscriptions"], arguments)
  },
// api_consumers => /api/consumers(.:format)
  api_consumers_path: function(options) {
  return Utils.build_path(1, ["/api/consumers"], arguments)
  },
// promote_api_changeset => /api/changesets/:id/promote(.:format)
  promote_api_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/promote"], arguments)
  },
// more_packages_system_system_packages => /systems/:system_id/system_packages/more_packages(.:format)
  more_packages_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/more_packages"], arguments)
  },
// new_changeset => /changesets/new(.:format)
  new_changeset_path: function(options) {
  return Utils.build_path(1, ["/changesets/new"], arguments)
  },
// update_environment_user => /users/:id/update_environment(.:format)
  update_environment_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/update_environment"], arguments)
  },
// organization_provider => /organizations/:organization_id/providers/:id(.:format)
  organization_provider_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/providers/"], arguments)
  },
// schedule_provider => /providers/:id/schedule(.:format)
  schedule_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/schedule"], arguments)
  },
// api_ping_index => /api/ping(.:format)
  api_ping_index_path: function(options) {
  return Utils.build_path(1, ["/api/ping"], arguments)
  },
// facts_system => /systems/:id/facts(.:format)
  facts_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/facts"], arguments)
  },
// api_status => /api/status(.:format)
  api_status_path: function(options) {
  return Utils.build_path(1, ["/api/status"], arguments)
  },
// errata_api_system => /api/systems/:id/errata(.:format)
  errata_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/errata"], arguments)
  },
// notices_auto_complete_search => /notices/auto_complete_search(.:format)
  notices_auto_complete_search_path: function(options) {
  return Utils.build_path(1, ["/notices/auto_complete_search"], arguments)
  },
// edit_activation_key => /activation_keys/:id/edit(.:format)
  edit_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/edit"], arguments)
  },
// new_filter => /filters/new(.:format)
  new_filter_path: function(options) {
  return Utils.build_path(1, ["/filters/new"], arguments)
  },
// details_promotion => /promotions/:id/details(.:format)
  details_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/details"], arguments)
  },
// user_session => /user_session(.:format)
  user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session"], arguments)
  },
// api_provider_sync_index => /api/providers/:provider_id/sync(.:format)
  api_provider_sync_index_path: function(_provider_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/sync"], arguments)
  },
// edit_owner => /owners/:id/edit(.:format)
  edit_owner_path: function(_id, options) {
  return Utils.build_path(2, ["/owners/", "/edit"], arguments)
  },
// show_user_session => /user_session(.:format)
  show_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session"], arguments)
  },
// auto_complete_search_filters => /filters/auto_complete_search(.:format)
  auto_complete_search_filters_path: function(options) {
  return Utils.build_path(1, ["/filters/auto_complete_search"], arguments)
  },
// product_packages_system_templates => /system_templates/product_packages(.:format)
  product_packages_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/product_packages"], arguments)
  },
// edit_api_organization_environment => /api/organizations/:organization_id/environments/:id/edit(.:format)
  edit_api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/environments/", "/edit"], arguments)
  },
// new_api_provider => /api/providers/new(.:format)
  new_api_provider_path: function(options) {
  return Utils.build_path(1, ["/api/providers/new"], arguments)
  },
// allowed_orgs_user_session => /user_session/allowed_orgs(.:format)
  allowed_orgs_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/allowed_orgs"], arguments)
  },
// systems => /systems(.:format)
  systems_path: function(options) {
  return Utils.build_path(1, ["/systems"], arguments)
  },
// products_filter => /filters/:id/products(.:format)
  products_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/products"], arguments)
  },
// api_template_products => /api/templates/:template_id/products(.:format)
  api_template_products_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/products"], arguments)
  },
// sync_management => /sync_management/:id(.:format)
  sync_management_path: function(_id, options) {
  return Utils.build_path(2, ["/sync_management/"], arguments)
  },
// api_repository_errata => /api/repositories/:repository_id/errata(.:format)
  api_repository_errata_path: function(_repository_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/errata"], arguments)
  },
// new_api_template_package => /api/templates/:template_id/packages/new(.:format)
  new_api_template_package_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/packages/new"], arguments)
  },
// password_reset => /password_resets/:id(.:format)
  password_reset_path: function(_id, options) {
  return Utils.build_path(2, ["/password_resets/"], arguments)
  },
// role_permission_destroy => /roles/:role_id/permission/:permission_id/destroy_permission(.:format)
  role_permission_destroy_path: function(_role_id, _permission_id, options) {
  return Utils.build_path(3, ["/roles/", "/permission/", "/destroy_permission"], arguments)
  },
// api_package => /api/packages/:id(.:format)
  api_package_path: function(_id, options) {
  return Utils.build_path(2, ["/api/packages/"], arguments)
  },
// api_repository => /api/repositories/:id(.:format)
  api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/"], arguments)
  },
// api_template_package_groups => /api/templates/:template_id/package_groups(.:format)
  api_template_package_groups_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/package_groups"], arguments)
  },
// environments_partial_organization => /organizations/:id/environments_partial(.:format)
  environments_partial_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments_partial"], arguments)
  },
// new_user => /users/new(.:format)
  new_user_path: function(options) {
  return Utils.build_path(1, ["/users/new"], arguments)
  },
// edit_role => /roles/:id/edit(.:format)
  edit_role_path: function(_id, options) {
  return Utils.build_path(2, ["/roles/", "/edit"], arguments)
  },
// new_organization => /organizations/new(.:format)
  new_organization_path: function(options) {
  return Utils.build_path(1, ["/organizations/new"], arguments)
  },
// new_provider => /providers/new(.:format)
  new_provider_path: function(options) {
  return Utils.build_path(1, ["/providers/new"], arguments)
  },
// import_status_owner => /owners/:id/import_status(.:format)
  import_status_owner_path: function(_id, options) {
  return Utils.build_path(2, ["/owners/", "/import_status"], arguments)
  },
// api_subscriptions => /api/subscriptions(.:format)
  api_subscriptions_path: function(options) {
  return Utils.build_path(1, ["/api/subscriptions"], arguments)
  },
// new_api_user => /api/users/new(.:format)
  new_api_user_path: function(options) {
  return Utils.build_path(1, ["/api/users/new"], arguments)
  },
// api_environment_templates => /api/environments/:environment_id/templates(.:format)
  api_environment_templates_path: function(_environment_id, options) {
  return Utils.build_path(2, ["/api/environments/", "/templates"], arguments)
  },
// new_api_template_package_group_category => /api/templates/:template_id/package_group_categories/new(.:format)
  new_api_template_package_group_category_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/package_group_categories/new"], arguments)
  },
// object_changeset => /changesets/:id/object(.:format)
  object_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/object"], arguments)
  },
// role_create_permission => /roles/:role_id/create_permission(.:format)
  role_create_permission_path: function(_role_id, options) {
  return Utils.build_path(2, ["/roles/", "/create_permission"], arguments)
  },
// api_templates => /api/templates(.:format)
  api_templates_path: function(options) {
  return Utils.build_path(1, ["/api/templates"], arguments)
  },
// sync_plan => /sync_plans/:id(.:format)
  sync_plan_path: function(_id, options) {
  return Utils.build_path(2, ["/sync_plans/"], arguments)
  },
// api_pools => /api/pools(.:format)
  api_pools_path: function(options) {
  return Utils.build_path(1, ["/api/pools"], arguments)
  },
// api_organization_filters => /api/organizations/:organization_id/filters(.:format)
  api_organization_filters_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/filters"], arguments)
  },
// repositories_api_organization_environment => /api/organizations/:organization_id/environments/:id/repositories(.:format)
  repositories_api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/environments/", "/repositories"], arguments)
  },
// sync_management_sync_status => /sync_management/sync_status(.:format)
  sync_management_sync_status_path: function(options) {
  return Utils.build_path(1, ["/sync_management/sync_status"], arguments)
  },
// roles_show_permission => /roles/show_permission(.:format)
  roles_show_permission_path: function(options) {
  return Utils.build_path(1, ["/roles/show_permission"], arguments)
  },
// available_subscriptions_activation_key => /activation_keys/:id/available_subscriptions(.:format)
  available_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/available_subscriptions"], arguments)
  },
// organization_environments => /organizations/:organization_id/environments(.:format)
  organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments"], arguments)
  },
// provider_products => /providers/:provider_id/products(.:format)
  provider_products_path: function(_provider_id, options) {
  return Utils.build_path(2, ["/providers/", "/products"], arguments)
  },
// systems_dashboard_index => /dashboard/systems(.:format)
  systems_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/systems"], arguments)
  },
// auto_complete_search_users => /users/auto_complete_search(.:format)
  auto_complete_search_users_path: function(options) {
  return Utils.build_path(1, ["/users/auto_complete_search"], arguments)
  },
// api_changeset => /api/changesets/:id(.:format)
  api_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/api/changesets/"], arguments)
  },
// new_user_session => /user_session/new(.:format)
  new_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/new"], arguments)
  },
// edit_environment_user => /users/:id/edit_environment(.:format)
  edit_environment_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/edit_environment"], arguments)
  },
// items_roles => /roles/items(.:format)
  items_roles_path: function(options) {
  return Utils.build_path(1, ["/roles/items"], arguments)
  },
// edit_organization_provider => /organizations/:organization_id/providers/:id/edit(.:format)
  edit_organization_provider_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/providers/", "/edit"], arguments)
  },
// system_template => /system_templates/:id(.:format)
  system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/"], arguments)
  },
// products_repos_provider => /providers/:id/products_repos(.:format)
  products_repos_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/products_repos"], arguments)
  },
// edit_product => /products/:id/edit(.:format)
  edit_product_path: function(_id, options) {
  return Utils.build_path(2, ["/products/", "/edit"], arguments)
  },
// packages_system_system_packages => /systems/:system_id/system_packages/packages(.:format)
  packages_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/packages"], arguments)
  },
// api_puppetclasses => /api/puppetclasses(.:format)
  api_puppetclasses_path: function(options) {
  return Utils.build_path(1, ["/api/puppetclasses"], arguments)
  },
// provider => /providers/:id(.:format)
  provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/"], arguments)
  },
// more_products_system => /systems/:id/more_products(.:format)
  more_products_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/more_products"], arguments)
  },
// auto_complete_locker_packages => /packages/auto_complete_locker(.:format)
  auto_complete_locker_packages_path: function(options) {
  return Utils.build_path(1, ["/packages/auto_complete_locker"], arguments)
  },
// new_activation_key => /activation_keys/new(.:format)
  new_activation_key_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/new"], arguments)
  },
// bulk_destroy_systems => /systems/bulk_destroy(.:format)
  bulk_destroy_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_destroy"], arguments)
  },
// packages_api_system => /api/systems/:id/packages(.:format)
  packages_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/packages"], arguments)
  },
// api_system => /api/systems/:id(.:format)
  api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/"], arguments)
  },
// new_environment => /environments/new(.:format)
  new_environment_path: function(options) {
  return Utils.build_path(1, ["/environments/new"], arguments)
  },
// items_system_templates => /system_templates/items(.:format)
  items_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/items"], arguments)
  },
// new_owner => /owners/new(.:format)
  new_owner_path: function(options) {
  return Utils.build_path(1, ["/owners/new"], arguments)
  },
// new_api_organization_environment => /api/organizations/:organization_id/environments/new(.:format)
  new_api_organization_environment_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/environments/new"], arguments)
  },
// api_providers => /api/providers(.:format)
  api_providers_path: function(options) {
  return Utils.build_path(1, ["/api/providers"], arguments)
  },
// system_templates_promotion => /promotions/:id/system_templates(.:format)
  system_templates_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/system_templates"], arguments)
  },
// notices_note_count => /notices/note_count(.:format)
  notices_note_count_path: function(options) {
  return Utils.build_path(1, ["/notices/note_count"], arguments)
  },
// remove_packages_filter => /filters/:id/remove_packages(.:format)
  remove_packages_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/remove_packages"], arguments)
  },
// distribution => /distributions/:id(.:format)
  distribution_path: function(_id, options) {
  return Utils.build_path(2, ["/distributions/"], arguments)
  },
// api_organization_systems => /api/organizations/:organization_id/systems(.:format)
  api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/systems"], arguments)
  },
// validate_api_template => /api/templates/:id/validate(.:format)
  validate_api_template_path: function(_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/validate"], arguments)
  },
// notices => /notices(.:format)
  notices_path: function(options) {
  return Utils.build_path(1, ["/notices"], arguments)
  },
// filter => /filters/:id(.:format)
  filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/"], arguments)
  },
// api_repository_packages => /api/repositories/:repository_id/packages(.:format)
  api_repository_packages_path: function(_repository_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/packages"], arguments)
  },
// api_template_package => /api/templates/:template_id/packages/:id(.:format)
  api_template_package_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/packages/"], arguments)
  },
// destroy_favorite_search_index => /search/favorite/:id(.:format)
  destroy_favorite_search_index_path: function(_id, options) {
  return Utils.build_path(2, ["/search/favorite/"], arguments)
  },
// edit_password_reset => /password_resets/:id/edit(.:format)
  edit_password_reset_path: function(_id, options) {
  return Utils.build_path(2, ["/password_resets/", "/edit"], arguments)
  },
// api_activation_key => /api/activation_keys/:id(.:format)
  api_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/api/activation_keys/"], arguments)
  },
// api_repositories => /api/repositories(.:format)
  api_repositories_path: function(options) {
  return Utils.build_path(1, ["/api/repositories"], arguments)
  },
// edit_api_template_parameter => /api/templates/:template_id/parameters/:id/edit(.:format)
  edit_api_template_parameter_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/parameters/", "/edit"], arguments)
  },
// items_organizations => /organizations/items(.:format)
  items_organizations_path: function(options) {
  return Utils.build_path(1, ["/organizations/items"], arguments)
  },
// new_role => /roles/new(.:format)
  new_role_path: function(options) {
  return Utils.build_path(1, ["/roles/new"], arguments)
  },
// edit_filter => /filters/:id/edit(.:format)
  edit_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/edit"], arguments)
  },
// import_owner => /owners/:id/import(.:format)
  import_owner_path: function(_id, options) {
  return Utils.build_path(2, ["/owners/", "/import"], arguments)
  },
// api_users => /api/users(.:format)
  api_users_path: function(options) {
  return Utils.build_path(1, ["/api/users"], arguments)
  },
// api_environment_activation_keys => /api/environments/:environment_id/activation_keys(.:format)
  api_environment_activation_keys_path: function(_environment_id, options) {
  return Utils.build_path(2, ["/api/environments/", "/activation_keys"], arguments)
  },
// api_template_package_group_category => /api/templates/:template_id/package_group_categories/:id(.:format)
  api_template_package_group_category_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/package_group_categories/"], arguments)
  },
// edit_environment => /environments/:id/edit(.:format)
  edit_environment_path: function(_id, options) {
  return Utils.build_path(2, ["/environments/", "/edit"], arguments)
  },
// promote_changeset => /changesets/:id/promote(.:format)
  promote_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/promote"], arguments)
  },
// edit_api_template_distribution => /api/templates/:template_id/distributions/:id/edit(.:format)
  edit_api_template_distribution_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/distributions/", "/edit"], arguments)
  },
// edit_sync_plan => /sync_plans/:id/edit(.:format)
  edit_sync_plan_path: function(_id, options) {
  return Utils.build_path(2, ["/sync_plans/", "/edit"], arguments)
  },
// new_system => /systems/new(.:format)
  new_system_path: function(options) {
  return Utils.build_path(1, ["/systems/new"], arguments)
  },
// promotion => /promotions/:id(.:format)
  promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/"], arguments)
  },
// api_organization_uebercert => /api/organizations/:organization_id/uebercert(.:format)
  api_organization_uebercert_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/uebercert"], arguments)
  },
// api_organization_products => /api/organizations/:organization_id/products(.:format)
  api_organization_products_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/products"], arguments)
  },
// provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id(.:format)
  provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/providers/", "/products/", "/repositories/"], arguments)
  },
// promotions_dashboard_index => /dashboard/promotions(.:format)
  promotions_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/promotions"], arguments)
  },
// gpg_key => /gpg_keys/:id(.:format)
  gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/gpg_keys/"], arguments)
  },
// product_comps_system_templates => /system_templates/product_comps(.:format)
  product_comps_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/product_comps"], arguments)
  },
// email_logins_password_resets => /password_resets/email_logins(.:format)
  email_logins_password_resets_path: function(options) {
  return Utils.build_path(1, ["/password_resets/email_logins"], arguments)
  },
// applied_subscriptions_activation_key => /activation_keys/:id/applied_subscriptions(.:format)
  applied_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/applied_subscriptions"], arguments)
  },
// api_organization => /api/organizations/:id(.:format)
  api_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/api/organizations/"], arguments)
  },
// update_roles_user => /users/:id/update_roles(.:format)
  update_roles_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/update_roles"], arguments)
  },
// auto_complete_search_roles => /roles/auto_complete_search(.:format)
  auto_complete_search_roles_path: function(options) {
  return Utils.build_path(1, ["/roles/auto_complete_search"], arguments)
  },
// new_organization_provider => /organizations/:organization_id/providers/new(.:format)
  new_organization_provider_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/organizations/", "/providers/new"], arguments)
  },
// activation_key => /activation_keys/:id(.:format)
  activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/"], arguments)
  },
// redhat_provider_providers => /providers/redhat_provider(.:format)
  redhat_provider_providers_path: function(options) {
  return Utils.build_path(1, ["/providers/redhat_provider"], arguments)
  },
// new_product => /products/new(.:format)
  new_product_path: function(options) {
  return Utils.build_path(1, ["/products/new"], arguments)
  },
// system_system_packages => /systems/:system_id/system_packages(.:format)
  system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages"], arguments)
  },
// api_product => /api/products/:id(.:format)
  api_product_path: function(_id, options) {
  return Utils.build_path(2, ["/api/products/"], arguments)
  },
// products_system => /systems/:id/products(.:format)
  products_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/products"], arguments)
  },
// sync_management_index => /sync_management/index(.:format)
  sync_management_index_path: function(options) {
  return Utils.build_path(1, ["/sync_management/index"], arguments)
  },
// dependencies_package => /packages/:id/dependencies(.:format)
  dependencies_package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/", "/dependencies"], arguments)
  },
// changeset => /changesets/:id(.:format)
  changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/"], arguments)
  },
// items_sync_plans => /sync_plans/items(.:format)
  items_sync_plans_path: function(options) {
  return Utils.build_path(1, ["/sync_plans/items"], arguments)
  },
// environments_systems => /systems/environments(.:format)
  environments_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/environments"], arguments)
  },
// operations => /operations(.:format)
  operations_path: function(options) {
  return Utils.build_path(1, ["/operations"], arguments)
  },
// api_systems => /api/systems(.:format)
  api_systems_path: function(options) {
  return Utils.build_path(1, ["/api/systems"], arguments)
  },
// filters => /filters(.:format)
  filters_path: function(options) {
  return Utils.build_path(1, ["/filters"], arguments)
  },
// auto_complete_search_system_templates => /system_templates/auto_complete_search(.:format)
  auto_complete_search_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/auto_complete_search"], arguments)
  },
// api_organization_environments => /api/organizations/:organization_id/environments(.:format)
  api_organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/environments"], arguments)
  },
// products_api_provider => /api/providers/:id/products(.:format)
  products_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/products"], arguments)
  },
// add_packages_filter => /filters/:id/add_packages(.:format)
  add_packages_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/add_packages"], arguments)
  },
// filelist_distribution => /distributions/:id/filelist(.:format)
  filelist_distribution_path: function(_id, options) {
  return Utils.build_path(2, ["/distributions/", "/filelist"], arguments)
  },
// report_api_organization_systems => /api/organizations/:organization_id/systems/report(.:format)
  report_api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/systems/report"], arguments)
  },
// export_api_template => /api/templates/:id/export(.:format)
  export_api_template_path: function(_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/export"], arguments)
  },
// api_repository_sync_index => /api/repositories/:repository_id/sync(.:format)
  api_repository_sync_index_path: function(_repository_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/sync"], arguments)
  },
// api_template_packages => /api/templates/:template_id/packages(.:format)
  api_template_packages_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/packages"], arguments)
  },
// products_promotion => /promotions/:id/products(.:format)
  products_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/products"], arguments)
  },
// object_system_template => /system_templates/:id/object(.:format)
  object_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/object"], arguments)
  },
// new_password_reset => /password_resets/new(.:format)
  new_password_reset_path: function(options) {
  return Utils.build_path(1, ["/password_resets/new"], arguments)
  }}
;
  
  window.KT.routes.options = {
    prefix: '',
    default_format: '',
  };


})();
