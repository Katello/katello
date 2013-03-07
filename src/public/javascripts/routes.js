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
// bulk_content_remove_systems => /systems/bulk_content_remove(.:format)
  bulk_content_remove_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_content_remove"], arguments)
  },
// configuration_templates_path => /configuration_templates(.:format)
  configuration_templates_path: function(options) {
  return Utils.build_path(1, ["/configuration_templates"], arguments)
  },
// items_distributors => /distributors/items(.:format)
  items_distributors_path: function(options) {
  return Utils.build_path(1, ["/distributors/items"], arguments)
  },
// new_api_changeset_repository => /api/changesets/:changeset_id/repositories/new(.:format)
  new_api_changeset_repository_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/repositories/new"], arguments)
  },
// items_sync_plans => /sync_plans/items(.:format)
  items_sync_plans_path: function(options) {
  return Utils.build_path(1, ["/sync_plans/items"], arguments)
  },
// allowed_orgs_user_session => /user_session/allowed_orgs(.:format)
  allowed_orgs_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/allowed_orgs"], arguments)
  },
// promotion_details_system_template => /system_templates/:id/promotion_details(.:format)
  promotion_details_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/promotion_details"], arguments)
  },
// copy_system_group => /system_groups/:id/copy(.:format)
  copy_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/copy"], arguments)
  },
// subscriptions_activation_keys => /activation_keys/subscriptions(.:format)
  subscriptions_activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/subscriptions"], arguments)
  },
// sync_schedules_apply => /sync_schedules/apply(.:format)
  sync_schedules_apply_path: function(options) {
  return Utils.build_path(1, ["/sync_schedules/apply"], arguments)
  },
// new_api_changeset_content_view => /api/changesets/:changeset_id/content_views/new(.:format)
  new_api_changeset_content_view_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/content_views/new"], arguments)
  },
// repository_distribution => /repositories/:repository_id/distributions/:id(.:format)
  repository_distribution_path: function(_repository_id, _id, options) {
  return Utils.build_path(3, ["/repositories/", "/distributions/"], arguments)
  },
// edit_organization_environment => /organizations/:organization_id/environments/:id/edit(.:format)
  edit_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/", "/edit"], arguments)
  },
// sync_management_product_status => /sync_management/product_status(.:format)
  sync_management_product_status_path: function(options) {
  return Utils.build_path(1, ["/sync_management/product_status"], arguments)
  },
// products_promotion => /promotions/:id/products(.:format)
  products_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/products"], arguments)
  },
// update_content_content_view_definition => /content_view_definitions/:id/update_content(.:format)
  update_content_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/", "/update_content"], arguments)
  },
// custom_info => /custom_info/:informable_type/:informable_id(.:format)
  custom_info_path: function(_informable_type, _informable_id, options) {
  return Utils.build_path(3, ["/custom_info/", "/"], arguments)
  },
// sync_complete_api_repositories => /api/repositories/sync_complete(.:format)
  sync_complete_api_repositories_path: function(options) {
  return Utils.build_path(1, ["/api/repositories/sync_complete"], arguments)
  },
// update_content_system_template => /system_templates/:id/update_content(.:format)
  update_content_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/update_content"], arguments)
  },
// new_environment => /environments/new(.:format)
  new_environment_path: function(options) {
  return Utils.build_path(1, ["/environments/new"], arguments)
  },
// pools_api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id/pools(.:format)
  pools_api_organization_activation_key_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/activation_keys/", "/pools"], arguments)
  },
// add_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/add_systems(.:format)
  add_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/add_systems"], arguments)
  },
// root => /(.:format)
  root_path: function(options) {
  return Utils.build_path(1, ["/"], arguments)
  },
// product_create_api_provider => /api/providers/:id/product_create(.:format)
  product_create_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/product_create"], arguments)
  },
// auto_complete_library_repositories => /repositories/auto_complete_library(.:format)
  auto_complete_library_repositories_path: function(options) {
  return Utils.build_path(1, ["/repositories/auto_complete_library"], arguments)
  },
// edit_api_organization_system_group_packages => /api/organizations/:organization_id/system_groups/:system_group_id/packages/edit(.:format)
  edit_api_organization_system_group_packages_path: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/packages/edit"], arguments)
  },
// edit_organization => /organizations/:id/edit(.:format)
  edit_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/edit"], arguments)
  },
// object_changeset => /changesets/:id/object(.:format)
  object_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/object"], arguments)
  },
// new_api_template_product => /api/templates/:template_id/products/new(.:format)
  new_api_template_product_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/products/new"], arguments)
  },
// user_session => /user_session(.:format)
  user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session"], arguments)
  },
// auto_complete_search_system_templates => /system_templates/auto_complete_search(.:format)
  auto_complete_search_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/auto_complete_search"], arguments)
  },
// new_api_user => /api/users/new(.:format)
  new_api_user_path: function(options) {
  return Utils.build_path(1, ["/api/users/new"], arguments)
  },
// edit_api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/:id/edit(.:format)
  edit_api_organization_sync_plan_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/sync_plans/", "/edit"], arguments)
  },
// refresh_content_product => /products/:id/refresh_content(.:format)
  refresh_content_product_path: function(_id, options) {
  return Utils.build_path(2, ["/products/", "/refresh_content"], arguments)
  },
// environments_partial_organization => /organizations/:id/environments_partial(.:format)
  environments_partial_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments_partial"], arguments)
  },
// content_view => /content_views/:id(.:format)
  content_view_path: function(_id, options) {
  return Utils.build_path(2, ["/content_views/"], arguments)
  },
// sync_plan => /sync_plans/:id(.:format)
  sync_plan_path: function(_id, options) {
  return Utils.build_path(2, ["/sync_plans/"], arguments)
  },
// erratum => /errata/:id(.:format)
  erratum_path: function(_id, options) {
  return Utils.build_path(2, ["/errata/"], arguments)
  },
// system_groups => /system_groups(.:format)
  system_groups_path: function(options) {
  return Utils.build_path(1, ["/system_groups"], arguments)
  },
// systems_dashboard_index => /dashboard/systems(.:format)
  systems_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/systems"], arguments)
  },
// new_api_template_package_group => /api/templates/:template_id/package_groups/new(.:format)
  new_api_template_package_group_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/package_groups/new"], arguments)
  },
// destroy_role_ldap_group => /roles/:role_id/ldap_groups/:id(.:format)
  destroy_role_ldap_group_path: function(_role_id, _id, options) {
  return Utils.build_path(3, ["/roles/", "/ldap_groups/"], arguments)
  },
// items_system_events => /systems/:system_id/events/items(.:format)
  items_system_events_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/events/items"], arguments)
  },
// new_api_template_repository => /api/templates/:template_id/repositories/new(.:format)
  new_api_template_repository_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/repositories/new"], arguments)
  },
// systems => /systems(.:format)
  systems_path: function(options) {
  return Utils.build_path(1, ["/systems"], arguments)
  },
// edit_system_group => /system_groups/:id/edit(.:format)
  edit_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/edit"], arguments)
  },
// errata_promotion => /promotions/:id/errata(.:format)
  errata_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/errata"], arguments)
  },
// items_gpg_keys => /gpg_keys/items(.:format)
  items_gpg_keys_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys/items"], arguments)
  },
// repositories_api_organization_product => /api/organizations/:organization_id/products/:id/repositories(.:format)
  repositories_api_organization_product_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/products/", "/repositories"], arguments)
  },
// auto_complete_content_views => /content_views/auto_complete(.:format)
  auto_complete_content_views_path: function(options) {
  return Utils.build_path(1, ["/content_views/auto_complete"], arguments)
  },
// errata_items_content_search_index => /content_search/errata_items(.:format)
  errata_items_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/errata_items"], arguments)
  },
// repo_compare_errata_content_search_index => /content_search/repo_compare_errata(.:format)
  repo_compare_errata_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/repo_compare_errata"], arguments)
  },
// edit_product => /products/:id/edit(.:format)
  edit_product_path: function(_id, options) {
  return Utils.build_path(2, ["/products/", "/edit"], arguments)
  },
// default_label_provider_product_repositories => /providers/:provider_id/products/:product_id/repositories/default_label(.:format)
  default_label_provider_product_repositories_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/repositories/default_label"], arguments)
  },
// provider_products => /providers/:provider_id/products(.:format)
  provider_products_path: function(_provider_id, options) {
  return Utils.build_path(2, ["/providers/", "/products"], arguments)
  },
// edit_role => /roles/:id/edit(.:format)
  edit_role_path: function(_id, options) {
  return Utils.build_path(2, ["/roles/", "/edit"], arguments)
  },
