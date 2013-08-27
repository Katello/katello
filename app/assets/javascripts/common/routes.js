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

  Utils.namespace(window, "KT.routes");

  window.KT.routes = {
// about => /about(.:format)
  about_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"about",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// activation_key => /activation_keys/:id(.:format)
  activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// activation_keys => /activation_keys(.:format)
  activation_keys_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"activation_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_parameter_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/add_parameter(.:format)
  add_parameter_content_view_definition_filter_rule_path: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_parameter",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_subscriptions_activation_key => /activation_keys/:id/add_subscriptions(.:format)
  add_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_system_group_packages => /system_groups/:system_group_id/packages/add(.:format)
  add_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"add",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_system_groups_activation_key => /activation_keys/:id/add_system_groups(.:format)
  add_system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_system_groups_system => /systems/:id/add_system_groups(.:format)
  add_system_groups_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_system_system_packages => /systems/:system_id/system_packages/add(.:format)
  add_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[7,"/",false]],[6,"add",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/add_systems(.:format)
  add_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_systems_api_system_group => /api/system_groups/:id/add_systems(.:format)
  add_systems_api_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// add_systems_system_group => /system_groups/:id/add_systems(.:format)
  add_systems_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"add_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// all_api_content_view_definition_products => /api/content_view_definitions/:content_view_definition_id/products/all(.:format)
  all_api_content_view_definition_products_path: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[6,"all",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// all_api_organization_content_view_definition_products => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/products/all(.:format)
  all_api_organization_content_view_definition_products_path: function(_organization_id, _content_view_definition_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[6,"all",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// allowed_orgs_user_session => /user_session/allowed_orgs(.:format)
  allowed_orgs_user_session_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"user_session",false]],[7,"/",false]],[6,"allowed_orgs",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api => /api(.:format)
  api_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"api",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_about_index => /api/about(.:format)
  api_about_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"about",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_activation_key => /api/activation_keys/:id(.:format)
  api_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_activation_keys => /api/activation_keys(.:format)
  api_activation_keys_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset => /api/changesets/:id(.:format)
  api_changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_content_view => /api/changesets/:changeset_id/content_views/:id(.:format)
  api_changeset_content_view_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_content_views => /api/changesets/:changeset_id/content_views(.:format)
  api_changeset_content_views_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_distribution => /api/changesets/:changeset_id/distributions/:id(.:format)
  api_changeset_distribution_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"distributions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_distributions => /api/changesets/:changeset_id/distributions(.:format)
  api_changeset_distributions_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"distributions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_errata => /api/changesets/:changeset_id/errata(.:format)
  api_changeset_errata_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_erratum => /api/changesets/:changeset_id/errata/:id(.:format)
  api_changeset_erratum_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_package => /api/changesets/:changeset_id/packages/:id(.:format)
  api_changeset_package_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_packages => /api/changesets/:changeset_id/packages(.:format)
  api_changeset_packages_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_product => /api/changesets/:changeset_id/products/:id(.:format)
  api_changeset_product_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_products => /api/changesets/:changeset_id/products(.:format)
  api_changeset_products_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_repositories => /api/changesets/:changeset_id/repositories(.:format)
  api_changeset_repositories_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_repository => /api/changesets/:changeset_id/repositories/:id(.:format)
  api_changeset_repository_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_template => /api/changesets/:changeset_id/templates/:id(.:format)
  api_changeset_template_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"templates",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_changeset_templates => /api/changesets/:changeset_id/templates(.:format)
  api_changeset_templates_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"templates",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_consumer => /api/consumers/:id(.:format)
  api_consumer_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_consumers => /api/consumers(.:format)
  api_consumers_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view => /api/content_views/:id(.:format)
  api_content_view_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition => /api/content_view_definitions/:id(.:format)
  api_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_content_views => /api/content_view_definitions/:content_view_definition_id/content_views(.:format)
  api_content_view_definition_content_views_path: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filter => /api/content_view_definitions/:content_view_definition_id/filters/:id(.:format)
  api_content_view_definition_filter_path: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filter_products => /api/content_view_definitions/:content_view_definition_id/filters/:filter_id/products(.:format)
  api_content_view_definition_filter_products_path: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filter_repositories => /api/content_view_definitions/:content_view_definition_id/filters/:filter_id/repositories(.:format)
  api_content_view_definition_filter_repositories_path: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filter_rule => /api/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id(.:format)
  api_content_view_definition_filter_rule_path: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filter_rules => /api/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules(.:format)
  api_content_view_definition_filter_rules_path: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_filters => /api/content_view_definitions/:content_view_definition_id/filters(.:format)
  api_content_view_definition_filters_path: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_products => /api/content_view_definitions/:content_view_definition_id/products(.:format)
  api_content_view_definition_products_path: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_content_view_definition_repositories => /api/content_view_definitions/:content_view_definition_id/repositories(.:format)
  api_content_view_definition_repositories_path: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_create_custom_info => /api/custom_info/:informable_type/:informable_id(.:format)
  api_create_custom_info_path: function(_informable_type, _informable_id, options) {
  return Utils.build_path(["informable_type","informable_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"custom_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"informable_id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_crls => /api/crls(.:format)
  api_crls_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"crls",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_custom_info => /api/custom_info/:informable_type/:informable_id(.:format)
  api_custom_info_path: function(_informable_type, _informable_id, options) {
  return Utils.build_path(["informable_type","informable_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"custom_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"informable_id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_destroy_custom_info => /api/custom_info/:informable_type/:informable_id/*keyname(.:format)
  api_destroy_custom_info_path: function(_informable_type, _informable_id, _keyname, options) {
  return Utils.build_path(["informable_type","informable_id","keyname"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"custom_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"informable_id",false]],[7,"/",false]],[5,[3,"keyname",false],false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_distributor => /api/distributors/:id(.:format)
  api_distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_distributor_subscription => /api/distributors/:distributor_id/subscriptions/:id(.:format)
  api_distributor_subscription_path: function(_distributor_id, _id, options) {
  return Utils.build_path(["distributor_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_distributor_subscriptions => /api/distributors/:distributor_id/subscriptions(.:format)
  api_distributor_subscriptions_path: function(_distributor_id, options) {
  return Utils.build_path(["distributor_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_distributors => /api/distributors(.:format)
  api_distributors_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment => /api/environments/:id(.:format)
  api_environment_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_activation_keys => /api/environments/:environment_id/activation_keys(.:format)
  api_environment_activation_keys_path: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"activation_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_changesets => /api/environments/:environment_id/changesets(.:format)
  api_environment_changesets_path: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"changesets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_content_views => /api/environments/:environment_id/content_views(.:format)
  api_environment_content_views_path: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_distributors => /api/environments/:environment_id/distributors(.:format)
  api_environment_distributors_path: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"distributors",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_products => /api/environments/:environment_id/products(.:format)
  api_environment_products_path: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_environment_systems => /api/environments/:environment_id/systems(.:format)
  api_environment_systems_path: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_errata => /api/errata(.:format)
  api_errata_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_gpg_key => /api/gpg_keys/:id(.:format)
  api_gpg_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"gpg_keys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_hypervisors => /api/hypervisors(.:format)
  api_hypervisors_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"hypervisors",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_node => /api/nodes/:id(.:format)
  api_node_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_node_capabilities => /api/nodes/:node_id/capabilities(.:format)
  api_node_capabilities_path: function(_node_id, options) {
  return Utils.build_path(["node_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"node_id",false]],[7,"/",false]],[6,"capabilities",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_node_capability => /api/nodes/:node_id/capabilities/:id(.:format)
  api_node_capability_path: function(_node_id, _id, options) {
  return Utils.build_path(["node_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"node_id",false]],[7,"/",false]],[6,"capabilities",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_nodes => /api/nodes(.:format)
  api_nodes_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization => /api/organizations/:id(.:format)
  api_organization_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id(.:format)
  api_organization_activation_key_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_activation_keys => /api/organizations/:organization_id/activation_keys(.:format)
  api_organization_activation_keys_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"activation_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_apply_default_info => /api/organizations/:organization_id/default_info/:informable_type/apply(.:format)
  api_organization_apply_default_info_path: function(_organization_id, _informable_type, options) {
  return Utils.build_path(["organization_id","informable_type"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"default_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[6,"apply",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_auto_attach_all_systems => /api/organizations/:organization_id/auto_attach(.:format)
  api_organization_auto_attach_all_systems_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"auto_attach",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view => /api/organizations/:organization_id/content_views/:id(.:format)
  api_organization_content_view_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/:id(.:format)
  api_organization_content_view_definition_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filter => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id(.:format)
  api_organization_content_view_definition_filter_path: function(_organization_id, _content_view_definition_id, _id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filter_products => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:filter_id/products(.:format)
  api_organization_content_view_definition_filter_products_path: function(_organization_id, _content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filter_repositories => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:filter_id/repositories(.:format)
  api_organization_content_view_definition_filter_repositories_path: function(_organization_id, _content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filter_rule => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id(.:format)
  api_organization_content_view_definition_filter_rule_path: function(_organization_id, _content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filter_rules => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules(.:format)
  api_organization_content_view_definition_filter_rules_path: function(_organization_id, _content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_filters => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters(.:format)
  api_organization_content_view_definition_filters_path: function(_organization_id, _content_view_definition_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_products => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/products(.:format)
  api_organization_content_view_definition_products_path: function(_organization_id, _content_view_definition_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definition_repositories => /api/organizations/:organization_id/content_view_definitions/:content_view_definition_id/repositories(.:format)
  api_organization_content_view_definition_repositories_path: function(_organization_id, _content_view_definition_id, options) {
  return Utils.build_path(["organization_id","content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_view_definitions => /api/organizations/:organization_id/content_view_definitions(.:format)
  api_organization_content_view_definitions_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_content_views => /api/organizations/:organization_id/content_views(.:format)
  api_organization_content_views_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_create_default_info => /api/organizations/:organization_id/default_info/:informable_type(.:format)
  api_organization_create_default_info_path: function(_organization_id, _informable_type, options) {
  return Utils.build_path(["organization_id","informable_type"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"default_info",false]],[7,"/",false]],[3,"informable_type",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_destroy_default_info => /api/organizations/:organization_id/default_info/:informable_type/:keyname(.:format)
  api_organization_destroy_default_info_path: function(_organization_id, _informable_type, _keyname, options) {
  return Utils.build_path(["organization_id","informable_type","keyname"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"default_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"keyname",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_distributors => /api/organizations/:organization_id/distributors(.:format)
  api_organization_distributors_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"distributors",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_environment => /api/organizations/:organization_id/environments/:id(.:format)
  api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_environment_changesets => /api/organizations/:organization_id/environments/:environment_id/changesets(.:format)
  api_organization_environment_changesets_path: function(_organization_id, _environment_id, options) {
  return Utils.build_path(["organization_id","environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"changesets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_environments => /api/organizations/:organization_id/environments(.:format)
  api_organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_gpg_keys => /api/organizations/:organization_id/gpg_keys(.:format)
  api_organization_gpg_keys_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"gpg_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_product => /api/organizations/:organization_id/products/:id(.:format)
  api_organization_product_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_product_repository_sets => /api/organizations/:organization_id/products/:product_id/repository_sets(.:format)
  api_organization_product_repository_sets_path: function(_organization_id, _product_id, options) {
  return Utils.build_path(["organization_id","product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_product_sync_index => /api/organizations/:organization_id/products/:product_id/sync(.:format)
  api_organization_product_sync_index_path: function(_organization_id, _product_id, options) {
  return Utils.build_path(["organization_id","product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_products => /api/organizations/:organization_id/products(.:format)
  api_organization_products_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_providers => /api/organizations/:organization_id/providers(.:format)
  api_organization_providers_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"providers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/:id(.:format)
  api_organization_sync_plan_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"sync_plans",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_sync_plans => /api/organizations/:organization_id/sync_plans(.:format)
  api_organization_sync_plans_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"sync_plans",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_system_group => /api/organizations/:organization_id/system_groups/:id(.:format)
  api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_system_group_errata => /api/organizations/:organization_id/system_groups/:system_group_id/errata(.:format)
  api_organization_system_group_errata_path: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(["organization_id","system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_system_group_packages => /api/organizations/:organization_id/system_groups/:system_group_id/packages(.:format)
  api_organization_system_group_packages_path: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(["organization_id","system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_system_groups => /api/organizations/:organization_id/system_groups(.:format)
  api_organization_system_groups_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_systems => /api/organizations/:organization_id/systems(.:format)
  api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_tasks => /api/organizations/:organization_id/tasks(.:format)
  api_organization_tasks_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"tasks",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organization_uebercert => /api/organizations/:organization_id/uebercert(.:format)
  api_organization_uebercert_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"uebercert",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_organizations => /api/organizations(.:format)
  api_organizations_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_ping_index => /api/ping(.:format)
  api_ping_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"ping",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_pool => /api/activation_keys/:id/pools/:id(.:format)
  api_pool_path: function(_id, _id, options) {
  return Utils.build_path(["id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_pools => /api/activation_keys/:id/pools(.:format)
  api_pools_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_product => /api/products/:id(.:format)
  api_product_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_product_repositories => /api/products/:product_id/repositories(.:format)
  api_product_repositories_path: function(_product_id, options) {
  return Utils.build_path(["product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_product_repository_sets => /api/products/:product_id/repository_sets(.:format)
  api_product_repository_sets_path: function(_product_id, options) {
  return Utils.build_path(["product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_product_sync_index => /api/products/:product_id/sync(.:format)
  api_product_sync_index_path: function(_product_id, options) {
  return Utils.build_path(["product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_provider => /api/providers/:id(.:format)
  api_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_provider_sync_index => /api/providers/:provider_id/sync(.:format)
  api_provider_sync_index_path: function(_provider_id, options) {
  return Utils.build_path(["provider_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_providers => /api/providers(.:format)
  api_providers_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_certificate_serials_path => /api/consumers/:id/certificates/serials(.:format)
  api_proxy_certificate_serials_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"certificates",false]],[7,"/",false]],[6,"serials",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_certificates_delete_path => /api/consumers/:consumer_id/certificates/:id(.:format)
  api_proxy_consumer_certificates_delete_path_path: function(_consumer_id, _id, options) {
  return Utils.build_path(["consumer_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"consumer_id",false]],[7,"/",false]],[6,"certificates",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_certificates_path => /api/consumers/:id/certificates(.:format)
  api_proxy_consumer_certificates_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"certificates",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_compliance_path => /api/consumers/:id/compliance(.:format)
  api_proxy_consumer_compliance_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"compliance",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_deletionrecord_delete_path => /api/consumers/:id/deletionrecord(.:format)
  api_proxy_consumer_deletionrecord_delete_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"deletionrecord",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_dryrun_path => /api/consumers/:id/entitlements/dry-run(.:format)
  api_proxy_consumer_dryrun_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"entitlements",false]],[7,"/",false]],[6,"dry-run",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_entitlements_delete_path => /api/consumers/:id/entitlements(.:format)
  api_proxy_consumer_entitlements_delete_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"entitlements",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_entitlements_path => /api/consumers/:id/entitlements(.:format)
  api_proxy_consumer_entitlements_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"entitlements",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_entitlements_post_path => /api/consumers/:id/entitlements(.:format)
  api_proxy_consumer_entitlements_post_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"entitlements",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_export_path => /api/consumers/:id/export(.:format)
  api_proxy_consumer_export_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"export",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_owners_path => /api/consumers/:id/owner(.:format)
  api_proxy_consumer_owners_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"owner",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_consumer_releases_path => /api/consumers/:id/release(.:format)
  api_proxy_consumer_releases_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"release",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_deleted_consumers_path => /api/deleted_consumers(.:format)
  api_proxy_deleted_consumers_path_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"deleted_consumers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_entitlements_path => /api/entitlements/:id(.:format)
  api_proxy_entitlements_path_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"entitlements",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_owner_pools_path => /api/owners/:organization_id/pools(.:format)
  api_proxy_owner_pools_path_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"owners",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_owner_servicelevels_path => /api/owners/:organization_id/servicelevels(.:format)
  api_proxy_owner_servicelevels_path_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"owners",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"servicelevels",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_pools_path => /api/pools(.:format)
  api_proxy_pools_path_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_proxy_subscriptions_post_path => /api/subscriptions(.:format)
  api_proxy_subscriptions_post_path_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repositories => /api/repositories(.:format)
  api_repositories_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository => /api/repositories/:id(.:format)
  api_repository_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_distribution => /api/repositories/:repository_id/distributions/:id(.:format)
  api_repository_distribution_path: function(_repository_id, _id, options) {
  return Utils.build_path(["repository_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"distributions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_distributions => /api/repositories/:repository_id/distributions(.:format)
  api_repository_distributions_path: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"distributions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_errata => /api/repositories/:repository_id/errata(.:format)
  api_repository_errata_path: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_erratum => /api/repositories/:repository_id/errata/:id(.:format)
  api_repository_erratum_path: function(_repository_id, _id, options) {
  return Utils.build_path(["repository_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_package => /api/repositories/:repository_id/packages/:id(.:format)
  api_repository_package_path: function(_repository_id, _id, options) {
  return Utils.build_path(["repository_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_packages => /api/repositories/:repository_id/packages(.:format)
  api_repository_packages_path: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_repository_sync_index => /api/repositories/:repository_id/sync(.:format)
  api_repository_sync_index_path: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_role => /api/roles/:id(.:format)
  api_role_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_role_ldap_group => /api/roles/:role_id/ldap_groups/:id(.:format)
  api_role_ldap_group_path: function(_role_id, _id, options) {
  return Utils.build_path(["role_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"ldap_groups",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_role_ldap_groups => /api/roles/:role_id/ldap_groups(.:format)
  api_role_ldap_groups_path: function(_role_id, options) {
  return Utils.build_path(["role_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"ldap_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_role_permission => /api/roles/:role_id/permissions/:id(.:format)
  api_role_permission_path: function(_role_id, _id, options) {
  return Utils.build_path(["role_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"permissions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_role_permissions => /api/roles/:role_id/permissions(.:format)
  api_role_permissions_path: function(_role_id, options) {
  return Utils.build_path(["role_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"permissions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_roles => /api/roles(.:format)
  api_roles_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_show_custom_info => /api/custom_info/:informable_type/:informable_id/*keyname(.:format)
  api_show_custom_info_path: function(_informable_type, _informable_id, _keyname, options) {
  return Utils.build_path(["informable_type","informable_id","keyname"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"custom_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"informable_id",false]],[7,"/",false]],[5,[3,"keyname",false],false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_status => /api/status(.:format)
  api_status_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_status_memory => /api/status/memory(.:format)
  api_status_memory_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"status",false]],[7,"/",false]],[6,"memory",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_subscriptions => /api/subscriptions(.:format)
  api_subscriptions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_sync_plan => /api/sync_plans/:id(.:format)
  api_sync_plan_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"sync_plans",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system => /api/systems/:id(.:format)
  api_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_group => /api/system_groups/:id(.:format)
  api_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_group_errata => /api/system_groups/:system_group_id/errata(.:format)
  api_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_group_packages => /api/system_groups/:system_group_id/packages(.:format)
  api_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_groups => /api/system_groups(.:format)
  api_system_groups_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_packages => /api/systems/:system_id/packages(.:format)
  api_system_packages_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_subscription => /api/systems/:system_id/subscriptions/:id(.:format)
  api_system_subscription_path: function(_system_id, _id, options) {
  return Utils.build_path(["system_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_system_subscriptions => /api/systems/:system_id/subscriptions(.:format)
  api_system_subscriptions_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_systems => /api/systems(.:format)
  api_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_task => /api/tasks/:id(.:format)
  api_task_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"tasks",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_update_custom_info => /api/custom_info/:informable_type/:informable_id/*keyname(.:format)
  api_update_custom_info_path: function(_informable_type, _informable_id, _keyname, options) {
  return Utils.build_path(["informable_type","informable_id","keyname"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"custom_info",false]],[7,"/",false]],[3,"informable_type",false]],[7,"/",false]],[3,"informable_id",false]],[7,"/",false]],[5,[3,"keyname",false],false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_user => /api/users/:id(.:format)
  api_user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_user_role => /api/users/:user_id/roles/:id(.:format)
  api_user_role_path: function(_user_id, _id, options) {
  return Utils.build_path(["user_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[3,"user_id",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_user_roles => /api/users/:user_id/roles(.:format)
  api_user_roles_path: function(_user_id, options) {
  return Utils.build_path(["user_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[3,"user_id",false]],[7,"/",false]],[6,"roles",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_users => /api/users(.:format)
  api_users_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// api_version => /api/version(.:format)
  api_version_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"version",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// apipie_apipie => /apidoc(/:version)(/:resource)(/:method)(.:format)
  apipie_apipie_path: function(options) {
  return Utils.build_path([], ["version","resource","method","format"], [2,[2,[2,[2,[2,[7,"/",false],[6,"apidoc",false]],[1,[2,[7,"/",false],[3,"version",false]],false]],[1,[2,[7,"/",false],[3,"resource",false]],false]],[1,[2,[7,"/",false],[3,"method",false]],false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// applied_subscriptions_activation_key => /activation_keys/:id/applied_subscriptions(.:format)
  applied_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"applied_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// apply_api_changeset => /api/changesets/:id/apply(.:format)
  apply_api_changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"apply",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// apply_changeset => /changesets/:id/apply(.:format)
  apply_changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"apply",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// apply_default_info_status_organization => /organizations/:id/apply_default_info_status(.:format)
  apply_default_info_status_organization_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"apply_default_info_status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// authenticate => /authenticate(.:format)
  authenticate_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"authenticate",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// author_auto_complete_puppet_modules => /puppet_modules/author_auto_complete(.:format)
  author_auto_complete_puppet_modules_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"puppet_modules",false]],[7,"/",false]],[6,"author_auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_content_views => /content_views/auto_complete(.:format)
  auto_complete_content_views_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_views",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_distributors => /distributors/auto_complete(.:format)
  auto_complete_distributors_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_errata => /errata/auto_complete(.:format)
  auto_complete_errata_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"errata",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_library_packages => /packages/auto_complete_library(.:format)
  auto_complete_library_packages_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[6,"auto_complete_library",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_library_repositories => /repositories/auto_complete_library(.:format)
  auto_complete_library_repositories_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"repositories",false]],[7,"/",false]],[6,"auto_complete_library",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_nvrea_library_packages => /packages/auto_complete_nvrea_library(.:format)
  auto_complete_nvrea_library_packages_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[6,"auto_complete_nvrea_library",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_packages => /packages/auto_complete(.:format)
  auto_complete_packages_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_products => /products/auto_complete(.:format)
  auto_complete_products_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_puppet_modules => /puppet_modules/auto_complete(.:format)
  auto_complete_puppet_modules_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"puppet_modules",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_activation_keys => /activation_keys/auto_complete_search(.:format)
  auto_complete_search_activation_keys_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_changesets => /changesets/auto_complete_search(.:format)
  auto_complete_search_changesets_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_gpg_keys => /gpg_keys/auto_complete_search(.:format)
  auto_complete_search_gpg_keys_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_organizations => /organizations/auto_complete_search(.:format)
  auto_complete_search_organizations_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_providers => /providers/auto_complete_search(.:format)
  auto_complete_search_providers_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_roles => /roles/auto_complete_search(.:format)
  auto_complete_search_roles_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_sync_plans => /sync_plans/auto_complete_search(.:format)
  auto_complete_search_sync_plans_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_plans",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_search_users => /users/auto_complete_search(.:format)
  auto_complete_search_users_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_system_groups => /system_groups/auto_complete(.:format)
  auto_complete_system_groups_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// auto_complete_systems => /systems/auto_complete(.:format)
  auto_complete_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"auto_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// available_subscriptions_activation_key => /activation_keys/:id/available_subscriptions(.:format)
  available_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"available_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// available_verbs_api_roles => /api/roles/available_verbs(.:format)
  available_verbs_api_roles_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[6,"available_verbs",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_add_system_group_systems => /systems/bulk_add_system_group(.:format)
  bulk_add_system_group_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_add_system_group",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_content_install_systems => /systems/bulk_content_install(.:format)
  bulk_content_install_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_content_install",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_content_remove_systems => /systems/bulk_content_remove(.:format)
  bulk_content_remove_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_content_remove",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_content_update_systems => /systems/bulk_content_update(.:format)
  bulk_content_update_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_content_update",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_destroy_distributors => /distributors/bulk_destroy(.:format)
  bulk_destroy_distributors_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"bulk_destroy",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_destroy_systems => /systems/bulk_destroy(.:format)
  bulk_destroy_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_destroy",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_errata_install_systems => /systems/bulk_errata_install(.:format)
  bulk_errata_install_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_errata_install",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// bulk_remove_system_group_systems => /systems/bulk_remove_system_group(.:format)
  bulk_remove_system_group_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"bulk_remove_system_group",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// cancel_discovery_provider => /providers/:id/cancel_discovery(.:format)
  cancel_discovery_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"cancel_discovery",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// changelog_package => /packages/:id/changelog(.:format)
  changelog_package_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"changelog",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// changeset => /changesets/:id(.:format)
  changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// changesets => /changesets(.:format)
  changesets_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"changesets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// checkin_api_system => /api/systems/:id/checkin(.:format)
  checkin_api_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"checkin",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// clear_helptips_user => /users/:id/clear_helptips(.:format)
  clear_helptips_user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"clear_helptips",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// clone_api_content_view_definition => /api/content_view_definitions/:id/clone(.:format)
  clone_api_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"clone",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// clone_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/:id/clone(.:format)
  clone_api_organization_content_view_definition_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"clone",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// clone_content_view_definition => /content_view_definitions/:id/clone(.:format)
  clone_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"clone",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// consumers_subscription => /subscriptions/:id/consumers(.:format)
  consumers_subscription_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"consumers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_api_gpg_key => /api/gpg_keys/:id/content(.:format)
  content_api_gpg_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"gpg_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_content_view_definition => /content_view_definitions/:id/content(.:format)
  content_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_organization_environment_content_view_version => /organizations/:organization_id/environments/:environment_id/content_view_versions/:id/content(.:format)
  content_organization_environment_content_view_version_path: function(_organization_id, _environment_id, _id, options) {
  return Utils.build_path(["organization_id","environment_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"content_view_versions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_search => /content_search/:id(.:format)
  content_search_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_search_index => /content_search(.:format)
  content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"content_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view => /content_views/:id(.:format)
  content_view_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition => /content_view_definitions/:id(.:format)
  content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition_content_view => /content_view_definitions/:content_view_definition_id/content_views/:id(.:format)
  content_view_definition_content_view_path: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition_filter => /content_view_definitions/:content_view_definition_id/filters/:id(.:format)
  content_view_definition_filter_path: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id(.:format)
  content_view_definition_filter_rule_path: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition_filter_rules => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules(.:format)
  content_view_definition_filter_rules_path: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definition_filters => /content_view_definitions/:content_view_definition_id/filters(.:format)
  content_view_definition_filters_path: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_view_definitions => /content_view_definitions(.:format)
  content_view_definitions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"content_view_definitions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views => /content_views(.:format)
  content_views_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views_api_content_view_definition => /api/content_view_definitions/:id/content_views(.:format)
  content_views_api_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views_dashboard_index => /dashboard/content_views(.:format)
  content_views_dashboard_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views_environment => /environments/:id/content_views(.:format)
  content_views_environment_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views_organization_environment => /organizations/:organization_id/environments/:id/content_views(.:format)
  content_views_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// content_views_promotion => /promotions/:id/content_views(.:format)
  content_views_promotion_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"promotions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"content_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// copy_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/copy(.:format)
  copy_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"copy",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// copy_api_system_group => /api/system_groups/:id/copy(.:format)
  copy_api_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"copy",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// copy_system_group => /system_groups/:id/copy(.:format)
  copy_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"copy",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// create_role_ldap_groups => /roles/:role_id/ldap_groups(.:format)
  create_role_ldap_groups_path: function(_role_id, options) {
  return Utils.build_path(["role_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"ldap_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// custom_info_distributor => /distributors/:id/custom_info(.:format)
  custom_info_distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"custom_info",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// custom_info_system => /systems/:id/custom_info(.:format)
  custom_info_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"custom_info",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// dashboard_index => /dashboard(.:format)
  dashboard_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"dashboard",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// default_label_content_view_definitions => /content_view_definitions/default_label(.:format)
  default_label_content_view_definitions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[6,"default_label",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// default_label_organization_environments => /organizations/:organization_id/environments/default_label(.:format)
  default_label_organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[6,"default_label",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// default_label_organizations => /organizations/default_label(.:format)
  default_label_organizations_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[6,"default_label",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// default_label_provider_product_repositories => /providers/:provider_id/products/:product_id/repositories/default_label(.:format)
  default_label_provider_product_repositories_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(["provider_id","product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[6,"default_label",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// default_label_provider_products => /providers/:provider_id/products/default_label(.:format)
  default_label_provider_products_path: function(_provider_id, options) {
  return Utils.build_path(["provider_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[6,"default_label",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// delete_manifest_api_provider => /api/providers/:id/delete_manifest(.:format)
  delete_manifest_api_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"delete_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// delete_manifest_subscriptions => /subscriptions/delete_manifest(.:format)
  delete_manifest_subscriptions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"delete_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// dependencies_api_changeset => /api/changesets/:id/dependencies(.:format)
  dependencies_api_changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"dependencies",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// dependencies_changeset => /changesets/:id/dependencies(.:format)
  dependencies_changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"dependencies",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// dependencies_package => /packages/:id/dependencies(.:format)
  dependencies_package_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"dependencies",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_favorite_search_index => /search/favorite/:id(.:format)
  destroy_favorite_search_index_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"search",false]],[7,"/",false]],[6,"favorite",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_filters_content_view_definition_filters => /content_view_definitions/:content_view_definition_id/filters/destroy_filters(.:format)
  destroy_filters_content_view_definition_filters_path: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[6,"destroy_filters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_parameters_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/destroy_parameters(.:format)
  destroy_parameters_content_view_definition_filter_rule_path: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"destroy_parameters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_role_ldap_group => /roles/:role_id/ldap_groups/:id(.:format)
  destroy_role_ldap_group_path: function(_role_id, _id, options) {
  return Utils.build_path(["role_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"ldap_groups",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_rules_content_view_definition_filter_rules => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/destroy_rules(.:format)
  destroy_rules_content_view_definition_filter_rules_path: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[6,"destroy_rules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/destroy_systems(.:format)
  destroy_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"destroy_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_systems_api_system_group => /api/system_groups/:id/destroy_systems(.:format)
  destroy_systems_api_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"destroy_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// destroy_systems_system_group => /system_groups/:id/destroy_systems(.:format)
  destroy_systems_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"destroy_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// details_package => /packages/:id/details(.:format)
  details_package_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"details",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// details_promotion => /promotions/:id/details(.:format)
  details_promotion_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"promotions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"details",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// disable_api_organization_product_repository_set => /api/organizations/:organization_id/products/:product_id/repository_sets/:id/disable(.:format)
  disable_api_organization_product_repository_set_path: function(_organization_id, _product_id, _id, options) {
  return Utils.build_path(["organization_id","product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"disable",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// disable_api_product_repository_set => /api/products/:product_id/repository_sets/:id/disable(.:format)
  disable_api_product_repository_set_path: function(_product_id, _id, options) {
  return Utils.build_path(["product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"disable",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// disable_content_product => /products/:id/disable_content(.:format)
  disable_content_product_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"disable_content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// disable_helptip_users => /users/disable_helptip(.:format)
  disable_helptip_users_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[6,"disable_helptip",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// discover_provider => /providers/:id/discover(.:format)
  discover_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"discover",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// discovered_repos_provider => /providers/:id/discovered_repos(.:format)
  discovered_repos_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"discovered_repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// discovery_api_provider => /api/providers/:id/discovery(.:format)
  discovery_api_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"discovery",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// distributor => /distributors/:id(.:format)
  distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// distributor_event => /distributors/:distributor_id/events/:id(.:format)
  distributor_event_path: function(_distributor_id, _id, options) {
  return Utils.build_path(["distributor_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// distributor_events => /distributors/:distributor_id/events(.:format)
  distributor_events_path: function(_distributor_id, options) {
  return Utils.build_path(["distributor_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// distributors => /distributors(.:format)
  distributors_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"distributors",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// download_debug_certificate_organization => /organizations/:id/download_debug_certificate(.:format)
  download_debug_certificate_organization_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"download_debug_certificate",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// download_distributor => /distributors/:id/download(.:format)
  download_distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"download",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_activation_key => /activation_keys/:id/edit(.:format)
  edit_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_activation_key => /api/activation_keys/:id/edit(.:format)
  edit_api_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_content_view => /api/changesets/:changeset_id/content_views/:id/edit(.:format)
  edit_api_changeset_content_view_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_distribution => /api/changesets/:changeset_id/distributions/:id/edit(.:format)
  edit_api_changeset_distribution_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"distributions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_erratum => /api/changesets/:changeset_id/errata/:id/edit(.:format)
  edit_api_changeset_erratum_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_package => /api/changesets/:changeset_id/packages/:id/edit(.:format)
  edit_api_changeset_package_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_product => /api/changesets/:changeset_id/products/:id/edit(.:format)
  edit_api_changeset_product_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_changeset_repository => /api/changesets/:changeset_id/repositories/:id/edit(.:format)
  edit_api_changeset_repository_path: function(_changeset_id, _id, options) {
  return Utils.build_path(["changeset_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_consumer => /api/consumers/:id/edit(.:format)
  edit_api_consumer_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_node => /api/nodes/:id/edit(.:format)
  edit_api_node_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_node_capability => /api/nodes/:node_id/capabilities/:id/edit(.:format)
  edit_api_node_capability_path: function(_node_id, _id, options) {
  return Utils.build_path(["node_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"node_id",false]],[7,"/",false]],[6,"capabilities",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_organization => /api/organizations/:id/edit(.:format)
  edit_api_organization_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/:id/edit(.:format)
  edit_api_organization_content_view_definition_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_organization_environment => /api/organizations/:organization_id/environments/:id/edit(.:format)
  edit_api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/:id/edit(.:format)
  edit_api_organization_sync_plan_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"sync_plans",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_organization_system_group_packages => /api/organizations/:organization_id/system_groups/:system_group_id/packages/edit(.:format)
  edit_api_organization_system_group_packages_path: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(["organization_id","system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_provider => /api/providers/:id/edit(.:format)
  edit_api_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_repository_package => /api/repositories/:repository_id/packages/:id/edit(.:format)
  edit_api_repository_package_path: function(_repository_id, _id, options) {
  return Utils.build_path(["repository_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_role => /api/roles/:id/edit(.:format)
  edit_api_role_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_system_group_packages => /api/system_groups/:system_group_id/packages/edit(.:format)
  edit_api_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_system_packages => /api/systems/:system_id/packages/edit(.:format)
  edit_api_system_packages_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_api_user => /api/users/:id/edit(.:format)
  edit_api_user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_changeset => /changesets/:id/edit(.:format)
  edit_changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_content_search => /content_search/:id/edit(.:format)
  edit_content_search_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_content_view => /content_views/:id/edit(.:format)
  edit_content_view_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_content_view_definition => /content_view_definitions/:id/edit(.:format)
  edit_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_content_view_definition_filter => /content_view_definitions/:content_view_definition_id/filters/:id/edit(.:format)
  edit_content_view_definition_filter_path: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/edit(.:format)
  edit_content_view_definition_filter_rule_path: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_date_type_parameters_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/edit_date_type_parameters(.:format)
  edit_date_type_parameters_content_view_definition_filter_rule_path: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit_date_type_parameters",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_distributor => /distributors/:id/edit(.:format)
  edit_distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_environment => /environments/:id/edit(.:format)
  edit_environment_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_environment_user => /users/:id/edit_environment(.:format)
  edit_environment_user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit_environment",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_gpg_key => /gpg_keys/:id/edit(.:format)
  edit_gpg_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_inclusion_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/edit_inclusion(.:format)
  edit_inclusion_content_view_definition_filter_rule_path: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit_inclusion",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_manifest_subscriptions => /subscriptions/edit_manifest(.:format)
  edit_manifest_subscriptions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"edit_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_organization => /organizations/:id/edit(.:format)
  edit_organization_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_organization_environment => /organizations/:organization_id/environments/:id/edit(.:format)
  edit_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_parameter_list_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/edit_parameter_list(.:format)
  edit_parameter_list_content_view_definition_filter_rule_path: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit_parameter_list",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_password_reset => /password_resets/:id/edit(.:format)
  edit_password_reset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"password_resets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_product => /products/:id/edit(.:format)
  edit_product_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_provider => /providers/:id/edit(.:format)
  edit_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_provider_product => /providers/:provider_id/products/:id/edit(.:format)
  edit_provider_product_path: function(_provider_id, _id, options) {
  return Utils.build_path(["provider_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/edit(.:format)
  edit_provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(["provider_id","product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_repository => /repositories/:id/edit(.:format)
  edit_repository_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_role => /roles/:id/edit(.:format)
  edit_role_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_subscription => /subscriptions/:id/edit(.:format)
  edit_subscription_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_sync_plan => /sync_plans/:id/edit(.:format)
  edit_sync_plan_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"sync_plans",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_system => /systems/:id/edit(.:format)
  edit_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_system_group => /system_groups/:id/edit(.:format)
  edit_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_systems_system_group => /system_groups/:id/edit_systems(.:format)
  edit_systems_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_user => /users/:id/edit(.:format)
  edit_user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// edit_user_session => /user_session/edit(.:format)
  edit_user_session_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"user_session",false]],[7,"/",false]],[6,"edit",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// email_logins_password_resets => /password_resets/email_logins(.:format)
  email_logins_password_resets_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"password_resets",false]],[7,"/",false]],[6,"email_logins",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enable_api_organization_product_repository_set => /api/organizations/:organization_id/products/:product_id/repository_sets/:id/enable(.:format)
  enable_api_organization_product_repository_set_path: function(_organization_id, _product_id, _id, options) {
  return Utils.build_path(["organization_id","product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"enable",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enable_api_product_repository_set => /api/products/:product_id/repository_sets/:id/enable(.:format)
  enable_api_product_repository_set_path: function(_product_id, _id, options) {
  return Utils.build_path(["product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repository_sets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"enable",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enable_api_repository => /api/repositories/:id/enable(.:format)
  enable_api_repository_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"enable",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enable_helptip_users => /users/enable_helptip(.:format)
  enable_helptip_users_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[6,"enable_helptip",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enable_repo => /repositories/:id/enable_repo(.:format)
  enable_repo_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"enable_repo",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// enabled_repos_api_system => /api/systems/:id/enabled_repos(.:format)
  enabled_repos_api_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"enabled_repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// env_items_distributors => /distributors/env_items(.:format)
  env_items_distributors_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"env_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// env_items_systems => /systems/env_items(.:format)
  env_items_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"env_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// environment => /environments/:id(.:format)
  environment_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// environments => /environments(.:format)
  environments_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"environments",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// environments_distributors => /distributors/environments(.:format)
  environments_distributors_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"environments",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// environments_partial_organization => /organizations/:id/environments_partial(.:format)
  environments_partial_organization_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"environments_partial",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// environments_systems => /systems/environments(.:format)
  environments_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"environments",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// errata_api_system => /api/systems/:id/errata(.:format)
  errata_api_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// errata_content_search_index => /content_search/errata(.:format)
  errata_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// errata_dashboard_index => /dashboard/errata(.:format)
  errata_dashboard_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// errata_items_content_search_index => /content_search/errata_items(.:format)
  errata_items_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"errata_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// erratum => /errata/:id(.:format)
  erratum_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// events_organization => /organizations/:id/events(.:format)
  events_organization_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// export_api_distributor => /api/distributors/:id/export(.:format)
  export_api_distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"export",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// facts_system => /systems/:id/facts(.:format)
  facts_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"facts",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// favorite_search_index => /search/favorite(.:format)
  favorite_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"search",false]],[7,"/",false]],[6,"favorite",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// filelist_package => /packages/:id/filelist(.:format)
  filelist_package_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"filelist",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// gpg_key => /gpg_keys/:id(.:format)
  gpg_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// gpg_key_content_api_repository => /api/repositories/:id/gpg_key_content(.:format)
  gpg_key_content_api_repository_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"gpg_key_content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// gpg_keys => /gpg_keys(.:format)
  gpg_keys_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"gpg_keys",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// history_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/history(.:format)
  history_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"history",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// history_api_system_group => /api/system_groups/:id/history(.:format)
  history_api_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"history",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// history_items_subscriptions => /subscriptions/history_items(.:format)
  history_items_subscriptions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"history_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// history_search_index => /search/history(.:format)
  history_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"search",false]],[7,"/",false]],[6,"history",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// history_subscriptions => /subscriptions/history(.:format)
  history_subscriptions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"history",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// i18n_dictionary => /i18n/dictionary(.:format)
  i18n_dictionary_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"i18n",false]],[7,"/",false]],[6,"dictionary",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// import_manifest_api_provider => /api/providers/:id/import_manifest(.:format)
  import_manifest_api_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"import_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// import_products_api_provider => /api/providers/:id/import_products(.:format)
  import_products_api_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"import_products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// install_system_errata => /systems/:system_id/errata/install(.:format)
  install_system_errata_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"install",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// install_system_group_errata => /system_groups/:system_group_id/errata/install(.:format)
  install_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"install",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_activation_keys => /activation_keys/items(.:format)
  items_activation_keys_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_changesets => /changesets/items(.:format)
  items_changesets_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_content_view_definitions => /content_view_definitions/items(.:format)
  items_content_view_definitions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_distributor_events => /distributors/:distributor_id/events/items(.:format)
  items_distributor_events_path: function(_distributor_id, options) {
  return Utils.build_path(["distributor_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_distributors => /distributors/items(.:format)
  items_distributors_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_gpg_keys => /gpg_keys/items(.:format)
  items_gpg_keys_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_organizations => /organizations/items(.:format)
  items_organizations_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_providers => /providers/items(.:format)
  items_providers_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_roles => /roles/items(.:format)
  items_roles_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_subscriptions => /subscriptions/items(.:format)
  items_subscriptions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_sync_plans => /sync_plans/items(.:format)
  items_sync_plans_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_plans",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_system_errata => /systems/:system_id/errata/items(.:format)
  items_system_errata_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_system_events => /systems/:system_id/events/items(.:format)
  items_system_events_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_system_group_errata => /system_groups/:system_group_id/errata/items(.:format)
  items_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_system_group_events => /system_groups/:system_group_id/events/items(.:format)
  items_system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_system_groups => /system_groups/items(.:format)
  items_system_groups_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_systems => /systems/items(.:format)
  items_systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// items_users => /users/items(.:format)
  items_users_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[6,"items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// list_changesets => /changesets/list(.:format)
  list_changesets_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[6,"list",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// login => /login(.:format)
  login_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"login",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// logout => /logout(.:format)
  logout_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"logout",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// manifest_progress_provider => /providers/:id/manifest_progress(.:format)
  manifest_progress_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"manifest_progress",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_events_distributor_events => /distributors/:distributor_id/events/more_events(.:format)
  more_events_distributor_events_path: function(_distributor_id, options) {
  return Utils.build_path(["distributor_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"more_events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_events_system_events => /systems/:system_id/events/more_events(.:format)
  more_events_system_events_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"more_events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_items_system_group_events => /system_groups/:system_group_id/events/more_items(.:format)
  more_items_system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"more_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_packages_system_system_packages => /systems/:system_id/system_packages/more_packages(.:format)
  more_packages_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[7,"/",false]],[6,"more_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_products_distributor => /distributors/:id/more_products(.:format)
  more_products_distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"more_products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// more_products_system => /systems/:id/more_products(.:format)
  more_products_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"more_products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// name_changeset => /changesets/:id/name(.:format)
  name_changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"name",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_activation_key => /activation_keys/new(.:format)
  new_activation_key_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_activation_key => /api/activation_keys/new(.:format)
  new_api_activation_key_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_content_view => /api/changesets/:changeset_id/content_views/new(.:format)
  new_api_changeset_content_view_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_distribution => /api/changesets/:changeset_id/distributions/new(.:format)
  new_api_changeset_distribution_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"distributions",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_erratum => /api/changesets/:changeset_id/errata/new(.:format)
  new_api_changeset_erratum_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_package => /api/changesets/:changeset_id/packages/new(.:format)
  new_api_changeset_package_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_product => /api/changesets/:changeset_id/products/new(.:format)
  new_api_changeset_product_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_changeset_repository => /api/changesets/:changeset_id/repositories/new(.:format)
  new_api_changeset_repository_path: function(_changeset_id, options) {
  return Utils.build_path(["changeset_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"changeset_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_consumer => /api/consumers/new(.:format)
  new_api_consumer_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"consumers",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_node => /api/nodes/new(.:format)
  new_api_node_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_node_capability => /api/nodes/:node_id/capabilities/new(.:format)
  new_api_node_capability_path: function(_node_id, options) {
  return Utils.build_path(["node_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"node_id",false]],[7,"/",false]],[6,"capabilities",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_organization => /api/organizations/new(.:format)
  new_api_organization_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/new(.:format)
  new_api_organization_content_view_definition_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_organization_environment => /api/organizations/:organization_id/environments/new(.:format)
  new_api_organization_environment_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_organization_sync_plan => /api/organizations/:organization_id/sync_plans/new(.:format)
  new_api_organization_sync_plan_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"sync_plans",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_organization_system_group_packages => /api/organizations/:organization_id/system_groups/:system_group_id/packages/new(.:format)
  new_api_organization_system_group_packages_path: function(_organization_id, _system_group_id, options) {
  return Utils.build_path(["organization_id","system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_provider => /api/providers/new(.:format)
  new_api_provider_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_repository_package => /api/repositories/:repository_id/packages/new(.:format)
  new_api_repository_package_path: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_role => /api/roles/new(.:format)
  new_api_role_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"roles",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_system_group_packages => /api/system_groups/:system_group_id/packages/new(.:format)
  new_api_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_system_packages => /api/systems/:system_id/packages/new(.:format)
  new_api_system_packages_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_api_user => /api/users/new(.:format)
  new_api_user_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_changeset => /changesets/new(.:format)
  new_changeset_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_content_search => /content_search/new(.:format)
  new_content_search_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_content_view => /content_views/new(.:format)
  new_content_view_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_views",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_content_view_definition => /content_view_definitions/new(.:format)
  new_content_view_definition_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_content_view_definition_filter => /content_view_definitions/:content_view_definition_id/filters/new(.:format)
  new_content_view_definition_filter_path: function(_content_view_definition_id, options) {
  return Utils.build_path(["content_view_definition_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/new(.:format)
  new_content_view_definition_filter_rule_path: function(_content_view_definition_id, _filter_id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_discovered_repos_provider => /providers/:id/new_discovered_repos(.:format)
  new_discovered_repos_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"new_discovered_repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_distributor => /distributors/new(.:format)
  new_distributor_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_environment => /environments/new(.:format)
  new_environment_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"environments",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_gpg_key => /gpg_keys/new(.:format)
  new_gpg_key_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_organization => /organizations/new(.:format)
  new_organization_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_organization_environment => /organizations/:organization_id/environments/new(.:format)
  new_organization_environment_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_product => /products/new(.:format)
  new_product_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_provider => /providers/new(.:format)
  new_provider_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_provider_product => /providers/:provider_id/products/new(.:format)
  new_provider_product_path: function(_provider_id, options) {
  return Utils.build_path(["provider_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/new(.:format)
  new_provider_product_repository_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(["provider_id","product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_repository => /repositories/new(.:format)
  new_repository_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"repositories",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_role => /roles/new(.:format)
  new_role_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_subscription => /subscriptions/new(.:format)
  new_subscription_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_sync_plan => /sync_plans/new(.:format)
  new_sync_plan_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_plans",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_system => /systems/new(.:format)
  new_system_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_system_group => /system_groups/new(.:format)
  new_system_group_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_user => /users/new(.:format)
  new_user_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// new_user_session => /user_session/new(.:format)
  new_user_session_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"user_session",false]],[7,"/",false]],[6,"new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices => /notices(.:format)
  notices_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"notices",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices_auto_complete_search => /notices/auto_complete_search(.:format)
  notices_auto_complete_search_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"notices",false]],[7,"/",false]],[6,"auto_complete_search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices_dashboard_index => /dashboard/notices(.:format)
  notices_dashboard_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"notices",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices_details => /notices/:id/details(.:format)
  notices_details_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"notices",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"details",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices_get_new => /notices/get_new(.:format)
  notices_get_new_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"notices",false]],[7,"/",false]],[6,"get_new",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// notices_note_count => /notices/note_count(.:format)
  notices_note_count_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"notices",false]],[7,"/",false]],[6,"note_count",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// object_changeset => /changesets/:id/object(.:format)
  object_changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"object",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// operations => /operations(.:format)
  operations_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"operations",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organization => /organizations/:id(.:format)
  organization_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organization_default_info => /organizations/:id/default_info/:informable_type(.:format)
  organization_default_info_path: function(_id, _informable_type, options) {
  return Utils.build_path(["id","informable_type"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"default_info",false]],[7,"/",false]],[3,"informable_type",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organization_environment => /organizations/:organization_id/environments/:id(.:format)
  organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organization_environment_content_view_version => /organizations/:organization_id/environments/:environment_id/content_view_versions/:id(.:format)
  organization_environment_content_view_version_path: function(_organization_id, _environment_id, _id, options) {
  return Utils.build_path(["organization_id","environment_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"content_view_versions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organization_environments => /organizations/:organization_id/environments(.:format)
  organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// organizations => /organizations(.:format)
  organizations_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"organizations",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// package => /packages/:id(.:format)
  package_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// package_group_categories_api_repository => /api/repositories/:id/package_group_categories(.:format)
  package_group_categories_api_repository_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"package_group_categories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// package_groups_api_repository => /api/repositories/:id/package_groups(.:format)
  package_groups_api_repository_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"package_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// packages_api_system => /api/systems/:id/packages(.:format)
  packages_api_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// packages_content_search_index => /content_search/packages(.:format)
  packages_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// packages_erratum => /errata/:id/packages(.:format)
  packages_erratum_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// packages_items_content_search_index => /content_search/packages_items(.:format)
  packages_items_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"packages_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// packages_system_system_packages => /systems/:system_id/system_packages/packages(.:format)
  packages_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// password_reset => /password_resets/:id(.:format)
  password_reset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"password_resets",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// password_resets => /password_resets(.:format)
  password_resets_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"password_resets",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// pools_api_activation_key => /api/activation_keys/:id/pools(.:format)
  pools_api_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// pools_api_distributor => /api/distributors/:id/pools(.:format)
  pools_api_distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// pools_api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id/pools(.:format)
  pools_api_organization_activation_key_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// pools_api_system => /api/systems/:id/pools(.:format)
  pools_api_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"pools",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// product => /products/:id(.:format)
  product_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// product_create_api_provider => /api/providers/:id/product_create(.:format)
  product_create_api_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"product_create",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products => /products(.:format)
  products_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_api_provider => /api/providers/:id/products(.:format)
  products_api_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_content_search_index => /content_search/products(.:format)
  products_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_distributor => /distributors/:id/products(.:format)
  products_distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_organization_environment => /organizations/:organization_id/environments/:id/products(.:format)
  products_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_repos_gpg_key => /gpg_keys/:id/products_repos(.:format)
  products_repos_gpg_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"gpg_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products_repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_repos_provider => /providers/:id/products_repos(.:format)
  products_repos_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products_repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_subscription => /subscriptions/:id/products(.:format)
  products_subscription_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// products_system => /systems/:id/products(.:format)
  products_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// promote_api_changeset => /api/changesets/:id/promote(.:format)
  promote_api_changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"promote",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// promote_api_content_view => /api/content_views/:id/promote(.:format)
  promote_api_content_view_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"promote",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// promotion => /promotions/:id(.:format)
  promotion_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"promotions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// promotions => /promotions(.:format)
  promotions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"promotions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// promotions_dashboard_index => /dashboard/promotions(.:format)
  promotions_dashboard_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"promotions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// provider => /providers/:id(.:format)
  provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// provider_product => /providers/:provider_id/products/:id(.:format)
  provider_product_path: function(_provider_id, _id, options) {
  return Utils.build_path(["provider_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// provider_product_repositories => /providers/:provider_id/products/:product_id/repositories(.:format)
  provider_product_repositories_path: function(_provider_id, _product_id, options) {
  return Utils.build_path(["provider_id","product_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id(.:format)
  provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(["provider_id","product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// provider_products => /providers/:provider_id/products(.:format)
  provider_products_path: function(_provider_id, options) {
  return Utils.build_path(["provider_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// providers => /providers(.:format)
  providers_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"providers",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// publish_api_content_view_definition => /api/content_view_definitions/:id/publish(.:format)
  publish_api_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"publish",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// publish_api_organization_content_view_definition => /api/organizations/:organization_id/content_view_definitions/:id/publish(.:format)
  publish_api_organization_content_view_definition_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"publish",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// publish_content_view_definition => /content_view_definitions/:id/publish(.:format)
  publish_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"publish",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// publish_setup_content_view_definition => /content_view_definitions/:id/publish_setup(.:format)
  publish_setup_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"publish_setup",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// puppet_module => /puppet_modules/:id(.:format)
  puppet_module_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"puppet_modules",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// puppet_modules_content_search_index => /content_search/puppet_modules(.:format)
  puppet_modules_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"puppet_modules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// puppet_modules_items_content_search_index => /content_search/puppet_modules_items(.:format)
  puppet_modules_items_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"puppet_modules_items",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// rails_info_properties => /rails/info/properties(.:format)
  rails_info_properties_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"rails",false]],[7,"/",false]],[6,"info",false]],[7,"/",false]],[6,"properties",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// redhat_provider_providers => /providers/redhat_provider(.:format)
  redhat_provider_providers_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[6,"redhat_provider",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_api_content_view => /api/content_views/:id/refresh(.:format)
  refresh_api_content_view_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_content_product => /products/:id/refresh_content(.:format)
  refresh_content_product_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh_content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_content_view_definition_content_view => /content_view_definitions/:content_view_definition_id/content_views/:id/refresh(.:format)
  refresh_content_view_definition_content_view_path: function(_content_view_definition_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"content_views",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_manifest_api_provider => /api/providers/:id/refresh_manifest(.:format)
  refresh_manifest_api_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_manifest_subscriptions => /subscriptions/refresh_manifest(.:format)
  refresh_manifest_subscriptions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"refresh_manifest",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_products_api_provider => /api/providers/:id/refresh_products(.:format)
  refresh_products_api_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh_products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_products_providers => /providers/refresh_products(.:format)
  refresh_products_providers_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[6,"refresh_products",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// refresh_subscriptions_api_system => /api/systems/:id/refresh_subscriptions(.:format)
  refresh_subscriptions_api_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"refresh_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// registerable_paths_organization_environments => /organizations/:organization_id/environments/registerable_paths(.:format)
  registerable_paths_organization_environments_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[6,"registerable_paths",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// releases_api_environment => /api/environments/:id/releases(.:format)
  releases_api_environment_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"releases",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// releases_api_system => /api/systems/:id/releases(.:format)
  releases_api_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"releases",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// releases_system => /systems/:id/releases(.:format)
  releases_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"releases",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_subscriptions_activation_key => /activation_keys/:id/remove_subscriptions(.:format)
  remove_subscriptions_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_system_group_packages => /system_groups/:system_group_id/packages/remove(.:format)
  remove_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"remove",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_system_groups_activation_key => /activation_keys/:id/remove_system_groups(.:format)
  remove_system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_system_groups_system => /systems/:id/remove_system_groups(.:format)
  remove_system_groups_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_system_system_packages => /systems/:system_id/system_packages/remove(.:format)
  remove_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[7,"/",false]],[6,"remove",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/remove_systems(.:format)
  remove_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_systems_api_system_group => /api/system_groups/:id/remove_systems(.:format)
  remove_systems_api_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// remove_systems_system_group => /system_groups/:id/remove_systems(.:format)
  remove_systems_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"remove_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_compare_errata_content_search_index => /content_search/repo_compare_errata(.:format)
  repo_compare_errata_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_compare_errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_compare_packages_content_search_index => /content_search/repo_compare_packages(.:format)
  repo_compare_packages_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_compare_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_compare_puppet_modules_content_search_index => /content_search/repo_compare_puppet_modules(.:format)
  repo_compare_puppet_modules_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_compare_puppet_modules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_discovery_provider => /providers/:id/repo_discovery(.:format)
  repo_discovery_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repo_discovery",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_errata_content_search_index => /content_search/repo_errata(.:format)
  repo_errata_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_packages_content_search_index => /content_search/repo_packages(.:format)
  repo_packages_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repo_puppet_modules_content_search_index => /content_search/repo_puppet_modules(.:format)
  repo_puppet_modules_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repo_puppet_modules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// report_api_environment_systems => /api/environments/:environment_id/systems/report(.:format)
  report_api_environment_systems_path: function(_environment_id, options) {
  return Utils.build_path(["environment_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[6,"report",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// report_api_organization_systems => /api/organizations/:organization_id/systems/report(.:format)
  report_api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[6,"report",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// report_api_users => /api/users/report(.:format)
  report_api_users_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[6,"report",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repos_content_search_index => /content_search/repos(.:format)
  repos_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"repos",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories => /repositories(.:format)
  repositories_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories_api_environment => /api/environments/:id/repositories(.:format)
  repositories_api_environment_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories_api_environment_product => /api/environments/:environment_id/products/:id/repositories(.:format)
  repositories_api_environment_product_path: function(_environment_id, _id, options) {
  return Utils.build_path(["environment_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"environment_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories_api_organization_environment => /api/organizations/:organization_id/environments/:id/repositories(.:format)
  repositories_api_organization_environment_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"environments",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories_api_organization_product => /api/organizations/:organization_id/products/:id/repositories(.:format)
  repositories_api_organization_product_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repositories_api_product => /api/products/:id/repositories(.:format)
  repositories_api_product_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"repositories",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// repository => /repositories/:id(.:format)
  repository_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// role => /roles/:id(.:format)
  role_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// role_create_permission => /roles/:role_id/create_permission(.:format)
  role_create_permission_path: function(_role_id, options) {
  return Utils.build_path(["role_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"create_permission",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// role_permission_destroy => /roles/:role_id/permission/:permission_id/destroy_permission(.:format)
  role_permission_destroy_path: function(_role_id, _permission_id, options) {
  return Utils.build_path(["role_id","permission_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"permission",false]],[7,"/",false]],[3,"permission_id",false]],[7,"/",false]],[6,"destroy_permission",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// role_permission_update => /roles/:role_id/permission/:permission_id/update_permission(.:format)
  role_permission_update_path: function(_role_id, _permission_id, options) {
  return Utils.build_path(["role_id","permission_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"role_id",false]],[7,"/",false]],[6,"permission",false]],[7,"/",false]],[3,"permission_id",false]],[7,"/",false]],[6,"update_permission",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// roles => /roles(.:format)
  roles_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"roles",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// roles_show_permission => /roles/show_permission(.:format)
  roles_show_permission_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[6,"show_permission",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// root => /
  root_path: function(options) {
  return Utils.build_path([], [], [7,"/",false], arguments);
  },
// schedule_provider => /providers/:id/schedule(.:format)
  schedule_provider_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"schedule",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// search_api_repository_packages => /api/repositories/:repository_id/packages/search(.:format)
  search_api_repository_packages_path: function(_repository_id, options) {
  return Utils.build_path(["repository_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"repository_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// search_index => /search(.:format)
  search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"search",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// set_org_user_session => /user_session/set_org(.:format)
  set_org_user_session_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"user_session",false]],[7,"/",false]],[6,"set_org",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// setup_default_org_user => /users/:id/setup_default_org(.:format)
  setup_default_org_user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"setup_default_org",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// short_details_erratum => /errata/:id/short_details(.:format)
  short_details_erratum_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"short_details",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// show_user_session => /user_session(.:format)
  show_user_session_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"user_session",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_changeset => /changesets/:id/status(.:format)
  status_changeset_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"changesets",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_content_view_definition => /content_view_definitions/:id/status(.:format)
  status_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_distributor_events => /distributors/:distributor_id/events/status(.:format)
  status_distributor_events_path: function(_distributor_id, options) {
  return Utils.build_path(["distributor_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"distributor_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_errata => /systems/:system_id/errata/status(.:format)
  status_system_errata_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_events => /systems/:system_id/events/status(.:format)
  status_system_events_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_group_errata => /system_groups/:system_group_id/errata/status(.:format)
  status_system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_group_events => /system_groups/:system_group_id/events/status(.:format)
  status_system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_group_packages => /system_groups/:system_group_id/packages/status(.:format)
  status_system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// status_system_system_packages => /systems/:system_id/system_packages/status(.:format)
  status_system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[7,"/",false]],[6,"status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscription => /subscriptions/:id(.:format)
  subscription_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscription_status_api_system => /api/systems/:id/subscription_status(.:format)
  subscription_status_api_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"subscription_status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscriptions => /subscriptions(.:format)
  subscriptions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscriptions_activation_keys => /activation_keys/subscriptions(.:format)
  subscriptions_activation_keys_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscriptions_dashboard_index => /dashboard/subscriptions(.:format)
  subscriptions_dashboard_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscriptions_distributor => /distributors/:id/subscriptions(.:format)
  subscriptions_distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// subscriptions_system => /systems/:id/subscriptions(.:format)
  subscriptions_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_api_node => /api/nodes/:id/sync(.:format)
  sync_api_node_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"nodes",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_complete_api_repositories => /api/repositories/sync_complete(.:format)
  sync_complete_api_repositories_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[6,"sync_complete",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_dashboard_index => /dashboard/sync(.:format)
  sync_dashboard_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_ldap_roles_api_users => /api/users/sync_ldap_roles(.:format)
  sync_ldap_roles_api_users_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"users",false]],[7,"/",false]],[6,"sync_ldap_roles",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management => /sync_management/:id(.:format)
  sync_management_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management_index => /sync_management/index(.:format)
  sync_management_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[6,"index",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management_manage => /sync_management/manage(.:format)
  sync_management_manage_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[6,"manage",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management_product_status => /sync_management/product_status(.:format)
  sync_management_product_status_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[6,"product_status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management_sync => /sync_management/sync(.:format)
  sync_management_sync_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[6,"sync",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_management_sync_status => /sync_management/sync_status(.:format)
  sync_management_sync_status_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_management",false]],[7,"/",false]],[6,"sync_status",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_plan => /sync_plans/:id(.:format)
  sync_plan_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_plans",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_plan_api_organization_product => /api/organizations/:organization_id/products/:id/sync_plan(.:format)
  sync_plan_api_organization_product_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"sync_plan",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_plan_api_product => /api/products/:id/sync_plan(.:format)
  sync_plan_api_product_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"sync_plan",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_plans => /sync_plans(.:format)
  sync_plans_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"sync_plans",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_schedules_apply => /sync_schedules/apply(.:format)
  sync_schedules_apply_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_schedules",false]],[7,"/",false]],[6,"apply",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// sync_schedules_index => /sync_schedules/index(.:format)
  sync_schedules_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"sync_schedules",false]],[7,"/",false]],[6,"index",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system => /systems/:id(.:format)
  system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_errata => /systems/:system_id/errata(.:format)
  system_errata_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_erratum => /systems/:system_id/errata/:id(.:format)
  system_erratum_path: function(_system_id, _id, options) {
  return Utils.build_path(["system_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"errata",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_event => /systems/:system_id/events/:id(.:format)
  system_event_path: function(_system_id, _id, options) {
  return Utils.build_path(["system_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_events => /systems/:system_id/events(.:format)
  system_events_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_group => /system_groups/:id(.:format)
  system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_group_errata => /system_groups/:system_group_id/errata(.:format)
  system_group_errata_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_group_event => /system_groups/:system_group_id/events/:id(.:format)
  system_group_event_path: function(_system_group_id, _id, options) {
  return Utils.build_path(["system_group_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"events",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_group_events => /system_groups/:system_group_id/events(.:format)
  system_group_events_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"events",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_group_packages => /system_groups/:system_group_id/packages(.:format)
  system_group_packages_path: function(_system_group_id, options) {
  return Utils.build_path(["system_group_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"system_group_id",false]],[7,"/",false]],[6,"packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups => /system_groups(.:format)
  system_groups_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups_activation_key => /activation_keys/:id/system_groups(.:format)
  system_groups_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups_api_organization_activation_key => /api/organizations/:organization_id/activation_keys/:id/system_groups(.:format)
  system_groups_api_organization_activation_key_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups_api_system => /api/systems/:id/system_groups(.:format)
  system_groups_api_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups_dashboard_index => /dashboard/system_groups(.:format)
  system_groups_dashboard_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_groups_system => /systems/:id/system_groups(.:format)
  system_groups_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"system_groups",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// system_system_packages => /systems/:system_id/system_packages(.:format)
  system_system_packages_path: function(_system_id, options) {
  return Utils.build_path(["system_id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"system_id",false]],[7,"/",false]],[6,"system_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems => /systems(.:format)
  systems_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems_activation_key => /activation_keys/:id/systems(.:format)
  systems_activation_key_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"activation_keys",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/systems(.:format)
  systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems_api_system_group => /api/system_groups/:id/systems(.:format)
  systems_api_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems_dashboard_index => /dashboard/systems(.:format)
  systems_dashboard_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"dashboard",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// systems_system_group => /system_groups/:id/systems(.:format)
  systems_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// tasks_api_organization_systems => /api/organizations/:organization_id/systems/tasks(.:format)
  tasks_api_organization_systems_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"systems",false]],[7,"/",false]],[6,"tasks",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_component_views_content_view_definition => /content_view_definitions/:id/update_component_views(.:format)
  update_component_views_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_component_views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_content_content_view_definition => /content_view_definitions/:id/update_content(.:format)
  update_content_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_content",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_environment_user => /users/:id/update_environment(.:format)
  update_environment_user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_environment",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_locale_user => /users/:id/update_locale(.:format)
  update_locale_user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_locale",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_parameter_content_view_definition_filter_rule => /content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id/update_parameter(.:format)
  update_parameter_content_view_definition_filter_rule_path: function(_content_view_definition_id, _filter_id, _id, options) {
  return Utils.build_path(["content_view_definition_id","filter_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"content_view_definition_id",false]],[7,"/",false]],[6,"filters",false]],[7,"/",false]],[3,"filter_id",false]],[7,"/",false]],[6,"rules",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_parameter",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_preference_user => /users/:id/update_preference(.:format)
  update_preference_user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_preference",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_repo_gpg_key_provider_product_repository => /providers/:provider_id/products/:product_id/repositories/:id/update_gpg_key(.:format)
  update_repo_gpg_key_provider_product_repository_path: function(_provider_id, _product_id, _id, options) {
  return Utils.build_path(["provider_id","product_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"providers",false]],[7,"/",false]],[3,"provider_id",false]],[7,"/",false]],[6,"products",false]],[7,"/",false]],[3,"product_id",false]],[7,"/",false]],[6,"repositories",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_gpg_key",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_roles_user => /users/:id/update_roles(.:format)
  update_roles_user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_roles",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_subscriptions_distributor => /distributors/:id/update_subscriptions(.:format)
  update_subscriptions_distributor_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"distributors",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_subscriptions_system => /systems/:id/update_subscriptions(.:format)
  update_subscriptions_system_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"systems",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_subscriptions",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_systems_api_organization_system_group => /api/organizations/:organization_id/system_groups/:id/update_systems(.:format)
  update_systems_api_organization_system_group_path: function(_organization_id, _id, options) {
  return Utils.build_path(["organization_id","id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"api",false]],[7,"/",false]],[6,"organizations",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// update_systems_system_group => /system_groups/:id/update_systems(.:format)
  update_systems_system_group_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"update_systems",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// upload_subscriptions => /subscriptions/upload(.:format)
  upload_subscriptions_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"subscriptions",false]],[7,"/",false]],[6,"upload",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// user => /users/:id(.:format)
  user_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"users",false]],[7,"/",false]],[3,"id",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// user_session => /user_session(.:format)
  user_session_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"user_session",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// user_session_logout => /user_session/logout(.:format)
  user_session_logout_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"user_session",false]],[7,"/",false]],[6,"logout",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// users => /users(.:format)
  users_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[7,"/",false],[6,"users",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// validate_name_library_packages => /packages/validate_name_library(.:format)
  validate_name_library_packages_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"packages",false]],[7,"/",false]],[6,"validate_name_library",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// validate_name_system_groups => /system_groups/validate_name(.:format)
  validate_name_system_groups_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"system_groups",false]],[7,"/",false]],[6,"validate_name",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// verbs_and_scopes => /roles/:organization_id/resource_type/verbs_and_scopes(.:format)
  verbs_and_scopes_path: function(_organization_id, options) {
  return Utils.build_path(["organization_id"], ["format"], [2,[2,[2,[2,[2,[2,[2,[2,[7,"/",false],[6,"roles",false]],[7,"/",false]],[3,"organization_id",false]],[7,"/",false]],[6,"resource_type",false]],[7,"/",false]],[6,"verbs_and_scopes",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// view_compare_errata_content_search_index => /content_search/view_compare_errata(.:format)
  view_compare_errata_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"view_compare_errata",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// view_compare_packages_content_search_index => /content_search/view_compare_packages(.:format)
  view_compare_packages_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"view_compare_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// view_compare_puppet_modules_content_search_index => /content_search/view_compare_puppet_modules(.:format)
  view_compare_puppet_modules_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"view_compare_puppet_modules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// view_packages_content_search_index => /content_search/view_packages(.:format)
  view_packages_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"view_packages",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// view_puppet_modules_content_search_index => /content_search/view_puppet_modules(.:format)
  view_puppet_modules_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"view_puppet_modules",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// views_content_search_index => /content_search/views(.:format)
  views_content_search_index_path: function(options) {
  return Utils.build_path([], ["format"], [2,[2,[2,[2,[7,"/",false],[6,"content_search",false]],[7,"/",false]],[6,"views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  },
// views_content_view_definition => /content_view_definitions/:id/views(.:format)
  views_content_view_definition_path: function(_id, options) {
  return Utils.build_path(["id"], ["format"], [2,[2,[2,[2,[2,[2,[7,"/",false],[6,"content_view_definitions",false]],[7,"/",false]],[3,"id",false]],[7,"/",false]],[6,"views",false]],[1,[2,[8,".",false],[3,"format",false]],false]], arguments);
  }}
;

  window.KT.routes.options = defaults;

}).call(this);
