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

KT.panel.list.registerPage('changesets', { 'extra_params' : ['env_id'] });


$(document).ready(function() {

	$.bbq.pushState({env_id : env_select.get_selected_env()});

    //Set the callback on the environment selector
    env_select.click_callback = function(env_id) {
        $.bbq.pushState({env_id : env_id});
    };
    
});


var changeset_page = {
    signal_rename: function(changeset_id, name) {
        KT.panel.list.refresh('changeset_' + changeset_id, $('#changeset').attr("data-ajax_url"));
    }
};
