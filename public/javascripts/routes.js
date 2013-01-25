(function(){

  var defaults = {
    prefix: '',
    format: ''
  };
  
  var Utils = {

    serialize: function(obj){
      if (obj === null) {return '';}
      var s = [];
      for (prop in obj){
        if (obj[prop]) {
          if (obj[prop] instanceof Array) {
            for (var i=0; i < obj[prop].length; i++) {
              key = prop + encodeURIComponent("[]");
              s.push(key + "=" + encodeURIComponent(obj[prop][i].toString()));
            }
          } else {
            s.push(prop + "=" + encodeURIComponent(obj[prop].toString()));
          }
        }
      }
      if (s.length === 0) {
        return '';
      }
      return "?" + s.join('&');
    },

    clean_path: function(path) {
      return path.replace(/\/+/g, "/").replace(/[\)\(]/g, "").replace(/\.$/m, '').replace(/\/$/m, '');
    },

    extract: function(name, options) {
      var o = undefined;
      if (options.hasOwnProperty(name)) {
        o = options[name];
        delete options[name];
      } else if (defaults.hasOwnProperty(name)) {
        o = defaults[name];
      }
      return o;
    },

    extract_format: function(options) {
      var format = options.hasOwnProperty("format") ? options.format : defaults.format;
      delete options.format;
      return format ? "." + format : "";
    },

    extract_anchor: function(options) {
      var anchor = options.hasOwnProperty("anchor") ? options.anchor : null;
      delete options.anchor;
      return anchor ? "#" + anchor : "";
    },

    extract_options: function(number_of_params, args) {
      if (args.length > number_of_params) {
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
        return ((typeof(object.to_param) == "function" && object.to_param()) || object.to_param || object.id || object).toString();
      } else {
        return object.toString();
      }
    },

    build_path: function(number_of_params, parts, optional_params, args) {
      args = Array.prototype.slice.call(args);
      var result = Utils.get_prefix();
      var opts = Utils.extract_options(number_of_params, args);
      if (args.length > number_of_params) {
        throw new Error("Too many parameters provided for path");
      }
      var params_count = 0, optional_params_count = 0;
      for (var i=0; i < parts.length; i++) {
        var part = parts[i];
        if (Utils.optional_part(part)) {
          var name = optional_params[optional_params_count];
          optional_params_count++;
          // try and find the option in opts
          var optional = Utils.extract(name, opts);
          if (Utils.specified(optional)) {
            result += part;
            result += Utils.path_identifier(optional);
          }
        } else {
          result += part;
          if (params_count < number_of_params) {
            params_count++;
            var value = args.shift();
            if (Utils.specified(value)) {
              result += Utils.path_identifier(value);
            } else {
              throw new Error("Insufficient parameters to build path");
            }
          }
        }
      }
      var format = Utils.extract_format(opts);
      var anchor = Utils.extract_anchor(opts);
      return Utils.clean_path(result + format + anchor) + Utils.serialize(opts);
    },

    specified: function(value) {
      return !(value === undefined || value === null);
    },

    optional_part: function(part) {
      return part.match(/\(/);
    },

    get_prefix: function(){
      var prefix = defaults.prefix;

      if( prefix !== "" ){
        prefix = prefix.match('\/$') ? prefix : ( prefix + '/');
      }
      
      return prefix;
    }

  };

  window.KT.routes = {
// system_group => /system_groups/:id(.:format)
  system_group_path: function(_id, options) {
  return Utils.build_path(1, ["/system_groups/"], ["format"], arguments)
  },
// system_event => /systems/:system_id/events/:id(.:format)
  system_event_path: function(_system_id, _id, options) {
  return Utils.build_path(2, ["/systems/", "/events/"], ["format"], arguments)
  },
// new_api_organization_environment => /api/organizations/:organization_id/environments/new(.:format)
  new_api_organization_environment_path: function(_organization_id, options) {
  return Utils.build_path(1, ["/api/organizations/", "/environments/new"], ["format"], arguments)
  },
// default_label_provider_product_repositories => /providers/:provider_id/products/:product_id/repositories/default_label(.:format)
  default_label_provider_product_repositories_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(2, ["/providers/", "/products/", "/repositories/default_label"], ["format"], arguments)
  },
// repos_content_search_index => /content_search/repos(.:format)
  repos_content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search/repos"], ["format"], arguments)
  },
// status_system_system_packages => /systems/:system_id/system_packages/status(.:format)
  status_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/system_packages/status"], ["format"], arguments)
  },
// provider_products => /providers/:provider_id/products(.:format)
  provider_products_path: function(_provider_id, options) {
  return Utils.build_path(1, ["/providers/", "/products"], ["format"], arguments)
  },
// consumers_subscription => /subscriptions/:id/consumers(.:format)
  consumers_subscription_path: function(_id, options) {
  return Utils.build_path(1, ["/subscriptions/", "/consumers"], ["format"], arguments)
  },
// new_content_search => /content_search/new(.:format)
  new_content_search_path: function(options) {
  return Utils.build_path(0, ["/content_search/new"], ["format"], arguments)
  },
// import_products_api_provider => /api/providers/:id/import_products(.:format)
  import_products_api_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/api/providers/", "/import_products"], ["format"], arguments)
  },
// edit_system => /systems/:id/edit(.:format)
  edit_system_path: function(_id, options) {
  return Utils.build_path(1, ["/systems/", "/edit"], ["format"], arguments)
  },
// repo_discovery_provider => /providers/:id/repo_discovery(.:format)
  repo_discovery_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/providers/", "/repo_discovery"], ["format"], arguments)
  },
// auto_complete_library_packages => /packages/auto_complete_library(.:format)
  auto_complete_library_packages_path: function(options) {
  return Utils.build_path(0, ["/packages/auto_complete_library"], ["format"], arguments)
  },
// discovery_api_provider => /api/providers/:id/discovery(.:format)
  discovery_api_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/api/providers/", "/discovery"], ["format"], arguments)
  },
// system_groups_system => /systems/:id/system_groups(.:format)
  system_groups_system_path: function(_id, options) {
  return Utils.build_path(1, ["/systems/", "/system_groups"], ["format"], arguments)
  },
// manifest_progress_provider => /providers/:id/manifest_progress(.:format)
  manifest_progress_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/providers/", "/manifest_progress"], ["format"], arguments)
  },
// new_api_organization_system_group_packages => /api/organizations/:organization_id/system_groups/:system_group_id/packages/new(.:format)
  new_api_organization_system_group_packages_path: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/system_groups/", "/packages/new"], ["format"], arguments)
  },
// sync_management_manage => /sync_management/manage(.:format)
  sync_management_manage_path: function(options) {
  return Utils.build_path(0, ["/sync_management/manage"], ["format"], arguments)
  },
// environment => /environments/:id(.:format)
  environment_path: function(_id, options) {
  return Utils.build_path(1, ["/environments/"], ["format"], arguments)
  },
// export_api_template => /api/templates/:id/export(.:format)
  export_api_template_path: function(_id, options) {
  return Utils.build_path(1, ["/api/templates/", "/export"], ["format"], arguments)
  },
// environments_systems => /systems/environments(.:format)
  environments_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/environments"], ["format"], arguments)
  },
// items_users => /users/items(.:format)
  items_users_path: function(options) {
  return Utils.build_path(0, ["/users/items"], ["format"], arguments)
  },
// system_groups => /system_groups(.:format)
  system_groups_path: function(options) {
  return Utils.build_path(0, ["/system_groups"], ["format"], arguments)
  },
// dependencies_changeset => /changesets/:id/dependencies(.:format)
  dependencies_changeset_path: function(_id, options) {
  return Utils.build_path(1, ["/changesets/", "/dependencies"], ["format"], arguments)
  },
// bulk_content_remove_systems => /systems/bulk_content_remove(.:format)
  bulk_content_remove_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/bulk_content_remove"], ["format"], arguments)
  },
// new_api_changeset_product => /api/changesets/:changeset_id/products/new(.:format)
  new_api_changeset_product_path: function(_changeset_id, options) {
  return Utils.build_path(1, ["/api/changesets/", "/products/new"], ["format"], arguments)
  },
// update_preference_user => /users/:id/update_preference(.:format)
  update_preference_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/update_preference"], ["format"], arguments)
  },
// items_changesets => /changesets/items(.:format)
  items_changesets_path: function(options) {
  return Utils.build_path(0, ["/changesets/items"], ["format"], arguments)
  },
// auto_complete_search_sync_plans => /sync_plans/auto_complete_search(.:format)
  auto_complete_search_sync_plans_path: function(options) {
  return Utils.build_path(0, ["/sync_plans/auto_complete_search"], ["format"], arguments)
  },
// new_api_template_parameter => /api/templates/:template_id/parameters/new(.:format)
  new_api_template_parameter_path: function(_template_id, options) {
  return Utils.build_path(1, ["/api/templates/", "/parameters/new"], ["format"], arguments)
  },
// repos_promotion => /promotions/:id/repos(.:format)
  repos_promotion_path: function(_id, options) {
  return Utils.build_path(1, ["/promotions/", "/repos"], ["format"], arguments)
  },
// new_api_changeset_repository => /api/changesets/:changeset_id/repositories/new(.:format)
  new_api_changeset_repository_path: function(_changeset_id, options) {
  return Utils.build_path(1, ["/api/changesets/", "/repositories/new"], ["format"], arguments)
  },
// items_activation_keys => /activation_keys/items(.:format)
  items_activation_keys_path: function(options) {
  return Utils.build_path(0, ["/activation_keys/items"], ["format"], arguments)
  },
// add_system_group_packages => /system_groups/:system_group_id/packages/add(.:format)
  add_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/packages/add"], ["format"], arguments)
  },
