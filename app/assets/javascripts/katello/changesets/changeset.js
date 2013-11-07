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

KT.panel.list.registerPage('changesets',
                            { 'extra_params' :
                                [ { hash_id     : 'env_id',
                                    init_func     : function(){
                                        var state = $.bbq.getState('env_id');

                                        if( state ){
                                            env_select.set_selected(state);
                                        } else {
                                            $.bbq.pushState({ env_id : env_select.get_selected_env() });
                                        }
                                    }
                                  }
                                ]
                            });


$(document).ready(function() {

    //Set the callback on the environment selector
    env_select.click_callback = function(env_id) {
        $.bbq.pushState({env_id : env_id});
        $('#search_form').trigger('submit');
    };

});


var changeset_page = {
    signal_rename: function(changeset_id, name) {
        KT.panel.list.refresh('changeset_' + changeset_id, $('input[id^=changeset]').attr("data-ajax_url"));
    }
};