// remove_system_system_packages => /systems/:system_id/system_packages/remove(.:format)
  remove_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/remove"], arguments)
  },
// packages_api_system => /api/systems/:id/packages(.:format)
  packages_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/packages"], arguments)
  },
// jammit => /assets/:package.:extension(.:format)
  jammit_path: function(_package, _extension, options) {
  return Utils.build_path(3, ["/assets/", "."], arguments)
  },
// new_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/new(.:format)
  new_api_organization_content_view_definition_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/content_view_definitions/new"], arguments)
  },
// repo_discovery_provider => /providers/:id/repo_discovery(.:format)
  repo_discovery_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/repo_discovery"], arguments)
  },
// install_system_errata => /systems/:system_id/errata/install(.:format)
  install_system_errata_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/errata/install"], arguments)
  },
// upload_subscriptions => /subscriptions/upload(.:format)
  upload_subscriptions_path: function(options) {
  return Utils.build_path(1, ["/subscriptions/upload"], arguments)
  },
// auto_complete_nvrea_library_packages => /packages/auto_complete_nvrea_library(.:format)
  auto_complete_nvrea_library_packages_path: function(options) {
  return Utils.build_path(1, ["/packages/auto_complete_nvrea_library"], arguments)
  },
// manifest_progress_provider => /providers/:id/manifest_progress(.:format)
  manifest_progress_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/manifest_progress"], arguments)
  },
// update_subscriptions_system => /systems/:id/update_subscriptions(.:format)
  update_subscriptions_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/update_subscriptions"], arguments)
  },
// environment => /environments/:id(.:format)
  environment_path: function(_id, options) {
  return Utils.build_path(2, ["/environments/"], arguments)
  },
// promote_api_changeset => /api/changesets/:id/promote(.:format)
  promote_api_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/promote"], arguments)
  },
// remove_system_groups_system => /systems/:id/remove_system_groups(.:format)
  remove_system_groups_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/remove_system_groups"], arguments)
  },
// enable_helptip_users => /users/enable_helptip(.:format)
  enable_helptip_users_path: function(options) {
  return Utils.build_path(1, ["/users/enable_helptip"], arguments)
  },
// system_group_event => /system_groups/:system_group_id/events/:id(.:format)
  system_group_event_path: function(_system_group_id, _id, options) {
  return Utils.build_path(3, ["/system_groups/", "/events/"], arguments)
  },
// edit_api_changeset_product => /api/changesets/:changeset_id/products/:id/edit(.:format)
  edit_api_changeset_product_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/products/", "/edit"], arguments)
  },
// apply_api_organization_system_info_keys => /api/organizations/:organization_id/system_info_keys/apply(.:format)
  apply_api_organization_system_info_keys_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/system_info_keys/apply"], arguments)
  },
// update_subscriptions_distributor => /distributors/:id/update_subscriptions(.:format)
  update_subscriptions_distributor_path: function(_id, options) {
  return Utils.build_path(2, ["/distributors/", "/update_subscriptions"], arguments)
  },
// bulk_destroy_systems => /systems/bulk_destroy(.:format)
  bulk_destroy_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_destroy"], arguments)
  },
// setup_default_org_user => /users/:id/setup_default_org(.:format)
  setup_default_org_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/setup_default_org"], arguments)
  },
// notices_get_new => /notices/get_new(.:format)
  notices_get_new_path: function(options) {
  return Utils.build_path(1, ["/notices/get_new"], arguments)
  },
// repos_promotion => /promotions/:id/repos(.:format)
  repos_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/repos"], arguments)
  },
// products => /products(.:format)
  products_path: function(options) {
  return Utils.build_path(1, ["/products"], arguments)
  },
// bulk_errata_install_systems => /systems/bulk_errata_install(.:format)
  bulk_errata_install_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_errata_install"], arguments)
  },
// refresh_content_view_definition_content_view => /content_view_definitions/:content_view_definition_id/content_view/:id/refresh(.:format)
  refresh_content_view_definition_content_view_path: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(3, ["/content_view_definitions/", "/content_view/", "/refresh"], arguments)
  },
// env_items_distributors => /distributors/env_items(.:format)
  env_items_distributors_path: function(options) {
  return Utils.build_path(1, ["/distributors/env_items"], arguments)
  },
// edit_api_changeset_repository => /api/changesets/:changeset_id/repositories/:id/edit(.:format)
  edit_api_changeset_repository_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/repositories/", "/edit"], arguments)
  },
// systems_system_group => /system_groups/:id/systems(.:format)
  systems_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/systems"], arguments)
  },
// object_system_template => /system_templates/:id/object(.:format)
  object_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/object"], arguments)
  },
// applied_subscriptions_activation_key => /activation_keys/:id/applied_subscriptions(.:format)
  applied_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/applied_subscriptions"], arguments)
  },
// edit_api_changeset_content_view => /api/changesets/:changeset_id/content_views/:id/edit(.:format)
  edit_api_changeset_content_view_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/content_views/", "/edit"], arguments)
  },
// status_system_group_packages => /system_groups/:system_group_id/packages/status(.:format)
  status_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/packages/status"], arguments)
  },
// organization_environment => /organizations/:organization_id/environments/:id(.:format)
  organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/"], arguments)
  },
// new_api_repository_package => /api/repositories/:repository_id/packages/new(.:format)
  new_api_repository_package_path: function(_repository_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/packages/new"], arguments)
  },
// update_component_views_content_view_definition => /content_view_definitions/:id/update_component_views(.:format)
  update_component_views_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/", "/update_component_views"], arguments)
  },
// new_user => /users/new(.:format)
  new_user_path: function(options) {
  return Utils.build_path(1, ["/users/new"], arguments)
  },
// new_distributor => /distributors/new(.:format)
  new_distributor_path: function(options) {
  return Utils.build_path(1, ["/distributors/new"], arguments)
  },
// set_org_user_session => /user_session/set_org(.:format)
  set_org_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/set_org"], arguments)
  },
// sync_schedules_index => /sync_schedules/index(.:format)
  sync_schedules_index_path: function(options) {
  return Utils.build_path(1, ["/sync_schedules/index"], arguments)
  },
// changesets => /changesets(.:format)
  changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets"], arguments)
  },
// copy_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/copy(.:format)
  copy_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/copy"], arguments)
  },
// sync_management_sync_status => /sync_management/sync_status(.:format)
  sync_management_sync_status_path: function(options) {
  return Utils.build_path(1, ["/sync_management/sync_status"], arguments)
  },
// products_api_provider => /api/providers/:id/products(.:format)
  products_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/products"], arguments)
  },
// sync_plans => /sync_plans(.:format)
  sync_plans_path: function(options) {
  return Utils.build_path(1, ["/sync_plans"], arguments)
  },
// pools_api_activation_key => /api/activation_keys/:id/pools(.:format)
  pools_api_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/api/activation_keys/", "/pools"], arguments)
  },
// import_api_templates => /api/templates/import(.:format)
  import_api_templates_path: function(options) {
  return Utils.build_path(1, ["/api/templates/import"], arguments)
  },
// report_api_users => /api/users/report(.:format)
  report_api_users_path: function(options) {
  return Utils.build_path(1, ["/api/users/report"], arguments)
  },
// new_api_organization_environment => /api/organizations/:organization_id/environments/new(.:format)
  new_api_organization_environment_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/environments/new"], arguments)
  },
// items_system_templates => /system_templates/items(.:format)
  items_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/items"], arguments)
  },
// auto_complete_search_changesets => /changesets/auto_complete_search(.:format)
  auto_complete_search_changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets/auto_complete_search"], arguments)
  },
// edit_api_template_product => /api/templates/:template_id/products/:id/edit(.:format)
  edit_api_template_product_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/products/", "/edit"], arguments)
  },
// details_promotion => /promotions/:id/details(.:format)
  details_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/details"], arguments)
  },
// new_system => /systems/new(.:format)
  new_system_path: function(options) {
  return Utils.build_path(1, ["/systems/new"], arguments)
  },
// update_custom_info => /custom_info/:informable_type/:informable_id/:keyname(.:format)
  update_custom_info_path: function(_informable_type, _informable_id, _keyname, options) {
  return Utils.build_path(4, ["/custom_info/", "/", "/"], arguments)
  },
// new_content_view_definition => /content_view_definitions/new(.:format)
  new_content_view_definition_path: function(options) {
  return Utils.build_path(1, ["/content_view_definitions/new"], arguments)
  },
// edit_api_user => /api/users/:id/edit(.:format)
  edit_api_user_path: function(_id, options) {
  return Utils.build_path(2, ["/api/users/", "/edit"], arguments)
  },