// promotion_details_system_template => /system_templates/:id/promotion_details(.:format)
  promotion_details_system_template_path: function(_id, options) {
  return Utils.build_path(1, ["/system_templates/", "/promotion_details"], ["format"], arguments)
  },
// new_api_template_distribution => /api/templates/:template_id/distributions/new(.:format)
  new_api_template_distribution_path: function(_template_id, options) {
  return Utils.build_path(1, ["/api/templates/", "/distributions/new"], ["format"], arguments)
  },
// role_permission_update => /roles/:role_id/permission/:permission_id/update_permission(.:format)
  role_permission_update_path: function(_role_id, _permission_id, options) {
  return Utils.build_path(2, ["/roles/", "/permission/", "/update_permission"], ["format"], arguments)
  },
// system_events => /systems/:system_id/events(.:format)
  system_events_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/events"], ["format"], arguments)
  },
// add_systems_system_group => /system_groups/:id/add_systems(.:format)
  add_systems_system_group_path: function(_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/add_systems"], ["format"], arguments)
  },
// favorite_search_index => /search/favorite(.:format)
  favorite_search_index_path: function(options) {
  return Utils.build_path(0, ["/search/favorite"], ["format"], arguments)
  },
// gpg_key_content_api_repository => /api/repositories/:id/gpg_key_content(.:format)
  gpg_key_content_api_repository_path: function(_format, options) {
  return Utils.build_path(1, ["/api/repositories/", "/gpg_key_content"], ["id"], arguments)
  },
// edit_sync_plan => /sync_plans/:id/edit(.:format)
  edit_sync_plan_path: function(_id, options) {
  return Utils.build_path(1, ["/sync_plans/", "/edit"], ["format"], arguments)
  },
// items_organizations => /organizations/items(.:format)
  items_organizations_path: function(options) {
  return Utils.build_path(0, ["/organizations/items"], ["format"], arguments)
  },
// report_api_environment_systems => /api/environments/:environment_id/systems/report(.:format)
  report_api_environment_systems_path: function(_environment_id, options) {
  return Utils.build_path(1, ["/api/environments/", "/systems/report"], ["format"], arguments)
  },
// update_content_system_template => /system_templates/:id/update_content(.:format)
  update_content_system_template_path: function(_id, options) {
  return Utils.build_path(1, ["/system_templates/", "/update_content"], ["format"], arguments)
  },
// system_templates_organization_environment => /organizations/:organization_id/environments/:id/system_templates(.:format)
  system_templates_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments/", "/system_templates"], ["format"], arguments)
  },
// items_system_group_errata => /system_groups/:system_group_id/errata/items(.:format)
  items_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/errata/items"], ["format"], arguments)
  },
// remove_system_groups_activation_key => /activation_keys/:id/remove_system_groups(.:format)
  remove_system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/activation_keys/", "/remove_system_groups"], ["format"], arguments)
  },
// pools_api_system => /api/systems/:id/pools(.:format)
  pools_api_system_path: function(_id, options) {
  return Utils.build_path(1, ["/api/systems/", "/pools"], ["format"], arguments)
  },
// edit_api_activation_key => /api/activation_keys/:id/edit(.:format)
  edit_api_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/api/activation_keys/", "/edit"], ["format"], arguments)
  },
// search_index => /search(.:format)
  search_index_path: function(options) {
  return Utils.build_path(0, ["/search"], ["format"], arguments)
  },
// auto_complete_search_system_templates => /system_templates/auto_complete_search(.:format)
  auto_complete_search_system_templates_path: function(options) {
  return Utils.build_path(0, ["/system_templates/auto_complete_search"], ["format"], arguments)
  },
// new_changeset => /changesets/new(.:format)
  new_changeset_path: function(options) {
  return Utils.build_path(0, ["/changesets/new"], ["format"], arguments)
  },
// details_promotion => /promotions/:id/details(.:format)
  details_promotion_path: function(_id, options) {
  return Utils.build_path(1, ["/promotions/", "/details"], ["format"], arguments)
  },
// user_session_logout => /user_session/logout(.:format)
  user_session_logout_path: function(options) {
  return Utils.build_path(0, ["/user_session/logout"], ["format"], arguments)
  },
// promotions_dashboard_index => /dashboard/promotions(.:format)
  promotions_dashboard_index_path: function(options) {
  return Utils.build_path(0, ["/dashboard/promotions"], ["format"], arguments)
  },
// erratum => /errata/:id(.:format)
  erratum_path: function(_id, options) {
  return Utils.build_path(1, ["/errata/"], ["format"], arguments)
  },
// edit_api_role => /api/roles/:id/edit(.:format)
  edit_api_role_path: function(_id, options) {
  return Utils.build_path(1, ["/api/roles/", "/edit"], ["format"], arguments)
  },
// more_events_system_events => /systems/:system_id/events/more_events(.:format)
  more_events_system_events_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/events/more_events"], ["format"], arguments)
  },
// auto_complete_search_gpg_keys => /gpg_keys/auto_complete_search(.:format)
  auto_complete_search_gpg_keys_path: function(options) {
  return Utils.build_path(0, ["/gpg_keys/auto_complete_search"], ["format"], arguments)
  },
// system_group_packages => /system_groups/:system_group_id/packages(.:format)
  system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/packages"], ["format"], arguments)
  },
// edit_password_reset => /password_resets/:id/edit(.:format)
  edit_password_reset_path: function(_id, options) {
  return Utils.build_path(1, ["/password_resets/", "/edit"], ["format"], arguments)
  },
// edit_product => /products/:id/edit(.:format)
  edit_product_path: function(_id, options) {
  return Utils.build_path(1, ["/products/", "/edit"], ["format"], arguments)
  },
// organization_environments => /organizations/:organization_id/environments(.:format)
  organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(1, ["/organizations/", "/environments"], ["format"], arguments)
  },
// errata_content_search_index => /content_search/errata(.:format)
  errata_content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search/errata"], ["format"], arguments)
  },
// add_system_system_packages => /systems/:system_id/system_packages/add(.:format)
  add_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/system_packages/add"], ["format"], arguments)
  },
// edit_api_organization_environment => /api/organizations/:organization_id/environments/:id/edit(.:format)
  edit_api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/environments/", "/edit"], ["format"], arguments)
  },
// update_repo_gpg_key_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/update_gpg_key(.:format)
  update_repo_gpg_key_provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/repositories/", "/update_gpg_key"], ["format"], arguments)
  },
// notices_auto_complete_search => /notices/auto_complete_search(.:format)
  notices_auto_complete_search_path: function(options) {
  return Utils.build_path(0, ["/notices/auto_complete_search"], ["format"], arguments)
  },
// repo_packages_content_search_index => /content_search/repo_packages(.:format)
  repo_packages_content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search/repo_packages"], ["format"], arguments)
  },
// new_api_system_packages => /api/systems/:system_id/packages/new(.:format)
  new_api_system_packages_path: function(_system_id, options) {
  return Utils.build_path(1, ["/api/systems/", "/packages/new"], ["format"], arguments)
  },
// items_system_errata => /systems/:system_id/errata/items(.:format)
  items_system_errata_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/errata/items"], ["format"], arguments)
  },
// new_provider_product => /providers/:provider_id/products/new(.:format)
  new_provider_product_path: function(_provider_id, options) {
  return Utils.build_path(1, ["/providers/", "/products/new"], ["format"], arguments)
  },
// items_subscriptions => /subscriptions/items(.:format)
  items_subscriptions_path: function(options) {
  return Utils.build_path(0, ["/subscriptions/items"], ["format"], arguments)
  },
// auto_complete_nvrea_library_packages => /packages/auto_complete_nvrea_library(.:format)
  auto_complete_nvrea_library_packages_path: function(options) {
  return Utils.build_path(0, ["/packages/auto_complete_nvrea_library"], ["format"], arguments)
  },
// edit_content_search => /content_search/:id/edit(.:format)
  edit_content_search_path: function(_id, options) {
  return Utils.build_path(1, ["/content_search/", "/edit"], ["format"], arguments)
  },
// import_manifest_api_provider => /api/providers/:id/import_manifest(.:format)
  import_manifest_api_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/api/providers/", "/import_manifest"], ["format"], arguments)
  },
// subscriptions_system => /systems/:id/subscriptions(.:format)
  subscriptions_system_path: function(_id, options) {
  return Utils.build_path(1, ["/systems/", "/subscriptions"], ["format"], arguments)
  },
// discovered_repos_provider => /providers/:id/discovered_repos(.:format)
  discovered_repos_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/providers/", "/discovered_repos"], ["format"], arguments)
  },
// new_user_session => /user_session/new(.:format)
  new_user_session_path: function(options) {
  return Utils.build_path(0, ["/user_session/new"], ["format"], arguments)
  },
// add_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/add_systems(.:format)
  add_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/system_groups/", "/add_systems"], ["format"], arguments)
  },
// add_system_groups_system => /systems/:id/add_system_groups(.:format)
  add_system_groups_system_path: function(_id, options) {
  return Utils.build_path(1, ["/systems/", "/add_system_groups"], ["format"], arguments)
  },
// schedule_provider => /providers/:id/schedule(.:format)
  schedule_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/providers/", "/schedule"], ["format"], arguments)
  },
// edit_api_organization_system_group_packages => /api/organizations/:organization_id/system_groups/:system_group_id/packages/edit(.:format)
  edit_api_organization_system_group_packages_path: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/system_groups/", "/packages/edit"], ["format"], arguments)
  },
