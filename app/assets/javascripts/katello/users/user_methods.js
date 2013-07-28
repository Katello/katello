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


KT.user_page = (function() {
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
            },
            complete: function(e) {
                notices.checkNotices();
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
            cache: false,
            complete: function(e) {
                notices.checkNotices();
            }
        });
        return false;
    },
    verifyPassword = function() {
        var match_button = $('.verify_password');
        var a = $('#password_field').val();
        var b = $('#confirm_field').val();

        if(a !== b){
            $("#password_conflict").text(i18n.password_match);
            $(match_button).addClass("disabled");
            $('#save_password').die('click');
            $('#save_user').addClass('disabled');
            return false;
        }
        else {
            //this is to say, if there is an environment available from which to select, then
            //allow the creation of a user
            if ($('#no_env_box').length === 0)
            {
                $("#password_conflict").text("");
                $(match_button).removeClass("disabled");

                //reset the edit user button
                $('#save_password').die('click');
                $('#save_password').live('click',changePassword);
                //reset the new user button
                if (a === "" && b === "") {
                    $('#save_user').addClass('disabled');
                    $('#save_password').addClass('disabled');
                } else {
                    $('#save_user').removeClass('disabled');
                }
                return true;
            }
            else {
                return false;
            }
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
            var email = $('#email_field').val();
            var env_id = $(".path_link.active").attr('data-env_id');
            $.ajax({
                type: "POST",
                url: button.attr('data-url'),
                data: { "user":{"username":username, "password":password, "email":email, "env_id":env_id }},
                cache: false,
                success: function(data) {
                    button.removeClass('disabled');
                    KT.panel.list.add(data);
                    KT.panel.closePanel($('#panel'));
                  },
                error: function(){button.removeClass('disabled');}
            });

        }
    },
    changePassword = function() {
        var button = $(this);
        if(button.hasClass("disabled")) {
            return;
        }
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
            },
            complete: function(e) {
                notices.checkNotices();
            }
        });
    },
    updateUser = function() {
        var button = $(this),
            url = button.attr("data-url"),
            env_id = $(".path_link.active").attr('data-env_id'),
            org_id = $('#org_id_org_id').val();

        button.addClass("disabled");
        $.ajax({
            type: "PUT",
            url: url,
            data: {"org_id":org_id, "env_id":{"env_id":env_id}},
            cache: false,
            success: function(data) {
                $('#env_name').html(data.env);
                $('#org_name').html(data.org);
                env_id = data.env_id;
                env_select.original_env_id = env_id;
                env_select.env_changed_callback(env_id);
            },
            error: function(e) {
                button.removeClass('disabled');  // Guarantee button is enabled (should be already, though)
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
    },
    registerEdits = function() {
        $('#password_field').live('keyup.katello', verifyPassword);
        $('#confirm_field').live('keyup.katello',verifyPassword);
        $('#clear_helptips').live('click',clearHelptips);
        $('#save_password').live('click',changePassword);
        $('#update_user').live('click',updateUser);
        $('#update_roles').live('submit', updateRoles);
    };

    return {
        createNewUser: createNewUser,
        verifyPassword: verifyPassword,
        updateUser: updateUser,
        changePassword: changePassword,
        checkboxChanged: checkboxChanged,
        clearHelptips: clearHelptips,
        updateRoles: updateRoles,
        registerEdits: registerEdits
    };
})();
