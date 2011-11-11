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

KT.panel.list.registerPage('users', { create : 'new_user' });

$(document).ready(function() {

    KT.user_page.registerEdits();

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
        org_selector.change(function(event) {
        var refill = $('#env_box');
        var selected_org_id = org_selector.val();
        var url = KT.common.rootURL() + 'organizations/' + selected_org_id +  '/environments_partial';
        $.ajax({
            type: "GET",
            url: url,
            success: function(data) {
                  refill.html(data);
           }
        });
   });

        $('#password_field').simplePassMeter({
            'container': '#password_meter',
            'offset': 10,
            'showOnFocus':false,
            'requirements': {
                'noUsernameMatch': {
                    value: "#match",
                    message: i18n.usernameMatch,
                    callback: function(password, value) {
                        return password.indexOf($("#username").text().trim()) === -1;
                    }
                }
            },
            'defaultText':i18n.meterText,
            'ratings':ratings});

        //from user.js
        $('#helptips_enabled').bind('change', KT.user_page.checkboxChanged);
    })

});

