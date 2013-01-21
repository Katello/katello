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

KT.panel.list.registerPage('subnets', {create: 'new_subnet'});

KT.subnet_page = (function() {
    var updateSubnet = function() {
        var button = $(this),
            url = button.attr("data-url");

        if (button.hasClass("disabled"))
            return;

        $.ajax({
            type: "PUT",
            url: url,
            data: { "subnet": KT.getData([
                "domain_ids",
                "dhcp_id",
                "tftp_id",
                "dns_id"])
            },
            cache: false
        });
    },
    register = function() {
        $('#domain_ids').delayed_chosen();

        $('#dhcp_id').chosen({allow_single_deselect:true});
        $('#tftp_id').chosen({allow_single_deselect:true});
        $('#dns_id').chosen({allow_single_deselect:true});

        $('#update_subnet').live('click', updateSubnet);
    };

    return {
        register: register
    }
}());



$(document).ready(function() {

    KT.panel.set_expand_cb(function(){
        KT.subnet_page.register();
    });


});
