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


$(document).ready(function() {

    //Set the callback on the environment selector
    env_select.click_callback = changeset_page.environment_select;

    //bind to the #search_form to make it useful
    $('#search_form').submit(function(){
        changeset_page.environment_search($('#path-controller .active').attr('data-env_id'));
        return false;
    });

    $('.queries').hide();

});


var changeset_page = {
    environment_select:  function(env_id) {
        panel.closePanel($('#panel'));
        list.complete_refresh('/changesets/items?env_id=' + env_id);
    },
    signal_rename: function(changeset_id) {
        list.refresh(changeset_id, $('#changeset').attr("data-ajax_url"));
    },
    environment_search:  function(env_id) {
        panel.closePanel($('#panel'));
        list.complete_refresh('/changesets/items?env_id=' + env_id + '&search=' + $('#search').val());
    }
};