// enable_helptip_users => /users/enable_helptip(.:format)
  enable_helptip_users_path: function(options) {
  return Utils.build_path(0, ["/users/enable_helptip"], ["format"], arguments)
  },
// edit_environment => /environments/:id/edit(.:format)
  edit_environment_path: function(_id, options) {
  return Utils.build_path(1, ["/environments/", "/edit"], ["format"], arguments)
  },
// activation_keys => /activation_keys(.:format)
  activation_keys_path: function(options) {
  return Utils.build_path(0, ["/activation_keys"], ["format"], arguments)
  },
// validate_api_template => /api/templates/:id/validate(.:format)
  validate_api_template_path: function(_id, options) {
  return Utils.build_path(1, ["/api/templates/", "/validate"], ["format"], arguments)
  },
// bulk_destroy_systems => /systems/bulk_destroy(.:format)
  bulk_destroy_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/bulk_destroy"], ["format"], arguments)
  },
// promote_api_changeset => /api/changesets/:id/promote(.:format)
  promote_api_changeset_path: function(_id, options) {
  return Utils.build_path(1, ["/api/changesets/", "/promote"], ["format"], arguments)
  },
// edit_api_changeset_product => /api/changesets/:changeset_id/products/:id/edit(.:format)
  edit_api_changeset_product_path: function(_changeset_id, _id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/products/", "/edit"], ["format"], arguments)
  },
// setup_default_org_user => /users/:id/setup_default_org(.:format)
  setup_default_org_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/setup_default_org"], ["format"], arguments)
  },
// provider => /providers/:id(.:format)
  provider_path: function(_id, options) {
  return Utils.build_path(1, ["/providers/"], ["format"], arguments)
  },
// apply_changeset => /changesets/:id/apply(.:format)
  apply_changeset_path: function(_id, options) {
  return Utils.build_path(1, ["/changesets/", "/apply"], ["format"], arguments)
  },
// bulk_errata_install_systems => /systems/bulk_errata_install(.:format)
  bulk_errata_install_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/bulk_errata_install"], ["format"], arguments)
  },
// items_sync_plans => /sync_plans/items(.:format)
  items_sync_plans_path: function(options) {
  return Utils.build_path(0, ["/sync_plans/items"], ["format"], arguments)
  },
// edit_api_template_parameter => /api/templates/:template_id/parameters/:id/edit(.:format)
  edit_api_template_parameter_path: function(_template_id, _id, options) {
  return Utils.build_path(2, ["/api/templates/", "/parameters/", "/edit"], ["format"], arguments)
  },
// status_system_group_events => /system_groups/:system_group_id/events/status(.:format)
  status_system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/events/status"], ["format"], arguments)
  },
// edit_api_changeset_repository => /api/changesets/:changeset_id/repositories/:id/edit(.:format)
  edit_api_changeset_repository_path: function(_changeset_id, _id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/repositories/", "/edit"], ["format"], arguments)
  },
// object_system_template => /system_templates/:id/object(.:format)
  object_system_template_path: function(_id, options) {
  return Utils.build_path(1, ["/system_templates/", "/object"], ["format"], arguments)
  },
// sync_schedules_apply => /sync_schedules/apply(.:format)
  sync_schedules_apply_path: function(options) {
  return Utils.build_path(0, ["/sync_schedules/apply"], ["format"], arguments)
  },
// subscriptions_activation_keys => /activation_keys/subscriptions(.:format)
  subscriptions_activation_keys_path: function(options) {
  return Utils.build_path(0, ["/activation_keys/subscriptions"], ["format"], arguments)
  },
// remove_system_group_packages => /system_groups/:system_group_id/packages/remove(.:format)
  remove_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/packages/remove"], ["format"], arguments)
  },
// auto_complete_search_roles => /roles/auto_complete_search(.:format)
  auto_complete_search_roles_path: function(options) {
  return Utils.build_path(0, ["/roles/auto_complete_search"], ["format"], arguments)
  },
// sync_management_product_status => /sync_management/product_status(.:format)
  sync_management_product_status_path: function(options) {
  return Utils.build_path(0, ["/sync_management/product_status"], ["format"], arguments)
  },
// edit_api_template_distribution => /api/templates/:template_id/distributions/:id/edit(.:format)
  edit_api_template_distribution_path: function(_template_id, _id, options) {
  return Utils.build_path(2, ["/api/templates/", "/distributions/", "/edit"], ["format"], arguments)
  },
// search_api_repository_packages => /api/repositories/:repository_id/packages/search(.:format)
  search_api_repository_packages_path: function(_format, options) {
  return Utils.build_path(1, ["/api/repositories/", "/packages/search"], ["repository_id"], arguments)
  },
// items_system_groups => /system_groups/items(.:format)
  items_system_groups_path: function(options) {
  return Utils.build_path(0, ["/system_groups/items"], ["format"], arguments)
  },
// new_api_template => /api/templates/new(.:format)
  new_api_template_path: function(options) {
  return Utils.build_path(0, ["/api/templates/new"], ["format"], arguments)
  },
// remove_systems_system_group => /system_groups/:id/remove_systems(.:format)
  remove_systems_system_group_path: function(_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/remove_systems"], ["format"], arguments)
  },
// new_user => /users/new(.:format)
  new_user_path: function(options) {
  return Utils.build_path(0, ["/users/new"], ["format"], arguments)
  },
// sync_plan => /sync_plans/:id(.:format)
  sync_plan_path: function(_id, options) {
  return Utils.build_path(1, ["/sync_plans/"], ["format"], arguments)
  },
// activation_key => /activation_keys/:id(.:format)
  activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/activation_keys/"], ["format"], arguments)
  },
// enable_api_repository => /api/repositories/:id/enable(.:format)
  enable_api_repository_path: function(_format, options) {
  return Utils.build_path(1, ["/api/repositories/", "/enable"], ["id"], arguments)
  },
// default_label_organizations => /organizations/default_label(.:format)
  default_label_organizations_path: function(options) {
  return Utils.build_path(0, ["/organizations/default_label"], ["format"], arguments)
  },
// repositories_api_environment_product => /api/environments/:environment_id/products/:id/repositories(.:format)
  repositories_api_environment_product_path: function(_environment_id, _id, options) {
  return Utils.build_path(2, ["/api/environments/", "/products/", "/repositories"], ["format"], arguments)
  },
// install_system_group_errata => /system_groups/:system_group_id/errata/install(.:format)
  install_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/errata/install"], ["format"], arguments)
  },
// role_permission_destroy => /roles/:role_id/permission/:permission_id/destroy_permission(.:format)
  role_permission_destroy_path: function(_role_id, _permission_id, options) {
  return Utils.build_path(2, ["/roles/", "/permission/", "/destroy_permission"], ["format"], arguments)
  },
// system => /systems/:id(.:format)
  system_path: function(_id, options) {
  return Utils.build_path(1, ["/systems/"], ["format"], arguments)
  },
// new_provider => /providers/new(.:format)
  new_provider_path: function(options) {
  return Utils.build_path(0, ["/providers/new"], ["format"], arguments)
  },
// content_api_gpg_key => /api/gpg_keys/:id/content(.:format)
  content_api_gpg_key_path: function(_id, options) {
  return Utils.build_path(1, ["/api/gpg_keys/", "/content"], ["format"], arguments)
  },
// releases_api_system => /api/systems/:id/releases(.:format)
  releases_api_system_path: function(_id, options) {
  return Utils.build_path(1, ["/api/systems/", "/releases"], ["format"], arguments)
  },
// subscriptions => /subscriptions(.:format)
  subscriptions_path: function(options) {
  return Utils.build_path(0, ["/subscriptions"], ["format"], arguments)
  },
// history_search_index => /search/history(.:format)
  history_search_index_path: function(options) {
  return Utils.build_path(0, ["/search/history"], ["format"], arguments)
  },
// subscription => /subscriptions/:id(.:format)
  subscription_path: function(_id, options) {
  return Utils.build_path(1, ["/subscriptions/"], ["format"], arguments)
  },
// new_system => /systems/new(.:format)
  new_system_path: function(options) {
  return Utils.build_path(0, ["/systems/new"], ["format"], arguments)
  },
// items_system_templates => /system_templates/items(.:format)
  items_system_templates_path: function(options) {
  return Utils.build_path(0, ["/system_templates/items"], ["format"], arguments)
  },
// edit_changeset => /changesets/:id/edit(.:format)
  edit_changeset_path: function(_id, options) {
  return Utils.build_path(1, ["/changesets/", "/edit"], ["format"], arguments)
  },
// systems_dashboard_index => /dashboard/systems(.:format)
  systems_dashboard_index_path: function(options) {
  return Utils.build_path(0, ["/dashboard/systems"], ["format"], arguments)
  },
// auto_complete_products => /products/auto_complete(.:format)
  auto_complete_products_path: function(options) {
  return Utils.build_path(0, ["/products/auto_complete"], ["format"], arguments)
  },
// items_system_events => /systems/:system_id/events/items(.:format)
  items_system_events_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/events/items"], ["format"], arguments)
  },
// items_gpg_keys => /gpg_keys/items(.:format)
  items_gpg_keys_path: function(options) {
  return Utils.build_path(0, ["/gpg_keys/items"], ["format"], arguments)
  },
// report_api_organization_systems => /api/organizations/:organization_id/systems/report(.:format)
  report_api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(1, ["/api/organizations/", "/systems/report"], ["format"], arguments)
  },
// new_organization_environment => /organizations/:organization_id/environments/new(.:format)
  new_organization_environment_path: function(_organization_id, options) {
  return Utils.build_path(1, ["/organizations/", "/environments/new"], ["format"], arguments)
  },
