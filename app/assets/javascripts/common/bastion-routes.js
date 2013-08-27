(function() {
  var NodeTypes, ParameterMissing, Utils, defaults,
    __hasProp = {}.hasOwnProperty;

  ParameterMissing = function(message) {
    this.message = message;
  };

  ParameterMissing.prototype = new Error();

  defaults = {
    prefix: "",
    default_url_options: {}
  };

  NodeTypes = {"GROUP":1,"CAT":2,"SYMBOL":3,"OR":4,"STAR":5,"LITERAL":6,"SLASH":7,"DOT":8};

  Utils = {
    serialize: function(object, prefix) {
      var element, i, key, prop, result, s, _i, _len;
      if (prefix == null) {
        prefix = null;
      }
      if (!object) {
        return "";
      }
      if (!prefix && !(this.get_object_type(object) === "object")) {
        throw new Error("Url parameters should be a javascript hash");
      }
      if (window.jQuery) {
        result = window.jQuery.param(object);
        return (!result ? "" : result);
      }
      s = [];
      switch (this.get_object_type(object)) {
        case "array":
          for (i = _i = 0, _len = object.length; _i < _len; i = ++_i) {
            element = object[i];
            s.push(this.serialize(element, prefix + "[]"));
          }
          break;
        case "object":
          for (key in object) {
            if (!__hasProp.call(object, key)) continue;
            prop = object[key];
            if (!(prop != null)) {
              continue;
            }
            if (prefix != null) {
              key = "" + prefix + "[" + key + "]";
            }
            s.push(this.serialize(prop, key));
          }
          break;
        default:
          if (object) {
            s.push("" + (encodeURIComponent(prefix.toString())) + "=" + (encodeURIComponent(object.toString())));
          }
      }
      if (!s.length) {
        return "";
      }
      return s.join("&");
    },
    clean_path: function(path) {
      var last_index;
      path = path.split("://");
      last_index = path.length - 1;
      path[last_index] = path[last_index].replace(/\/+/g, "/").replace(/.\/$/m, "");
      return path.join("://");
    },
    set_default_url_options: function(optional_parts, options) {
      var i, part, _i, _len, _results;
      _results = [];
      for (i = _i = 0, _len = optional_parts.length; _i < _len; i = ++_i) {
        part = optional_parts[i];
        if (!options.hasOwnProperty(part) && defaults.default_url_options.hasOwnProperty(part)) {
          _results.push(options[part] = defaults.default_url_options[part]);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    extract_anchor: function(options) {
      var anchor;
      anchor = "";
      if (options.hasOwnProperty("anchor")) {
        anchor = "#" + options.anchor;
        delete options.anchor;
      }
      return anchor;
    },
    extract_options: function(number_of_params, args) {
      var ret_value;
      ret_value = {};
      if (args.length > number_of_params) {
        ret_value = args.pop();
      }
      return ret_value;
    },
    path_identifier: function(object) {
      var property;
      if (object === 0) {
        return "0";
      }
      if (!object) {
        return "";
      }
      property = object;
      if (this.get_object_type(object) === "object") {
        property = object.to_param || object.id || object;
        if (this.get_object_type(property) === "function") {
          property = property.call(object);
        }
      }
      return property.toString();
    },
    clone: function(obj) {
      var attr, copy, key;
      if ((obj == null) || "object" !== this.get_object_type(obj)) {
        return obj;
      }
      copy = obj.constructor();
      for (key in obj) {
        if (!__hasProp.call(obj, key)) continue;
        attr = obj[key];
        copy[key] = attr;
      }
      return copy;
    },
    prepare_parameters: function(required_parameters, actual_parameters, options) {
      var i, result, val, _i, _len;
      result = this.clone(options) || {};
      for (i = _i = 0, _len = required_parameters.length; _i < _len; i = ++_i) {
        val = required_parameters[i];
        result[val] = actual_parameters[i];
      }
      return result;
    },
    build_path: function(required_parameters, optional_parts, route, args) {
      var anchor, opts, parameters, result, url, url_params;
      args = Array.prototype.slice.call(args);
      opts = this.extract_options(required_parameters.length, args);
      if (args.length > required_parameters.length) {
        throw new Error("Too many parameters provided for path");
      }
      parameters = this.prepare_parameters(required_parameters, args, opts);
      this.set_default_url_options(optional_parts, parameters);
      anchor = this.extract_anchor(parameters);
      result = "" + (this.get_prefix()) + (this.visit(route, parameters));
      url = Utils.clean_path("" + result);
      if ((url_params = this.serialize(parameters)).length) {
        url += "?" + url_params;
      }
      url += anchor;
      return url;
    },
    visit: function(route, parameters, optional) {
      var left, left_part, right, right_part, type, value;
      if (optional == null) {
        optional = false;
      }
      type = route[0], left = route[1], right = route[2];
      switch (type) {
        case NodeTypes.GROUP:
          return this.visit(left, parameters, true);
        case NodeTypes.STAR:
          return this.visit_globbing(left, parameters, true);
        case NodeTypes.LITERAL:
        case NodeTypes.SLASH:
        case NodeTypes.DOT:
          return left;
        case NodeTypes.CAT:
          left_part = this.visit(left, parameters, optional);
          right_part = this.visit(right, parameters, optional);
          if (optional && !(left_part && right_part)) {
            return "";
          }
          return "" + left_part + right_part;
        case NodeTypes.SYMBOL:
          value = parameters[left];
          if (value != null) {
            delete parameters[left];
            return this.path_identifier(value);
          }
          if (optional) {
            return "";
          } else {
            throw new ParameterMissing("Route parameter missing: " + left);
          }
          break;
        default:
          throw new Error("Unknown Rails node type");
      }
    },
    visit_globbing: function(route, parameters, optional) {
      var left, right, type, value;
      type = route[0], left = route[1], right = route[2];
      if (left.replace(/^\*/i, "") !== left) {
        route[1] = left = left.replace(/^\*/i, "");
      }
      value = parameters[left];
      if (value == null) {
        return this.visit(route, parameters, optional);
      }
      parameters[left] = (function() {
        switch (this.get_object_type(value)) {
          case "array":
            return value.join("/");
          default:
            return value;
        }
      }).call(this);
      return this.visit(route, parameters, optional);
    },
    get_prefix: function() {
      var prefix;
      prefix = defaults.prefix;
      if (prefix !== "") {
        prefix = (prefix.match("/$") ? prefix : "" + prefix + "/");
      }
      return prefix;
    },
    _classToTypeCache: null,
    _classToType: function() {
      var name, _i, _len, _ref;
      if (this._classToTypeCache != null) {
        return this._classToTypeCache;
      }
      this._classToTypeCache = {};
      _ref = "Boolean Number String Function Array Date RegExp Undefined Null".split(" ");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        this._classToTypeCache["[object " + name + "]"] = name.toLowerCase();
      }
      return this._classToTypeCache;
    },
    get_object_type: function(obj) {
      var strType;
      if (window.jQuery && (window.jQuery.type != null)) {
        return window.jQuery.type(obj);
      }
      strType = Object.prototype.toString.call(obj);
      return this._classToType()[strType] || "object";
    },
    namespace: function(root, namespaceString) {
      var current, parts;
      parts = (namespaceString ? namespaceString.split(".") : []);
      if (!parts.length) {
        return;
      }
      current = parts.shift();
      root[current] = root[current] || {};
      return Utils.namespace(root[current], parts.join("."));
    }
  };

  Utils.namespace(window, "BASTION.KT.routes");

  window.BASTION.KT.routes = {
// about => /about(.:format)
  aboutPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"about",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// activation_key => /activation_keys/:id(.:format)
  activationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// activation_keys => /activation_keys(.:format)
  activationKeysPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"activation_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_parameter_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/add_parameter(.:format)
  addParameterContentViewDefinitionFilterRulePath: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_parameter",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_subscriptions_activation_key => /activation_keys/:id/add_subscriptions(.:format)
  addSubscriptionsActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_system_group_packages => /system_groups/:system_group_id/packages/add(.:format)
  addSystemGroupPackagesPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"add",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_system_groups_activation_key => /activation_keys/:id/add_system_groups(.:format)
  addSystemGroupsActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_system_groups_system => /systems/:id/add_system_groups(.:format)
  addSystemGroupsSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_system_system_packages => /systems/:system_id/system_packages/add(.:format)
  addSystemSystemPackagesPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[7,"/",false]],[6,"add",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/add_systems(.:format)
  addSystemsApiOrganizationSystemGroupPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_systems_api_system_group => /api/system_groups/:id/add_systems(.:format)
  addSystemsApiSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_systems_system_group => /system_groups/:id/add_systems(.:format)
  addSystemsSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// all_api_content_view_definition_products => /api/content_view_definitions/:content_view_definition_id/products/all(.:format)
  allApiContentViewDefinitionProductsPath: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[6,"all",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// all_api_organization_content_view_definition_products => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/products/all(.:format)
  allApiOrganizationContentViewDefinitionProductsPath: function(_organization_id, _content_view_definition_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[6,"all",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// allowed_orgs_user_session => /user_session/allowed_orgs(.:format)
  allowedOrgsUserSessionPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"user_session",false]],[7,"/",false]],[6,"allowed_orgs",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api => /api(.:format)
  apiPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"api",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_about_index => /api/about(.:format)
  apiAboutIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"about",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_activation_key => /api/activation_keys/:id(.:format)
  apiActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_activation_keys => /api/activation_keys(.:format)
  apiActivationKeysPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset => /api/changesets/:id(.:format)
  apiChangesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_content_view => /api/changesets/:changeset_id/content_views/:id(.:format)
  apiChangesetContentViewPath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_content_views => /api/changesets/:changeset_id/content_views(.:format)
  apiChangesetContentViewsPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_distribution => /api/changesets/:changeset_id/distributions/:id(.:format)
  apiChangesetDistributionPath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"distributions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_distributions => /api/changesets/:changeset_id/distributions(.:format)
  apiChangesetDistributionsPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"distributions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_errata => /api/changesets/:changeset_id/errata(.:format)
  apiChangesetErrataPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_erratum => /api/changesets/:changeset_id/errata/:id(.:format)
  apiChangesetErratumPath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_package => /api/changesets/:changeset_id/packages/:id(.:format)
  apiChangesetPackagePath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_packages => /api/changesets/:changeset_id/packages(.:format)
  apiChangesetPackagesPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_product => /api/changesets/:changeset_id/products/:id(.:format)
  apiChangesetProductPath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_products => /api/changesets/:changeset_id/products(.:format)
  apiChangesetProductsPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_repositories => /api/changesets/:changeset_id/repositories(.:format)
  apiChangesetRepositoriesPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_repository => /api/changesets/:changeset_id/repositories/:id(.:format)
  apiChangesetRepositoryPath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_template => /api/changesets/:changeset_id/templates/:id(.:format)
  apiChangesetTemplatePath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"templates",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_templates => /api/changesets/:changeset_id/templates(.:format)
  apiChangesetTemplatesPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"templates",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_consumer => /api/consumers/:id(.:format)
  apiConsumerPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_consumers => /api/consumers(.:format)
  apiConsumersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view => /api/content_views/:id(.:format)
  apiContentViewPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition => /api/content_view_definitions/:id(.:format)
  apiContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_content_views => /api/content_view_definitions/:content_view_definition_id/content_views(.:format)
  apiContentViewDefinitionContentViewsPath: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filter => /api/content_view_definitions/:content_view_definition_id/filters/:id(.:format)
  apiContentViewDefinitionFilterPath: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filter_products => /api/content_view_definitions/:content_view_definition_id/filters/:filter_id/products(.:format)
  apiContentViewDefinitionFilterProductsPath: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filter_repositories => /api/content_view_definitions/:content_view_definition_id/filters/:filter_id/repositories(.:format)
  apiContentViewDefinitionFilterRepositoriesPath: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filter_rule => /api/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id(.:format)
  apiContentViewDefinitionFilterRulePath: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filter_rules => /api/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules(.:format)
  apiContentViewDefinitionFilterRulesPath: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filters => /api/content_view_definitions/:content_view_definition_id/filters(.:format)
  apiContentViewDefinitionFiltersPath: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_products => /api/content_view_definitions/:content_view_definition_id/products(.:format)
  apiContentViewDefinitionProductsPath: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_repositories => /api/content_view_definitions/:content_view_definition_id/repositories(.:format)
  apiContentViewDefinitionRepositoriesPath: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_create_custom_info => /api/custom_info/:informable_type/:informable_id(.:format)
  apiCreateCustomInfoPath: function(_informable_type, _informable_id, options) {
  return Utils.build_path(["informable_type","informable_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"custom_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"informable_id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_crls => /api/crls(.:format)
  apiCrlsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"crls",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_custom_info => /api/custom_info/:informable_type/:informable_id(.:format)
  apiCustomInfoPath: function(_informable_type, _informable_id, options) {
  return Utils.build_path(["informable_type","informable_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"custom_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"informable_id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_destroy_custom_info => /api/custom_info/:informable_type/:informable_id/*keyname(.:format)
  apiDestroyCustomInfoPath: function(_informable_type, _informable_id, _keyname, options) {
  return Utils.build_path(["informable_type","informable_id","keyname"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"custom_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"informable_id",false]],[7,"/",false]],[5,[3,"keyname",false],false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_distributor => /api/distributors/:id(.:format)
  apiDistributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_distributor_subscription => /api/distributors/:distributor_id/subscriptions/:id(.:format)
  apiDistributorSubscriptionPath: function(_distributor_id, _id, options) {
  return Utils.build_path(["distributor_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_distributor_subscriptions => /api/distributors/:distributor_id/subscriptions(.:format)
  apiDistributorSubscriptionsPath: function(_distributor_id, options) {
  return Utils.build_path(["distributor_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_distributors => /api/distributors(.:format)
  apiDistributorsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment => /api/environments/:id(.:format)
  apiEnvironmentPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_activation_keys => /api/environments/:environment_id/activation_keys(.:format)
  apiEnvironmentActivationKeysPath: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"activation_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_changesets => /api/environments/:environment_id/changesets(.:format)
  apiEnvironmentChangesetsPath: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"changesets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_content_views => /api/environments/:environment_id/content_views(.:format)
  apiEnvironmentContentViewsPath: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_distributors => /api/environments/:environment_id/distributors(.:format)
  apiEnvironmentDistributorsPath: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"distributors",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_products => /api/environments/:environment_id/products(.:format)
  apiEnvironmentProductsPath: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_systems => /api/environments/:environment_id/systems(.:format)
  apiEnvironmentSystemsPath: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_errata => /api/errata(.:format)
  apiErrataPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_gpg_key => /api/gpg_keys/:id(.:format)
  apiGpgKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"gpg_keys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_hypervisors => /api/hypervisors(.:format)
  apiHypervisorsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"hypervisors",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_node => /api/nodes/:id(.:format)
  apiNodePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_node_capabilities => /api/nodes/:node_id/capabilities(.:format)
  apiNodeCapabilitiesPath: function(_node_id, options) {
  return Utils.build_path(["node_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"node_id",false]],[7,"/",false]],[6,"capabilities",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_node_capability => /api/nodes/:node_id/capabilities/:id(.:format)
  apiNodeCapabilityPath: function(_node_id, _id, options) {
  return Utils.build_path(["node_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"node_id",false]],[7,"/",false]],[6,"capabilities",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_nodes => /api/nodes(.:format)
  apiNodesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization => /api/organizations/:id(.:format)
  apiOrganizationPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id(.:format)
  apiOrganizationActivationKeyPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_activation_keys => /api/organizations/:organization_id/activation_keys(.:format)
  apiOrganizationActivationKeysPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"activation_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_apply_default_info => /api/organizations/:organization_id/default_info/:informable_type/apply(.:format)
  apiOrganizationApplyDefaultInfoPath: function(_organization_id, _informable_type, options) {
  return Utils.build_path(["organization_id","informable_type"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"default_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[6,"apply",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_auto_attach_all_systems => /api/organizations/:organization_id/auto_attach(.:format)
  apiOrganizationAutoAttachAllSystemsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"auto_attach",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view => /api/organizations/:organization_id/content_views/:id(.:format)
  apiOrganizationContentViewPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/:id(.:format)
  apiOrganizationContentViewDefinitionPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filter => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id(.:format)
  apiOrganizationContentViewDefinitionFilterPath: function(_organization_id, _content_view_definition_id, _id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filter_products => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:filter_id/products(.:format)
  apiOrganizationContentViewDefinitionFilterProductsPath: function(_organization_id, _content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filter_repositories => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:filter_id/repositories(.:format)
  apiOrganizationContentViewDefinitionFilterRepositoriesPath: function(_organization_id, _content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filter_rule => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id(.:format)
  apiOrganizationContentViewDefinitionFilterRulePath: function(_organization_id, _content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filter_rules => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules(.:format)
  apiOrganizationContentViewDefinitionFilterRulesPath: function(_organization_id, _content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filters => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters(.:format)
  apiOrganizationContentViewDefinitionFiltersPath: function(_organization_id, _content_view_definition_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_products => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/products(.:format)
  apiOrganizationContentViewDefinitionProductsPath: function(_organization_id, _content_view_definition_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_repositories => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/repositories(.:format)
  apiOrganizationContentViewDefinitionRepositoriesPath: function(_organization_id, _content_view_definition_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definitions => /api/organizations/:organization_id/content_view_definitions(.:format)
  apiOrganizationContentViewDefinitionsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_views => /api/organizations/:organization_id/content_views(.:format)
  apiOrganizationContentViewsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_create_default_info => /api/organizations/:organization_id/default_info/:informable_type(.:format)
  apiOrganizationCreateDefaultInfoPath: function(_organization_id, _informable_type, options) {
  return Utils.build_path(["organization_id","informable_type"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"default_info",false]],[7,"/",false]],[3,"informable_type",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_destroy_default_info => /api/organizations/:organization_id/default_info/:informable_type/:keyname(.:format)
  apiOrganizationDestroyDefaultInfoPath: function(_organization_id, _informable_type, _keyname, options) {
  return Utils.build_path(["organization_id","informable_type","keyname"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"default_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"keyname",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_distributors => /api/organizations/:organization_id/distributors(.:format)
  apiOrganizationDistributorsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"distributors",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_environment => /api/organizations/:organization_id/environments/:id(.:format)
  apiOrganizationEnvironmentPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_environment_changesets => /api/organizations/:organization_id/environments/:environment_id/changesets(.:format)
  apiOrganizationEnvironmentChangesetsPath: function(_organization_id, _environment_id, options) {
  return Utils.build_path(["organization_id","environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"changesets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_environments => /api/organizations/:organization_id/environments(.:format)
  apiOrganizationEnvironmentsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_gpg_keys => /api/organizations/:organization_id/gpg_keys(.:format)
  apiOrganizationGpgKeysPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"gpg_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_product => /api/organizations/:organization_id/products/:id(.:format)
  apiOrganizationProductPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_product_repository_sets => /api/organizations/:organization_id/products/:product_id/repository_sets(.:format)
  apiOrganizationProductRepositorySetsPath: function(_organization_id, _product_id, options) {
  return Utils.build_path(["organization_id","product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_product_sync_index => /api/organizations/:organization_id/products/:product_id/sync(.:format)
  apiOrganizationProductSyncIndexPath: function(_organization_id, _product_id, options) {
  return Utils.build_path(["organization_id","product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_products => /api/organizations/:organization_id/products(.:format)
  apiOrganizationProductsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_providers => /api/organizations/:organization_id/providers(.:format)
  apiOrganizationProvidersPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"providers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/:id(.:format)
  apiOrganizationSyncPlanPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"sync_plans",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_sync_plans => /api/organizations/:organization_id/sync_plans(.:format)
  apiOrganizationSyncPlansPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"sync_plans",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_system_group => /api/organizations/:organization_id/system_groups/:id(.:format)
  apiOrganizationSystemGroupPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_system_group_errata => /api/organizations/:organization_id/system_groups/:system_group_id/errata(.:format)
  apiOrganizationSystemGroupErrataPath: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(["organization_id","system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_system_group_packages => /api/organizations/:organization_id/system_groups/:system_group_id/packages(.:format)
  apiOrganizationSystemGroupPackagesPath: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(["organization_id","system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_system_groups => /api/organizations/:organization_id/system_groups(.:format)
  apiOrganizationSystemGroupsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_systems => /api/organizations/:organization_id/systems(.:format)
  apiOrganizationSystemsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_tasks => /api/organizations/:organization_id/tasks(.:format)
  apiOrganizationTasksPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"tasks",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_uebercert => /api/organizations/:organization_id/uebercert(.:format)
  apiOrganizationUebercertPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"uebercert",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organizations => /api/organizations(.:format)
  apiOrganizationsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_ping_index => /api/ping(.:format)
  apiPingIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"ping",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_pool => /api/activation_keys/:id/pools/:id(.:format)
  apiPoolPath: function(_id, _id, options) {
  return Utils.build_path(["id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_pools => /api/activation_keys/:id/pools(.:format)
  apiPoolsPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_product => /api/products/:id(.:format)
  apiProductPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_product_repositories => /api/products/:product_id/repositories(.:format)
  apiProductRepositoriesPath: function(_product_id, options) {
  return Utils.build_path(["product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_product_repository_sets => /api/products/:product_id/repository_sets(.:format)
  apiProductRepositorySetsPath: function(_product_id, options) {
  return Utils.build_path(["product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_product_sync_index => /api/products/:product_id/sync(.:format)
  apiProductSyncIndexPath: function(_product_id, options) {
  return Utils.build_path(["product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_provider => /api/providers/:id(.:format)
  apiProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_provider_sync_index => /api/providers/:provider_id/sync(.:format)
  apiProviderSyncIndexPath: function(_provider_id, options) {
  return Utils.build_path(["provider_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_providers => /api/providers(.:format)
  apiProvidersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_certificate_serials_path => /api/consumers/:id/certificates/serials(.:format)
  apiProxyCertificateSerialsPathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"certificates",false]],[7,"/",false]],[6,"serials",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_certificates_delete_path => /api/consumers/:consumer_id/certificates/:id(.:format)
  apiProxyConsumerCertificatesDeletePathPath: function(_consumer_id, _id, options) {
  return Utils.build_path(["consumer_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"consumer_id",false]],[7,"/",false]],[6,"certificates",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_certificates_path => /api/consumers/:id/certificates(.:format)
  apiProxyConsumerCertificatesPathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"certificates",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_compliance_path => /api/consumers/:id/compliance(.:format)
  apiProxyConsumerCompliancePathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"compliance",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_deletionrecord_delete_path => /api/consumers/:id/deletionrecord(.:format)
  apiProxyConsumerDeletionrecordDeletePathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"deletionrecord",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_dryrun_path => /api/consumers/:id/entitlements/dry-run(.:format)
  apiProxyConsumerDryrunPathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"entitlements",false]],[7,"/",false]],[6,"dry-run",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_entitlements_delete_path => /api/consumers/:id/entitlements(.:format)
  apiProxyConsumerEntitlementsDeletePathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"entitlements",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_entitlements_path => /api/consumers/:id/entitlements(.:format)
  apiProxyConsumerEntitlementsPathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"entitlements",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_entitlements_post_path => /api/consumers/:id/entitlements(.:format)
  apiProxyConsumerEntitlementsPostPathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"entitlements",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_export_path => /api/consumers/:id/export(.:format)
  apiProxyConsumerExportPathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"export",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_owners_path => /api/consumers/:id/owner(.:format)
  apiProxyConsumerOwnersPathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"owner",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_releases_path => /api/consumers/:id/release(.:format)
  apiProxyConsumerReleasesPathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"release",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_deleted_consumers_path => /api/deleted_consumers(.:format)
  apiProxyDeletedConsumersPathPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"deleted_consumers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_entitlements_path => /api/entitlements/:id(.:format)
  apiProxyEntitlementsPathPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"entitlements",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_owner_pools_path => /api/owners/:organization_id/pools(.:format)
  apiProxyOwnerPoolsPathPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"owners",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_owner_servicelevels_path => /api/owners/:organization_id/servicelevels(.:format)
  apiProxyOwnerServicelevelsPathPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"owners",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"servicelevels",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_pools_path => /api/pools(.:format)
  apiProxyPoolsPathPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_subscriptions_post_path => /api/subscriptions(.:format)
  apiProxySubscriptionsPostPathPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repositories => /api/repositories(.:format)
  apiRepositoriesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository => /api/repositories/:id(.:format)
  apiRepositoryPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_distribution => /api/repositories/:repository_id/distributions/:id(.:format)
  apiRepositoryDistributionPath: function(_repository_id, _id, options) {
  return Utils.build_path(["repository_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"distributions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_distributions => /api/repositories/:repository_id/distributions(.:format)
  apiRepositoryDistributionsPath: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"distributions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_errata => /api/repositories/:repository_id/errata(.:format)
  apiRepositoryErrataPath: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_erratum => /api/repositories/:repository_id/errata/:id(.:format)
  apiRepositoryErratumPath: function(_repository_id, _id, options) {
  return Utils.build_path(["repository_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_package => /api/repositories/:repository_id/packages/:id(.:format)
  apiRepositoryPackagePath: function(_repository_id, _id, options) {
  return Utils.build_path(["repository_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_packages => /api/repositories/:repository_id/packages(.:format)
  apiRepositoryPackagesPath: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_sync_index => /api/repositories/:repository_id/sync(.:format)
  apiRepositorySyncIndexPath: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_role => /api/roles/:id(.:format)
  apiRolePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_role_ldap_group => /api/roles/:role_id/ldap_groups/:id(.:format)
  apiRoleLdapGroupPath: function(_role_id, _id, options) {
  return Utils.build_path(["role_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"ldap_groups",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_role_ldap_groups => /api/roles/:role_id/ldap_groups(.:format)
  apiRoleLdapGroupsPath: function(_role_id, options) {
  return Utils.build_path(["role_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"ldap_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_role_permission => /api/roles/:role_id/permissions/:id(.:format)
  apiRolePermissionPath: function(_role_id, _id, options) {
  return Utils.build_path(["role_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"permissions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_role_permissions => /api/roles/:role_id/permissions(.:format)
  apiRolePermissionsPath: function(_role_id, options) {
  return Utils.build_path(["role_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"permissions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_roles => /api/roles(.:format)
  apiRolesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_show_custom_info => /api/custom_info/:informable_type/:informable_id/*keyname(.:format)
  apiShowCustomInfoPath: function(_informable_type, _informable_id, _keyname, options) {
  return Utils.build_path(["informable_type","informable_id","keyname"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"custom_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"informable_id",false]],[7,"/",false]],[5,[3,"keyname",false],false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_status => /api/status(.:format)
  apiStatusPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_status_memory => /api/status/memory(.:format)
  apiStatusMemoryPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"status",false]],[7,"/",false]],[6,"memory",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_subscriptions => /api/subscriptions(.:format)
  apiSubscriptionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_sync_plan => /api/sync_plans/:id(.:format)
  apiSyncPlanPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"sync_plans",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system => /api/systems/:id(.:format)
  apiSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_group => /api/system_groups/:id(.:format)
  apiSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_group_errata => /api/system_groups/:system_group_id/errata(.:format)
  apiSystemGroupErrataPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_group_packages => /api/system_groups/:system_group_id/packages(.:format)
  apiSystemGroupPackagesPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_groups => /api/system_groups(.:format)
  apiSystemGroupsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_packages => /api/systems/:system_id/packages(.:format)
  apiSystemPackagesPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_subscription => /api/systems/:system_id/subscriptions/:id(.:format)
  apiSystemSubscriptionPath: function(_system_id, _id, options) {
  return Utils.build_path(["system_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_subscriptions => /api/systems/:system_id/subscriptions(.:format)
  apiSystemSubscriptionsPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_systems => /api/systems(.:format)
  apiSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_task => /api/tasks/:id(.:format)
  apiTaskPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"tasks",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_update_custom_info => /api/custom_info/:informable_type/:informable_id/*keyname(.:format)
  apiUpdateCustomInfoPath: function(_informable_type, _informable_id, _keyname, options) {
  return Utils.build_path(["informable_type","informable_id","keyname"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"custom_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"informable_id",false]],[7,"/",false]],[5,[3,"keyname",false],false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_user => /api/users/:id(.:format)
  apiUserPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_user_role => /api/users/:user_id/roles/:id(.:format)
  apiUserRolePath: function(_user_id, _id, options) {
  return Utils.build_path(["user_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[3,"user_id",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_user_roles => /api/users/:user_id/roles(.:format)
  apiUserRolesPath: function(_user_id, options) {
  return Utils.build_path(["user_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[3,"user_id",false]],[7,"/",false]],[6,"roles",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_users => /api/users(.:format)
  apiUsersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_version => /api/version(.:format)
  apiVersionPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"version",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// apipie_apipie => /apidoc(/:version)(/:resource)(/:method)(.:format)
  apipieApipiePath: function(options) {
  return Utils.build_path([], ["version","resource","method","format"], [2,[2,[2,[2,[2,[7,"/",false],[6,"apidoc",false]],[1,[2,[7,"/",false],[3,"version",false]],false]],[1,[2,[7,"/",false],[3,"resource",false]],false]],[1,[2,[7,"/",false],[3,"method",false]],false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// applied_subscriptions_activation_key => /activation_keys/:id/applied_subscriptions(.:format)
  appliedSubscriptionsActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"applied_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// apply_api_changeset => /api/changesets/:id/apply(.:format)
  applyApiChangesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"apply",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// apply_changeset => /changesets/:id/apply(.:format)
  applyChangesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"apply",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// apply_default_info_status_organization => /organizations/:id/apply_default_info_status(.:format)
  applyDefaultInfoStatusOrganizationPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"apply_default_info_status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// authenticate => /authenticate(.:format)
  authenticatePath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"authenticate",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_content_views => /content_views/auto_complete(.:format)
  autoCompleteContentViewsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_views",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_distributors => /distributors/auto_complete(.:format)
  autoCompleteDistributorsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_errata => /errata/auto_complete(.:format)
  autoCompleteErrataPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"errata",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_library_packages => /packages/auto_complete_library(.:format)
  autoCompleteLibraryPackagesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[6,"auto_complete_library",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_library_repositories => /repositories/auto_complete_library(.:format)
  autoCompleteLibraryRepositoriesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"repositories",false]],[7,"/",false]],[6,"auto_complete_library",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_nvrea_library_packages => /packages/auto_complete_nvrea_library(.:format)
  autoCompleteNvreaLibraryPackagesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[6,"auto_complete_nvrea_library",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_packages => /packages/auto_complete(.:format)
  autoCompletePackagesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_products => /products/auto_complete(.:format)
  autoCompleteProductsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_activation_keys => /activation_keys/auto_complete_search(.:format)
  autoCompleteSearchActivationKeysPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_changesets => /changesets/auto_complete_search(.:format)
  autoCompleteSearchChangesetsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_gpg_keys => /gpg_keys/auto_complete_search(.:format)
  autoCompleteSearchGpgKeysPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_organizations => /organizations/auto_complete_search(.:format)
  autoCompleteSearchOrganizationsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_providers => /providers/auto_complete_search(.:format)
  autoCompleteSearchProvidersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_roles => /roles/auto_complete_search(.:format)
  autoCompleteSearchRolesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_sync_plans => /sync_plans/auto_complete_search(.:format)
  autoCompleteSearchSyncPlansPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_plans",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_users => /users/auto_complete_search(.:format)
  autoCompleteSearchUsersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_system_groups => /system_groups/auto_complete(.:format)
  autoCompleteSystemGroupsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_systems => /systems/auto_complete(.:format)
  autoCompleteSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// available_subscriptions_activation_key => /activation_keys/:id/available_subscriptions(.:format)
  availableSubscriptionsActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"available_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// available_verbs_api_roles => /api/roles/available_verbs(.:format)
  availableVerbsApiRolesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[6,"available_verbs",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_add_system_group_systems => /systems/bulk_add_system_group(.:format)
  bulkAddSystemGroupSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_add_system_group",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_content_install_systems => /systems/bulk_content_install(.:format)
  bulkContentInstallSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_content_install",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_content_remove_systems => /systems/bulk_content_remove(.:format)
  bulkContentRemoveSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_content_remove",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_content_update_systems => /systems/bulk_content_update(.:format)
  bulkContentUpdateSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_content_update",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_destroy_distributors => /distributors/bulk_destroy(.:format)
  bulkDestroyDistributorsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"bulk_destroy",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_destroy_systems => /systems/bulk_destroy(.:format)
  bulkDestroySystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_destroy",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_errata_install_systems => /systems/bulk_errata_install(.:format)
  bulkErrataInstallSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_errata_install",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_remove_system_group_systems => /systems/bulk_remove_system_group(.:format)
  bulkRemoveSystemGroupSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_remove_system_group",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// cancel_discovery_provider => /providers/:id/cancel_discovery(.:format)
  cancelDiscoveryProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"cancel_discovery",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// changelog_package => /packages/:id/changelog(.:format)
  changelogPackagePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"changelog",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// changeset => /changesets/:id(.:format)
  changesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// changesets => /changesets(.:format)
  changesetsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"changesets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// checkin_api_system => /api/systems/:id/checkin(.:format)
  checkinApiSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"checkin",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// clear_helptips_user => /users/:id/clear_helptips(.:format)
  clearHelptipsUserPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"clear_helptips",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// clone_api_content_view_definition => /api/content_view_definitions/:id/clone(.:format)
  cloneApiContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"clone",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// clone_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/:id/clone(.:format)
  cloneApiOrganizationContentViewDefinitionPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"clone",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// clone_content_view_definition => /content_view_definitions/:id/clone(.:format)
  cloneContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"clone",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// consumers_subscription => /subscriptions/:id/consumers(.:format)
  consumersSubscriptionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"consumers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_api_gpg_key => /api/gpg_keys/:id/content(.:format)
  contentApiGpgKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"gpg_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_content_view_definition => /content_view_definitions/:id/content(.:format)
  contentContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_organization_environment_content_view_version => /organizations/:organization_id/environments/:environment_id/content_view_versions/:id/content(.:format)
  contentOrganizationEnvironmentContentViewVersionPath: function(_organization_id, _environment_id, _id, options) {
  return Utils.build_path(["organization_id","environment_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"content_view_versions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_search => /content_search/:id(.:format)
  contentSearchPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_search_index => /content_search(.:format)
  contentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"content_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view => /content_views/:id(.:format)
  contentViewPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition => /content_view_definitions/:id(.:format)
  contentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition_content_view => /content_view_definitions/:content_view_definition_id/content_views/:id(.:format)
  contentViewDefinitionContentViewPath: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition_filter => /content_view_definitions/:content_view_definition_id/filters/:id(.:format)
  contentViewDefinitionFilterPath: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id(.:format)
  contentViewDefinitionFilterRulePath: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition_filter_rules => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules(.:format)
  contentViewDefinitionFilterRulesPath: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition_filters => /content_view_definitions/:content_view_definition_id/filters(.:format)
  contentViewDefinitionFiltersPath: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definitions => /content_view_definitions(.:format)
  contentViewDefinitionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"content_view_definitions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views => /content_views(.:format)
  contentViewsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views_api_content_view_definition => /api/content_view_definitions/:id/content_views(.:format)
  contentViewsApiContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views_dashboard_index => /dashboard/content_views(.:format)
  contentViewsDashboardIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views_environment => /environments/:id/content_views(.:format)
  contentViewsEnvironmentPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views_organization_environment => /organizations/:organization_id/environments/:id/content_views(.:format)
  contentViewsOrganizationEnvironmentPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views_promotion => /promotions/:id/content_views(.:format)
  contentViewsPromotionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"promotions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// copy_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/copy(.:format)
  copyApiOrganizationSystemGroupPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"copy",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// copy_api_system_group => /api/system_groups/:id/copy(.:format)
  copyApiSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"copy",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// copy_system_group => /system_groups/:id/copy(.:format)
  copySystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"copy",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// create_role_ldap_groups => /roles/:role_id/ldap_groups(.:format)
  createRoleLdapGroupsPath: function(_role_id, options) {
  return Utils.build_path(["role_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"ldap_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// custom_info_distributor => /distributors/:id/custom_info(.:format)
  customInfoDistributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"custom_info",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// custom_info_system => /systems/:id/custom_info(.:format)
  customInfoSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"custom_info",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// dashboard_index => /dashboard(.:format)
  dashboardIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"dashboard",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// default_label_content_view_definitions => /content_view_definitions/default_label(.:format)
  defaultLabelContentViewDefinitionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[6,"default_label",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// default_label_organization_environments => /organizations/:organization_id/environments/default_label(.:format)
  defaultLabelOrganizationEnvironmentsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[6,"default_label",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// default_label_organizations => /organizations/default_label(.:format)
  defaultLabelOrganizationsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[6,"default_label",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// default_label_provider_product_repositories => /providers/:provider_id/products/:product_id/repositories/default_label(.:format)
  defaultLabelProviderProductRepositoriesPath: function(_provider_id, _product_id, options) {
  return Utils.build_path(["provider_id","product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[6,"default_label",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// default_label_provider_products => /providers/:provider_id/products/default_label(.:format)
  defaultLabelProviderProductsPath: function(_provider_id, options) {
  return Utils.build_path(["provider_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[6,"default_label",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// delete_manifest_api_provider => /api/providers/:id/delete_manifest(.:format)
  deleteManifestApiProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"delete_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// delete_manifest_subscriptions => /subscriptions/delete_manifest(.:format)
  deleteManifestSubscriptionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"delete_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// dependencies_api_changeset => /api/changesets/:id/dependencies(.:format)
  dependenciesApiChangesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"dependencies",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// dependencies_changeset => /changesets/:id/dependencies(.:format)
  dependenciesChangesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"dependencies",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// dependencies_package => /packages/:id/dependencies(.:format)
  dependenciesPackagePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"dependencies",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_favorite_search_index => /search/favorite/:id(.:format)
  destroyFavoriteSearchIndexPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"search",false]],[7,"/",false]],[6,"favorite",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_filters_content_view_definition_filters => /content_view_definitions/:content_view_definition_id/filters/destroy_filters(.:format)
  destroyFiltersContentViewDefinitionFiltersPath: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[6,"destroy_filters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_parameters_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/destroy_parameters(.:format)
  destroyParametersContentViewDefinitionFilterRulePath: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"destroy_parameters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_role_ldap_group => /roles/:role_id/ldap_groups/:id(.:format)
  destroyRoleLdapGroupPath: function(_role_id, _id, options) {
  return Utils.build_path(["role_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"ldap_groups",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_rules_content_view_definition_filter_rules => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/destroy_rules(.:format)
  destroyRulesContentViewDefinitionFilterRulesPath: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[6,"destroy_rules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/destroy_systems(.:format)
  destroySystemsApiOrganizationSystemGroupPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"destroy_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_systems_api_system_group => /api/system_groups/:id/destroy_systems(.:format)
  destroySystemsApiSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"destroy_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_systems_system_group => /system_groups/:id/destroy_systems(.:format)
  destroySystemsSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"destroy_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// details_package => /packages/:id/details(.:format)
  detailsPackagePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"details",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// details_promotion => /promotions/:id/details(.:format)
  detailsPromotionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"promotions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"details",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// disable_api_organization_product_repository_set => /api/organizations/:organization_id/products/:product_id/repository_sets/:id/disable(.:format)
  disableApiOrganizationProductRepositorySetPath: function(_organization_id, _product_id, _id, options) {
  return Utils.build_path(["organization_id","product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"disable",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// disable_api_product_repository_set => /api/products/:product_id/repository_sets/:id/disable(.:format)
  disableApiProductRepositorySetPath: function(_product_id, _id, options) {
  return Utils.build_path(["product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"disable",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// disable_content_product => /products/:id/disable_content(.:format)
  disableContentProductPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"disable_content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// disable_helptip_users => /users/disable_helptip(.:format)
  disableHelptipUsersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[6,"disable_helptip",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// discover_provider => /providers/:id/discover(.:format)
  discoverProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"discover",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// discovered_repos_provider => /providers/:id/discovered_repos(.:format)
  discoveredReposProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"discovered_repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// discovery_api_provider => /api/providers/:id/discovery(.:format)
  discoveryApiProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"discovery",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// distributor => /distributors/:id(.:format)
  distributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// distributor_event => /distributors/:distributor_id/events/:id(.:format)
  distributorEventPath: function(_distributor_id, _id, options) {
  return Utils.build_path(["distributor_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// distributor_events => /distributors/:distributor_id/events(.:format)
  distributorEventsPath: function(_distributor_id, options) {
  return Utils.build_path(["distributor_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// distributors => /distributors(.:format)
  distributorsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"distributors",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// download_debug_certificate_organization => /organizations/:id/download_debug_certificate(.:format)
  downloadDebugCertificateOrganizationPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"download_debug_certificate",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// download_distributor => /distributors/:id/download(.:format)
  downloadDistributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"download",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_activation_key => /activation_keys/:id/edit(.:format)
  editActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_activation_key => /api/activation_keys/:id/edit(.:format)
  editApiActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_content_view => /api/changesets/:changeset_id/content_views/:id/edit(.:format)
  editApiChangesetContentViewPath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_distribution => /api/changesets/:changeset_id/distributions/:id/edit(.:format)
  editApiChangesetDistributionPath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"distributions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_erratum => /api/changesets/:changeset_id/errata/:id/edit(.:format)
  editApiChangesetErratumPath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_package => /api/changesets/:changeset_id/packages/:id/edit(.:format)
  editApiChangesetPackagePath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_product => /api/changesets/:changeset_id/products/:id/edit(.:format)
  editApiChangesetProductPath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_repository => /api/changesets/:changeset_id/repositories/:id/edit(.:format)
  editApiChangesetRepositoryPath: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_consumer => /api/consumers/:id/edit(.:format)
  editApiConsumerPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_node => /api/nodes/:id/edit(.:format)
  editApiNodePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_node_capability => /api/nodes/:node_id/capabilities/:id/edit(.:format)
  editApiNodeCapabilityPath: function(_node_id, _id, options) {
  return Utils.build_path(["node_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"node_id",false]],[7,"/",false]],[6,"capabilities",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_organization => /api/organizations/:id/edit(.:format)
  editApiOrganizationPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/:id/edit(.:format)
  editApiOrganizationContentViewDefinitionPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_organization_environment => /api/organizations/:organization_id/environments/:id/edit(.:format)
  editApiOrganizationEnvironmentPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/:id/edit(.:format)
  editApiOrganizationSyncPlanPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"sync_plans",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_organization_system_group_packages => /api/organizations/:organization_id/system_groups/:system_group_id/packages/edit(.:format)
  editApiOrganizationSystemGroupPackagesPath: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(["organization_id","system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_provider => /api/providers/:id/edit(.:format)
  editApiProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_repository_package => /api/repositories/:repository_id/packages/:id/edit(.:format)
  editApiRepositoryPackagePath: function(_repository_id, _id, options) {
  return Utils.build_path(["repository_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_role => /api/roles/:id/edit(.:format)
  editApiRolePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_system_group_packages => /api/system_groups/:system_group_id/packages/edit(.:format)
  editApiSystemGroupPackagesPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_system_packages => /api/systems/:system_id/packages/edit(.:format)
  editApiSystemPackagesPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_user => /api/users/:id/edit(.:format)
  editApiUserPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_changeset => /changesets/:id/edit(.:format)
  editChangesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_content_search => /content_search/:id/edit(.:format)
  editContentSearchPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_content_view => /content_views/:id/edit(.:format)
  editContentViewPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_content_view_definition => /content_view_definitions/:id/edit(.:format)
  editContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_content_view_definition_filter => /content_view_definitions/:content_view_definition_id/filters/:id/edit(.:format)
  editContentViewDefinitionFilterPath: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/edit(.:format)
  editContentViewDefinitionFilterRulePath: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_date_type_parameters_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/edit_date_type_parameters(.:format)
  editDateTypeParametersContentViewDefinitionFilterRulePath: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit_date_type_parameters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_distributor => /distributors/:id/edit(.:format)
  editDistributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_environment => /environments/:id/edit(.:format)
  editEnvironmentPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_environment_user => /users/:id/edit_environment(.:format)
  editEnvironmentUserPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit_environment",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_gpg_key => /gpg_keys/:id/edit(.:format)
  editGpgKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_inclusion_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/edit_inclusion(.:format)
  editInclusionContentViewDefinitionFilterRulePath: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit_inclusion",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_manifest_subscriptions => /subscriptions/edit_manifest(.:format)
  editManifestSubscriptionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"edit_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_organization => /organizations/:id/edit(.:format)
  editOrganizationPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_organization_environment => /organizations/:organization_id/environments/:id/edit(.:format)
  editOrganizationEnvironmentPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_parameter_list_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/edit_parameter_list(.:format)
  editParameterListContentViewDefinitionFilterRulePath: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit_parameter_list",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_password_reset => /password_resets/:id/edit(.:format)
  editPasswordResetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"password_resets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_product => /products/:id/edit(.:format)
  editProductPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_provider => /providers/:id/edit(.:format)
  editProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_provider_product => /providers/:provider_id/products/:id/edit(.:format)
  editProviderProductPath: function(_provider_id, _id, options) {
  return Utils.build_path(["provider_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/edit(.:format)
  editProviderProductRepositoryPath: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(["provider_id","product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_repository => /repositories/:id/edit(.:format)
  editRepositoryPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_role => /roles/:id/edit(.:format)
  editRolePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_subscription => /subscriptions/:id/edit(.:format)
  editSubscriptionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_sync_plan => /sync_plans/:id/edit(.:format)
  editSyncPlanPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"sync_plans",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_system => /systems/:id/edit(.:format)
  editSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_system_group => /system_groups/:id/edit(.:format)
  editSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_systems_system_group => /system_groups/:id/edit_systems(.:format)
  editSystemsSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_user => /users/:id/edit(.:format)
  editUserPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_user_session => /user_session/edit(.:format)
  editUserSessionPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"user_session",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// email_logins_password_resets => /password_resets/email_logins(.:format)
  emailLoginsPasswordResetsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"password_resets",false]],[7,"/",false]],[6,"email_logins",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enable_api_organization_product_repository_set => /api/organizations/:organization_id/products/:product_id/repository_sets/:id/enable(.:format)
  enableApiOrganizationProductRepositorySetPath: function(_organization_id, _product_id, _id, options) {
  return Utils.build_path(["organization_id","product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"enable",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enable_api_product_repository_set => /api/products/:product_id/repository_sets/:id/enable(.:format)
  enableApiProductRepositorySetPath: function(_product_id, _id, options) {
  return Utils.build_path(["product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"enable",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enable_api_repository => /api/repositories/:id/enable(.:format)
  enableApiRepositoryPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"enable",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enable_helptip_users => /users/enable_helptip(.:format)
  enableHelptipUsersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[6,"enable_helptip",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enable_repo => /repositories/:id/enable_repo(.:format)
  enableRepoPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"enable_repo",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enabled_repos_api_system => /api/systems/:id/enabled_repos(.:format)
  enabledReposApiSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"enabled_repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// env_items_distributors => /distributors/env_items(.:format)
  envItemsDistributorsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"env_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// env_items_systems => /systems/env_items(.:format)
  envItemsSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"env_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// environment => /environments/:id(.:format)
  environmentPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// environments => /environments(.:format)
  environmentsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"environments",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// environments_distributors => /distributors/environments(.:format)
  environmentsDistributorsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"environments",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// environments_partial_organization => /organizations/:id/environments_partial(.:format)
  environmentsPartialOrganizationPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"environments_partial",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// environments_systems => /systems/environments(.:format)
  environmentsSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"environments",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// errata_api_system => /api/systems/:id/errata(.:format)
  errataApiSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// errata_content_search_index => /content_search/errata(.:format)
  errataContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// errata_dashboard_index => /dashboard/errata(.:format)
  errataDashboardIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// errata_items_content_search_index => /content_search/errata_items(.:format)
  errataItemsContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"errata_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// erratum => /errata/:id(.:format)
  erratumPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// events_organization => /organizations/:id/events(.:format)
  eventsOrganizationPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// export_api_distributor => /api/distributors/:id/export(.:format)
  exportApiDistributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"export",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// facts_system => /systems/:id/facts(.:format)
  factsSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"facts",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// favorite_search_index => /search/favorite(.:format)
  favoriteSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"search",false]],[7,"/",false]],[6,"favorite",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// filelist_package => /packages/:id/filelist(.:format)
  filelistPackagePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"filelist",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// gpg_key => /gpg_keys/:id(.:format)
  gpgKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// gpg_key_content_api_repository => /api/repositories/:id/gpg_key_content(.:format)
  gpgKeyContentApiRepositoryPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"gpg_key_content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// gpg_keys => /gpg_keys(.:format)
  gpgKeysPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"gpg_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// history_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/history(.:format)
  historyApiOrganizationSystemGroupPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"history",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// history_api_system_group => /api/system_groups/:id/history(.:format)
  historyApiSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"history",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// history_items_subscriptions => /subscriptions/history_items(.:format)
  historyItemsSubscriptionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"history_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// history_search_index => /search/history(.:format)
  historySearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"search",false]],[7,"/",false]],[6,"history",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// history_subscriptions => /subscriptions/history(.:format)
  historySubscriptionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"history",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// i18n_dictionary => /i18n/dictionary(.:format)
  i18nDictionaryPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"i18n",false]],[7,"/",false]],[6,"dictionary",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// import_manifest_api_provider => /api/providers/:id/import_manifest(.:format)
  importManifestApiProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"import_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// import_products_api_provider => /api/providers/:id/import_products(.:format)
  importProductsApiProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"import_products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// install_system_errata => /systems/:system_id/errata/install(.:format)
  installSystemErrataPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"install",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// install_system_group_errata => /system_groups/:system_group_id/errata/install(.:format)
  installSystemGroupErrataPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"install",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_activation_keys => /activation_keys/items(.:format)
  itemsActivationKeysPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_changesets => /changesets/items(.:format)
  itemsChangesetsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_content_view_definitions => /content_view_definitions/items(.:format)
  itemsContentViewDefinitionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_distributor_events => /distributors/:distributor_id/events/items(.:format)
  itemsDistributorEventsPath: function(_distributor_id, options) {
  return Utils.build_path(["distributor_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_distributors => /distributors/items(.:format)
  itemsDistributorsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_gpg_keys => /gpg_keys/items(.:format)
  itemsGpgKeysPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_organizations => /organizations/items(.:format)
  itemsOrganizationsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_providers => /providers/items(.:format)
  itemsProvidersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_roles => /roles/items(.:format)
  itemsRolesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_subscriptions => /subscriptions/items(.:format)
  itemsSubscriptionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_sync_plans => /sync_plans/items(.:format)
  itemsSyncPlansPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_plans",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_system_errata => /systems/:system_id/errata/items(.:format)
  itemsSystemErrataPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_system_events => /systems/:system_id/events/items(.:format)
  itemsSystemEventsPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_system_group_errata => /system_groups/:system_group_id/errata/items(.:format)
  itemsSystemGroupErrataPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_system_group_events => /system_groups/:system_group_id/events/items(.:format)
  itemsSystemGroupEventsPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_system_groups => /system_groups/items(.:format)
  itemsSystemGroupsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_systems => /systems/items(.:format)
  itemsSystemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_users => /users/items(.:format)
  itemsUsersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// list_changesets => /changesets/list(.:format)
  listChangesetsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[6,"list",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// login => /login(.:format)
  loginPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"login",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// logout => /logout(.:format)
  logoutPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"logout",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// manifest_progress_provider => /providers/:id/manifest_progress(.:format)
  manifestProgressProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"manifest_progress",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_events_distributor_events => /distributors/:distributor_id/events/more_events(.:format)
  moreEventsDistributorEventsPath: function(_distributor_id, options) {
  return Utils.build_path(["distributor_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"more_events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_events_system_events => /systems/:system_id/events/more_events(.:format)
  moreEventsSystemEventsPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"more_events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_items_system_group_events => /system_groups/:system_group_id/events/more_items(.:format)
  moreItemsSystemGroupEventsPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"more_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_packages_system_system_packages => /systems/:system_id/system_packages/more_packages(.:format)
  morePackagesSystemSystemPackagesPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[7,"/",false]],[6,"more_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_products_distributor => /distributors/:id/more_products(.:format)
  moreProductsDistributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"more_products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_products_system => /systems/:id/more_products(.:format)
  moreProductsSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"more_products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// name_changeset => /changesets/:id/name(.:format)
  nameChangesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"name",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_activation_key => /activation_keys/new(.:format)
  newActivationKeyPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_activation_key => /api/activation_keys/new(.:format)
  newApiActivationKeyPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_content_view => /api/changesets/:changeset_id/content_views/new(.:format)
  newApiChangesetContentViewPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_distribution => /api/changesets/:changeset_id/distributions/new(.:format)
  newApiChangesetDistributionPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"distributions",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_erratum => /api/changesets/:changeset_id/errata/new(.:format)
  newApiChangesetErratumPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_package => /api/changesets/:changeset_id/packages/new(.:format)
  newApiChangesetPackagePath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_product => /api/changesets/:changeset_id/products/new(.:format)
  newApiChangesetProductPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_repository => /api/changesets/:changeset_id/repositories/new(.:format)
  newApiChangesetRepositoryPath: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_consumer => /api/consumers/new(.:format)
  newApiConsumerPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_node => /api/nodes/new(.:format)
  newApiNodePath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_node_capability => /api/nodes/:node_id/capabilities/new(.:format)
  newApiNodeCapabilityPath: function(_node_id, options) {
  return Utils.build_path(["node_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"node_id",false]],[7,"/",false]],[6,"capabilities",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_organization => /api/organizations/new(.:format)
  newApiOrganizationPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/new(.:format)
  newApiOrganizationContentViewDefinitionPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_organization_environment => /api/organizations/:organization_id/environments/new(.:format)
  newApiOrganizationEnvironmentPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/new(.:format)
  newApiOrganizationSyncPlanPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"sync_plans",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_organization_system_group_packages => /api/organizations/:organization_id/system_groups/:system_group_id/packages/new(.:format)
  newApiOrganizationSystemGroupPackagesPath: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(["organization_id","system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_provider => /api/providers/new(.:format)
  newApiProviderPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_repository_package => /api/repositories/:repository_id/packages/new(.:format)
  newApiRepositoryPackagePath: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_role => /api/roles/new(.:format)
  newApiRolePath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_system_group_packages => /api/system_groups/:system_group_id/packages/new(.:format)
  newApiSystemGroupPackagesPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_system_packages => /api/systems/:system_id/packages/new(.:format)
  newApiSystemPackagesPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_user => /api/users/new(.:format)
  newApiUserPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_changeset => /changesets/new(.:format)
  newChangesetPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_content_search => /content_search/new(.:format)
  newContentSearchPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_content_view => /content_views/new(.:format)
  newContentViewPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_views",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_content_view_definition => /content_view_definitions/new(.:format)
  newContentViewDefinitionPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_content_view_definition_filter => /content_view_definitions/:content_view_definition_id/filters/new(.:format)
  newContentViewDefinitionFilterPath: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/new(.:format)
  newContentViewDefinitionFilterRulePath: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_discovered_repos_provider => /providers/:id/new_discovered_repos(.:format)
  newDiscoveredReposProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"new_discovered_repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_distributor => /distributors/new(.:format)
  newDistributorPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_environment => /environments/new(.:format)
  newEnvironmentPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"environments",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_gpg_key => /gpg_keys/new(.:format)
  newGpgKeyPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_organization => /organizations/new(.:format)
  newOrganizationPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_organization_environment => /organizations/:organization_id/environments/new(.:format)
  newOrganizationEnvironmentPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_product => /products/new(.:format)
  newProductPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_provider => /providers/new(.:format)
  newProviderPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_provider_product => /providers/:provider_id/products/new(.:format)
  newProviderProductPath: function(_provider_id, options) {
  return Utils.build_path(["provider_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/new(.:format)
  newProviderProductRepositoryPath: function(_provider_id, _product_id, options) {
  return Utils.build_path(["provider_id","product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_repository => /repositories/new(.:format)
  newRepositoryPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"repositories",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_role => /roles/new(.:format)
  newRolePath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_subscription => /subscriptions/new(.:format)
  newSubscriptionPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_sync_plan => /sync_plans/new(.:format)
  newSyncPlanPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_plans",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_system => /systems/new(.:format)
  newSystemPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_system_group => /system_groups/new(.:format)
  newSystemGroupPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_user => /users/new(.:format)
  newUserPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_user_session => /user_session/new(.:format)
  newUserSessionPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"user_session",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices => /notices(.:format)
  noticesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"notices",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices_auto_complete_search => /notices/auto_complete_search(.:format)
  noticesAutoCompleteSearchPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"notices",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices_dashboard_index => /dashboard/notices(.:format)
  noticesDashboardIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"notices",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices_details => /notices/:id/details(.:format)
  noticesDetailsPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"notices",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"details",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices_get_new => /notices/get_new(.:format)
  noticesGetNewPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"notices",false]],[7,"/",false]],[6,"get_new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices_note_count => /notices/note_count(.:format)
  noticesNoteCountPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"notices",false]],[7,"/",false]],[6,"note_count",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// object_changeset => /changesets/:id/object(.:format)
  objectChangesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"object",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// operations => /operations(.:format)
  operationsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"operations",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organization => /organizations/:id(.:format)
  organizationPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organization_default_info => /organizations/:id/default_info/:informable_type(.:format)
  organizationDefaultInfoPath: function(_id, _informable_type, options) {
  return Utils.build_path(["id","informable_type"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"default_info",false]],[7,"/",false]],[3,"informable_type",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organization_environment => /organizations/:organization_id/environments/:id(.:format)
  organizationEnvironmentPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organization_environment_content_view_version => /organizations/:organization_id/environments/:environment_id/content_view_versions/:id(.:format)
  organizationEnvironmentContentViewVersionPath: function(_organization_id, _environment_id, _id, options) {
  return Utils.build_path(["organization_id","environment_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"content_view_versions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organization_environments => /organizations/:organization_id/environments(.:format)
  organizationEnvironmentsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organizations => /organizations(.:format)
  organizationsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"organizations",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// package => /packages/:id(.:format)
  packagePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// package_group_categories_api_repository => /api/repositories/:id/package_group_categories(.:format)
  packageGroupCategoriesApiRepositoryPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"package_group_categories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// package_groups_api_repository => /api/repositories/:id/package_groups(.:format)
  packageGroupsApiRepositoryPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"package_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// packages_api_system => /api/systems/:id/packages(.:format)
  packagesApiSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// packages_content_search_index => /content_search/packages(.:format)
  packagesContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// packages_erratum => /errata/:id/packages(.:format)
  packagesErratumPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// packages_items_content_search_index => /content_search/packages_items(.:format)
  packagesItemsContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"packages_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// packages_system_system_packages => /systems/:system_id/system_packages/packages(.:format)
  packagesSystemSystemPackagesPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// password_reset => /password_resets/:id(.:format)
  passwordResetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"password_resets",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// password_resets => /password_resets(.:format)
  passwordResetsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"password_resets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// pools_api_activation_key => /api/activation_keys/:id/pools(.:format)
  poolsApiActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// pools_api_distributor => /api/distributors/:id/pools(.:format)
  poolsApiDistributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// pools_api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id/pools(.:format)
  poolsApiOrganizationActivationKeyPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// pools_api_system => /api/systems/:id/pools(.:format)
  poolsApiSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// product => /products/:id(.:format)
  productPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// product_create_api_provider => /api/providers/:id/product_create(.:format)
  productCreateApiProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"product_create",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products => /products(.:format)
  productsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_api_provider => /api/providers/:id/products(.:format)
  productsApiProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_content_search_index => /content_search/products(.:format)
  productsContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_distributor => /distributors/:id/products(.:format)
  productsDistributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_organization_environment => /organizations/:organization_id/environments/:id/products(.:format)
  productsOrganizationEnvironmentPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_repos_gpg_key => /gpg_keys/:id/products_repos(.:format)
  productsReposGpgKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products_repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_repos_provider => /providers/:id/products_repos(.:format)
  productsReposProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products_repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_subscription => /subscriptions/:id/products(.:format)
  productsSubscriptionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_system => /systems/:id/products(.:format)
  productsSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// promote_api_changeset => /api/changesets/:id/promote(.:format)
  promoteApiChangesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"promote",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// promote_api_content_view => /api/content_views/:id/promote(.:format)
  promoteApiContentViewPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"promote",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// promotion => /promotions/:id(.:format)
  promotionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"promotions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// promotions => /promotions(.:format)
  promotionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"promotions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// promotions_dashboard_index => /dashboard/promotions(.:format)
  promotionsDashboardIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"promotions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// provider => /providers/:id(.:format)
  providerPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// provider_product => /providers/:provider_id/products/:id(.:format)
  providerProductPath: function(_provider_id, _id, options) {
  return Utils.build_path(["provider_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// provider_product_repositories => /providers/:provider_id/products/:product_id/repositories(.:format)
  providerProductRepositoriesPath: function(_provider_id, _product_id, options) {
  return Utils.build_path(["provider_id","product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id(.:format)
  providerProductRepositoryPath: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(["provider_id","product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// provider_products => /providers/:provider_id/products(.:format)
  providerProductsPath: function(_provider_id, options) {
  return Utils.build_path(["provider_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// providers => /providers(.:format)
  providersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"providers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// publish_api_content_view_definition => /api/content_view_definitions/:id/publish(.:format)
  publishApiContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"publish",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// publish_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/:id/publish(.:format)
  publishApiOrganizationContentViewDefinitionPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"publish",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// publish_content_view_definition => /content_view_definitions/:id/publish(.:format)
  publishContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"publish",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// publish_setup_content_view_definition => /content_view_definitions/:id/publish_setup(.:format)
  publishSetupContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"publish_setup",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// puppet_module => /puppet_modules/:id(.:format)
  puppetModulePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"puppet_modules",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// puppet_modules_content_search_index => /content_search/puppet_modules(.:format)
  puppetModulesContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"puppet_modules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// puppet_modules_items_content_search_index => /content_search/puppet_modules_items(.:format)
  puppetModulesItemsContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"puppet_modules_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// rails_info_properties => /rails/info/properties(.:format)
  railsInfoPropertiesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"rails",false]],[7,"/",false]],[6,"info",false]],[7,"/",false]],[6,"properties",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// redhat_provider_providers => /providers/redhat_provider(.:format)
  redhatProviderProvidersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[6,"redhat_provider",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_api_content_view => /api/content_views/:id/refresh(.:format)
  refreshApiContentViewPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_content_product => /products/:id/refresh_content(.:format)
  refreshContentProductPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh_content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_content_view_definition_content_view => /content_view_definitions/:content_view_definition_id/content_views/:id/refresh(.:format)
  refreshContentViewDefinitionContentViewPath: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_manifest_api_provider => /api/providers/:id/refresh_manifest(.:format)
  refreshManifestApiProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_manifest_subscriptions => /subscriptions/refresh_manifest(.:format)
  refreshManifestSubscriptionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"refresh_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_products_api_provider => /api/providers/:id/refresh_products(.:format)
  refreshProductsApiProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh_products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_products_providers => /providers/refresh_products(.:format)
  refreshProductsProvidersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[6,"refresh_products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_subscriptions_api_system => /api/systems/:id/refresh_subscriptions(.:format)
  refreshSubscriptionsApiSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// registerable_paths_organization_environments => /organizations/:organization_id/environments/registerable_paths(.:format)
  registerablePathsOrganizationEnvironmentsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[6,"registerable_paths",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// releases_api_environment => /api/environments/:id/releases(.:format)
  releasesApiEnvironmentPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"releases",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// releases_api_system => /api/systems/:id/releases(.:format)
  releasesApiSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"releases",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// releases_system => /systems/:id/releases(.:format)
  releasesSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"releases",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_subscriptions_activation_key => /activation_keys/:id/remove_subscriptions(.:format)
  removeSubscriptionsActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_system_group_packages => /system_groups/:system_group_id/packages/remove(.:format)
  removeSystemGroupPackagesPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"remove",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_system_groups_activation_key => /activation_keys/:id/remove_system_groups(.:format)
  removeSystemGroupsActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_system_groups_system => /systems/:id/remove_system_groups(.:format)
  removeSystemGroupsSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_system_system_packages => /systems/:system_id/system_packages/remove(.:format)
  removeSystemSystemPackagesPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[7,"/",false]],[6,"remove",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/remove_systems(.:format)
  removeSystemsApiOrganizationSystemGroupPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_systems_api_system_group => /api/system_groups/:id/remove_systems(.:format)
  removeSystemsApiSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_systems_system_group => /system_groups/:id/remove_systems(.:format)
  removeSystemsSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_compare_errata_content_search_index => /content_search/repo_compare_errata(.:format)
  repoCompareErrataContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_compare_errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_compare_packages_content_search_index => /content_search/repo_compare_packages(.:format)
  repoComparePackagesContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_compare_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_compare_puppet_modules_content_search_index => /content_search/repo_compare_puppet_modules(.:format)
  repoComparePuppetModulesContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_compare_puppet_modules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_discovery_provider => /providers/:id/repo_discovery(.:format)
  repoDiscoveryProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repo_discovery",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_errata_content_search_index => /content_search/repo_errata(.:format)
  repoErrataContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_packages_content_search_index => /content_search/repo_packages(.:format)
  repoPackagesContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_puppet_modules_content_search_index => /content_search/repo_puppet_modules(.:format)
  repoPuppetModulesContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_puppet_modules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// report_api_environment_systems => /api/environments/:environment_id/systems/report(.:format)
  reportApiEnvironmentSystemsPath: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[6,"report",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// report_api_organization_systems => /api/organizations/:organization_id/systems/report(.:format)
  reportApiOrganizationSystemsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[6,"report",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// report_api_users => /api/users/report(.:format)
  reportApiUsersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[6,"report",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repos_content_search_index => /content_search/repos(.:format)
  reposContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories => /repositories(.:format)
  repositoriesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories_api_environment => /api/environments/:id/repositories(.:format)
  repositoriesApiEnvironmentPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories_api_environment_product => /api/environments/:environment_id/products/:id/repositories(.:format)
  repositoriesApiEnvironmentProductPath: function(_environment_id, _id, options) {
  return Utils.build_path(["environment_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories_api_organization_environment => /api/organizations/:organization_id/environments/:id/repositories(.:format)
  repositoriesApiOrganizationEnvironmentPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories_api_organization_product => /api/organizations/:organization_id/products/:id/repositories(.:format)
  repositoriesApiOrganizationProductPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories_api_product => /api/products/:id/repositories(.:format)
  repositoriesApiProductPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repository => /repositories/:id(.:format)
  repositoryPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// role => /roles/:id(.:format)
  rolePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// role_create_permission => /roles/:role_id/create_permission(.:format)
  roleCreatePermissionPath: function(_role_id, options) {
  return Utils.build_path(["role_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"create_permission",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// role_permission_destroy => /roles/:role_id/permission/:permission_id/destroy_permission(.:format)
  rolePermissionDestroyPath: function(_role_id, _permission_id, options) {
  return Utils.build_path(["role_id","permission_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"permission",false]],[7,"/",false]],[3,"permission_id",false]],[7,"/",false]],[6,"destroy_permission",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// role_permission_update => /roles/:role_id/permission/:permission_id/update_permission(.:format)
  rolePermissionUpdatePath: function(_role_id, _permission_id, options) {
  return Utils.build_path(["role_id","permission_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"permission",false]],[7,"/",false]],[3,"permission_id",false]],[7,"/",false]],[6,"update_permission",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// roles => /roles(.:format)
  rolesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"roles",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// roles_show_permission => /roles/show_permission(.:format)
  rolesShowPermissionPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[6,"show_permission",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// root => /
  rootPath: function(options) {
  return Utils.build_path([], [], [7,"/",false], arguments);
  },
// schedule_provider => /providers/:id/schedule(.:format)
  scheduleProviderPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"schedule",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// search_api_repository_packages => /api/repositories/:repository_id/packages/search(.:format)
  searchApiRepositoryPackagesPath: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// search_index => /search(.:format)
  searchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// set_org_user_session => /user_session/set_org(.:format)
  setOrgUserSessionPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"user_session",false]],[7,"/",false]],[6,"set_org",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// setup_default_org_user => /users/:id/setup_default_org(.:format)
  setupDefaultOrgUserPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"setup_default_org",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// short_details_erratum => /errata/:id/short_details(.:format)
  shortDetailsErratumPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"short_details",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// show_user_session => /user_session(.:format)
  showUserSessionPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"user_session",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_changeset => /changesets/:id/status(.:format)
  statusChangesetPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_content_view_definition => /content_view_definitions/:id/status(.:format)
  statusContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_distributor_events => /distributors/:distributor_id/events/status(.:format)
  statusDistributorEventsPath: function(_distributor_id, options) {
  return Utils.build_path(["distributor_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_errata => /systems/:system_id/errata/status(.:format)
  statusSystemErrataPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_events => /systems/:system_id/events/status(.:format)
  statusSystemEventsPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_group_errata => /system_groups/:system_group_id/errata/status(.:format)
  statusSystemGroupErrataPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_group_events => /system_groups/:system_group_id/events/status(.:format)
  statusSystemGroupEventsPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_group_packages => /system_groups/:system_group_id/packages/status(.:format)
  statusSystemGroupPackagesPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_system_packages => /systems/:system_id/system_packages/status(.:format)
  statusSystemSystemPackagesPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscription => /subscriptions/:id(.:format)
  subscriptionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscription_status_api_system => /api/systems/:id/subscription_status(.:format)
  subscriptionStatusApiSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"subscription_status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscriptions => /subscriptions(.:format)
  subscriptionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscriptions_activation_keys => /activation_keys/subscriptions(.:format)
  subscriptionsActivationKeysPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscriptions_dashboard_index => /dashboard/subscriptions(.:format)
  subscriptionsDashboardIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscriptions_distributor => /distributors/:id/subscriptions(.:format)
  subscriptionsDistributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscriptions_system => /systems/:id/subscriptions(.:format)
  subscriptionsSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_api_node => /api/nodes/:id/sync(.:format)
  syncApiNodePath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_complete_api_repositories => /api/repositories/sync_complete(.:format)
  syncCompleteApiRepositoriesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[6,"sync_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_dashboard_index => /dashboard/sync(.:format)
  syncDashboardIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_ldap_roles_api_users => /api/users/sync_ldap_roles(.:format)
  syncLdapRolesApiUsersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[6,"sync_ldap_roles",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management => /sync_management/:id(.:format)
  syncManagementPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management_index => /sync_management/index(.:format)
  syncManagementIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[6,"index",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management_manage => /sync_management/manage(.:format)
  syncManagementManagePath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[6,"manage",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management_product_status => /sync_management/product_status(.:format)
  syncManagementProductStatusPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[6,"product_status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management_sync => /sync_management/sync(.:format)
  syncManagementSyncPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management_sync_status => /sync_management/sync_status(.:format)
  syncManagementSyncStatusPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[6,"sync_status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_plan => /sync_plans/:id(.:format)
  syncPlanPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_plans",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_plan_api_organization_product => /api/organizations/:organization_id/products/:id/sync_plan(.:format)
  syncPlanApiOrganizationProductPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"sync_plan",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_plan_api_product => /api/products/:id/sync_plan(.:format)
  syncPlanApiProductPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"sync_plan",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_plans => /sync_plans(.:format)
  syncPlansPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"sync_plans",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_schedules_apply => /sync_schedules/apply(.:format)
  syncSchedulesApplyPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_schedules",false]],[7,"/",false]],[6,"apply",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_schedules_index => /sync_schedules/index(.:format)
  syncSchedulesIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_schedules",false]],[7,"/",false]],[6,"index",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system => /systems/:id(.:format)
  systemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_errata => /systems/:system_id/errata(.:format)
  systemErrataPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_erratum => /systems/:system_id/errata/:id(.:format)
  systemErratumPath: function(_system_id, _id, options) {
  return Utils.build_path(["system_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_event => /systems/:system_id/events/:id(.:format)
  systemEventPath: function(_system_id, _id, options) {
  return Utils.build_path(["system_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_events => /systems/:system_id/events(.:format)
  systemEventsPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_group => /system_groups/:id(.:format)
  systemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_group_errata => /system_groups/:system_group_id/errata(.:format)
  systemGroupErrataPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_group_event => /system_groups/:system_group_id/events/:id(.:format)
  systemGroupEventPath: function(_system_group_id, _id, options) {
  return Utils.build_path(["system_group_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_group_events => /system_groups/:system_group_id/events(.:format)
  systemGroupEventsPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_group_packages => /system_groups/:system_group_id/packages(.:format)
  systemGroupPackagesPath: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups => /system_groups(.:format)
  systemGroupsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups_activation_key => /activation_keys/:id/system_groups(.:format)
  systemGroupsActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups_api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id/system_groups(.:format)
  systemGroupsApiOrganizationActivationKeyPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups_api_system => /api/systems/:id/system_groups(.:format)
  systemGroupsApiSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups_dashboard_index => /dashboard/system_groups(.:format)
  systemGroupsDashboardIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups_system => /systems/:id/system_groups(.:format)
  systemGroupsSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_system_packages => /systems/:system_id/system_packages(.:format)
  systemSystemPackagesPath: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems => /systems(.:format)
  systemsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems_activation_key => /activation_keys/:id/systems(.:format)
  systemsActivationKeyPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/systems(.:format)
  systemsApiOrganizationSystemGroupPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems_api_system_group => /api/system_groups/:id/systems(.:format)
  systemsApiSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems_dashboard_index => /dashboard/systems(.:format)
  systemsDashboardIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems_system_group => /system_groups/:id/systems(.:format)
  systemsSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// tasks_api_organization_systems => /api/organizations/:organization_id/systems/tasks(.:format)
  tasksApiOrganizationSystemsPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[6,"tasks",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_component_views_content_view_definition => /content_view_definitions/:id/update_component_views(.:format)
  updateComponentViewsContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_component_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_content_content_view_definition => /content_view_definitions/:id/update_content(.:format)
  updateContentContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_environment_user => /users/:id/update_environment(.:format)
  updateEnvironmentUserPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_environment",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_locale_user => /users/:id/update_locale(.:format)
  updateLocaleUserPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_locale",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_parameter_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/update_parameter(.:format)
  updateParameterContentViewDefinitionFilterRulePath: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_parameter",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_preference_user => /users/:id/update_preference(.:format)
  updatePreferenceUserPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_preference",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_repo_gpg_key_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/update_gpg_key(.:format)
  updateRepoGpgKeyProviderProductRepositoryPath: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(["provider_id","product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_gpg_key",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_roles_user => /users/:id/update_roles(.:format)
  updateRolesUserPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_roles",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_subscriptions_distributor => /distributors/:id/update_subscriptions(.:format)
  updateSubscriptionsDistributorPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_subscriptions_system => /systems/:id/update_subscriptions(.:format)
  updateSubscriptionsSystemPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/update_systems(.:format)
  updateSystemsApiOrganizationSystemGroupPath: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_systems_system_group => /system_groups/:id/update_systems(.:format)
  updateSystemsSystemGroupPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// upload_subscriptions => /subscriptions/upload(.:format)
  uploadSubscriptionsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"upload",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// user => /users/:id(.:format)
  userPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// user_session => /user_session(.:format)
  userSessionPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"user_session",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// user_session_logout => /user_session/logout(.:format)
  userSessionLogoutPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"user_session",false]],[7,"/",false]],[6,"logout",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// users => /users(.:format)
  usersPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"users",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// validate_name_library_packages => /packages/validate_name_library(.:format)
  validateNameLibraryPackagesPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[6,"validate_name_library",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// validate_name_system_groups => /system_groups/validate_name(.:format)
  validateNameSystemGroupsPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[6,"validate_name",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// verbs_and_scopes => /roles/:organization_id/resource_type/verbs_and_scopes(.:format)
  verbsAndScopesPath: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"resource_type",false]],[7,"/",false]],[6,"verbs_and_scopes",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// view_compare_errata_content_search_index => /content_search/view_compare_errata(.:format)
  viewCompareErrataContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"view_compare_errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// view_compare_packages_content_search_index => /content_search/view_compare_packages(.:format)
  viewComparePackagesContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"view_compare_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// view_compare_puppet_modules_content_search_index => /content_search/view_compare_puppet_modules(.:format)
  viewComparePuppetModulesContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"view_compare_puppet_modules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// view_packages_content_search_index => /content_search/view_packages(.:format)
  viewPackagesContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"view_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// view_puppet_modules_content_search_index => /content_search/view_puppet_modules(.:format)
  viewPuppetModulesContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"view_puppet_modules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// views_content_search_index => /content_search/views(.:format)
  viewsContentSearchIndexPath: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// views_content_view_definition => /content_view_definitions/:id/views(.:format)
  viewsContentViewDefinitionPath: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  }}
;

  window.BASTION.KT.routes.options = defaults;

}).call(this);
