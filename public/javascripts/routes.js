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
// new_owner => /owners/new(.:format)
  new_owner_path: function(options) {
  return Utils.build_path(1, ["/owners/new"], arguments)
  },
// env_items_systems => /systems/env_items(.:format)
  env_items_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/env_items"], arguments)
  },
// dependencies_api_changeset => /api/changesets/:id/dependencies(.:format)
  dependencies_api_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/dependencies"], arguments)
  },
// edit_environment => /environments/:id/edit(.:format)
  edit_environment_path: function(_id, options) {
  return Utils.build_path(2, ["/environments/", "/edit"], arguments)
  },
// role_create_permission => /roles/:role_id/create_permission(.:format)
  role_create_permission_path: function(_role_id, options) {
  return Utils.build_path(2, ["/roles/", "/create_permission"], arguments)
  },
// edit_api_activation_key => /api/activation_keys/:id/edit(.:format)
  edit_api_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/api/activation_keys/", "/edit"], arguments)
  },
// new_api_template_repository => /api/templates/:template_id/repositories/new(.:format)
  new_api_template_repository_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/repositories/new"], arguments)
  },
// bulk_content_update_systems => /systems/bulk_content_update(.:format)
  bulk_content_update_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_content_update"], arguments)
  },
// new_api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/new(.:format)
  new_api_organization_sync_plan_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/sync_plans/new"], arguments)
  },
// promotion_details_system_template => /system_templates/:id/promotion_details(.:format)
  promotion_details_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/promotion_details"], arguments)
  },
// repositories_api_organization_product => /api/organizations/:organization_id/products/:id/repositories(.:format)
  repositories_api_organization_product_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/products/", "/repositories"], arguments)
  },
// edit_api_changeset_erratum => /api/changesets/:changeset_id/errata/:id/edit(.:format)
  edit_api_changeset_erratum_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/errata/", "/edit"], arguments)
  },
// tasks_api_organization_systems => /api/organizations/:organization_id/systems/tasks(.:format)
  tasks_api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/systems/tasks"], arguments)
  },
// lock_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/lock(.:format)
  lock_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/lock"], arguments)
  },
// system_templates_promotion => /promotions/:id/system_templates(.:format)
  system_templates_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/system_templates"], arguments)
  },
// edit_api_changeset_template => /api/changesets/:changeset_id/templates/:id/edit(.:format)
  edit_api_changeset_template_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/templates/", "/edit"], arguments)
  },
// status_system_group_errata => /system_groups/:system_group_id/errata/status(.:format)
  status_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/errata/status"], arguments)
  },
// organizations => /organizations(.:format)
  organizations_path: function(options) {
  return Utils.build_path(1, ["/organizations"], arguments)
  },
// items_users => /users/items(.:format)
  items_users_path: function(options) {
  return Utils.build_path(1, ["/users/items"], arguments)
  },
// new_api_repository_package => /api/repositories/:repository_id/packages/new(.:format)
  new_api_repository_package_path: function(_repository_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/packages/new"], arguments)
  },
// update_content_system_template => /system_templates/:id/update_content(.:format)
  update_content_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/update_content"], arguments)
  },
// update_preference_user => /users/:id/update_preference(.:format)
  update_preference_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/update_preference"], arguments)
  },
// name_changeset => /changesets/:id/name(.:format)
  name_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/name"], arguments)
  },
// enabled_repos_api_system => /api/systems/:id/enabled_repos(.:format)
  enabled_repos_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/enabled_repos"], arguments)
  },
// destroy_favorite_search_index => /search/favorite/:id(.:format)
  destroy_favorite_search_index_path: function(_id, options) {
  return Utils.build_path(2, ["/search/favorite/"], arguments)
  },
// sync_complete_api_repositories => /api/repositories/sync_complete(.:format)
  sync_complete_api_repositories_path: function(options) {
  return Utils.build_path(1, ["/api/repositories/sync_complete"], arguments)
  },
// list_changesets => /changesets/list(.:format)
  list_changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets/list"], arguments)
  },
// auto_complete_system_groups => /system_groups/auto_complete(.:format)
  auto_complete_system_groups_path: function(options) {
  return Utils.build_path(1, ["/system_groups/auto_complete"], arguments)
  },
// organization => /organizations/:id(.:format)
  organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/"], arguments)
  },
// auto_complete_search_system_templates => /system_templates/auto_complete_search(.:format)
  auto_complete_search_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/auto_complete_search"], arguments)
  },
// new_system_group => /system_groups/new(.:format)
  new_system_group_path: function(options) {
  return Utils.build_path(1, ["/system_groups/new"], arguments)
  },
// applied_subscriptions_activation_key => /activation_keys/:id/applied_subscriptions(.:format)
  applied_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/applied_subscriptions"], arguments)
  },
// notices_get_new => /notices/get_new(.:format)
  notices_get_new_path: function(options) {
  return Utils.build_path(1, ["/notices/get_new"], arguments)
  },
// new_user => /users/new(.:format)
  new_user_path: function(options) {
  return Utils.build_path(1, ["/users/new"], arguments)
  },
// provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id(.:format)
  provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/providers/", "/products/", "/repositories/"], arguments)
  },
// notices_dashboard_index => /dashboard/notices(.:format)
  notices_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/notices"], arguments)
  },
// distributions_promotion => /promotions/:id/distributions(.:format)
  distributions_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/distributions"], arguments)
  },
// redhat_provider_providers => /providers/redhat_provider(.:format)
  redhat_provider_providers_path: function(options) {
  return Utils.build_path(1, ["/providers/redhat_provider"], arguments)
  },
// show_user_session => /user_session(.:format)
  show_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session"], arguments)
  },
// status_system_events => /systems/:system_id/events/status(.:format)
  status_system_events_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/events/status"], arguments)
  },
// download_debug_certificate_organization => /organizations/:id/download_debug_certificate(.:format)
  download_debug_certificate_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/download_debug_certificate"], arguments)
  },
// user_session => /user_session(.:format)
  user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session"], arguments)
  },
// verbs_and_scopes => /roles/:organization_id/resource_type/verbs_and_scopes(.:format)
  verbs_and_scopes_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/roles/", "/resource_type/verbs_and_scopes"], arguments)
  },
// auto_complete_products_repos_filters => /filters/auto_complete_products_repos(.:format)
  auto_complete_products_repos_filters_path: function(options) {
  return Utils.build_path(1, ["/filters/auto_complete_products_repos"], arguments)
  },
// import_owner => /owners/:id/import(.:format)
  import_owner_path: function(_id, options) {
  return Utils.build_path(2, ["/owners/", "/import"], arguments)
  },
// product_create_api_provider => /api/providers/:id/product_create(.:format)
  product_create_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/product_create"], arguments)
  },
