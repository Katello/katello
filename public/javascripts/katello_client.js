/**
 Copyright 2011 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

var client_common = {
    create: function(data, url, on_success, on_error) {
      $.ajax({
        type: "POST",
        url: url,
        data: data,
        cache: false,
        success: on_success,
        error: on_error
      });
    },
    destroy: function(url, on_success, on_error) {
      $.ajax({
        type: "DELETE",
        url: url,
        cache: false,
        success: on_success,
        error: on_error
      });
    }
};

var role = {

    create: function(name, on_success, on_error) {
      $.ajax({
        type: "POST",
        url: "/roles/",
        data: { "role":{"name":name}},
        cache: false,
        success: on_success,
        error: on_error
      });
    },

    remove_permission: function(role_id, perm_id, on_success, on_error) {
      $.ajax({
        type: "PUT",
        url: "/roles/" + role_id,
        data: { "role":{
								"permissions_attributes": {"0":
											{"id": perm_id,
											"_destroy":1} }}},
        cache: false,
        success: on_success,
        error: on_error
      });
	},

    get_verbs_and_scopes: function(resource_type, on_success, on_error) {
      $.ajax({
        type: "GET",
        url: "/roles/resource_type/" + resource_type  + "/verbs_and_scopes",
        data: {},
				dataType: 'json',
        cache: false,
        success: on_success,
        error: on_error
      });
	},

    create_or_update_permission: function(method, url, data, on_success, on_error) {
      $.ajax({
        type: method,
        url: url,
        data: data,
        cache: false,
        success: on_success,
        error: on_error,
				dataType: "html"
      });
	},
    get_new: function(role_id, url, on_success) {
      $.ajax({
        type: "GET",
        url: url,
        data: {"role_id":role_id},
        cache: false,
        success: on_success,
        dataType: "html"
      });
    },
    get_existing: function(role_id, perm_id, url, on_success) {
      $.ajax({
        type: "GET",
        url: url,
        data: {"role_id":role_id, "perm_id":perm_id},
        cache: false,
        success: on_success,
        dataType: "html"
      });
    }

};

var search = {
    create_favorite: function(favorite, url, on_success, on_error) {
      $.ajax({
        type: "POST",
        url: url,
        data: {"favorite": favorite},
        cache: false,
        success: on_success,
        error: on_error
      });
    },
}

var user = {

    create: function(username, password, on_success, on_error) {
      $.ajax({
        type: "POST",
        url: "/users/",
        data: { "user":{"username":username, "password":password}},
        cache: false,
        success: on_success,
        error: on_error
      });
    },

   update_user: function(username, options, on_success, on_error) {
      $.ajax({
        type: "PUT",
        url: "/users/" + username,
        data: options,
        cache: false,
        success: on_success,
        error: on_error
      });
   },
    update_password: function(username, password, on_success, on_error) {
      $.ajax({
        type: "PUT",
        url: "/users/" + username,
        data: { "user":{"password":password}},
        cache: false,
        success: on_success,
        error: on_error
      });
    },
    clear_helptips: function(username, on_success, on_error) {
      $.ajax({
        type: "POST",
        url: "/users/" + username + "/clear_helptips",
        data: {},
        cache: false,
        success: on_success,
        error: on_error
      });
    }

};


var environment = {
    create: function(data, url, on_success, on_error) {
      $.ajax({
        type: "POST",
        url: url,
        data: data,
        cache: false,
        success: on_success,
        error: on_error
      });
    },
    destroy: function(url, on_success, on_error) {
      $.ajax({
        type: "DELETE",
        url: url,
        cache: false,
        success: on_success,
        error: on_error
      });

    }
};


var change_set = {
    update: function(changeset_id, items, timestamp, on_success, on_error) {
      var data = [];
      $.each(items, function(index, value) {
          var item = {};
          item["type"] = value[0];
          item["item_id"] = value[1];
          item["item_name"] = value[2];
          item["adding"] = value[3];
          if (value[4]) {
              item["product_id"] = value[4];
          }
          data.push(item);
        });
      $.ajax({
        contentType:"application/json",
        type: "PUT",
        url: "/changesets/" + changeset_id,
        data: JSON.stringify({data:data, timestamp:timestamp}),
        cache: false,
        success: on_success,
        error: on_error
      });
    },

    update_name: function(changeset_id, name, on_success, on_error) {
        $.ajax({
          type: "PUT",
          url: "/changesets/" + changeset_id + "/changesets/name",
          data: { name: name },
          cache: false,
          success: on_success,
          error: on_error
        });
    },

    get: function(changeset_id, on_success, on_error, data_type) {
      $.ajax({
        type: "GET",
        dataType: data_type === undefined ? "html" : data_type,
        url: "/changesetss/" + changeset_id,
        cache: false,
        success: on_success,
        error: on_error
      });
    }
};

var notice = {
    details: function(notice_id, on_success, on_error, data_type) {
      $.ajax({
        type: "GET",
        dataType: data_type === undefined ? "html" : data_type,
        url: "/notices/" + notice_id + "/details",
        cache: false,
        success: on_success,
        error: on_error
      });
    }
};