// disable_content_product => /products/:id/disable_content(.:format)
  disable_content_product_path: function(_id, options) {
  return Utils.build_path(2, ["/products/", "/disable_content"], arguments)
  },
// events_organization => /organizations/:id/events(.:format)
  events_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/events"], arguments)
  },
// system_group_errata => /system_groups/:system_group_id/errata(.:format)
  system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/errata"], arguments)
  },
// edit_user_session => /user_session/edit(.:format)
  edit_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/edit"], arguments)
  },
// content_view_definitions => /content_view_definitions(.:format)
  content_view_definitions_path: function(options) {
  return Utils.build_path(1, ["/content_view_definitions"], arguments)
  },
// system_groups_dashboard_index => /dashboard/system_groups(.:format)
  system_groups_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/system_groups"], arguments)
  },
// edit_api_template_package_group => /api/templates/:template_id/package_groups/:id/edit(.:format)
  edit_api_template_package_group_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/package_groups/", "/edit"], arguments)
  },
// create_role_ldap_groups => /roles/:role_id/ldap_groups(.:format)
  create_role_ldap_groups_path: function(_role_id, options) {
  return Utils.build_path(2, ["/roles/", "/ldap_groups"], arguments)
  },
// system => /systems/:id(.:format)
  system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/"], arguments)
  },
// organizations => /organizations(.:format)
  organizations_path: function(options) {
  return Utils.build_path(1, ["/organizations"], arguments)
  },
// edit_api_template_repository => /api/templates/:template_id/repositories/:id/edit(.:format)
  edit_api_template_repository_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/repositories/", "/edit"], arguments)
  },
// distributors => /distributors(.:format)
  distributors_path: function(options) {
  return Utils.build_path(1, ["/distributors"], arguments)
  },
// system_group => /system_groups/:id(.:format)
  system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/"], arguments)
  },
// products_repos_gpg_key => /gpg_keys/:id/products_repos(.:format)
  products_repos_gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/gpg_keys/", "/products_repos"], arguments)
  },
// sync_plan_api_organization_product => /api/organizations/:organization_id/products/:id/sync_plan(.:format)
  sync_plan_api_organization_product_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/products/", "/sync_plan"], arguments)
  },
// system_templates => /system_templates(.:format)
  system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates"], arguments)
  },
// distributor => /distributors/:id(.:format)
  distributor_path: function(_id, options) {
  return Utils.build_path(2, ["/distributors/"], arguments)
  },
// repos_content_search_index => /content_search/repos(.:format)
  repos_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/repos"], arguments)
  },
// content_search_index => /content_search(.:format)
  content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search"], arguments)
  },
// products_organization_environment => /organizations/:organization_id/environments/:id/products(.:format)
  products_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/", "/products"], arguments)
  },
// update_repo_gpg_key_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/update_gpg_key(.:format)
  update_repo_gpg_key_provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/providers/", "/products/", "/repositories/", "/update_gpg_key"], arguments)
  },
// errata_api_system => /api/systems/:id/errata(.:format)
  errata_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/errata"], arguments)
  },
// new_provider_product => /providers/:provider_id/products/new(.:format)
  new_provider_product_path: function(_provider_id, options) {
  return Utils.build_path(2, ["/providers/", "/products/new"], arguments)
  },
// system_system_packages => /systems/:system_id/system_packages(.:format)
  system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages"], arguments)
  },
// edit_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/:id/edit(.:format)
  edit_api_organization_content_view_definition_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/content_view_definitions/", "/edit"], arguments)
  },
// user => /users/:id(.:format)
  user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/"], arguments)
  },
// discovered_repos_provider => /providers/:id/discovered_repos(.:format)
  discovered_repos_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/discovered_repos"], arguments)
  },
// status_system_errata => /systems/:system_id/errata/status(.:format)
  status_system_errata_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/errata/status"], arguments)
  },
// subscription => /subscriptions/:id(.:format)
  subscription_path: function(_id, options) {
  return Utils.build_path(2, ["/subscriptions/"], arguments)
  },
// delete_manifest_subscriptions => /subscriptions/delete_manifest(.:format)
  delete_manifest_subscriptions_path: function(options) {
  return Utils.build_path(1, ["/subscriptions/delete_manifest"], arguments)
  },
// content_views_api_content_view_definition => /api/content_view_definitions/:id/content_views(.:format)
  content_views_api_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/api/content_view_definitions/", "/content_views"], arguments)
  },
// validate_name_library_packages => /packages/validate_name_library(.:format)
  validate_name_library_packages_path: function(options) {
  return Utils.build_path(1, ["/packages/validate_name_library"], arguments)
  },
// schedule_provider => /providers/:id/schedule(.:format)
  schedule_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/schedule"], arguments)
  },
// products_system => /systems/:id/products(.:format)
  products_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/products"], arguments)
  },
// apply_api_changeset => /api/changesets/:id/apply(.:format)
  apply_api_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/apply"], arguments)
  },
// custom_info_system => /systems/:id/custom_info(.:format)
  custom_info_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/custom_info"], arguments)
  },
// default_label_content_view_definitions => /content_view_definitions/default_label(.:format)
  default_label_content_view_definitions_path: function(options) {
  return Utils.build_path(1, ["/content_view_definitions/default_label"], arguments)
  },
// disable_helptip_users => /users/disable_helptip(.:format)
  disable_helptip_users_path: function(options) {
  return Utils.build_path(1, ["/users/disable_helptip"], arguments)
  },
// add_system_group_packages => /system_groups/:system_group_id/packages/add(.:format)
  add_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/packages/add"], arguments)
  },
// products_distributor => /distributors/:id/products(.:format)
  products_distributor_path: function(_id, options) {
  return Utils.build_path(2, ["/distributors/", "/products"], arguments)
  },
// bulk_add_system_group_systems => /systems/bulk_add_system_group(.:format)
  bulk_add_system_group_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_add_system_group"], arguments)
  },
// edit_environment_user => /users/:id/edit_environment(.:format)
  edit_environment_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/edit_environment"], arguments)
  },
// new_api_changeset_erratum => /api/changesets/:changeset_id/errata/new(.:format)
  new_api_changeset_erratum_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/errata/new"], arguments)
  },
// environments_distributors => /distributors/environments(.:format)
  environments_distributors_path: function(options) {
  return Utils.build_path(1, ["/distributors/environments"], arguments)
  },
// add_systems_system_group => /system_groups/:id/add_systems(.:format)
  add_systems_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/add_systems"], arguments)
  },
// new_api_changeset_template => /api/changesets/:changeset_id/templates/new(.:format)
  new_api_changeset_template_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/templates/new"], arguments)
  },
// content_organization_environment_content_view_version => /organizations/:organization_id/environments/:environment_id/content_view_versions/:id/content(.:format)
  content_organization_environment_content_view_version_path: function(_organization_id, _environment_id, _id, options) {
  return Utils.build_path(4, ["/organizations/", "/environments/", "/content_view_versions/", "/content"], arguments)
  },
// available_subscriptions_activation_key => /activation_keys/:id/available_subscriptions(.:format)
  available_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/available_subscriptions"], arguments)
  },
// role_create_permission => /roles/:role_id/create_permission(.:format)
  role_create_permission_path: function(_role_id, options) {
  return Utils.build_path(2, ["/roles/", "/create_permission"], arguments)
  },
// items_system_group_errata => /system_groups/:system_group_id/errata/items(.:format)
  items_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/errata/items"], arguments)
  },
// notices_note_count => /notices/note_count(.:format)
  notices_note_count_path: function(options) {
  return Utils.build_path(1, ["/notices/note_count"], arguments)
  },
// edit_api_repository_package => /api/repositories/:repository_id/packages/:id/edit(.:format)
  edit_api_repository_package_path: function(_repository_id, _id, options) {
  return Utils.build_path(3, ["/api/repositories/", "/packages/", "/edit"], arguments)
  },
// content_search => /content_search/:id(.:format)
  content_search_path: function(_id, options) {
  return Utils.build_path(2, ["/content_search/"], arguments)
  },
// edit_user => /users/:id/edit(.:format)
  edit_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/edit"], arguments)
  },
// filter_content_view_definition => /content_view_definitions/:id/filter(.:format)
  filter_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/", "/filter"], arguments)
  },
// package_groups_api_repository => /api/repositories/:id/package_groups(.:format)
  package_groups_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/package_groups"], arguments)
  },
// changeset => /changesets/:id(.:format)
  changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/"], arguments)
  },
// promotions => /promotions(.:format)
  promotions_path: function(options) {
  return Utils.build_path(1, ["/promotions"], arguments)
  },
