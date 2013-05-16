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

KT.panel.list.registerPage('domains', {create: 'new_domain'});



KT.domain_page = (function() {
    var updateDomain = function() {
        var button = $(this),
            url = button.attr("data-url"),
            dnsId = $('#dns_id').val(),
            domain_data = {};

        if (button.hasClass("disabled")) {
            return;
        }

        if (dnsId !== null) {
            domain_data["dns_id"] = dnsId;
        }

        $.ajax({
            type: "PUT",
            url: url,
            data: { "domain": domain_data },
            cache: false
        });
    },
    register = function() {
        $('#dns_id').chosen({allow_single_deselect:true});
        $('#update_domain').live('click', updateDomain);
    };

    return {
        register: register
    };
}());


$(document).ready(function() {

    KT.panel.set_expand_cb(function(){
        KT.domain_page.register();
    });


});