// update_products_filter => /filters/:id/update_products(.:format)
  update_products_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/update_products"], arguments)
  },
// import_api_templates => /api/templates/import(.:format)
  import_api_templates_path: function(options) {
  return Utils.build_path(1, ["/api/templates/import"], arguments)
  },
// new_provider => /providers/new(.:format)
  new_provider_path: function(options) {
  return Utils.build_path(1, ["/providers/new"], arguments)
  },
// system_event => /systems/:system_id/events/:id(.:format)
  system_event_path: function(_system_id, _id, options) {
  return Utils.build_path(3, ["/systems/", "/events/"], arguments)
  },
// edit_api_template_product => /api/templates/:template_id/products/:id/edit(.:format)
  edit_api_template_product_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/products/", "/edit"], arguments)
  },
// status_system_system_packages => /systems/:system_id/system_packages/status(.:format)
  status_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/status"], arguments)
  },
// sync_management_sync_status => /sync_management/sync_status(.:format)
  sync_management_sync_status_path: function(options) {
  return Utils.build_path(1, ["/sync_management/sync_status"], arguments)
  },
// new_filter => /filters/new(.:format)
  new_filter_path: function(options) {
  return Utils.build_path(1, ["/filters/new"], arguments)
  },
// auto_complete_library_packages => /packages/auto_complete_library(.:format)
  auto_complete_library_packages_path: function(options) {
  return Utils.build_path(1, ["/packages/auto_complete_library"], arguments)
  },
// edit_system => /systems/:id/edit(.:format)
  edit_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/edit"], arguments)
  },
// owner => /owners/:id(.:format)
  owner_path: function(_id, options) {
  return Utils.build_path(2, ["/owners/"], arguments)
  },
// edit_api_template_package_group => /api/templates/:template_id/package_groups/:id/edit(.:format)
  edit_api_template_package_group_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/package_groups/", "/edit"], arguments)
  },
// system_groups_system => /systems/:id/system_groups(.:format)
  system_groups_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_groups"], arguments)
  },
// edit_owner => /owners/:id/edit(.:format)
  edit_owner_path: function(_id, options) {
  return Utils.build_path(2, ["/owners/", "/edit"], arguments)
  },
// environments_systems => /systems/environments(.:format)
  environments_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/environments"], arguments)
  },
// object_system_template => /system_templates/:id/object(.:format)
  object_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/object"], arguments)
  },
// edit_api_template_repository => /api/templates/:template_id/repositories/:id/edit(.:format)
  edit_api_template_repository_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/repositories/", "/edit"], arguments)
  },
// bulk_content_remove_systems => /systems/bulk_content_remove(.:format)
  bulk_content_remove_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_content_remove"], arguments)
  },
// new_api_changeset_package => /api/changesets/:changeset_id/packages/new(.:format)
  new_api_changeset_package_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/packages/new"], arguments)
  },
// edit_api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/:id/edit(.:format)
  edit_api_organization_sync_plan_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/sync_plans/", "/edit"], arguments)
  },
// new_api_user_role => /api/users/:user_id/roles/new(.:format)
  new_api_user_role_path: function(_user_id, options) {
  return Utils.build_path(2, ["/api/users/", "/roles/new"], arguments)
  },
// sync_plan_api_organization_product => /api/organizations/:organization_id/products/:id/sync_plan(.:format)
  sync_plan_api_organization_product_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/products/", "/sync_plan"], arguments)
  },
// available_verbs_api_roles => /api/roles/available_verbs(.:format)
  available_verbs_api_roles_path: function(options) {
  return Utils.build_path(1, ["/api/roles/available_verbs"], arguments)
  },
// unlock_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/unlock(.:format)
  unlock_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/unlock"], arguments)
  },
// subscriptions => /subscriptions(.:format)
  subscriptions_path: function(options) {
  return Utils.build_path(1, ["/subscriptions"], arguments)
  },
// new_api_changeset_distribution => /api/changesets/:changeset_id/distributions/new(.:format)
  new_api_changeset_distribution_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/distributions/new"], arguments)
  },
// new_api_role => /api/roles/new(.:format)
  new_api_role_path: function(options) {
  return Utils.build_path(1, ["/api/roles/new"], arguments)
  },
// repositories_api_organization_environment => /api/organizations/:organization_id/environments/:id/repositories(.:format)
  repositories_api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/environments/", "/repositories"], arguments)
  },
// system_groups => /system_groups(.:format)
  system_groups_path: function(options) {
  return Utils.build_path(1, ["/system_groups"], arguments)
  },
// system_group_errata => /system_groups/:system_group_id/errata(.:format)
  system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/errata"], arguments)
  },
// items_system_groups => /system_groups/items(.:format)
  items_system_groups_path: function(options) {
  return Utils.build_path(1, ["/system_groups/items"], arguments)
  },
// enable_helptip_users => /users/enable_helptip(.:format)
  enable_helptip_users_path: function(options) {
  return Utils.build_path(1, ["/users/enable_helptip"], arguments)
  },
// edit_api_repository_package => /api/repositories/:repository_id/packages/:id/edit(.:format)
  edit_api_repository_package_path: function(_repository_id, _id, options) {
  return Utils.build_path(3, ["/api/repositories/", "/packages/", "/edit"], arguments)
  },
// system_groups_api_system => /api/systems/:id/system_groups(.:format)
  system_groups_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/system_groups"], arguments)
  },
// sync_plan => /sync_plans/:id(.:format)
  sync_plan_path: function(_id, options) {
  return Utils.build_path(2, ["/sync_plans/"], arguments)
  },
// edit_environment_user => /users/:id/edit_environment(.:format)
  edit_environment_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/edit_environment"], arguments)
  },
// dependencies_changeset => /changesets/:id/dependencies(.:format)
  dependencies_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/dependencies"], arguments)
  },
// validate_name_system_groups => /system_groups/validate_name(.:format)
  validate_name_system_groups_path: function(options) {
  return Utils.build_path(1, ["/system_groups/validate_name"], arguments)
  },
// items_changesets => /changesets/items(.:format)
  items_changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets/items"], arguments)
  },
// new_gpg_key => /gpg_keys/new(.:format)
  new_gpg_key_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys/new"], arguments)
  },
// pools_api_activation_key => /api/activation_keys/:id/pools(.:format)
  pools_api_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/api/activation_keys/", "/pools"], arguments)
  },
// items_system_templates => /system_templates/items(.:format)
  items_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/items"], arguments)
  },
// role_permission_update => /roles/:role_id/permission/:permission_id/update_permission(.:format)
  role_permission_update_path: function(_role_id, _permission_id, options) {
  return Utils.build_path(3, ["/roles/", "/permission/", "/update_permission"], arguments)
  },
