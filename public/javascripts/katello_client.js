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


/*
 * THIS FILE IS DEPRECATED, DO NOT MAKE ADDITIONS
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
    }
}


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
