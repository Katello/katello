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

KT.panel.list.registerPage(
    'users',
    { create            : 'new_user',
    validation          : KT.user_page.verifyPassword,
    extra_create_data   : function(){
        var env_id = $(".path_link.active").attr('data-env_id');
        return { "user" : { "env_id" : env_id }};
    }
});

$(document).ready(function() {

    KT.user_page.registerEdits();
    env_select.ajax_params ={};
    env_select.original_env_id = undefined;
    env_select.env_changed_callback = function(env_id) {
        if(env_select.original_env_id === env_id) {
            $('#update_user').addClass('disabled');
        }else{
            $('#update_user').removeClass('disabled');
        }
    };

    ratings =
        [{'minScore': 0,
            'className': 'meterFail',
            'text': i18n.very_weak
        },
            {'minScore': 25,
                'className': 'meterWarn',
                'text': i18n.weak
            },
            {'minScore': 50,
                'className': 'meterGood',
                'text': i18n.good
            },
            {'minScore': 75,
                'className': 'meterExcel',
                'text': i18n.strong
            }];

    KT.panel.set_expand_cb(function() {
        //taken out of user_edit, so it can be resused on accounts
        $(".multiselect").multiselect({"dividerLocation":0.5, "sortable":false});

        var org_selector = $('#org_id_org_id');
        org_selector.live('change', function(event) {
            var refill = $('#env_box');
            var spinner = $('#org_spinner');
            var selected_org_id = org_selector.val();

            if(!selected_org_id) {
                refill.html(i18n.noDefaultEnv);
                env_select.env_changed_callback('');
            } else {

                var url = KT.routes.environments_partial_organization_path(selected_org_id),
                    params = {};

                if (env_select.ajax_params !== undefined) {
                    params = env_select.ajax_params;
                }
                spinner.show();
                refill.html('');
                $.ajax({
                    type: "GET",
                    url: url,
                    data: params,
                    success: function(data) {
                        refill.html(data);
                        // On successful update, update the original env id and disable save button
                        env_select.init();
                        env_select.env_changed_callback(env_select.get_selected_env());
                        spinner.hide();
                    }
                });
            }
        }).live('keypress', function(e) {
            var keyCode = e.keyCode || e.which;
            if (keyCode === 38 || keyCode === 40) { // if up or down key is pressed
               $(this).change(); // trigger the change event
            }
        });

        var locale_selector = $('#locale_locale');
        locale_selector.change(function(event) {
            $('#locale_form').trigger('submit');
        });

        //from user.js
        $('#helptips_enabled').bind('change', KT.user_page.checkboxChanged);
        $('#experimental_ui').bind('change', KT.user_page.checkboxChanged);
    });

});