// edit_system_group => /system_groups/:id/edit(.:format)
  edit_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/edit"], arguments)
  },
// available_subscriptions_activation_key => /activation_keys/:id/available_subscriptions(.:format)
  available_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/available_subscriptions"], arguments)
  },
// favorite_search_index => /search/favorite(.:format)
  favorite_search_index_path: function(options) {
  return Utils.build_path(1, ["/search/favorite"], arguments)
  },
// edit_user => /users/:id/edit(.:format)
  edit_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/edit"], arguments)
  },
// new_product => /products/new(.:format)
  new_product_path: function(options) {
  return Utils.build_path(1, ["/products/new"], arguments)
  },
// provider_products => /providers/:provider_id/products(.:format)
  provider_products_path: function(_provider_id, options) {
  return Utils.build_path(2, ["/providers/", "/products"], arguments)
  },
// user => /users/:id(.:format)
  user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/"], arguments)
  },
// errata_dashboard_index => /dashboard/errata(.:format)
  errata_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/errata"], arguments)
  },
// system => /systems/:id(.:format)
  system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/"], arguments)
  },
// sync_management => /sync_management/:id(.:format)
  sync_management_path: function(_id, options) {
  return Utils.build_path(2, ["/sync_management/"], arguments)
  },
// system_template => /system_templates/:id(.:format)
  system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/"], arguments)
  },
// system_templates_organization_environment => /organizations/:organization_id/environments/:id/system_templates(.:format)
  system_templates_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/", "/system_templates"], arguments)
  },
// products_repos_provider => /providers/:id/products_repos(.:format)
  products_repos_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/products_repos"], arguments)
  },
// more_events_system_events => /systems/:system_id/events/more_events(.:format)
  more_events_system_events_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/events/more_events"], arguments)
  },
// jammit => /assets/:package.:extension(.:format)
  jammit_path: function(_package, _extension, options) {
  return Utils.build_path(3, ["/assets/", "."], arguments)
  },
// system_groups_activation_key => /activation_keys/:id/system_groups(.:format)
  system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/system_groups"], arguments)
  },
// search_index => /search(.:format)
  search_index_path: function(options) {
  return Utils.build_path(1, ["/search"], arguments)
  },
// notices_note_count => /notices/note_count(.:format)
  notices_note_count_path: function(options) {
  return Utils.build_path(1, ["/notices/note_count"], arguments)
  },
// new_changeset => /changesets/new(.:format)
  new_changeset_path: function(options) {
  return Utils.build_path(1, ["/changesets/new"], arguments)
  },
// items_filters => /filters/items(.:format)
  items_filters_path: function(options) {
  return Utils.build_path(1, ["/filters/items"], arguments)
  },
// notices => /notices(.:format)
  notices_path: function(options) {
  return Utils.build_path(1, ["/notices"], arguments)
  },
// import_status_owner => /owners/:id/import_status(.:format)
  import_status_owner_path: function(_id, options) {
  return Utils.build_path(2, ["/owners/", "/import_status"], arguments)
  },
// products_api_provider => /api/providers/:id/products(.:format)
  products_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/products"], arguments)
  },
// user_session_logout => /user_session/logout(.:format)
  user_session_logout_path: function(options) {
  return Utils.build_path(1, ["/user_session/logout"], arguments)
  },
// export_api_template => /api/templates/:id/export(.:format)
  export_api_template_path: function(_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/export"], arguments)
  },
// edit_provider => /providers/:id/edit(.:format)
  edit_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/edit"], arguments)
  },
// add_system_system_packages => /systems/:system_id/system_packages/add(.:format)
  add_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/add"], arguments)
  },
// items_system_errata => /systems/:system_id/errata/items(.:format)
  items_system_errata_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/errata/items"], arguments)
  },
// new_activation_key => /activation_keys/new(.:format)
  new_activation_key_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/new"], arguments)
  },
// new_api_template_parameter => /api/templates/:template_id/parameters/new(.:format)
  new_api_template_parameter_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/parameters/new"], arguments)
  },
// validate_name_library_packages => /packages/validate_name_library(.:format)
  validate_name_library_packages_path: function(options) {
  return Utils.build_path(1, ["/packages/validate_name_library"], arguments)
  },
// subscriptions_system => /systems/:id/subscriptions(.:format)
  subscriptions_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/subscriptions"], arguments)
  },
// discovery_api_organization_repositories => /api/organizations/:organization_id/repositories/discovery(.:format)
  discovery_api_organization_repositories_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/repositories/discovery"], arguments)
  },
// add_system_groups_system => /systems/:id/add_system_groups(.:format)
  add_system_groups_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/add_system_groups"], arguments)
  },
// new_api_organization => /api/organizations/new(.:format)
  new_api_organization_path: function(options) {
  return Utils.build_path(1, ["/api/organizations/new"], arguments)
  },
// new_password_reset => /password_resets/new(.:format)
  new_password_reset_path: function(options) {
  return Utils.build_path(1, ["/password_resets/new"], arguments)
  },
// new_api_organization_environment => /api/organizations/:organization_id/environments/new(.:format)
  new_api_organization_environment_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/environments/new"], arguments)
  },
// new_api_template_distribution => /api/templates/:template_id/distributions/new(.:format)
  new_api_template_distribution_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/distributions/new"], arguments)
  },
// organization_environments => /organizations/:organization_id/environments(.:format)
  organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments"], arguments)
  },
// bulk_destroy_systems => /systems/bulk_destroy(.:format)
  bulk_destroy_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_destroy"], arguments)
  },
// sync_management_sync => /sync_management/sync(.:format)
  sync_management_sync_path: function(options) {
  return Utils.build_path(1, ["/sync_management/sync"], arguments)
  },
// bulk_errata_install_systems => /systems/bulk_errata_install(.:format)
  bulk_errata_install_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_errata_install"], arguments)
  },
// edit_api_changeset_package => /api/changesets/:changeset_id/packages/:id/edit(.:format)
  edit_api_changeset_package_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/packages/", "/edit"], arguments)
  },
// edit_api_user_role => /api/users/:user_id/roles/:id/edit(.:format)
  edit_api_user_role_path: function(_user_id, _id, options) {
  return Utils.build_path(3, ["/api/users/", "/roles/", "/edit"], arguments)
  },
// new_user_session => /user_session/new(.:format)
  new_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/new"], arguments)
  },
// systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/systems(.:format)
  systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/systems"], arguments)
  },
// edit_api_changeset_distribution => /api/changesets/:changeset_id/distributions/:id/edit(.:format)
  edit_api_changeset_distribution_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/distributions/", "/edit"], arguments)
  },
