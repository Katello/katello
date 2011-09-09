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
   
    $('#password_field').live('keyup.katello', user_page.verifyPassword);
    $('#confirm_field').live('keyup.katello',user_page.verifyPassword);
    $('#save_user').live('click',user_page.createNewUser);
    $('#clear_helptips').live('click',user_page.clearHelptips);
    $('#save_password').live('click',user_page.changePassword);
    $('#update_roles').live('submit', user_page.updateRoles);
});



var user_page = function() {
    var clearHelptips = function() {
        var chkbox = $(this);
        var url = chkbox.attr("data-url");
        chkbox.addClass("disabled");
        $.ajax({
            type: "POST",
            url: url,
            data: {},
            cache: false,
            success: function(data) {
                chkbox.button('destroy');
                chkbox.text(data);
            },
            error: function(data) {
                chkbox.removeClass("disabled");
                chkbox.button('option',  'label', data);
            }
        });
    },
    checkboxChanged = function() {
        var checkbox = $(this);
        var name = $(this).attr("name");
        var options = {};
        if (checkbox.attr("checked") !== undefined) {
            options[name] = "1";
        } else {
            options[name] = "0";
        }
        var url = checkbox.attr("data-url");
        $.ajax({
            type: "PUT",
            url: url,
            data: options,
            cache: false
        });        
        return false;
    },
    verifyPassword = function() {
        var match_button = $('.verify_password');
        var a = $('#password_field').val();
        var b = $('#confirm_field').val();

        if(a!= b){
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
            //reset the new user button
            $('#save_user').die('click');
            $('#save_user').live('click',createNewUser);
            return true;
        }

    },
    createNewUser = function() {
        var button = $(this);
        if (button.hasClass("disabled")) {
            return false;
        }

        if (verifyPassword()) {
            button.addClass('disabled');
            var username = $('#username_field').val();
            var password = $('#password_field').val();
            $.ajax({
                type: "POST",
                url: button.attr('data-url'),
                data: { "user":{"username":username, "password":password}},
                cache: false,
                success: function(data) {
                    button.removeClass('disabled');
                    list.add(data);
                    panel.closePanel($('#panel'));
                  },
                error: function(){button.removeClass('disabled');}
            });

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
            success: function() {
                button.removeClass("disabled");
            },
            error: function(e) {
                button.removeClass('disabled');
            }
        });
    },
    updateRoles = function(e) {
        e.preventDefault();
        var button = $(this).find('input[type|="submit"]');
        button.attr("disabled","disabled");
        $(this).ajaxSubmit({
            success: function(data) {
                button.removeAttr('disabled');
            },
            error: function(e) {
                button.removeAttr('disabled');
            }
        });
    };

    return {
        createNewUser: createNewUser,
        verifyPassword: verifyPassword,
        changePassword: changePassword,
        checkboxChanged: checkboxChanged,
        clearHelptips: clearHelptips,
        updateRoles: updateRoles
    }
}();