// password_reset => /password_resets/:id(.:format)
  password_reset_path: function(_id, options) {
  return Utils.build_path(1, ["/password_resets/"], ["format"], arguments)
  },
// products_content_search_index => /content_search/products(.:format)
  products_content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search/products"], ["format"], arguments)
  },
// remove_system_system_packages => /systems/:system_id/system_packages/remove(.:format)
  remove_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/system_packages/remove"], ["format"], arguments)
  },
// provider_product_repositories => /providers/:provider_id/products/:product_id/repositories(.:format)
  provider_product_repositories_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(2, ["/providers/", "/products/", "/repositories"], ["format"], arguments)
  },
// repo_errata_content_search_index => /content_search/repo_errata(.:format)
  repo_errata_content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search/repo_errata"], ["format"], arguments)
  },
// edit_api_system_packages => /api/systems/:system_id/packages/edit(.:format)
  edit_api_system_packages_path: function(_system_id, options) {
  return Utils.build_path(1, ["/api/systems/", "/packages/edit"], ["format"], arguments)
  },
// install_system_errata => /systems/:system_id/errata/install(.:format)
  install_system_errata_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/errata/install"], ["format"], arguments)
  },
// edit_provider_product => /providers/:provider_id/products/:id/edit(.:format)
  edit_provider_product_path: function(_provider_id, _id, options) {
  return Utils.build_path(2, ["/providers/", "/products/", "/edit"], ["format"], arguments)
  },
// upload_subscriptions => /subscriptions/upload(.:format)
  upload_subscriptions_path: function(options) {
  return Utils.build_path(0, ["/subscriptions/upload"], ["format"], arguments)
  },
// validate_name_library_packages => /packages/validate_name_library(.:format)
  validate_name_library_packages_path: function(options) {
  return Utils.build_path(0, ["/packages/validate_name_library"], ["format"], arguments)
  },
// delete_manifest_api_provider => /api/providers/:id/delete_manifest(.:format)
  delete_manifest_api_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/api/providers/", "/delete_manifest"], ["format"], arguments)
  },
// update_subscriptions_system => /systems/:id/update_subscriptions(.:format)
  update_subscriptions_system_path: function(_id, options) {
  return Utils.build_path(1, ["/systems/", "/update_subscriptions"], ["format"], arguments)
  },
// new_discovered_repos_provider => /providers/:id/new_discovered_repos(.:format)
  new_discovered_repos_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/providers/", "/new_discovered_repos"], ["format"], arguments)
  },
// copy_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/copy(.:format)
  copy_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/system_groups/", "/copy"], ["format"], arguments)
  },
// new_api_provider => /api/providers/new(.:format)
  new_api_provider_path: function(options) {
  return Utils.build_path(0, ["/api/providers/new"], ["format"], arguments)
  },
// remove_system_groups_system => /systems/:id/remove_system_groups(.:format)
  remove_system_groups_system_path: function(_id, options) {
  return Utils.build_path(1, ["/systems/", "/remove_system_groups"], ["format"], arguments)
  },
// notices_get_new => /notices/get_new(.:format)
  notices_get_new_path: function(options) {
  return Utils.build_path(0, ["/notices/get_new"], ["format"], arguments)
  },
// disable_helptip_users => /users/disable_helptip(.:format)
  disable_helptip_users_path: function(options) {
  return Utils.build_path(0, ["/users/disable_helptip"], ["format"], arguments)
  },
// new_organization => /organizations/new(.:format)
  new_organization_path: function(options) {
  return Utils.build_path(0, ["/organizations/new"], ["format"], arguments)
  },
// bulk_add_system_group_systems => /systems/bulk_add_system_group(.:format)
  bulk_add_system_group_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/bulk_add_system_group"], ["format"], arguments)
  },
// apply_api_changeset => /api/changesets/:id/apply(.:format)
  apply_api_changeset_path: function(_id, options) {
  return Utils.build_path(1, ["/api/changesets/", "/apply"], ["format"], arguments)
  },
// edit_environment_user => /users/:id/edit_environment(.:format)
  edit_environment_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/edit_environment"], ["format"], arguments)
  },
// status_changeset => /changesets/:id/status(.:format)
  status_changeset_path: function(_id, options) {
  return Utils.build_path(1, ["/changesets/", "/status"], ["format"], arguments)
  },
// new_api_template_package => /api/templates/:template_id/packages/new(.:format)
  new_api_template_package_path: function(_template_id, options) {
  return Utils.build_path(1, ["/api/templates/", "/packages/new"], ["format"], arguments)
  },
// new_api_changeset_erratum => /api/changesets/:changeset_id/errata/new(.:format)
  new_api_changeset_erratum_path: function(_changeset_id, options) {
  return Utils.build_path(1, ["/api/changesets/", "/errata/new"], ["format"], arguments)
  },
// more_items_system_group_events => /system_groups/:system_group_id/events/more_items(.:format)
  more_items_system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/events/more_items"], ["format"], arguments)
  },
// roles_show_permission => /roles/show_permission(.:format)
  roles_show_permission_path: function(options) {
  return Utils.build_path(0, ["/roles/show_permission"], ["format"], arguments)
  },
// new_api_template_package_group_category => /api/templates/:template_id/package_group_categories/new(.:format)
  new_api_template_package_group_category_path: function(_template_id, options) {
  return Utils.build_path(1, ["/api/templates/", "/package_group_categories/new"], ["format"], arguments)
  },
// applied_subscriptions_activation_key => /activation_keys/:id/applied_subscriptions(.:format)
  applied_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/activation_keys/", "/applied_subscriptions"], ["format"], arguments)
  },
// new_api_changeset_template => /api/changesets/:changeset_id/templates/new(.:format)
  new_api_changeset_template_path: function(_changeset_id, options) {
  return Utils.build_path(1, ["/api/changesets/", "/templates/new"], ["format"], arguments)
  },
// items_roles => /roles/items(.:format)
  items_roles_path: function(options) {
  return Utils.build_path(0, ["/roles/items"], ["format"], arguments)
  },
// auto_complete_system_groups => /system_groups/auto_complete(.:format)
  auto_complete_system_groups_path: function(options) {
  return Utils.build_path(0, ["/system_groups/auto_complete"], ["format"], arguments)
  },
// edit_api_template => /api/templates/:id/edit(.:format)
  edit_api_template_path: function(_id, options) {
  return Utils.build_path(1, ["/api/templates/", "/edit"], ["format"], arguments)
  },
// password_resets => /password_resets(.:format)
  password_resets_path: function(options) {
  return Utils.build_path(0, ["/password_resets"], ["format"], arguments)
  },
// notices => /notices(.:format)
  notices_path: function(options) {
  return Utils.build_path(0, ["/notices"], ["format"], arguments)
  },
// destroy_systems_system_group => /system_groups/:id/destroy_systems(.:format)
  destroy_systems_system_group_path: function(_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/destroy_systems"], ["format"], arguments)
  },
// edit_user => /users/:id/edit(.:format)
  edit_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/edit"], ["format"], arguments)
  },
// jammit => /assets/:package.:extension(.:format)
  jammit_path: function(_package, _format, options) {
  return Utils.build_path(2, ["/assets/", "."], ["extension"], arguments)
  },
// about => /about(.:format)
  about_path: function(options) {
  return Utils.build_path(0, ["/about"], ["format"], arguments)
  },
// sync_complete_api_repositories => /api/repositories/sync_complete(.:format)
  sync_complete_api_repositories_path: function(options) {
  return Utils.build_path(0, ["/api/repositories/sync_complete"], ["format"], arguments)
  },
// sync_schedules_index => /sync_schedules/index(.:format)
  sync_schedules_index_path: function(options) {
  return Utils.build_path(0, ["/sync_schedules/index"], ["format"], arguments)
  },
// packages_erratum => /errata/:id/packages(.:format)
  packages_erratum_path: function(_id, options) {
  return Utils.build_path(1, ["/errata/", "/packages"], ["format"], arguments)
  },
// login => /login(.:format)
  login_path: function(options) {
  return Utils.build_path(0, ["/login"], ["format"], arguments)
  },
// environments_partial_organization => /organizations/:id/environments_partial(.:format)
  environments_partial_organization_path: function(_id, options) {
  return Utils.build_path(1, ["/organizations/", "/environments_partial"], ["format"], arguments)
  },
// edit_provider => /providers/:id/edit(.:format)
  edit_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/providers/", "/edit"], ["format"], arguments)
  },
// status_system_group_errata => /system_groups/:system_group_id/errata/status(.:format)
  status_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/errata/status"], ["format"], arguments)
  },
// sync_management_sync_status => /sync_management/sync_status(.:format)
  sync_management_sync_status_path: function(options) {
  return Utils.build_path(0, ["/sync_management/sync_status"], ["format"], arguments)
  },
// enabled_repos_api_system => /api/systems/:id/enabled_repos(.:format)
  enabled_repos_api_system_path: function(_id, options) {
  return Utils.build_path(1, ["/api/systems/", "/enabled_repos"], ["format"], arguments)
  },
// new_role => /roles/new(.:format)
  new_role_path: function(options) {
  return Utils.build_path(0, ["/roles/new"], ["format"], arguments)
  },
// packages_promotion => /promotions/:id/packages(.:format)
  packages_promotion_path: function(_id, options) {
  return Utils.build_path(1, ["/promotions/", "/packages"], ["format"], arguments)
  },
// new_api_user => /api/users/new(.:format)
  new_api_user_path: function(options) {
  return Utils.build_path(0, ["/api/users/new"], ["format"], arguments)
  },
// product_packages_system_templates => /system_templates/product_packages(.:format)
  product_packages_system_templates_path: function(options) {
  return Utils.build_path(0, ["/system_templates/product_packages"], ["format"], arguments)
  },