// edit_api_role => /api/roles/:id/edit(.:format)
  edit_api_role_path: function(_id, options) {
  return Utils.build_path(2, ["/api/roles/", "/edit"], arguments)
  },
// edit_filter => /filters/:id/edit(.:format)
  edit_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/edit"], arguments)
  },
// environment => /environments/:id(.:format)
  environment_path: function(_id, options) {
  return Utils.build_path(2, ["/environments/"], arguments)
  },
// system_group_erratum => /system_groups/:system_group_id/errata/:id(.:format)
  system_group_erratum_path: function(_system_group_id, _id, options) {
  return Utils.build_path(3, ["/system_groups/", "/errata/"], arguments)
  },
// packages_api_system => /api/systems/:id/packages(.:format)
  packages_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/packages"], arguments)
  },
// disable_helptip_users => /users/disable_helptip(.:format)
  disable_helptip_users_path: function(options) {
  return Utils.build_path(1, ["/users/disable_helptip"], arguments)
  },
// update_environment_user => /users/:id/update_environment(.:format)
  update_environment_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/update_environment"], arguments)
  },
// package_groups_api_repository => /api/repositories/:id/package_groups(.:format)
  package_groups_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/package_groups"], arguments)
  },
// promote_changeset => /changesets/:id/promote(.:format)
  promote_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/promote"], arguments)
  },
// systems_system_group => /system_groups/:id/systems(.:format)
  systems_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/systems"], arguments)
  },
// root => /(.:format)
  root_path: function(options) {
  return Utils.build_path(1, ["/"], arguments)
  },
// operations => /operations(.:format)
  operations_path: function(options) {
  return Utils.build_path(1, ["/operations"], arguments)
  },
// packages_erratum => /errata/:id/packages(.:format)
  packages_erratum_path: function(_id, options) {
  return Utils.build_path(2, ["/errata/", "/packages"], arguments)
  },
// edit_gpg_key => /gpg_keys/:id/edit(.:format)
  edit_gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/gpg_keys/", "/edit"], arguments)
  },
// system_group => /system_groups/:id(.:format)
  system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/"], arguments)
  },
// product_packages_system_templates => /system_templates/product_packages(.:format)
  product_packages_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/product_packages"], arguments)
  },
// auto_complete_search_roles => /roles/auto_complete_search(.:format)
  auto_complete_search_roles_path: function(options) {
  return Utils.build_path(1, ["/roles/auto_complete_search"], arguments)
  },
// remove_subscriptions_activation_key => /activation_keys/:id/remove_subscriptions(.:format)
  remove_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/remove_subscriptions"], arguments)
  },
// new_system => /systems/new(.:format)
  new_system_path: function(options) {
  return Utils.build_path(1, ["/systems/new"], arguments)
  },
// products_promotion => /promotions/:id/products(.:format)
  products_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/products"], arguments)
  },
// update_repo_gpg_key_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/update_gpg_key(.:format)
  update_repo_gpg_key_provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/providers/", "/products/", "/repositories/", "/update_gpg_key"], arguments)
  },
// edit_product => /products/:id/edit(.:format)
  edit_product_path: function(_id, options) {
  return Utils.build_path(2, ["/products/", "/edit"], arguments)
  },
// auto_complete_search_organizations => /organizations/auto_complete_search(.:format)
  auto_complete_search_organizations_path: function(options) {
  return Utils.build_path(1, ["/organizations/auto_complete_search"], arguments)
  },
// new_provider_product => /providers/:provider_id/products/new(.:format)
  new_provider_product_path: function(_provider_id, options) {
  return Utils.build_path(2, ["/providers/", "/products/new"], arguments)
  },
// promotions_dashboard_index => /dashboard/promotions(.:format)
  promotions_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/promotions"], arguments)
  },
// role_permission_destroy => /roles/:role_id/permission/:permission_id/destroy_permission(.:format)
  role_permission_destroy_path: function(_role_id, _permission_id, options) {
  return Utils.build_path(3, ["/roles/", "/permission/", "/destroy_permission"], arguments)
  },
// new_sync_plan => /sync_plans/new(.:format)
  new_sync_plan_path: function(options) {
  return Utils.build_path(1, ["/sync_plans/new"], arguments)
  },
// schedule_provider => /providers/:id/schedule(.:format)
  schedule_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/", "/schedule"], arguments)
  },
// items_system_events => /systems/:system_id/events/items(.:format)
  items_system_events_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/events/items"], arguments)
  },
// add_system_groups_activation_key => /activation_keys/:id/add_system_groups(.:format)
  add_system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/add_system_groups"], arguments)
  },
// history_search_index => /search/history(.:format)
  history_search_index_path: function(options) {
  return Utils.build_path(1, ["/search/history"], arguments)
  },
// rails_info_properties => /rails/info/properties(.:format)
  rails_info_properties_path: function(options) {
  return Utils.build_path(1, ["/rails/info/properties"], arguments)
  },
// packages_filter => /filters/:id/packages(.:format)
  packages_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/packages"], arguments)
  },
// edit_changeset => /changesets/:id/edit(.:format)
  edit_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/edit"], arguments)
  },
// remove_system_system_packages => /systems/:system_id/system_packages/remove(.:format)
  remove_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/remove"], arguments)
  },
// filter => /filters/:id(.:format)
  filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/"], arguments)
  },
// product_repos_system_templates => /system_templates/product_repos(.:format)
  product_repos_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/product_repos"], arguments)
  },
// validate_api_template => /api/templates/:id/validate(.:format)
  validate_api_template_path: function(_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/validate"], arguments)
  },
// install_system_errata => /systems/:system_id/errata/install(.:format)
  install_system_errata_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/errata/install"], arguments)
  },
// new_repository => /repositories/new(.:format)
  new_repository_path: function(options) {
  return Utils.build_path(1, ["/repositories/new"], arguments)
  },
// edit_activation_key => /activation_keys/:id/edit(.:format)
  edit_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/edit"], arguments)
  },
// edit_api_template_parameter => /api/templates/:template_id/parameters/:id/edit(.:format)
  edit_api_template_parameter_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/parameters/", "/edit"], arguments)
  },
// errata_promotion => /promotions/:id/errata(.:format)
  errata_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/errata"], arguments)
  },
// update_subscriptions_system => /systems/:id/update_subscriptions(.:format)
  update_subscriptions_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/update_subscriptions"], arguments)
  },
// remove_system_groups_system => /systems/:id/remove_system_groups(.:format)
  remove_system_groups_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/remove_system_groups"], arguments)
  },
// edit_api_organization => /api/organizations/:id/edit(.:format)
  edit_api_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/edit"], arguments)
  },
// edit_password_reset => /password_resets/:id/edit(.:format)
  edit_password_reset_path: function(_id, options) {
  return Utils.build_path(2, ["/password_resets/", "/edit"], arguments)
  },
