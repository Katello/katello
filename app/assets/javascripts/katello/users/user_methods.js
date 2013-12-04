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
                $('#clear_helptips').die('click',clearHelptips);
            },
            error: function(data) {
                chkbox.removeClass("disabled");
                $('#clear_helptips').live('click',clearHelptips);
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
        $('#clear_helptips').live('click',clearHelptips);
        $('#update_user').live('click',updateUser);
        $('#update_roles').live('submit', updateRoles);
    };

    return {
        updateUser: updateUser,
        checkboxChanged: checkboxChanged,
        clearHelptips: clearHelptips,
        updateRoles: updateRoles,
        registerEdits: registerEdits
    };
})();
