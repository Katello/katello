/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

update_content_views = function(env_id) {
    // update content view options
    $.ajax({  url: KT.routes.content_views_environment_path(env_id),
              type: "GET",
              success: (function(data) {
                  options = {'': ''};
                  $.each(data, function(key, value) {
                       options[value.id] = value.name;
                  });
                  $("#distributor_content_view").data("options", options);
              })
            });
}