// email_logins_password_resets => /password_resets/email_logins(.:format)
  email_logins_password_resets_path: function(options) {
  return Utils.build_path(0, ["/password_resets/email_logins"], ["format"], arguments)
  },
// system_groups_dashboard_index => /dashboard/system_groups(.:format)
  system_groups_dashboard_index_path: function(options) {
  return Utils.build_path(0, ["/dashboard/system_groups"], ["format"], arguments)
  },
// system_templates => /system_templates(.:format)
  system_templates_path: function(options) {
  return Utils.build_path(0, ["/system_templates"], ["format"], arguments)
  },
// changesets => /changesets(.:format)
  changesets_path: function(options) {
  return Utils.build_path(0, ["/changesets"], ["format"], arguments)
  },
// products_repos_gpg_key => /gpg_keys/:id/products_repos(.:format)
  products_repos_gpg_key_path: function(_id, options) {
  return Utils.build_path(1, ["/gpg_keys/", "/products_repos"], ["format"], arguments)
  },
// tasks_api_organization_systems => /api/organizations/:organization_id/systems/tasks(.:format)
  tasks_api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(1, ["/api/organizations/", "/systems/tasks"], ["format"], arguments)
  },
// allowed_orgs_user_session => /user_session/allowed_orgs(.:format)
  allowed_orgs_user_session_path: function(options) {
  return Utils.build_path(0, ["/user_session/allowed_orgs"], ["format"], arguments)
  },
// users => /users(.:format)
  users_path: function(options) {
  return Utils.build_path(0, ["/users"], ["format"], arguments)
  },
// edit_organization_environment => /organizations/:organization_id/environments/:id/edit(.:format)
  edit_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments/", "/edit"], ["format"], arguments)
  },
// roles => /roles(.:format)
  roles_path: function(options) {
  return Utils.build_path(0, ["/roles"], ["format"], arguments)
  },
// gpg_key => /gpg_keys/:id(.:format)
  gpg_key_path: function(_id, options) {
  return Utils.build_path(1, ["/gpg_keys/"], ["format"], arguments)
  },
// packages_content_search_index => /content_search/packages(.:format)
  packages_content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search/packages"], ["format"], arguments)
  },
// system_system_packages => /systems/:system_id/system_packages(.:format)
  system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/system_packages"], ["format"], arguments)
  },
// new_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/new(.:format)
  new_provider_product_repository_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(2, ["/providers/", "/products/", "/repositories/new"], ["format"], arguments)
  },
// delete_manifest_subscriptions => /subscriptions/delete_manifest(.:format)
  delete_manifest_subscriptions_path: function(options) {
  return Utils.build_path(0, ["/subscriptions/delete_manifest"], ["format"], arguments)
  },
// changelog_package => /packages/:id/changelog(.:format)
  changelog_package_path: function(_id, options) {
  return Utils.build_path(1, ["/packages/", "/changelog"], ["format"], arguments)
  },
// system_templates_promotion => /promotions/:id/system_templates(.:format)
  system_templates_promotion_path: function(_id, options) {
  return Utils.build_path(1, ["/promotions/", "/system_templates"], ["format"], arguments)
  },
// repo_compare_packages_content_search_index => /content_search/repo_compare_packages(.:format)
  repo_compare_packages_content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search/repo_compare_packages"], ["format"], arguments)
  },
// status_system_errata => /systems/:system_id/errata/status(.:format)
  status_system_errata_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/errata/status"], ["format"], arguments)
  },
// provider_product => /providers/:provider_id/products/:id(.:format)
  provider_product_path: function(_provider_id, _id, options) {
  return Utils.build_path(2, ["/providers/", "/products/"], ["format"], arguments)
  },
// remove_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/remove_systems(.:format)
  remove_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/system_groups/", "/remove_systems"], ["format"], arguments)
  },
// product_repos_system_templates => /system_templates/product_repos(.:format)
  product_repos_system_templates_path: function(options) {
  return Utils.build_path(0, ["/system_templates/product_repos"], ["format"], arguments)
  },
// new_environment => /environments/new(.:format)
  new_environment_path: function(options) {
  return Utils.build_path(0, ["/environments/new"], ["format"], arguments)
  },
// refresh_products_api_provider => /api/providers/:id/refresh_products(.:format)
  refresh_products_api_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/api/providers/", "/refresh_products"], ["format"], arguments)
  },
// products_system => /systems/:id/products(.:format)
  products_system_path: function(_id, options) {
  return Utils.build_path(1, ["/systems/", "/products"], ["format"], arguments)
  },
// discover_provider => /providers/:id/discover(.:format)
  discover_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/providers/", "/discover"], ["format"], arguments)
  },
// edit_api_provider => /api/providers/:id/edit(.:format)
  edit_api_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/api/providers/", "/edit"], ["format"], arguments)
  },
// auto_complete_systems => /systems/auto_complete(.:format)
  auto_complete_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/auto_complete"], ["format"], arguments)
  },
// clear_helptips_user => /users/:id/clear_helptips(.:format)
  clear_helptips_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/clear_helptips"], ["format"], arguments)
  },
// edit_organization => /organizations/:id/edit(.:format)
  edit_organization_path: function(_id, options) {
  return Utils.build_path(1, ["/organizations/", "/edit"], ["format"], arguments)
  },
// bulk_remove_system_group_systems => /systems/bulk_remove_system_group(.:format)
  bulk_remove_system_group_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/bulk_remove_system_group"], ["format"], arguments)
  },
// dependencies_api_changeset => /api/changesets/:id/dependencies(.:format)
  dependencies_api_changeset_path: function(_id, options) {
  return Utils.build_path(1, ["/api/changesets/", "/dependencies"], ["format"], arguments)
  },
// update_environment_user => /users/:id/update_environment(.:format)
  update_environment_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/update_environment"], ["format"], arguments)
  },
// object_changeset => /changesets/:id/object(.:format)
  object_changeset_path: function(_id, options) {
  return Utils.build_path(1, ["/changesets/", "/object"], ["format"], arguments)
  },
// edit_api_template_package => /api/templates/:template_id/packages/:id/edit(.:format)
  edit_api_template_package_path: function(_template_id, _format, options) {
  return Utils.build_path(2, ["/api/templates/", "/packages/", "/edit"], ["id"], arguments)
  },
// edit_api_changeset_erratum => /api/changesets/:changeset_id/errata/:id/edit(.:format)
  edit_api_changeset_erratum_path: function(_changeset_id, _id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/errata/", "/edit"], ["format"], arguments)
  },
// items_system_group_events => /system_groups/:system_group_id/events/items(.:format)
  items_system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/events/items"], ["format"], arguments)
  },
// edit_api_template_package_group_category => /api/templates/:template_id/package_group_categories/:id/edit(.:format)
  edit_api_template_package_group_category_path: function(_template_id, _id, options) {
  return Utils.build_path(2, ["/api/templates/", "/package_group_categories/", "/edit"], ["format"], arguments)
  },
// sync_management => /sync_management/:id(.:format)
  sync_management_path: function(_id, options) {
  return Utils.build_path(1, ["/sync_management/"], ["format"], arguments)
  },
// available_subscriptions_activation_key => /activation_keys/:id/available_subscriptions(.:format)
  available_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/activation_keys/", "/available_subscriptions"], ["format"], arguments)
  },
// edit_api_changeset_template => /api/changesets/:changeset_id/templates/:id/edit(.:format)
  edit_api_changeset_template_path: function(_changeset_id, _id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/templates/", "/edit"], ["format"], arguments)
  },
// destroy_role_ldap_group => /roles/:role_id/ldap_groups/:id(.:format)
  destroy_role_ldap_group_path: function(_role_id, _id, options) {
  return Utils.build_path(2, ["/roles/", "/ldap_groups/"], ["format"], arguments)
  },
// notices_note_count => /notices/note_count(.:format)
  notices_note_count_path: function(options) {
  return Utils.build_path(0, ["/notices/note_count"], ["format"], arguments)
  },
// new_api_repository_package => /api/repositories/:repository_id/packages/new(.:format)
  new_api_repository_package_path: function(_format, options) {
  return Utils.build_path(1, ["/api/repositories/", "/packages/new"], ["repository_id"], arguments)
  },
// validate_name_system_groups => /system_groups/validate_name(.:format)
  validate_name_system_groups_path: function(options) {
  return Utils.build_path(0, ["/system_groups/validate_name"], ["format"], arguments)
  },
// distributions_promotion => /promotions/:id/distributions(.:format)
  distributions_promotion_path: function(_id, options) {
  return Utils.build_path(1, ["/promotions/", "/distributions"], ["format"], arguments)
  },
// systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/systems(.:format)
  systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/system_groups/", "/systems"], ["format"], arguments)
  },
// events_organization => /organizations/:id/events(.:format)
  events_organization_path: function(_id, options) {
  return Utils.build_path(1, ["/organizations/", "/events"], ["format"], arguments)
  },
// short_details_erratum => /errata/:id/short_details(.:format)
  short_details_erratum_path: function(_id, options) {
  return Utils.build_path(1, ["/errata/", "/short_details"], ["format"], arguments)
  },
// system_groups_activation_key => /activation_keys/:id/system_groups(.:format)
  system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/activation_keys/", "/system_groups"], ["format"], arguments)
  },
// promotions => /promotions(.:format)
  promotions_path: function(options) {
  return Utils.build_path(0, ["/promotions"], ["format"], arguments)
  },
// pools_api_activation_key => /api/activation_keys/:id/pools(.:format)
  pools_api_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/api/activation_keys/", "/pools"], ["format"], arguments)
  },