// import_products_api_provider => /api/providers/:id/import_products(.:format)
  import_products_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/import_products"], arguments)
  },
// packages_erratum => /errata/:id/packages(.:format)
  packages_erratum_path: function(_id, options) {
  return Utils.build_path(2, ["/errata/", "/packages"], arguments)
  },
// new_provider => /providers/new(.:format)
  new_provider_path: function(options) {
  return Utils.build_path(1, ["/providers/new"], arguments)
  },
// remove_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/remove_systems(.:format)
  remove_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/remove_systems"], arguments)
  },
// discovery_api_provider => /api/providers/:id/discovery(.:format)
  discovery_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/discovery"], arguments)
  },
// system_groups_activation_key => /activation_keys/:id/system_groups(.:format)
  system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/system_groups"], arguments)
  },
// name_changeset => /changesets/:id/name(.:format)
  name_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/name"], arguments)
  },
// export_api_template => /api/templates/:id/export(.:format)
  export_api_template_path: function(_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/export"], arguments)
  },
// sync_ldap_roles_api_users => /api/users/sync_ldap_roles(.:format)
  sync_ldap_roles_api_users_path: function(options) {
  return Utils.build_path(1, ["/api/users/sync_ldap_roles"], arguments)
  },
// edit_api_organization_environment => /api/organizations/:organization_id/environments/:id/edit(.:format)
  edit_api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/environments/", "/edit"], arguments)
  },
// edit_content_view_definition => /content_view_definitions/:id/edit(.:format)
  edit_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/", "/edit"], arguments)
  },
// destroy_favorite_search_index => /search/favorite/:id(.:format)
  destroy_favorite_search_index_path: function(_id, options) {
  return Utils.build_path(2, ["/search/favorite/"], arguments)
  },
// product_packages_system_templates => /system_templates/product_packages(.:format)
  product_packages_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/product_packages"], arguments)
  },
// list_changesets => /changesets/list(.:format)
  list_changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets/list"], arguments)
  },
// promotion => /promotions/:id(.:format)
  promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/"], arguments)
  },
// sync_dashboard_index => /dashboard/sync(.:format)
  sync_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/sync"], arguments)
  },
// new_api_template_parameter => /api/templates/:template_id/parameters/new(.:format)
  new_api_template_parameter_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/parameters/new"], arguments)
  },
// download_debug_certificate_organization => /organizations/:id/download_debug_certificate(.:format)
  download_debug_certificate_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/download_debug_certificate"], arguments)
  },
// subscriptions_dashboard_index => /dashboard/subscriptions(.:format)
  subscriptions_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/subscriptions"], arguments)
  },
// sync_management_sync => /sync_management/sync(.:format)
  sync_management_sync_path: function(options) {
  return Utils.build_path(1, ["/sync_management/sync"], arguments)
  },
// new_api_template_distribution => /api/templates/:template_id/distributions/new(.:format)
  new_api_template_distribution_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/distributions/new"], arguments)
  },
// errata_content_search_index => /content_search/errata(.:format)
  errata_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/errata"], arguments)
  },
// views_content_search_index => /content_search/views(.:format)
  views_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/views"], arguments)
  },
// systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/systems(.:format)
  systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/systems"], arguments)
  },
// logout => /logout(.:format)
  logout_path: function(options) {
  return Utils.build_path(1, ["/logout"], arguments)
  },
// show_user_session => /user_session(.:format)
  show_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session"], arguments)
  },
// new_content_search => /content_search/new(.:format)
  new_content_search_path: function(options) {
  return Utils.build_path(1, ["/content_search/new"], arguments)
  },
// provider_product_repositories => /providers/:provider_id/products/:product_id/repositories(.:format)
  provider_product_repositories_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/repositories"], arguments)
  },
// publish_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/:id/publish(.:format)
  publish_api_organization_content_view_definition_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/content_view_definitions/", "/publish"], arguments)
  },
// pools_api_system => /api/systems/:id/pools(.:format)
  pools_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/pools"], arguments)
  },
// edit_provider_product => /providers/:provider_id/products/:id/edit(.:format)
  edit_provider_product_path: function(_provider_id, _id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/edit"], arguments)
  },
// verbs_and_scopes => /roles/:organization_id/resource_type/verbs_and_scopes(.:format)
  verbs_and_scopes_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/roles/", "/resource_type/verbs_and_scopes"], arguments)
  },
// packages_system_system_packages => /systems/:system_id/system_packages/packages(.:format)
  packages_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/packages"], arguments)
  },
// edit_subscription => /subscriptions/:id/edit(.:format)
  edit_subscription_path: function(_id, options) {
  return Utils.build_path(2, ["/subscriptions/", "/edit"], arguments)
  },
// changelog_package => /packages/:id/changelog(.:format)
  changelog_package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/", "/changelog"], arguments)
  },
// new_discovered_repos_provider => /providers/:id/new_discovered_repos(.:format)
  new_discovered_repos_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/new_discovered_repos"], arguments)
  },
// system_errata => /systems/:system_id/errata(.:format)
  system_errata_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/errata"], arguments)
  },
// content_view_definition => /content_view_definitions/:id(.:format)
  content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/"], arguments)
  },
// product_repos_system_templates => /system_templates/product_repos(.:format)
  product_repos_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/product_repos"], arguments)
  },
// history_subscriptions => /subscriptions/history(.:format)
  history_subscriptions_path: function(options) {
  return Utils.build_path(1, ["/subscriptions/history"], arguments)
  },
// status_system_group_events => /system_groups/:system_group_id/events/status(.:format)
  status_system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/events/status"], arguments)
  },
// more_products_system => /systems/:id/more_products(.:format)
  more_products_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/more_products"], arguments)
  },
// login => /login(.:format)
  login_path: function(options) {
  return Utils.build_path(1, ["/login"], arguments)
  },
// dependencies_api_changeset => /api/changesets/:id/dependencies(.:format)
  dependencies_api_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/dependencies"], arguments)
  },
// clear_helptips_user => /users/:id/clear_helptips(.:format)
  clear_helptips_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/clear_helptips"], arguments)
  },
// remove_system_group_packages => /system_groups/:system_group_id/packages/remove(.:format)
  remove_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/packages/remove"], arguments)
  },
// auto_complete_systems => /systems/auto_complete(.:format)
  auto_complete_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/auto_complete"], arguments)
  },
// items_content_view_definitions => /content_view_definitions/items(.:format)
  items_content_view_definitions_path: function(options) {
  return Utils.build_path(1, ["/content_view_definitions/items"], arguments)
  },
// update_environment_user => /users/:id/update_environment(.:format)
  update_environment_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/update_environment"], arguments)
  },
// more_products_distributor => /distributors/:id/more_products(.:format)
  more_products_distributor_path: function(_id, options) {
  return Utils.build_path(2, ["/distributors/", "/more_products"], arguments)
  },
// bulk_remove_system_group_systems => /systems/bulk_remove_system_group(.:format)
  bulk_remove_system_group_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_remove_system_group"], arguments)
  },
// edit_api_changeset_erratum => /api/changesets/:changeset_id/errata/:id/edit(.:format)
  edit_api_changeset_erratum_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/errata/", "/edit"], arguments)
  },
// bulk_destroy_distributors => /distributors/bulk_destroy(.:format)
  bulk_destroy_distributors_path: function(options) {
  return Utils.build_path(1, ["/distributors/bulk_destroy"], arguments)
  },
// items_system_groups => /system_groups/items(.:format)
  items_system_groups_path: function(options) {
  return Utils.build_path(1, ["/system_groups/items"], arguments)
  },
// new_gpg_key => /gpg_keys/new(.:format)
  new_gpg_key_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys/new"], arguments)
  },
// provider => /providers/:id(.:format)
  provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/"], arguments)
  },
// remove_systems_system_group => /system_groups/:id/remove_systems(.:format)
  remove_systems_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/remove_systems"], arguments)
  },
// content_views => /content_views(.:format)
  content_views_path: function(options) {
  return Utils.build_path(1, ["/content_views"], arguments)
  },
// role => /roles/:id(.:format)
  role_path: function(_id, options) {
  return Utils.build_path(2, ["/roles/"], arguments)
  },
// edit_api_changeset_template => /api/changesets/:changeset_id/templates/:id/edit(.:format)
  edit_api_changeset_template_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/templates/", "/edit"], arguments)
  },
// organization_environment_content_view_version => /organizations/:organization_id/environments/:environment_id/content_view_versions/:id(.:format)
  organization_environment_content_view_version_path: function(_organization_id, _environment_id, _id, options) {
  return Utils.build_path(4, ["/organizations/", "/environments/", "/content_view_versions/"], arguments)
  },
