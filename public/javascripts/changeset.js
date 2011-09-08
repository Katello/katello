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


//must be outside of document ready
panel.control_bbq = false;

$(document).ready(function() {

    //Set the callback on the environment selector
    env_select.click_callback = function(env_id) {
        $.bbq.pushState({env_id:env_id});
    };

    //bind to the #search_form to make it useful
    $('#search_form').submit(function(){
        changeset_page.environment_search($('#path-controller .active').attr('data-env_id'));
        return false;
    });

    $('.queries').hide();


    $(window).bind( 'hashchange', changeset_page.hash_change);

    //the hash has an environment, so that's our default
    var selected = $.bbq.getState("env_id");
    if(selected !== undefined) {
        env_select.set_selected(selected);
    }
    else { //it doesn't so use whatever was rendered
        changeset_page.current_env = env_select.get_selected_env();
    }
    $(window).trigger('hashchange');


});


var changeset_page = {
    current_env: undefined,
    environment_select:  function(env_id, cb) {
        panel.closePanel($('#panel'));
        list.complete_refresh('/changesets/items?env_id=' + env_id, cb);
    },
    signal_rename: function(changeset_id, name) {
        list.refresh('changeset_' + changeset_id, $('#changeset').attr("data-ajax_url"));
    },
    environment_search:  function(env_id) {
        panel.closePanel($('#panel'));
        list.complete_refresh('/changesets/items?env_id=' + env_id + '&search=' + $('#search').val());
    },
    hash_change: function() {
        var env_id = $.bbq.getState("env_id");
        if (env_id === undefined) {
            env_id = changeset_page.current_env;
        }
        
        if (changeset_page.current_env != env_id) {
            changeset_page.current_env = env_id;
            changeset_page.environment_select(env_id, function() {
                panel.hash_change();
            })
        }
        else {
            panel.hash_change();
        }

    }

};