// new_repository => /repositories/new(.:format)
  new_repository_path: function(options) {
  return Utils.build_path(0, ["/repositories/new"], ["format"], arguments)
  },
// system_groups_api_system => /api/systems/:id/system_groups(.:format)
  system_groups_api_system_path: function(_id, options) {
  return Utils.build_path(1, ["/api/systems/", "/system_groups"], ["format"], arguments)
  },
// edit_role => /roles/:id/edit(.:format)
  edit_role_path: function(_id, options) {
  return Utils.build_path(1, ["/roles/", "/edit"], ["format"], arguments)
  },
// organizations => /organizations(.:format)
  organizations_path: function(options) {
  return Utils.build_path(0, ["/organizations"], ["format"], arguments)
  },
// report_api_users => /api/users/report(.:format)
  report_api_users_path: function(options) {
  return Utils.build_path(0, ["/api/users/report"], ["format"], arguments)
  },
// edit_api_user => /api/users/:id/edit(.:format)
  edit_api_user_path: function(_id, options) {
  return Utils.build_path(1, ["/api/users/", "/edit"], ["format"], arguments)
  },
// sync_dashboard_index => /dashboard/sync(.:format)
  sync_dashboard_index_path: function(options) {
  return Utils.build_path(0, ["/dashboard/sync"], ["format"], arguments)
  },
// sync_management_sync => /sync_management/sync(.:format)
  sync_management_sync_path: function(options) {
  return Utils.build_path(0, ["/sync_management/sync"], ["format"], arguments)
  },
// products_organization_environment => /organizations/:organization_id/environments/:id/products(.:format)
  products_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments/", "/products"], ["format"], arguments)
  },
// subscriptions_dashboard_index => /dashboard/subscriptions(.:format)
  subscriptions_dashboard_index_path: function(options) {
  return Utils.build_path(0, ["/dashboard/subscriptions"], ["format"], arguments)
  },
// providers => /providers(.:format)
  providers_path: function(options) {
  return Utils.build_path(0, ["/providers"], ["format"], arguments)
  },
// operations => /operations(.:format)
  operations_path: function(options) {
  return Utils.build_path(0, ["/operations"], ["format"], arguments)
  },
// rails_info_properties => /rails/info/properties(.:format)
  rails_info_properties_path: function(options) {
  return Utils.build_path(0, ["/rails/info/properties"], ["format"], arguments)
  },
// new_api_consumer => /api/consumers/new(.:format)
  new_api_consumer_path: function(options) {
  return Utils.build_path(0, ["/api/consumers/new"], ["format"], arguments)
  },
// package => /packages/:id(.:format)
  package_path: function(_id, options) {
  return Utils.build_path(1, ["/packages/"], ["format"], arguments)
  },
// system_groups_api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id/system_groups(.:format)
  system_groups_api_organization_activation_key_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/activation_keys/", "/system_groups"], ["format"], arguments)
  },
// auto_complete_search_providers => /providers/auto_complete_search(.:format)
  auto_complete_search_providers_path: function(options) {
  return Utils.build_path(0, ["/providers/auto_complete_search"], ["format"], arguments)
  },
// organization_environment => /organizations/:organization_id/environments/:id(.:format)
  organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/organizations/", "/environments/"], ["format"], arguments)
  },
// new_system_group => /system_groups/new(.:format)
  new_system_group_path: function(options) {
  return Utils.build_path(0, ["/system_groups/new"], ["format"], arguments)
  },
// repositories => /repositories(.:format)
  repositories_path: function(options) {
  return Utils.build_path(0, ["/repositories"], ["format"], arguments)
  },
// edit_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/edit(.:format)
  edit_provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/repositories/", "/edit"], ["format"], arguments)
  },
// edit_subscription => /subscriptions/:id/edit(.:format)
  edit_subscription_path: function(_id, options) {
  return Utils.build_path(1, ["/subscriptions/", "/edit"], ["format"], arguments)
  },
// packages_items_content_search_index => /content_search/packages_items(.:format)
  packages_items_content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search/packages_items"], ["format"], arguments)
  },
// packages_system_system_packages => /systems/:system_id/system_packages/packages(.:format)
  packages_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/system_packages/packages"], ["format"], arguments)
  },
// new_api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/new(.:format)
  new_api_organization_sync_plan_path: function(_organization_id, options) {
  return Utils.build_path(1, ["/api/organizations/", "/sync_plans/new"], ["format"], arguments)
  },
// items_providers => /providers/items(.:format)
  items_providers_path: function(options) {
  return Utils.build_path(0, ["/providers/items"], ["format"], arguments)
  },
// set_org_user_session => /user_session/set_org(.:format)
  set_org_user_session_path: function(options) {
  return Utils.build_path(0, ["/user_session/set_org"], ["format"], arguments)
  },
// history_subscriptions => /subscriptions/history(.:format)
  history_subscriptions_path: function(options) {
  return Utils.build_path(0, ["/subscriptions/history"], ["format"], arguments)
  },
// filelist_package => /packages/:id/filelist(.:format)
  filelist_package_path: function(_id, options) {
  return Utils.build_path(1, ["/packages/", "/filelist"], ["format"], arguments)
  },
// repo_compare_errata_content_search_index => /content_search/repo_compare_errata(.:format)
  repo_compare_errata_content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search/repo_compare_errata"], ["format"], arguments)
  },
// system_errata => /systems/:system_id/errata(.:format)
  system_errata_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/errata"], ["format"], arguments)
  },
// cancel_discovery_provider => /providers/:id/cancel_discovery(.:format)
  cancel_discovery_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/providers/", "/cancel_discovery"], ["format"], arguments)
  },
// destroy_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/destroy_systems(.:format)
  destroy_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/system_groups/", "/destroy_systems"], ["format"], arguments)
  },
// product_create_api_provider => /api/providers/:id/product_create(.:format)
  product_create_api_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/api/providers/", "/product_create"], ["format"], arguments)
  },
// more_products_system => /systems/:id/more_products(.:format)
  more_products_system_path: function(_id, options) {
  return Utils.build_path(1, ["/systems/", "/more_products"], ["format"], arguments)
  },
// items_systems => /systems/items(.:format)
  items_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/items"], ["format"], arguments)
  },
// new_api_organization => /api/organizations/new(.:format)
  new_api_organization_path: function(options) {
  return Utils.build_path(0, ["/api/organizations/new"], ["format"], arguments)
  },
// update_roles_user => /users/:id/update_roles(.:format)
  update_roles_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/update_roles"], ["format"], arguments)
  },
// new_api_template_product => /api/templates/:template_id/products/new(.:format)
  new_api_template_product_path: function(_template_id, options) {
  return Utils.build_path(1, ["/api/templates/", "/products/new"], ["format"], arguments)
  },
// bulk_content_install_systems => /systems/bulk_content_install(.:format)
  bulk_content_install_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/bulk_content_install"], ["format"], arguments)
  },
// new_api_changeset_package => /api/changesets/:changeset_id/packages/new(.:format)
  new_api_changeset_package_path: function(_changeset_id, options) {
  return Utils.build_path(1, ["/api/changesets/", "/packages/new"], ["format"], arguments)
  },
// system_template => /system_templates/:id(.:format)
  system_template_path: function(_id, options) {
  return Utils.build_path(1, ["/system_templates/"], ["format"], arguments)
  },
// auto_complete_search_changesets => /changesets/auto_complete_search(.:format)
  auto_complete_search_changesets_path: function(options) {
  return Utils.build_path(0, ["/changesets/auto_complete_search"], ["format"], arguments)
  },
// new_gpg_key => /gpg_keys/new(.:format)
  new_gpg_key_path: function(options) {
  return Utils.build_path(0, ["/gpg_keys/new"], ["format"], arguments)
  },
// system_group_events => /system_groups/:system_group_id/events(.:format)
  system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/events"], ["format"], arguments)
  },
// edit_user_session => /user_session/edit(.:format)
  edit_user_session_path: function(options) {
  return Utils.build_path(0, ["/user_session/edit"], ["format"], arguments)
  },
// new_api_template_package_group => /api/templates/:template_id/package_groups/new(.:format)
  new_api_template_package_group_path: function(_template_id, options) {
  return Utils.build_path(1, ["/api/templates/", "/package_groups/new"], ["format"], arguments)
  },
// new_api_changeset_distribution => /api/changesets/:changeset_id/distributions/new(.:format)
  new_api_changeset_distribution_path: function(_changeset_id, options) {
  return Utils.build_path(1, ["/api/changesets/", "/distributions/new"], ["format"], arguments)
  },
// remove_subscriptions_activation_key => /activation_keys/:id/remove_subscriptions(.:format)
  remove_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/activation_keys/", "/remove_subscriptions"], ["format"], arguments)
  },
// filelist_repository_distribution => /repositories/:repository_id/distributions/:id/filelist(.:format)
  filelist_repository_distribution_path: function(_repository_id, _format, options) {
  return Utils.build_path(2, ["/repositories/", "/distributions/", "/filelist"], ["id"], arguments)
  },
// create_role_ldap_groups => /roles/:role_id/ldap_groups(.:format)
  create_role_ldap_groups_path: function(_role_id, options) {
  return Utils.build_path(1, ["/roles/", "/ldap_groups"], ["format"], arguments)
  },
// new_api_template_repository => /api/templates/:template_id/repositories/new(.:format)
  new_api_template_repository_path: function(_template_id, options) {
  return Utils.build_path(1, ["/api/templates/", "/repositories/new"], ["format"], arguments)
  },
// logout => /logout(.:format)
  logout_path: function(options) {
  return Utils.build_path(0, ["/logout"], ["format"], arguments)
  },
