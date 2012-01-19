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
KT.password = function() {
    var resetPassword = false;
    var verifyPassword = function() {
        var match_button = $('.verify_password');
        var a = $('#password_field').val();
        var b = $('#confirm_field').val();

        if(a != b){
            $("#password_conflict").text(i18n.password_match);
            $(match_button).addClass("disabled");
            $('#save_password').die('click');
            $('#save_user').die('click');
            return false;
        }
        else {
            $("#password_conflict").text("");
            $(match_button).removeClass("disabled");

            //reset the edit user button
            $('#save_password').die('click');
            $('#save_password').live('click',changePassword);
            return true;
        }
    },
    changePassword = function() {
        var button = $(this);
        var url = button.attr("data-url");
        var password = $('#password_field').val();
        button.addClass("disabled");
        $.ajax({
            type: "PUT",
            url: url,
            data: { "user":{"password":password}},
            cache: false,
            success: function(data, textStatus, xhr) {
                button.removeClass("disabled");
                if (resetPassword && xhr.status < 400) {
                    // this is a password reset, so we'll redirect the user to the login page
                    window.location.replace(KT.routes.root_path());
                }
            },
            error: function(e) {
                button.removeClass('disabled');
            }
        });
    },
    registerEvents = function() {
        $('#password_field').live('keyup.katello', verifyPassword);
        $('#confirm_field').live('keyup.katello',verifyPassword);
        $('#save_password').live('click',changePassword);
    },
    resettingPassword = function(resetValue) {
        resetPassword = resetValue;
    };

    return {
        verifyPassword: verifyPassword,
        changePassword: changePassword,
        registerEvents: registerEvents,
        resettingPassword: resettingPassword
    }
}();

$(document).ready(function() {
   KT.password.registerEvents();
   KT.password.resettingPassword(true);

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

});