// remove_subscriptions_activation_key => /activation_keys/:id/remove_subscriptions(.:format)
  remove_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/remove_subscriptions"], arguments)
  },
// publish_content_view_definition => /content_view_definitions/:id/publish(.:format)
  publish_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/", "/publish"], arguments)
  },
// install_system_group_errata => /system_groups/:system_group_id/errata/install(.:format)
  install_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/errata/install"], arguments)
  },
// subscriptions => /subscriptions(.:format)
  subscriptions_path: function(options) {
  return Utils.build_path(1, ["/subscriptions"], arguments)
  },
// package_group_categories_api_repository => /api/repositories/:id/package_group_categories(.:format)
  package_group_categories_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/package_group_categories"], arguments)
  },
// new_api_system_packages => /api/systems/:system_id/packages/new(.:format)
  new_api_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/packages/new"], arguments)
  },
// report_api_organization_systems => /api/organizations/:organization_id/systems/report(.:format)
  report_api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/systems/report"], arguments)
  },
// repository => /repositories/:id(.:format)
  repository_path: function(_id, options) {
  return Utils.build_path(2, ["/repositories/"], arguments)
  },
// import_manifest_api_provider => /api/providers/:id/import_manifest(.:format)
  import_manifest_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/import_manifest"], arguments)
  },
// short_details_erratum => /errata/:id/short_details(.:format)
  short_details_erratum_path: function(_id, options) {
  return Utils.build_path(2, ["/errata/", "/short_details"], arguments)
  },
// edit_provider => /providers/:id/edit(.:format)
  edit_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/edit"], arguments)
  },
// releases_api_environment => /api/environments/:id/releases(.:format)
  releases_api_environment_path: function(_id, options) {
  return Utils.build_path(2, ["/api/environments/", "/releases"], arguments)
  },
// destroy_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/destroy_systems(.:format)
  destroy_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/destroy_systems"], arguments)
  },
// systems_activation_key => /activation_keys/:id/systems(.:format)
  systems_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/systems"], arguments)
  },
// new_api_activation_key => /api/activation_keys/new(.:format)
  new_api_activation_key_path: function(options) {
  return Utils.build_path(1, ["/api/activation_keys/new"], arguments)
  },
// dependencies_changeset => /changesets/:id/dependencies(.:format)
  dependencies_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/dependencies"], arguments)
  },
// validate_api_template => /api/templates/:id/validate(.:format)
  validate_api_template_path: function(_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/validate"], arguments)
  },
// packages_promotion => /promotions/:id/packages(.:format)
  packages_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/packages"], arguments)
  },
// items_changesets => /changesets/items(.:format)
  items_changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets/items"], arguments)
  },
// auto_complete_search_organizations => /organizations/auto_complete_search(.:format)
  auto_complete_search_organizations_path: function(options) {
  return Utils.build_path(1, ["/organizations/auto_complete_search"], arguments)
  },
// available_verbs_api_roles => /api/roles/available_verbs(.:format)
  available_verbs_api_roles_path: function(options) {
  return Utils.build_path(1, ["/api/roles/available_verbs"], arguments)
  },
// system_events => /systems/:system_id/events(.:format)
  system_events_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/events"], arguments)
  },
// notices_dashboard_index => /dashboard/notices(.:format)
  notices_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/notices"], arguments)
  },
// edit_api_template_parameter => /api/templates/:template_id/parameters/:id/edit(.:format)
  edit_api_template_parameter_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/parameters/", "/edit"], arguments)
  },
// default_label_organization_environments => /organizations/:organization_id/environments/default_label(.:format)
  default_label_organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments/default_label"], arguments)
  },
// new_api_role => /api/roles/new(.:format)
  new_api_role_path: function(options) {
  return Utils.build_path(1, ["/api/roles/new"], arguments)
  },
// role_permission_update => /roles/:role_id/permission/:permission_id/update_permission(.:format)
  role_permission_update_path: function(_role_id, _permission_id, options) {
  return Utils.build_path(3, ["/roles/", "/permission/", "/update_permission"], arguments)
  },
// dashboard_index => /dashboard(.:format)
  dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard"], arguments)
  },
// new_activation_key => /activation_keys/new(.:format)
  new_activation_key_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/new"], arguments)
  },
// edit_api_template_distribution => /api/templates/:template_id/distributions/:id/edit(.:format)
  edit_api_template_distribution_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/distributions/", "/edit"], arguments)
  },
// new_api_template => /api/templates/new(.:format)
  new_api_template_path: function(options) {
  return Utils.build_path(1, ["/api/templates/new"], arguments)
  },
// show_custom_info => /custom_info/:informable_type/:informable_id/:keyname(.:format)
  show_custom_info_path: function(_informable_type, _informable_id, _keyname, options) {
  return Utils.build_path(4, ["/custom_info/", "/", "/"], arguments)
  },
// favorite_search_index => /search/favorite(.:format)
  favorite_search_index_path: function(options) {
  return Utils.build_path(1, ["/search/favorite"], arguments)
  },
// gpg_key => /gpg_keys/:id(.:format)
  gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/gpg_keys/"], arguments)
  },
// products_content_search_index => /content_search/products(.:format)
  products_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/products"], arguments)
  },
// enable_api_organization_product_repository_set => /api/organizations/:organization_id/products/:product_id/repository_sets/:id/enable(.:format)
  enable_api_organization_product_repository_set_path: function(_organization_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/api/organizations/", "/products/", "/repository_sets/", "/enable"], arguments)
  },
// system_group_packages => /system_groups/:system_group_id/packages(.:format)
  system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/packages"], arguments)
  },
// organization => /organizations/:id(.:format)
  organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/"], arguments)
  },
// repo_packages_content_search_index => /content_search/repo_packages(.:format)
  repo_packages_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/repo_packages"], arguments)
  },
// history_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/history(.:format)
  history_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/history"], arguments)
  },
// sync_management_index => /sync_management/index(.:format)
  sync_management_index_path: function(options) {
  return Utils.build_path(1, ["/sync_management/index"], arguments)
  },
// status_distributor_events => /distributors/:distributor_id/events/status(.:format)
  status_distributor_events_path: function(_distributor_id, options) {
  return Utils.build_path(2, ["/distributors/", "/events/status"], arguments)
  },
// auto_complete_search_providers => /providers/auto_complete_search(.:format)
  auto_complete_search_providers_path: function(options) {
  return Utils.build_path(1, ["/providers/auto_complete_search"], arguments)
  },
// edit_content_search => /content_search/:id/edit(.:format)
  edit_content_search_path: function(_id, options) {
  return Utils.build_path(2, ["/content_search/", "/edit"], arguments)
  },
// about => /about(.:format)
  about_path: function(options) {
  return Utils.build_path(1, ["/about"], arguments)
  },
// new_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/new(.:format)
  new_provider_product_repository_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/repositories/new"], arguments)
  },
// new_api_consumer => /api/consumers/new(.:format)
  new_api_consumer_path: function(options) {
  return Utils.build_path(1, ["/api/consumers/new"], arguments)
  },
// products_subscription => /subscriptions/:id/products(.:format)
  products_subscription_path: function(_id, options) {
  return Utils.build_path(2, ["/subscriptions/", "/products"], arguments)
  },
// system_templates_promotion => /promotions/:id/system_templates(.:format)
  system_templates_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/system_templates"], arguments)
  },
// releases_api_system => /api/systems/:id/releases(.:format)
  releases_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/releases"], arguments)
  },
// enable_repo => /repositories/:id/enable_repo(.:format)
  enable_repo_path: function(_id, options) {
  return Utils.build_path(2, ["/repositories/", "/enable_repo"], arguments)
  },
// provider_product => /providers/:provider_id/products/:id(.:format)
  provider_product_path: function(_provider_id, _id, options) {
  return Utils.build_path(3, ["/providers/", "/products/"], arguments)
  },
// search_index => /search(.:format)
  search_index_path: function(options) {
  return Utils.build_path(1, ["/search"], arguments)
  },
// more_packages_system_system_packages => /systems/:system_id/system_packages/more_packages(.:format)
  more_packages_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/more_packages"], arguments)
  },
// new_changeset => /changesets/new(.:format)
  new_changeset_path: function(options) {
  return Utils.build_path(1, ["/changesets/new"], arguments)
  },
// history_items_subscriptions => /subscriptions/history_items(.:format)
  history_items_subscriptions_path: function(options) {
  return Utils.build_path(1, ["/subscriptions/history_items"], arguments)
  },
// filelist_package => /packages/:id/filelist(.:format)
  filelist_package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/", "/filelist"], arguments)
  },