// content_search => /content_search/:id(.:format)
  content_search_path: function(_id, options) {
  return Utils.build_path(1, ["/content_search/"], ["format"], arguments)
  },
// edit_api_repository_package => /api/repositories/:repository_id/packages/:id/edit(.:format)
  edit_api_repository_package_path: function(_id, _format, options) {
  return Utils.build_path(2, ["/api/repositories/", "/packages/", "/edit"], ["repository_id"], arguments)
  },
// copy_system_group => /system_groups/:id/copy(.:format)
  copy_system_group_path: function(_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/copy"], ["format"], arguments)
  },
// repositories_api_organization_product => /api/organizations/:organization_id/products/:id/repositories(.:format)
  repositories_api_organization_product_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/products/", "/repositories"], ["format"], arguments)
  },
// package_groups_api_repository => /api/repositories/:id/package_groups(.:format)
  package_groups_api_repository_path: function(_format, options) {
  return Utils.build_path(1, ["/api/repositories/", "/package_groups"], ["id"], arguments)
  },
// gpg_keys => /gpg_keys(.:format)
  gpg_keys_path: function(options) {
  return Utils.build_path(0, ["/gpg_keys"], ["format"], arguments)
  },
// history_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/history(.:format)
  history_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/system_groups/", "/history"], ["format"], arguments)
  },
// download_debug_certificate_organization => /organizations/:id/download_debug_certificate(.:format)
  download_debug_certificate_organization_path: function(_id, options) {
  return Utils.build_path(1, ["/organizations/", "/download_debug_certificate"], ["format"], arguments)
  },
// product => /products/:id(.:format)
  product_path: function(_id, options) {
  return Utils.build_path(1, ["/products/"], ["format"], arguments)
  },
// download_system_template => /system_templates/:id/download(.:format)
  download_system_template_path: function(_id, options) {
  return Utils.build_path(1, ["/system_templates/", "/download"], ["format"], arguments)
  },
// systems_activation_key => /activation_keys/:id/systems(.:format)
  systems_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/activation_keys/", "/systems"], ["format"], arguments)
  },
// packages_api_system => /api/systems/:id/packages(.:format)
  packages_api_system_path: function(_id, options) {
  return Utils.build_path(1, ["/api/systems/", "/packages"], ["format"], arguments)
  },
// user_session => /user_session(.:format)
  user_session_path: function(options) {
  return Utils.build_path(0, ["/user_session"], ["format"], arguments)
  },
// role => /roles/:id(.:format)
  role_path: function(_id, options) {
  return Utils.build_path(1, ["/roles/"], ["format"], arguments)
  },
// edit_repository => /repositories/:id/edit(.:format)
  edit_repository_path: function(_id, options) {
  return Utils.build_path(1, ["/repositories/", "/edit"], ["format"], arguments)
  },
// sync_ldap_roles_api_users => /api/users/sync_ldap_roles(.:format)
  sync_ldap_roles_api_users_path: function(options) {
  return Utils.build_path(0, ["/api/users/sync_ldap_roles"], ["format"], arguments)
  },
// system_group_errata => /system_groups/:system_group_id/errata(.:format)
  system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/errata"], ["format"], arguments)
  },
// products => /products(.:format)
  products_path: function(options) {
  return Utils.build_path(0, ["/products"], ["format"], arguments)
  },
// user => /users/:id(.:format)
  user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/"], ["format"], arguments)
  },
// notices_dashboard_index => /dashboard/notices(.:format)
  notices_dashboard_index_path: function(options) {
  return Utils.build_path(0, ["/dashboard/notices"], ["format"], arguments)
  },
// new_system_template => /system_templates/new(.:format)
  new_system_template_path: function(options) {
  return Utils.build_path(0, ["/system_templates/new"], ["format"], arguments)
  },
// dashboard_index => /dashboard(.:format)
  dashboard_index_path: function(options) {
  return Utils.build_path(0, ["/dashboard"], ["format"], arguments)
  },
// new_activation_key => /activation_keys/new(.:format)
  new_activation_key_path: function(options) {
  return Utils.build_path(0, ["/activation_keys/new"], ["format"], arguments)
  },
// edit_api_consumer => /api/consumers/:id/edit(.:format)
  edit_api_consumer_path: function(_id, options) {
  return Utils.build_path(1, ["/api/consumers/", "/edit"], ["format"], arguments)
  },
// repository => /repositories/:id(.:format)
  repository_path: function(_id, options) {
  return Utils.build_path(1, ["/repositories/"], ["format"], arguments)
  },
// pools_api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id/pools(.:format)
  pools_api_organization_activation_key_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/activation_keys/", "/pools"], ["format"], arguments)
  },
// role_create_permission => /roles/:role_id/create_permission(.:format)
  role_create_permission_path: function(_role_id, options) {
  return Utils.build_path(1, ["/roles/", "/create_permission"], ["format"], arguments)
  },
// sync_management_index => /sync_management/index(.:format)
  sync_management_index_path: function(options) {
  return Utils.build_path(0, ["/sync_management/index"], ["format"], arguments)
  },
// edit_system_group => /system_groups/:id/edit(.:format)
  edit_system_group_path: function(_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/edit"], ["format"], arguments)
  },
// default_label_provider_products => /providers/:provider_id/products/default_label(.:format)
  default_label_provider_products_path: function(_provider_id, options) {
  return Utils.build_path(1, ["/providers/", "/products/default_label"], ["format"], arguments)
  },
// errata_items_content_search_index => /content_search/errata_items(.:format)
  errata_items_content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search/errata_items"], ["format"], arguments)
  },
// more_packages_system_system_packages => /systems/:system_id/system_packages/more_packages(.:format)
  more_packages_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/system_packages/more_packages"], ["format"], arguments)
  },
// edit_api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/:id/edit(.:format)
  edit_api_organization_sync_plan_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/sync_plans/", "/edit"], ["format"], arguments)
  },
// provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id(.:format)
  provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(3, ["/providers/", "/products/", "/repositories/"], ["format"], arguments)
  },
// products_subscription => /subscriptions/:id/products(.:format)
  products_subscription_path: function(_id, options) {
  return Utils.build_path(1, ["/subscriptions/", "/products"], ["format"], arguments)
  },
// organization => /organizations/:id(.:format)
  organization_path: function(_id, options) {
  return Utils.build_path(1, ["/organizations/"], ["format"], arguments)
  },
// content_search_index => /content_search(.:format)
  content_search_index_path: function(options) {
  return Utils.build_path(0, ["/content_search"], ["format"], arguments)
  },
// system_erratum => /systems/:system_id/errata/:id(.:format)
  system_erratum_path: function(_system_id, _id, options) {
  return Utils.build_path(2, ["/systems/", "/errata/"], ["format"], arguments)
  },
// redhat_provider_providers => /providers/redhat_provider(.:format)
  redhat_provider_providers_path: function(options) {
  return Utils.build_path(0, ["/providers/redhat_provider"], ["format"], arguments)
  },
// history_items_subscriptions => /subscriptions/history_items(.:format)
  history_items_subscriptions_path: function(options) {
  return Utils.build_path(0, ["/subscriptions/history_items"], ["format"], arguments)
  },
// dependencies_package => /packages/:id/dependencies(.:format)
  dependencies_package_path: function(_id, options) {
  return Utils.build_path(1, ["/packages/", "/dependencies"], ["format"], arguments)
  },
// products_api_provider => /api/providers/:id/products(.:format)
  products_api_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/api/providers/", "/products"], ["format"], arguments)
  },
// facts_system => /systems/:id/facts(.:format)
  facts_system_path: function(_id, options) {
  return Utils.build_path(1, ["/systems/", "/facts"], ["format"], arguments)
  },
// products_repos_provider => /providers/:id/products_repos(.:format)
  products_repos_provider_path: function(_id, options) {
  return Utils.build_path(1, ["/providers/", "/products_repos"], ["format"], arguments)
  },
// env_items_systems => /systems/env_items(.:format)
  env_items_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/env_items"], ["format"], arguments)
  },
// edit_api_organization => /api/organizations/:id/edit(.:format)
  edit_api_organization_path: function(_id, options) {
  return Utils.build_path(1, ["/api/organizations/", "/edit"], ["format"], arguments)
  },
// repositories_api_organization_environment => /api/organizations/:organization_id/environments/:id/repositories(.:format)
  repositories_api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/environments/", "/repositories"], ["format"], arguments)
  },
// auto_complete_search_users => /users/auto_complete_search(.:format)
  auto_complete_search_users_path: function(options) {
  return Utils.build_path(0, ["/users/auto_complete_search"], ["format"], arguments)
  },
// import_api_templates => /api/templates/import(.:format)
  import_api_templates_path: function(options) {
  return Utils.build_path(0, ["/api/templates/import"], ["format"], arguments)
  },
// bulk_content_update_systems => /systems/bulk_content_update(.:format)
  bulk_content_update_systems_path: function(options) {
  return Utils.build_path(0, ["/systems/bulk_content_update"], ["format"], arguments)
  },
// update_locale_user => /users/:id/update_locale(.:format)
  update_locale_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/update_locale"], ["format"], arguments)
  },
// promotion => /promotions/:id(.:format)
  promotion_path: function(_id, options) {
  return Utils.build_path(1, ["/promotions/"], ["format"], arguments)
  },
// name_changeset => /changesets/:id/name(.:format)
  name_changeset_path: function(_id, options) {
  return Utils.build_path(1, ["/changesets/", "/name"], ["format"], arguments)
  },
// edit_api_template_product => /api/templates/:template_id/products/:id/edit(.:format)
  edit_api_template_product_path: function(_template_id, _id, options) {
  return Utils.build_path(2, ["/api/templates/", "/products/", "/edit"], ["format"], arguments)
  },