// edit_api_organization_environment => /api/organizations/:organization_id/environments/:id/edit(.:format)
  edit_api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/environments/", "/edit"], arguments)
  },
// edit_api_template_distribution => /api/templates/:template_id/distributions/:id/edit(.:format)
  edit_api_template_distribution_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/distributions/", "/edit"], arguments)
  },
// new_organization_environment => /organizations/:organization_id/environments/new(.:format)
  new_organization_environment_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments/new"], arguments)
  },
// bulk_add_system_group_systems => /systems/bulk_add_system_group(.:format)
  bulk_add_system_group_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_add_system_group"], arguments)
  },
// new_api_changeset_product => /api/changesets/:changeset_id/products/new(.:format)
  new_api_changeset_product_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/products/new"], arguments)
  },
// report_api_users => /api/users/report(.:format)
  report_api_users_path: function(options) {
  return Utils.build_path(1, ["/api/users/report"], arguments)
  },
// new_api_template => /api/templates/new(.:format)
  new_api_template_path: function(options) {
  return Utils.build_path(1, ["/api/templates/new"], arguments)
  },
// new_api_changeset_repository => /api/changesets/:changeset_id/repositories/new(.:format)
  new_api_changeset_repository_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/repositories/new"], arguments)
  },
// add_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/add_systems(.:format)
  add_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/add_systems"], arguments)
  },
// errata_api_system => /api/systems/:id/errata(.:format)
  errata_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/errata"], arguments)
  },
// sync_management_index => /sync_management/index(.:format)
  sync_management_index_path: function(options) {
  return Utils.build_path(1, ["/sync_management/index"], arguments)
  },
// clear_helptips_user => /users/:id/clear_helptips(.:format)
  clear_helptips_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/clear_helptips"], arguments)
  },
// new_organization => /organizations/new(.:format)
  new_organization_path: function(options) {
  return Utils.build_path(1, ["/organizations/new"], arguments)
  },
// package_group_categories_api_repository => /api/repositories/:id/package_group_categories(.:format)
  package_group_categories_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/package_group_categories"], arguments)
  },
// object_changeset => /changesets/:id/object(.:format)
  object_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/object"], arguments)
  },
// report_api_environment_systems => /api/environments/:environment_id/systems/report(.:format)
  report_api_environment_systems_path: function(_environment_id, options) {
  return Utils.build_path(2, ["/api/environments/", "/systems/report"], arguments)
  },
// systems => /systems(.:format)
  systems_path: function(options) {
  return Utils.build_path(1, ["/systems"], arguments)
  },
// erratum => /errata/:id(.:format)
  erratum_path: function(_id, options) {
  return Utils.build_path(2, ["/errata/"], arguments)
  },
// repos_promotion => /promotions/:id/repos(.:format)
  repos_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/repos"], arguments)
  },
// add_systems_system_group => /system_groups/:id/add_systems(.:format)
  add_systems_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/add_systems"], arguments)
  },
// releases_api_environment => /api/environments/:id/releases(.:format)
  releases_api_environment_path: function(_id, options) {
  return Utils.build_path(2, ["/api/environments/", "/releases"], arguments)
  },
// auto_complete_search_sync_plans => /sync_plans/auto_complete_search(.:format)
  auto_complete_search_sync_plans_path: function(options) {
  return Utils.build_path(1, ["/sync_plans/auto_complete_search"], arguments)
  },
// roles_show_permission => /roles/show_permission(.:format)
  roles_show_permission_path: function(options) {
  return Utils.build_path(1, ["/roles/show_permission"], arguments)
  },
// auto_complete_search_activation_keys => /activation_keys/auto_complete_search(.:format)
  auto_complete_search_activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/auto_complete_search"], arguments)
  },
// items_roles => /roles/items(.:format)
  items_roles_path: function(options) {
  return Utils.build_path(1, ["/roles/items"], arguments)
  },
// add_subscriptions_activation_key => /activation_keys/:id/add_subscriptions(.:format)
  add_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/add_subscriptions"], arguments)
  },
// products => /products(.:format)
  products_path: function(options) {
  return Utils.build_path(1, ["/products"], arguments)
  },
// provider_product_repositories => /providers/:provider_id/products/:product_id/repositories(.:format)
  provider_product_repositories_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/repositories"], arguments)
  },
// items_organizations => /organizations/items(.:format)
  items_organizations_path: function(options) {
  return Utils.build_path(1, ["/organizations/items"], arguments)
  },
// users => /users(.:format)
  users_path: function(options) {
  return Utils.build_path(1, ["/users"], arguments)
  },
// edit_provider_product => /providers/:provider_id/products/:id/edit(.:format)
  edit_provider_product_path: function(_provider_id, _id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/edit"], arguments)
  },
// systems_dashboard_index => /dashboard/systems(.:format)
  systems_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/systems"], arguments)
  },
// providers => /providers(.:format)
  providers_path: function(options) {
  return Utils.build_path(1, ["/providers"], arguments)
  },
// edit_sync_plan => /sync_plans/:id/edit(.:format)
  edit_sync_plan_path: function(_id, options) {
  return Utils.build_path(2, ["/sync_plans/", "/edit"], arguments)
  },
// logout => /logout(.:format)
  logout_path: function(options) {
  return Utils.build_path(1, ["/logout"], arguments)
  },
// new_role => /roles/new(.:format)
  new_role_path: function(options) {
  return Utils.build_path(1, ["/roles/new"], arguments)
  },
// filelist_repository_distribution => /repositories/:repository_id/distributions/:id/filelist(.:format)
  filelist_repository_distribution_path: function(_repository_id, _id, options) {
  return Utils.build_path(3, ["/repositories/", "/distributions/", "/filelist"], arguments)
  },
// auto_complete_search_providers => /providers/auto_complete_search(.:format)
  auto_complete_search_providers_path: function(options) {
  return Utils.build_path(1, ["/providers/auto_complete_search"], arguments)
  },
// filters => /filters(.:format)
  filters_path: function(options) {
  return Utils.build_path(1, ["/filters"], arguments)
  },
// remove_system_groups_activation_key => /activation_keys/:id/remove_system_groups(.:format)
  remove_system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/", "/remove_system_groups"], arguments)
  },
// add_packages_filter => /filters/:id/add_packages(.:format)
  add_packages_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/add_packages"], arguments)
  },
// sync_plans => /sync_plans(.:format)
  sync_plans_path: function(options) {
  return Utils.build_path(1, ["/sync_plans"], arguments)
  },
// gpg_key => /gpg_keys/:id(.:format)
  gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/gpg_keys/"], arguments)
  },
// gpg_keys => /gpg_keys(.:format)
  gpg_keys_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys"], arguments)
  },