// discover_provider => /providers/:id/discover(.:format)
  discover_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/discover"], arguments)
  },
// system_erratum => /systems/:system_id/errata/:id(.:format)
  system_erratum_path: function(_system_id, _id, options) {
  return Utils.build_path(3, ["/systems/", "/errata/"], arguments)
  },
// promote_api_content_view => /api/content_views/:id/promote(.:format)
  promote_api_content_view_path: function(_id, options) {
  return Utils.build_path(2, ["/api/content_views/", "/promote"], arguments)
  },
// more_items_system_group_events => /system_groups/:system_group_id/events/more_items(.:format)
  more_items_system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/events/more_items"], arguments)
  },
// user_session_logout => /user_session/logout(.:format)
  user_session_logout_path: function(options) {
  return Utils.build_path(1, ["/user_session/logout"], arguments)
  },
// facts_system => /systems/:id/facts(.:format)
  facts_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/facts"], arguments)
  },
// clone_content_view_definition => /content_view_definitions/:id/clone(.:format)
  clone_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/", "/clone"], arguments)
  },
// update_roles_user => /users/:id/update_roles(.:format)
  update_roles_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/update_roles"], arguments)
  },
// distributor_event => /distributors/:distributor_id/events/:id(.:format)
  distributor_event_path: function(_distributor_id, _id, options) {
  return Utils.build_path(3, ["/distributors/", "/events/"], arguments)
  },
// items_systems => /systems/items(.:format)
  items_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/items"], arguments)
  },
// new_api_changeset_package => /api/changesets/:changeset_id/packages/new(.:format)
  new_api_changeset_package_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/packages/new"], arguments)
  },
// download_distributor => /distributors/:id/download(.:format)
  download_distributor_path: function(_id, options) {
  return Utils.build_path(2, ["/distributors/", "/download"], arguments)
  },
// bulk_content_install_systems => /systems/bulk_content_install(.:format)
  bulk_content_install_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_content_install"], arguments)
  },
// environments => /environments(.:format)
  environments_path: function(options) {
  return Utils.build_path(1, ["/environments"], arguments)
  },
// auto_complete_system_groups => /system_groups/auto_complete(.:format)
  auto_complete_system_groups_path: function(options) {
  return Utils.build_path(1, ["/system_groups/auto_complete"], arguments)
  },
// edit_gpg_key => /gpg_keys/:id/edit(.:format)
  edit_gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/gpg_keys/", "/edit"], arguments)
  },
// new_api_changeset_distribution => /api/changesets/:changeset_id/distributions/new(.:format)
  new_api_changeset_distribution_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/distributions/new"], arguments)
  },
// destroy_systems_system_group => /system_groups/:id/destroy_systems(.:format)
  destroy_systems_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/destroy_systems"], arguments)
  },
// auto_complete_search_activation_keys => /activation_keys/auto_complete_search(.:format)
  auto_complete_search_activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/auto_complete_search"], arguments)
  },
// organization_environments => /organizations/:organization_id/environments(.:format)
  organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments"], arguments)
  },
// add_subscriptions_activation_key => /activation_keys/:id/add_subscriptions(.:format)
  add_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/add_subscriptions"], arguments)
  },
// edit_password_reset => /password_resets/:id/edit(.:format)
  edit_password_reset_path: function(_id, options) {
  return Utils.build_path(2, ["/password_resets/", "/edit"], arguments)
  },
// status_content_view_definition => /content_view_definitions/:id/status(.:format)
  status_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/", "/status"], arguments)
  },
// status_system_group_errata => /system_groups/:system_group_id/errata/status(.:format)
  status_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/errata/status"], arguments)
  },
// password_resets => /password_resets(.:format)
  password_resets_path: function(options) {
  return Utils.build_path(1, ["/password_resets"], arguments)
  },
// distributions_promotion => /promotions/:id/distributions(.:format)
  distributions_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/distributions"], arguments)
  },
// gpg_key_content_api_repository => /api/repositories/:id/gpg_key_content(.:format)
  gpg_key_content_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/gpg_key_content"], arguments)
  },
// new_user_session => /user_session/new(.:format)
  new_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/new"], arguments)
  },
// download_system_template => /system_templates/:id/download(.:format)
  download_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/download"], arguments)
  },
// new_subscription => /subscriptions/new(.:format)
  new_subscription_path: function(options) {
  return Utils.build_path(1, ["/subscriptions/new"], arguments)
  },
// new_sync_plan => /sync_plans/new(.:format)
  new_sync_plan_path: function(options) {
  return Utils.build_path(1, ["/sync_plans/new"], arguments)
  },
// edit_api_system_packages => /api/systems/:system_id/packages/edit(.:format)
  edit_api_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/packages/edit"], arguments)
  },
// report_api_environment_systems => /api/environments/:environment_id/systems/report(.:format)
  report_api_environment_systems_path: function(_environment_id, options) {
  return Utils.build_path(2, ["/api/environments/", "/systems/report"], arguments)
  },
// tasks_api_organization_systems => /api/organizations/:organization_id/systems/tasks(.:format)
  tasks_api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/systems/tasks"], arguments)
  },
// delete_manifest_api_provider => /api/providers/:id/delete_manifest(.:format)
  delete_manifest_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/delete_manifest"], arguments)
  },
// new_repository => /repositories/new(.:format)
  new_repository_path: function(options) {
  return Utils.build_path(1, ["/repositories/new"], arguments)
  },
// add_system_groups_activation_key => /activation_keys/:id/add_system_groups(.:format)
  add_system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/add_system_groups"], arguments)
  },
// new_api_provider => /api/providers/new(.:format)
  new_api_provider_path: function(options) {
  return Utils.build_path(1, ["/api/providers/new"], arguments)
  },
// edit_api_activation_key => /api/activation_keys/:id/edit(.:format)
  edit_api_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/api/activation_keys/", "/edit"], arguments)
  },
// repositories_api_organization_environment => /api/organizations/:organization_id/environments/:id/repositories(.:format)
  repositories_api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/environments/", "/repositories"], arguments)
  },
// activation_keys => /activation_keys(.:format)
  activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys"], arguments)
  },
// apply_changeset => /changesets/:id/apply(.:format)
  apply_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/apply"], arguments)
  },
// items_organizations => /organizations/items(.:format)
  items_organizations_path: function(options) {
  return Utils.build_path(1, ["/organizations/items"], arguments)
  },
// activation_key => /activation_keys/:id(.:format)
  activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/"], arguments)
  },
// new_api_template_package => /api/templates/:template_id/packages/new(.:format)
  new_api_template_package_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/packages/new"], arguments)
  },
// system_templates_organization_environment => /organizations/:organization_id/environments/:id/system_templates(.:format)
  system_templates_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/", "/system_templates"], arguments)
  },
// system_template => /system_templates/:id(.:format)
  system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/"], arguments)
  },
// new_system_template => /system_templates/new(.:format)
  new_system_template_path: function(options) {
  return Utils.build_path(1, ["/system_templates/new"], arguments)
  },
// errata_dashboard_index => /dashboard/errata(.:format)
  errata_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/errata"], arguments)
  },
// edit_api_role => /api/roles/:id/edit(.:format)
  edit_api_role_path: function(_id, options) {
  return Utils.build_path(2, ["/api/roles/", "/edit"], arguments)
  },
// auto_complete_search_roles => /roles/auto_complete_search(.:format)
  auto_complete_search_roles_path: function(options) {
  return Utils.build_path(1, ["/roles/auto_complete_search"], arguments)
  },
// product => /products/:id(.:format)
  product_path: function(_id, options) {
  return Utils.build_path(2, ["/products/"], arguments)
  },
// status_system_events => /systems/:system_id/events/status(.:format)
  status_system_events_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/events/status"], arguments)
  },
// new_api_template_package_group_category => /api/templates/:template_id/package_group_categories/new(.:format)
  new_api_template_package_group_category_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/package_group_categories/new"], arguments)
  },
// notices_details => /notices/:id/details(.:format)
  notices_details_path: function(_id, options) {
  return Utils.build_path(2, ["/notices/", "/details"], arguments)
  },
// edit_activation_key => /activation_keys/:id/edit(.:format)
  edit_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/edit"], arguments)
  },
// edit_environment => /environments/:id/edit(.:format)
  edit_environment_path: function(_id, options) {
  return Utils.build_path(2, ["/environments/", "/edit"], arguments)
  },
// edit_api_template => /api/templates/:id/edit(.:format)
  edit_api_template_path: function(_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/edit"], arguments)
  },
// content_views_promotion => /promotions/:id/content_views(.:format)
  content_views_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/content_views"], arguments)
  },