// edit_api_changeset_package => /api/changesets/:changeset_id/packages/:id/edit(.:format)
  edit_api_changeset_package_path: function(_changeset_id, _format, options) {
  return Utils.build_path(2, ["/api/changesets/", "/packages/", "/edit"], ["id"], arguments)
  },
// destroy_favorite_search_index => /search/favorite/:id(.:format)
  destroy_favorite_search_index_path: function(_id, options) {
  return Utils.build_path(1, ["/search/favorite/"], ["format"], arguments)
  },
// list_changesets => /changesets/list(.:format)
  list_changesets_path: function(options) {
  return Utils.build_path(0, ["/changesets/list"], ["format"], arguments)
  },
// edit_gpg_key => /gpg_keys/:id/edit(.:format)
  edit_gpg_key_path: function(_id, options) {
  return Utils.build_path(1, ["/gpg_keys/", "/edit"], ["format"], arguments)
  },
// auto_complete_search_activation_keys => /activation_keys/auto_complete_search(.:format)
  auto_complete_search_activation_keys_path: function(options) {
  return Utils.build_path(0, ["/activation_keys/auto_complete_search"], ["format"], arguments)
  },
// system_group_event => /system_groups/:system_group_id/events/:id(.:format)
  system_group_event_path: function(_system_group_id, _id, options) {
  return Utils.build_path(2, ["/system_groups/", "/events/"], ["format"], arguments)
  },
// edit_api_template_package_group => /api/templates/:template_id/package_groups/:id/edit(.:format)
  edit_api_template_package_group_path: function(_template_id, _id, options) {
  return Utils.build_path(2, ["/api/templates/", "/package_groups/", "/edit"], ["format"], arguments)
  },
// edit_api_changeset_distribution => /api/changesets/:changeset_id/distributions/:id/edit(.:format)
  edit_api_changeset_distribution_path: function(_changeset_id, _id, options) {
  return Utils.build_path(2, ["/api/changesets/", "/distributions/", "/edit"], ["format"], arguments)
  },
// add_subscriptions_activation_key => /activation_keys/:id/add_subscriptions(.:format)
  add_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/activation_keys/", "/add_subscriptions"], ["format"], arguments)
  },
// systems => /systems(.:format)
  systems_path: function(options) {
  return Utils.build_path(0, ["/systems"], ["format"], arguments)
  },
// repository_distribution => /repositories/:repository_id/distributions/:id(.:format)
  repository_distribution_path: function(_repository_id, _format, options) {
  return Utils.build_path(2, ["/repositories/", "/distributions/"], ["id"], arguments)
  },
// edit_api_template_repository => /api/templates/:template_id/repositories/:id/edit(.:format)
  edit_api_template_repository_path: function(_template_id, _id, options) {
  return Utils.build_path(2, ["/api/templates/", "/repositories/", "/edit"], ["format"], arguments)
  },
// changeset => /changesets/:id(.:format)
  changeset_path: function(_id, options) {
  return Utils.build_path(1, ["/changesets/"], ["format"], arguments)
  },
// products_promotion => /promotions/:id/products(.:format)
  products_promotion_path: function(_id, options) {
  return Utils.build_path(1, ["/promotions/", "/products"], ["format"], arguments)
  },
// systems_system_group => /system_groups/:id/systems(.:format)
  systems_system_group_path: function(_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/systems"], ["format"], arguments)
  },
// sync_plan_api_organization_product => /api/organizations/:organization_id/products/:id/sync_plan(.:format)
  sync_plan_api_organization_product_path: function(_organization_id, _id, options) {
  return Utils.build_path(2, ["/api/organizations/", "/products/", "/sync_plan"], ["format"], arguments)
  },
// package_group_categories_api_repository => /api/repositories/:id/package_group_categories(.:format)
  package_group_categories_api_repository_path: function(_format, options) {
  return Utils.build_path(1, ["/api/repositories/", "/package_group_categories"], ["id"], arguments)
  },
// environments => /environments(.:format)
  environments_path: function(options) {
  return Utils.build_path(0, ["/environments"], ["format"], arguments)
  },
// new_sync_plan => /sync_plans/new(.:format)
  new_sync_plan_path: function(options) {
  return Utils.build_path(0, ["/sync_plans/new"], ["format"], arguments)
  },
// auto_complete_search_organizations => /organizations/auto_complete_search(.:format)
  auto_complete_search_organizations_path: function(options) {
  return Utils.build_path(0, ["/organizations/auto_complete_search"], ["format"], arguments)
  },
// new_subscription => /subscriptions/new(.:format)
  new_subscription_path: function(options) {
  return Utils.build_path(0, ["/subscriptions/new"], ["format"], arguments)
  },
// sync_plans => /sync_plans(.:format)
  sync_plans_path: function(options) {
  return Utils.build_path(0, ["/sync_plans"], ["format"], arguments)
  },
// default_label_organization_environments => /organizations/:organization_id/environments/default_label(.:format)
  default_label_organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(1, ["/organizations/", "/environments/default_label"], ["format"], arguments)
  },
// apply_api_organization_system_info_keys => /api/organizations/:organization_id/system_info_keys/apply(.:format)
  apply_api_organization_system_info_keys_path: function(_organization_id, options) {
  return Utils.build_path(1, ["/api/organizations/", "/system_info_keys/apply"], ["format"], arguments)
  },
// status_system_group_packages => /system_groups/:system_group_id/packages/status(.:format)
  status_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(1, ["/system_groups/", "/packages/status"], ["format"], arguments)
  },
// show_user_session => /user_session(.:format)
  show_user_session_path: function(options) {
  return Utils.build_path(0, ["/user_session"], ["format"], arguments)
  },
// validate_system_template => /system_templates/:id/validate(.:format)
  validate_system_template_path: function(_id, options) {
  return Utils.build_path(1, ["/system_templates/", "/validate"], ["format"], arguments)
  },
// releases_api_environment => /api/environments/:id/releases(.:format)
  releases_api_environment_path: function(_id, options) {
  return Utils.build_path(1, ["/api/environments/", "/releases"], ["format"], arguments)
  },
// add_system_groups_activation_key => /activation_keys/:id/add_system_groups(.:format)
  add_system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/activation_keys/", "/add_system_groups"], ["format"], arguments)
  },
// auto_complete_library_repositories => /repositories/auto_complete_library(.:format)
  auto_complete_library_repositories_path: function(options) {
  return Utils.build_path(0, ["/repositories/auto_complete_library"], ["format"], arguments)
  },
// errata_api_system => /api/systems/:id/errata(.:format)
  errata_api_system_path: function(_id, options) {
  return Utils.build_path(1, ["/api/systems/", "/errata"], ["format"], arguments)
  },
// new_api_activation_key => /api/activation_keys/new(.:format)
  new_api_activation_key_path: function(options) {
  return Utils.build_path(0, ["/api/activation_keys/new"], ["format"], arguments)
  },
// verbs_and_scopes => /roles/:organization_id/resource_type/verbs_and_scopes(.:format)
  verbs_and_scopes_path: function(_organization_id, options) {
  return Utils.build_path(1, ["/roles/", "/resource_type/verbs_and_scopes"], ["format"], arguments)
  },
// available_verbs_api_roles => /api/roles/available_verbs(.:format)
  available_verbs_api_roles_path: function(options) {
  return Utils.build_path(0, ["/api/roles/available_verbs"], ["format"], arguments)
  },
// errata_dashboard_index => /dashboard/errata(.:format)
  errata_dashboard_index_path: function(options) {
  return Utils.build_path(0, ["/dashboard/errata"], ["format"], arguments)
  },
// new_api_role => /api/roles/new(.:format)
  new_api_role_path: function(options) {
  return Utils.build_path(0, ["/api/roles/new"], ["format"], arguments)
  },
// status_system_events => /systems/:system_id/events/status(.:format)
  status_system_events_path: function(_system_id, options) {
  return Utils.build_path(1, ["/systems/", "/events/status"], ["format"], arguments)
  },
// edit_system_template => /system_templates/:id/edit(.:format)
  edit_system_template_path: function(_id, options) {
  return Utils.build_path(1, ["/system_templates/", "/edit"], ["format"], arguments)
  },
// notices_details => /notices/:id/details(.:format)
  notices_details_path: function(_id, options) {
  return Utils.build_path(1, ["/notices/", "/details"], ["format"], arguments)
  },
// enable_repo => /repositories/:id/enable_repo(.:format)
  enable_repo_path: function(_id, options) {
  return Utils.build_path(1, ["/repositories/", "/enable_repo"], ["format"], arguments)
  },
// edit_activation_key => /activation_keys/:id/edit(.:format)
  edit_activation_key_path: function(_id, options) {
  return Utils.build_path(1, ["/activation_keys/", "/edit"], ["format"], arguments)
  },
// errata_promotion => /promotions/:id/errata(.:format)
  errata_promotion_path: function(_id, options) {
  return Utils.build_path(1, ["/promotions/", "/errata"], ["format"], arguments)
  },
// product_comps_system_templates => /system_templates/product_comps(.:format)
  product_comps_system_templates_path: function(options) {
  return Utils.build_path(0, ["/system_templates/product_comps"], ["format"], arguments)
  },
// root => /(.:format)
  root_path: function(options) {
  return Utils.build_path(0, ["/"], ["format"], arguments)
  },
// new_product => /products/new(.:format)
  new_product_path: function(options) {
  return Utils.build_path(0, ["/products/new"], ["format"], arguments)
  }}
;
  window.KT.routes.options = defaults;
})();