// details_promotion => /promotions/:id/details(.:format)
  details_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/details"], arguments)
  },
// import_products_api_provider => /api/providers/:id/import_products(.:format)
  import_products_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/import_products"], arguments)
  },
// email_logins_password_resets => /password_resets/email_logins(.:format)
  email_logins_password_resets_path: function(options) {
  return Utils.build_path(1, ["/password_resets/email_logins"], arguments)
  },
// new_api_provider => /api/providers/new(.:format)
  new_api_provider_path: function(options) {
  return Utils.build_path(1, ["/api/providers/new"], arguments)
  },
// system_system_packages => /systems/:system_id/system_packages(.:format)
  system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages"], arguments)
  },
// status_system_errata => /systems/:system_id/errata/status(.:format)
  status_system_errata_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/errata/status"], arguments)
  },
// new_api_template_package => /api/templates/:template_id/packages/new(.:format)
  new_api_template_package_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/packages/new"], arguments)
  },
// changelog_package => /packages/:id/changelog(.:format)
  changelog_package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/", "/changelog"], arguments)
  },
// edit_repository => /repositories/:id/edit(.:format)
  edit_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/repositories/", "/edit"], arguments)
  },
// products_system => /systems/:id/products(.:format)
  products_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/products"], arguments)
  },
// allowed_orgs_user_session => /user_session/allowed_orgs(.:format)
  allowed_orgs_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/allowed_orgs"], arguments)
  },
// auto_complete_search_gpg_keys => /gpg_keys/auto_complete_search(.:format)
  auto_complete_search_gpg_keys_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys/auto_complete_search"], arguments)
  },
// auto_complete_systems => /systems/auto_complete(.:format)
  auto_complete_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/auto_complete"], arguments)
  },
// role => /roles/:id(.:format)
  role_path: function(_id, options) {
  return Utils.build_path(2, ["/roles/"], arguments)
  },
// new_api_template_package_group_category => /api/templates/:template_id/package_group_categories/new(.:format)
  new_api_template_package_group_category_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/package_group_categories/new"], arguments)
  },
// bulk_remove_system_group_systems => /systems/bulk_remove_system_group(.:format)
  bulk_remove_system_group_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_remove_system_group"], arguments)
  },
// edit_api_changeset_product => /api/changesets/:changeset_id/products/:id/edit(.:format)
  edit_api_changeset_product_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/products/", "/edit"], arguments)
  },
// password_reset => /password_resets/:id(.:format)
  password_reset_path: function(_id, options) {
  return Utils.build_path(2, ["/password_resets/"], arguments)
  },
// edit_organization_environment => /organizations/:organization_id/environments/:id/edit(.:format)
  edit_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/", "/edit"], arguments)
  },
// sync_ldap_roles_api_users => /api/users/sync_ldap_roles(.:format)
  sync_ldap_roles_api_users_path: function(options) {
  return Utils.build_path(1, ["/api/users/sync_ldap_roles"], arguments)
  },
// edit_api_template => /api/templates/:id/edit(.:format)
  edit_api_template_path: function(_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/edit"], arguments)
  },
// new_api_user => /api/users/new(.:format)
  new_api_user_path: function(options) {
  return Utils.build_path(1, ["/api/users/new"], arguments)
  },
// edit_api_changeset_repository => /api/changesets/:changeset_id/repositories/:id/edit(.:format)
  edit_api_changeset_repository_path: function(_changeset_id, _id, options) {
  return Utils.build_path(3, ["/api/changesets/", "/repositories/", "/edit"], arguments)
  },
// notices_details => /notices/:id/details(.:format)
  notices_details_path: function(_id, options) {
  return Utils.build_path(2, ["/notices/", "/details"], arguments)
  },
// items_system_group_errata => /system_groups/:system_group_id/errata/items(.:format)
  items_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/errata/items"], arguments)
  },
// remove_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/remove_systems(.:format)
  remove_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/system_groups/", "/remove_systems"], arguments)
  },
// new_environment => /environments/new(.:format)
  new_environment_path: function(options) {
  return Utils.build_path(1, ["/environments/new"], arguments)
  },
// promotion => /promotions/:id(.:format)
  promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/"], arguments)
  },
// search_api_repository_packages => /api/repositories/:repository_id/packages/search(.:format)
  search_api_repository_packages_path: function(_repository_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/packages/search"], arguments)
  },
// new_api_consumer => /api/consumers/new(.:format)
  new_api_consumer_path: function(options) {
  return Utils.build_path(1, ["/api/consumers/new"], arguments)
  },
// update_roles_user => /users/:id/update_roles(.:format)
  update_roles_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/update_roles"], arguments)
  },
// edit_organization => /organizations/:id/edit(.:format)
  edit_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/edit"], arguments)
  },
// pools_api_system => /api/systems/:id/pools(.:format)
  pools_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/pools"], arguments)
  },
// download_system_template => /system_templates/:id/download(.:format)
  download_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/download"], arguments)
  },
// gpg_key_content_api_repository => /api/repositories/:id/gpg_key_content(.:format)
  gpg_key_content_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/gpg_key_content"], arguments)
  },
// promotion_progress_changeset => /changesets/:id/promotion_progress(.:format)
  promotion_progress_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/", "/promotion_progress"], arguments)
  },
// remove_systems_system_group => /system_groups/:id/remove_systems(.:format)
  remove_systems_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/remove_systems"], arguments)
  },
// items_sync_plans => /sync_plans/items(.:format)
  items_sync_plans_path: function(options) {
  return Utils.build_path(1, ["/sync_plans/items"], arguments)
  },
// password_resets => /password_resets(.:format)
  password_resets_path: function(options) {
  return Utils.build_path(1, ["/password_resets"], arguments)
  },
// destroy_role_ldap_group => /roles/:role_id/ldap_groups/:id(.:format)
  destroy_role_ldap_group_path: function(_role_id, _id, options) {
  return Utils.build_path(3, ["/roles/", "/ldap_groups/"], arguments)
  },
// sync_schedules_apply => /sync_schedules/apply(.:format)
  sync_schedules_apply_path: function(options) {
  return Utils.build_path(1, ["/sync_schedules/apply"], arguments)
  },
// items_activation_keys => /activation_keys/items(.:format)
  items_activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/items"], arguments)
  },
// promotions => /promotions(.:format)
  promotions_path: function(options) {
  return Utils.build_path(1, ["/promotions"], arguments)
  },
// new_system_template => /system_templates/new(.:format)
  new_system_template_path: function(options) {
  return Utils.build_path(1, ["/system_templates/new"], arguments)
  },
// product => /products/:id(.:format)
  product_path: function(_id, options) {
  return Utils.build_path(2, ["/products/"], arguments)
  },