// packages_content_search_index => /content_search/packages(.:format)
  packages_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/packages"], arguments)
  },
// disable_api_organization_product_repository_set => /api/organizations/:organization_id/products/:product_id/repository_sets/:id/disable(.:format)
  disable_api_organization_product_repository_set_path: function(_organization_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/api/organizations/", "/products/", "/repository_sets/", "/disable"], arguments)
  },
// repo_errata_content_search_index => /content_search/repo_errata(.:format)
  repo_errata_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/repo_errata"], arguments)
  },
// more_events_distributor_events => /distributors/:distributor_id/events/more_events(.:format)
  more_events_distributor_events_path: function(_distributor_id, options) {
  return Utils.build_path(2, ["/distributors/", "/events/more_events"], arguments)
  },
// refresh_products_providers => /providers/refresh_products(.:format)
  refresh_products_providers_path: function(options) {
  return Utils.build_path(1, ["/providers/refresh_products"], arguments)
  },
// role_permission_destroy => /roles/:role_id/permission/:permission_id/destroy_permission(.:format)
  role_permission_destroy_path: function(_role_id, _permission_id, options) {
  return Utils.build_path(3, ["/roles/", "/permission/", "/destroy_permission"], arguments)
  },
// system_event => /systems/:system_id/events/:id(.:format)
  system_event_path: function(_system_id, _id, options) {
  return Utils.build_path(3, ["/systems/", "/events/"], arguments)
  },
// edit_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/edit(.:format)
  edit_provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/providers/", "/products/", "/repositories/", "/edit"], arguments)
  },
// edit_api_consumer => /api/consumers/:id/edit(.:format)
  edit_api_consumer_path: function(_id, options) {
  return Utils.build_path(2, ["/api/consumers/", "/edit"], arguments)
  },
// status_system_system_packages => /systems/:system_id/system_packages/status(.:format)
  status_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/status"], arguments)
  },
// consumers_subscription => /subscriptions/:id/consumers(.:format)
  consumers_subscription_path: function(_id, options) {
  return Utils.build_path(2, ["/subscriptions/", "/consumers"], arguments)
  },
// enabled_repos_api_system => /api/systems/:id/enabled_repos(.:format)
  enabled_repos_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/enabled_repos"], arguments)
  },
// roles => /roles(.:format)
  roles_path: function(options) {
  return Utils.build_path(1, ["/roles"], arguments)
  },
// items_providers => /providers/items(.:format)
  items_providers_path: function(options) {
  return Utils.build_path(1, ["/providers/items"], arguments)
  },
// history_search_index => /search/history(.:format)
  history_search_index_path: function(options) {
  return Utils.build_path(1, ["/search/history"], arguments)
  },
// new_api_organization => /api/organizations/new(.:format)
  new_api_organization_path: function(options) {
  return Utils.build_path(1, ["/api/organizations/new"], arguments)
  },
// edit_system => /systems/:id/edit(.:format)
  edit_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/edit"], arguments)
  },
// edit_changeset => /changesets/:id/edit(.:format)
  edit_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/edit"], arguments)
  },
// dependencies_package => /packages/:id/dependencies(.:format)
  dependencies_package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/", "/dependencies"], arguments)
  },
// cancel_discovery_provider => /providers/:id/cancel_discovery(.:format)
  cancel_discovery_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/cancel_discovery"], arguments)
  },
// new_content_view => /content_views/new(.:format)
  new_content_view_path: function(options) {
  return Utils.build_path(1, ["/content_views/new"], arguments)
  },
// refresh_api_content_view => /api/content_views/:id/refresh(.:format)
  refresh_api_content_view_path: function(_id, options) {
  return Utils.build_path(2, ["/api/content_views/", "/refresh"], arguments)
  },
// auto_complete_search_users => /users/auto_complete_search(.:format)
  auto_complete_search_users_path: function(options) {
  return Utils.build_path(1, ["/users/auto_complete_search"], arguments)
  },
// items_system_group_events => /system_groups/:system_group_id/events/items(.:format)
  items_system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/events/items"], arguments)
  },
// content_views_organization_environment => /organizations/:organization_id/environments/:id/content_views(.:format)
  content_views_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/", "/content_views"], arguments)
  },
// sync_management_manage => /sync_management/manage(.:format)
  sync_management_manage_path: function(options) {
  return Utils.build_path(1, ["/sync_management/manage"], arguments)
  },
// system_groups_system => /systems/:id/system_groups(.:format)
  system_groups_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_groups"], arguments)
  },
// views_content_view_definition => /content_view_definitions/:id/views(.:format)
  views_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/", "/views"], arguments)
  },
// update_locale_user => /users/:id/update_locale(.:format)
  update_locale_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/update_locale"], arguments)
  },
// edit_distributor => /distributors/:id/edit(.:format)
  edit_distributor_path: function(_id, options) {
  return Utils.build_path(2, ["/distributors/", "/edit"], arguments)
  },
// env_items_systems => /systems/env_items(.:format)
  env_items_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/env_items"], arguments)
  },
// edit_api_changeset_package => /api/changesets/:changeset_id/packages/:id/edit(.:format)
  edit_api_changeset_package_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/packages/", "/edit"], arguments)
  },
// operations => /operations(.:format)
  operations_path: function(options) {
  return Utils.build_path(1, ["/operations"], arguments)
  },
// auto_complete_distributors => /distributors/auto_complete(.:format)
  auto_complete_distributors_path: function(options) {
  return Utils.build_path(1, ["/distributors/auto_complete"], arguments)
  },
// bulk_content_update_systems => /systems/bulk_content_update(.:format)
  bulk_content_update_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_content_update"], arguments)
  },
// package => /packages/:id(.:format)
  package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/"], arguments)
  },
// validate_name_system_groups => /system_groups/validate_name(.:format)
  validate_name_system_groups_path: function(options) {
  return Utils.build_path(1, ["/system_groups/validate_name"], arguments)
  },
// auto_complete_search_sync_plans => /sync_plans/auto_complete_search(.:format)
  auto_complete_search_sync_plans_path: function(options) {
  return Utils.build_path(1, ["/sync_plans/auto_complete_search"], arguments)
  },
// edit_api_changeset_distribution => /api/changesets/:changeset_id/distributions/:id/edit(.:format)
  edit_api_changeset_distribution_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/distributions/", "/edit"], arguments)
  },
// items_activation_keys => /activation_keys/items(.:format)
  items_activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/items"], arguments)
  },
// filelist_repository_distribution => /repositories/:repository_id/distributions/:id/filelist(.:format)
  filelist_repository_distribution_path: function(_repository_id, _id, options) {
  return Utils.build_path(3, ["/repositories/", "/distributions/", "/filelist"], arguments)
  },
// password_reset => /password_resets/:id(.:format)
  password_reset_path: function(_id, options) {
  return Utils.build_path(2, ["/password_resets/"], arguments)
  },
// sync_management => /sync_management/:id(.:format)
  sync_management_path: function(_id, options) {
  return Utils.build_path(2, ["/sync_management/"], arguments)
  },
// new_organization_environment => /organizations/:organization_id/environments/new(.:format)
  new_organization_environment_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments/new"], arguments)
  },
// search_api_repository_packages => /api/repositories/:repository_id/packages/search(.:format)
  search_api_repository_packages_path: function(_repository_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/packages/search"], arguments)
  },
// users => /users(.:format)
  users_path: function(options) {
  return Utils.build_path(1, ["/users"], arguments)
  },
// content_content_view_definition => /content_view_definitions/:id/content(.:format)
  content_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/", "/content"], arguments)
  },
// destroy_custom_info => /custom_info/:informable_type/:informable_id/:keyname(.:format)
  destroy_custom_info_path: function(_informable_type, _informable_id, _keyname, options) {
  return Utils.build_path(4, ["/custom_info/", "/", "/"], arguments)
  },
// notices => /notices(.:format)
  notices_path: function(options) {
  return Utils.build_path(1, ["/notices"], arguments)
  },
// enable_api_repository => /api/repositories/:id/enable(.:format)
  enable_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/enable"], arguments)
  },
// edit_sync_plan => /sync_plans/:id/edit(.:format)
  edit_sync_plan_path: function(_id, options) {
  return Utils.build_path(2, ["/sync_plans/", "/edit"], arguments)
  },
// validate_system_template => /system_templates/:id/validate(.:format)
  validate_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/validate"], arguments)
  },
// repositories_api_environment_product => /api/environments/:environment_id/products/:id/repositories(.:format)
  repositories_api_environment_product_path: function(_environment_id, _id, options) {
  return Utils.build_path(3, ["/api/environments/", "/products/", "/repositories"], arguments)
  },
