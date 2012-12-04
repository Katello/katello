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
    var getData = function(fieldNames) {
        var data = {};
        $.each(fieldNames, function(i, fieldName){
            var value = $('#'+fieldName).val();
            if (value != null)
                data[fieldName] = value;
        });
        return data;
    },
    updateSubnet = function() {
        var button = $(this),
            url = button.attr("data-url");

        if (button.hasClass("disabled"))
            return;

        $.ajax({
            type: "PUT",
            url: url,
            data: { "subnet": getData([
                "domain_ids",
                "dhcp_id",
                "tftp_id",
                "dns_id"])
            },
            cache: false
        });
    },
    register = function() {
        $('#domain_ids').chosen();

        // Workaround for a bug in chosen
        // When a chosen select receives focus() invoked from js code
        // it ends up in an infinite loop of displaying and hiding the options.
        // 2pane gives focus to a first enabled visible input on the panel.
        // Therefore we hide the inner input at the beginning and show it
        // after first click.
        $("#domain_ids_chzn :input").hide();
        $("#domain_ids_chzn").click(function() {
            $("#domain_ids_chzn :input").show();
        });

        $('#dhcp_id').chosen();
        $('#tftp_id').chosen();
        $('#dns_id').chosen();

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