// new_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/new(.:format)
  new_provider_product_repository_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/repositories/new"], arguments)
  },
// subscriptions_dashboard_index => /dashboard/subscriptions(.:format)
  subscriptions_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/subscriptions"], arguments)
  },
// environments_partial_organization => /organizations/:id/environments_partial(.:format)
  environments_partial_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments_partial"], arguments)
  },
// provider_product => /providers/:provider_id/products/:id(.:format)
  provider_product_path: function(_provider_id, _id, options) {
  return Utils.build_path(3, ["/providers/", "/products/"], arguments)
  },
// enable_repo => /repositories/:id/enable_repo(.:format)
  enable_repo_path: function(_id, options) {
  return Utils.build_path(2, ["/repositories/", "/enable_repo"], arguments)
  },
// edit_role => /roles/:id/edit(.:format)
  edit_role_path: function(_id, options) {
  return Utils.build_path(2, ["/roles/", "/edit"], arguments)
  },
// repository_distribution => /repositories/:repository_id/distributions/:id(.:format)
  repository_distribution_path: function(_repository_id, _id, options) {
  return Utils.build_path(3, ["/repositories/", "/distributions/"], arguments)
  },
// new_api_system_packages => /api/systems/:system_id/packages/new(.:format)
  new_api_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/packages/new"], arguments)
  },
// remove_packages_filter => /filters/:id/remove_packages(.:format)
  remove_packages_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/remove_packages"], arguments)
  },
// import_manifest_api_provider => /api/providers/:id/import_manifest(.:format)
  import_manifest_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/import_manifest"], arguments)
  },
// system_templates => /system_templates(.:format)
  system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates"], arguments)
  },
// products_organization_environment => /organizations/:organization_id/environments/:id/products(.:format)
  products_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/", "/products"], arguments)
  },
// edit_api_provider => /api/providers/:id/edit(.:format)
  edit_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/edit"], arguments)
  },
// auto_complete_library_repositories => /repositories/auto_complete_library(.:format)
  auto_complete_library_repositories_path: function(options) {
  return Utils.build_path(1, ["/repositories/auto_complete_library"], arguments)
  },
// packages_system_system_packages => /systems/:system_id/system_packages/packages(.:format)
  packages_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/packages"], arguments)
  },
// filelist_package => /packages/:id/filelist(.:format)
  filelist_package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/", "/filelist"], arguments)
  },
// repository => /repositories/:id(.:format)
  repository_path: function(_id, options) {
  return Utils.build_path(2, ["/repositories/"], arguments)
  },
// system_errata => /systems/:system_id/errata(.:format)
  system_errata_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/errata"], arguments)
  },
// edit_api_template_package => /api/templates/:template_id/packages/:id/edit(.:format)
  edit_api_template_package_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/packages/", "/edit"], arguments)
  },
// more_products_system => /systems/:id/more_products(.:format)
  more_products_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/more_products"], arguments)
  },
// environments => /environments(.:format)
  environments_path: function(options) {
  return Utils.build_path(1, ["/environments"], arguments)
  },
// items_gpg_keys => /gpg_keys/items(.:format)
  items_gpg_keys_path: function(options) {
  return Utils.build_path(1, ["/gpg_keys/items"], arguments)
  },
// package => /packages/:id(.:format)
  package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/"], arguments)
  },
// items_systems => /systems/items(.:format)
  items_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/items"], arguments)
  },
// promote_api_changeset => /api/changesets/:id/promote(.:format)
  promote_api_changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/promote"], arguments)
  },
// system_events => /systems/:system_id/events(.:format)
  system_events_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/events"], arguments)
  },
// edit_api_template_package_group_category => /api/templates/:template_id/package_group_categories/:id/edit(.:format)
  edit_api_template_package_group_category_path: function(_template_id, _id, options) {
  return Utils.build_path(3, ["/api/templates/", "/package_group_categories/", "/edit"], arguments)
  },
// new_api_activation_key => /api/activation_keys/new(.:format)
  new_api_activation_key_path: function(options) {
  return Utils.build_path(1, ["/api/activation_keys/new"], arguments)
  },
// organization_environment => /organizations/:organization_id/environments/:id(.:format)
  organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/organizations/", "/environments/"], arguments)
  },
// bulk_content_install_systems => /systems/bulk_content_install(.:format)
  bulk_content_install_systems_path: function(options) {
  return Utils.build_path(1, ["/systems/bulk_content_install"], arguments)
  },
// roles => /roles(.:format)
  roles_path: function(options) {
  return Utils.build_path(1, ["/roles"], arguments)
  },
// new_api_changeset_erratum => /api/changesets/:changeset_id/errata/new(.:format)
  new_api_changeset_erratum_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/errata/new"], arguments)
  },
// report_api_organization_systems => /api/organizations/:organization_id/systems/report(.:format)
  report_api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/systems/report"], arguments)
  },
// edit_api_user => /api/users/:id/edit(.:format)
  edit_api_user_path: function(_id, options) {
  return Utils.build_path(2, ["/api/users/", "/edit"], arguments)
  },
// set_org_user_session => /user_session/set_org(.:format)
  set_org_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/set_org"], arguments)
  },
// provider => /providers/:id(.:format)
  provider_path: function(_id, options) {
  return Utils.build_path(2, ["/providers/"], arguments)
  },
// new_api_changeset_template => /api/changesets/:changeset_id/templates/new(.:format)
  new_api_changeset_template_path: function(_changeset_id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/templates/new"], arguments)
  },
// install_system_group_errata => /system_groups/:system_group_id/errata/install(.:format)
  install_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/errata/install"], arguments)
  },
// auto_complete_search_users => /users/auto_complete_search(.:format)
  auto_complete_search_users_path: function(options) {
  return Utils.build_path(1, ["/users/auto_complete_search"], arguments)
  },
// edit_api_consumer => /api/consumers/:id/edit(.:format)
  edit_api_consumer_path: function(_id, options) {
  return Utils.build_path(2, ["/api/consumers/", "/edit"], arguments)
  },
// update_locale_user => /users/:id/update_locale(.:format)
  update_locale_user_path: function(_id, options) {
  return Utils.build_path(2, ["/users/", "/update_locale"], arguments)
  },
// releases_api_system => /api/systems/:id/releases(.:format)
  releases_api_system_path: function(_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/releases"], arguments)
  },
// validate_system_template => /system_templates/:id/validate(.:format)
  validate_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/validate"], arguments)
  },
// notices_auto_complete_search => /notices/auto_complete_search(.:format)
  notices_auto_complete_search_path: function(options) {
  return Utils.build_path(1, ["/notices/auto_complete_search"], arguments)
  },
