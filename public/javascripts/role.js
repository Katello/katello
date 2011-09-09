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

    $('#save_role_button').live('click',roles_page.create_new_role);

});

var roles_page = (function($) {
    var create_new_role = function (){
        var button = $(this);
        if (button.hasClass("disabled")) {return false;}
        button.addClass("disabled");

        $.ajax({
            type: "POST",
            url: button.attr('data-url'),
            data: { "role":{"name":$('#role_name_field').val()}},
            cache: false,
            success: function(data) {
                  list.add(data);
                  panel.closePanel($('#panel'));
                },
            error: function(){button.removeClass("disabled");}
        });
    };


    return {
        create_new_role : create_new_role,
    }
})(jQuery);