// system_groups_api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id/system_groups(.:format)
  system_groups_api_organization_activation_key_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/activation_keys/", "/system_groups"], arguments)
  },
// refresh_products_api_provider => /api/providers/:id/refresh_products(.:format)
  refresh_products_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/refresh_products"], arguments)
  },
// content_api_gpg_key => /api/gpg_keys/:id/content(.:format)
  content_api_gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/api/gpg_keys/", "/content"], arguments)
  },
// new_api_organization_system_group_packages => /api/organizations/:organization_id/system_groups/:system_group_id/packages/new(.:format)
  new_api_organization_system_group_packages_path: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/packages/new"], arguments)
  },
// repositories => /repositories(.:format)
  repositories_path: function(options) {
  return Utils.build_path(1, ["/repositories"], arguments)
  },
// edit_api_provider => /api/providers/:id/edit(.:format)
  edit_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/edit"], arguments)
  },
// edit_repository => /repositories/:id/edit(.:format)
  edit_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/repositories/", "/edit"], arguments)
  },
// remove_system_groups_activation_key => /activation_keys/:id/remove_system_groups(.:format)
  remove_system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/remove_system_groups"], arguments)
  },
// new_organization => /organizations/new(.:format)
  new_organization_path: function(options) {
  return Utils.build_path(1, ["/organizations/new"], arguments)
  },
// status_changeset => /changesets/:id/status(.:format)
  status_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/status"], arguments)
  },
// new_api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/new(.:format)
  new_api_organization_sync_plan_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/sync_plans/new"], arguments)
  },
// edit_api_template_package => /api/templates/:template_id/packages/:id/edit(.:format)
  edit_api_template_package_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/packages/", "/edit"], arguments)
  },
// auto_complete_products => /products/auto_complete(.:format)
  auto_complete_products_path: function(options) {
  return Utils.build_path(1, ["/products/auto_complete"], arguments)
  },
// default_label_organizations => /organizations/default_label(.:format)
  default_label_organizations_path: function(options) {
  return Utils.build_path(1, ["/organizations/default_label"], arguments)
  },
// edit_system_template => /system_templates/:id/edit(.:format)
  edit_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/edit"], arguments)
  },
// roles_show_permission => /roles/show_permission(.:format)
  roles_show_permission_path: function(options) {
  return Utils.build_path(1, ["/roles/show_permission"], arguments)
  },
// promotions_dashboard_index => /dashboard/promotions(.:format)
  promotions_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/promotions"], arguments)
  },
// items_roles => /roles/items(.:format)
  items_roles_path: function(options) {
  return Utils.build_path(1, ["/roles/items"], arguments)
  },
// more_events_system_events => /systems/:system_id/events/more_events(.:format)
  more_events_system_events_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/events/more_events"], arguments)
  },
// edit_api_template_package_group_category => /api/templates/:template_id/package_group_categories/:id/edit(.:format)
  edit_api_template_package_group_category_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/package_group_categories/", "/edit"], arguments)
  },
// new_system_group => /system_groups/new(.:format)
  new_system_group_path: function(options) {
  return Utils.build_path(1, ["/system_groups/new"], arguments)
  },
// auto_complete_search_gpg_keys => /gpg_keys/auto_complete_search(.:format)
  auto_complete_search_gpg_keys_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys/auto_complete_search"], arguments)
  },
// providers => /providers(.:format)
  providers_path: function(options) {
  return Utils.build_path(1, ["/providers"], arguments)
  },
// rails_info_properties => /rails/info/properties(.:format)
  rails_info_properties_path: function(options) {
  return Utils.build_path(1, ["/rails/info/properties"], arguments)
  },
// product_comps_system_templates => /system_templates/product_comps(.:format)
  product_comps_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/product_comps"], arguments)
  },
// packages_items_content_search_index => /content_search/packages_items(.:format)
  packages_items_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/packages_items"], arguments)
  },
// repo_compare_packages_content_search_index => /content_search/repo_compare_packages(.:format)
  repo_compare_packages_content_search_index_path: function(options) {
  return Utils.build_path(1, ["/content_search/repo_compare_packages"], arguments)
  },
// new_product => /products/new(.:format)
  new_product_path: function(options) {
  return Utils.build_path(1, ["/products/new"], arguments)
  },
// default_label_provider_products => /providers/:provider_id/products/default_label(.:format)
  default_label_provider_products_path: function(_provider_id, options) {
  return Utils.build_path(2, ["/providers/", "/products/default_label"], arguments)
  },
// items_distributor_events => /distributors/:distributor_id/events/items(.:format)
  items_distributor_events_path: function(_distributor_id, options) {
  return Utils.build_path(2, ["/distributors/", "/events/items"], arguments)
  },
// provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id(.:format)
  provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/providers/", "/products/", "/repositories/"], arguments)
  },
// new_role => /roles/new(.:format)
  new_role_path: function(options) {
  return Utils.build_path(1, ["/roles/new"], arguments)
  },
// add_system_system_packages => /systems/:system_id/system_packages/add(.:format)
  add_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/add"], arguments)
  },
// notices_auto_complete_search => /notices/auto_complete_search(.:format)
  notices_auto_complete_search_path: function(options) {
  return Utils.build_path(1, ["/notices/auto_complete_search"], arguments)
  },
// items_system_errata => /systems/:system_id/errata/items(.:format)
  items_system_errata_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/errata/items"], arguments)
  },
// distributor_events => /distributors/:distributor_id/events(.:format)
  distributor_events_path: function(_distributor_id, options) {
  return Utils.build_path(2, ["/distributors/", "/events"], arguments)
  },
// gpg_keys => /gpg_keys(.:format)
  gpg_keys_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys"], arguments)
  },
// items_subscriptions => /subscriptions/items(.:format)
  items_subscriptions_path: function(options) {
  return Utils.build_path(1, ["/subscriptions/items"], arguments)
  },
// system_groups_api_system => /api/systems/:id/system_groups(.:format)
  system_groups_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/system_groups"], arguments)
  },
// create_custom_info => /custom_info/:informable_type/:informable_id(.:format)
  create_custom_info_path: function(_informable_type, _informable_id, options) {
  return Utils.build_path(3, ["/custom_info/", "/"], arguments)
  },
// redhat_provider_providers => /providers/redhat_provider(.:format)
  redhat_provider_providers_path: function(options) {
  return Utils.build_path(1, ["/providers/redhat_provider"], arguments)
  },
// edit_api_organization => /api/organizations/:id/edit(.:format)
  edit_api_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/edit"], arguments)
  },
// edit_content_view => /content_views/:id/edit(.:format)
  edit_content_view_path: function(_id, options) {
  return Utils.build_path(2, ["/content_views/", "/edit"], arguments)
  },
// subscriptions_system => /systems/:id/subscriptions(.:format)
  subscriptions_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/subscriptions"], arguments)
  },
// auto_complete_library_packages => /packages/auto_complete_library(.:format)
  auto_complete_library_packages_path: function(options) {
  return Utils.build_path(1, ["/packages/auto_complete_library"], arguments)
  },
// products_repos_provider => /providers/:id/products_repos(.:format)
  products_repos_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/products_repos"], arguments)
  },
// email_logins_password_resets => /password_resets/email_logins(.:format)
  email_logins_password_resets_path: function(options) {
  return Utils.build_path(1, ["/password_resets/email_logins"], arguments)
  },
// add_system_groups_system => /systems/:id/add_system_groups(.:format)
  add_system_groups_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/add_system_groups"], arguments)
  },
// items_users => /users/items(.:format)
  items_users_path: function(options) {
  return Utils.build_path(1, ["/users/items"], arguments)
  },
// system_group_events => /system_groups/:system_group_id/events(.:format)
  system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/events"], arguments)
  },
// new_api_changeset_product => /api/changesets/:changeset_id/products/new(.:format)
  new_api_changeset_product_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/products/new"], arguments)
  },
// environments_systems => /systems/environments(.:format)
  environments_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/environments"], arguments)
  },
// publish_setup_content_view_definition => /content_view_definitions/:id/publish_setup(.:format)
  publish_setup_content_view_definition_path: function(_id, options) {
  return Utils.build_path(2, ["/content_view_definitions/", "/publish_setup"], arguments)
  },
// update_preference_user => /users/:id/update_preference(.:format)
  update_preference_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/update_preference"], arguments)
  },
// subscriptions_distributor => /distributors/:id/subscriptions(.:format)
  subscriptions_distributor_path: function(_id, options) {
  return Utils.build_path(2, ["/distributors/", "/subscriptions"], arguments)
  }}
;
  
  window.KT.routes.options = {
    prefix: '',
    default_format: '',
  };


})();