// enable_api_repository => /api/repositories/:id/enable(.:format)
  enable_api_repository_path: function(_id, options) {
  return Utils.build_path(2, ["/api/repositories/", "/enable"], arguments)
  },
// auto_complete_search_changesets => /changesets/auto_complete_search(.:format)
  auto_complete_search_changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets/auto_complete_search"], arguments)
  },
// repositories => /repositories(.:format)
  repositories_path: function(options) {
  return Utils.build_path(1, ["/repositories"], arguments)
  },
// repositories_api_environment_product => /api/environments/:environment_id/products/:id/repositories(.:format)
  repositories_api_environment_product_path: function(_environment_id, _id, options) {
  return Utils.build_path(3, ["/api/environments/", "/products/", "/repositories"], arguments)
  },
// lock_system_group => /system_groups/:id/lock(.:format)
  lock_system_group_path: function(_id, options) {
  return Utils.build_path(2, ["/system_groups/", "/lock"], arguments)
  },
// edit_user_session => /user_session/edit(.:format)
  edit_user_session_path: function(options) {
  return Utils.build_path(1, ["/user_session/edit"], arguments)
  },
// content_api_gpg_key => /api/gpg_keys/:id/content(.:format)
  content_api_gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/api/gpg_keys/", "/content"], arguments)
  },
// activation_key => /activation_keys/:id(.:format)
  activation_key_path: function(_id, options) {
  return Utils.build_path(2, ["/activation_keys/"], arguments)
  },
// create_role_ldap_groups => /roles/:role_id/ldap_groups(.:format)
  create_role_ldap_groups_path: function(_role_id, options) {
  return Utils.build_path(2, ["/roles/", "/ldap_groups"], arguments)
  },
// subscriptions_activation_keys => /activation_keys/subscriptions(.:format)
  subscriptions_activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys/subscriptions"], arguments)
  },
// edit_system_template => /system_templates/:id/edit(.:format)
  edit_system_template_path: function(_id, options) {
  return Utils.build_path(2, ["/system_templates/", "/edit"], arguments)
  },
// edit_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/edit(.:format)
  edit_provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(4, ["/providers/", "/products/", "/repositories/", "/edit"], arguments)
  },
// sync_dashboard_index => /dashboard/sync(.:format)
  sync_dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard/sync"], arguments)
  },
// activation_keys => /activation_keys(.:format)
  activation_keys_path: function(options) {
  return Utils.build_path(1, ["/activation_keys"], arguments)
  },
// items_providers => /providers/items(.:format)
  items_providers_path: function(options) {
  return Utils.build_path(1, ["/providers/items"], arguments)
  },
// dashboard_index => /dashboard(.:format)
  dashboard_index_path: function(options) {
  return Utils.build_path(1, ["/dashboard"], arguments)
  },
// owners => /owners(.:format)
  owners_path: function(options) {
  return Utils.build_path(1, ["/owners"], arguments)
  },
// events_organization => /organizations/:id/events(.:format)
  events_organization_path: function(_id, options) {
  return Utils.build_path(2, ["/organizations/", "/events"], arguments)
  },
// product_comps_system_templates => /system_templates/product_comps(.:format)
  product_comps_system_templates_path: function(options) {
  return Utils.build_path(1, ["/system_templates/product_comps"], arguments)
  },
// changesets => /changesets(.:format)
  changesets_path: function(options) {
  return Utils.build_path(1, ["/changesets"], arguments)
  },
// sync_schedules_index => /sync_schedules/index(.:format)
  sync_schedules_index_path: function(options) {
  return Utils.build_path(1, ["/sync_schedules/index"], arguments)
  },
// sync_management_product_status => /sync_management/product_status(.:format)
  sync_management_product_status_path: function(options) {
  return Utils.build_path(1, ["/sync_management/product_status"], arguments)
  },
// packages_promotion => /promotions/:id/packages(.:format)
  packages_promotion_path: function(_id, options) {
  return Utils.build_path(2, ["/promotions/", "/packages"], arguments)
  },
// edit_api_system_packages => /api/systems/:system_id/packages/edit(.:format)
  edit_api_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/api/systems/", "/packages/edit"], arguments)
  },
// auto_complete_search_filters => /filters/auto_complete_search(.:format)
  auto_complete_search_filters_path: function(options) {
  return Utils.build_path(1, ["/filters/auto_complete_search"], arguments)
  },
// refresh_products_api_provider => /api/providers/:id/refresh_products(.:format)
  refresh_products_api_provider_path: function(_id, options) {
  return Utils.build_path(2, ["/api/providers/", "/refresh_products"], arguments)
  },
// products_filter => /filters/:id/products(.:format)
  products_filter_path: function(_id, options) {
  return Utils.build_path(2, ["/filters/", "/products"], arguments)
  },
// changeset => /changesets/:id(.:format)
  changeset_path: function(_id, options) {
  return Utils.build_path(2, ["/changesets/"], arguments)
  },
// new_api_template_product => /api/templates/:template_id/products/new(.:format)
  new_api_template_product_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/products/new"], arguments)
  },
// more_packages_system_system_packages => /systems/:system_id/system_packages/more_packages(.:format)
  more_packages_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(2, ["/systems/", "/system_packages/more_packages"], arguments)
  },
// dependencies_package => /packages/:id/dependencies(.:format)
  dependencies_package_path: function(_id, options) {
  return Utils.build_path(2, ["/packages/", "/dependencies"], arguments)
  },
// system_erratum => /systems/:system_id/errata/:id(.:format)
  system_erratum_path: function(_system_id, _id, options) {
  return Utils.build_path(3, ["/systems/", "/errata/"], arguments)
  },
// system_groups_api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id/system_groups(.:format)
  system_groups_api_organization_activation_key_path: function(_organization_id, _id, options) {
  return Utils.build_path(3, ["/api/organizations/", "/activation_keys/", "/system_groups"], arguments)
  },
// products_repos_gpg_key => /gpg_keys/:id/products_repos(.:format)
  products_repos_gpg_key_path: function(_id, options) {
  return Utils.build_path(2, ["/gpg_keys/", "/products_repos"], arguments)
  },
// login => /login(.:format)
  login_path: function(options) {
  return Utils.build_path(1, ["/login"], arguments)
  },
// new_api_template_package_group => /api/templates/:template_id/package_groups/new(.:format)
  new_api_template_package_group_path: function(_template_id, options) {
  return Utils.build_path(2, ["/api/templates/", "/package_groups/new"], arguments)
  },
// facts_system => /systems/:id/facts(.:format)
  facts_system_path: function(_id, options) {
  return Utils.build_path(2, ["/systems/", "/facts"], arguments)
  }}
;
  
  window.KT.routes.options = {
    prefix: '',
    default_format: '',
  };


})();
