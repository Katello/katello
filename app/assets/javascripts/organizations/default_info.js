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

var KT = (KT === undefined) ? {} : KT;

KT.default_info = (function() {

    var task_status_updater;

    var start_updater = function(task_uuid) {
        allow_default_info_manipulation(false);
        $("#apply_default_info_button").addClass("processing");
        var timeout = 6000;

        if (task_status_updater !== undefined) {
            task_status_updater.stop();
        }

        task_status_updater = $.PeriodicalUpdater(
            KT.routes.api_task_path(task_uuid),
            {
                method    : 'get',
                type      : 'json',
                cache     : false,
                global    : false,
                minTimeout: timeout,
                maxTimeout: timeout
            },
            updateStatus
        );
    };

    var async_panel_refresh = function (){
        if ($("#apply_default_info_button").length > 0) {
            if (task_status_updater !== undefined) {
                task_status_updater.stop();
            }
            var state = $("#apply_default_info_button").data("taskstate");
            if (state === "waiting" || state === "running") {
                start_updater($("#apply_default_info_button").data("taskuuid"));
            }
        }
    };

    var updateStatus = function(data, success, xhr, handle) {
        if (data !== "") { // "" means nothing has changed since the last poll
            var state = data['state'];
            if (state !== "waiting" && state !== "running") {
                $("#apply_default_info_button").removeClass("processing");
                allow_default_info_manipulation(true);
                task_status_updater.stop();
                if (data['result'].length > 0) {
                    notices.displayNotice("success", window.JSON.stringify({ "notices": [i18n.default_info_apply_success] }));
                }
            }
        }
    };

    var check_for_apply_button_enable = function() {
        if ($("#default_info_table tr").length > 1) {
            $("#apply_default_info_button").removeAttr("disabled");
        } else {
            $("#apply_default_info_button").attr("disabled", "true");
        }
    };

    var allow_default_info_manipulation = function(allow) {
        if (allow === true) {
            $("#new_default_info_keyname").removeAttr("disabled");
            check_for_empty($("#new_default_info_keyname"));
            $(".remove_default_info_button").removeAttr("disabled");
            check_for_apply_button_enable();
        } else {
            $("#apply_default_info_button").attr("disabled", "true");
            $("#new_default_info_keyname").attr("disabled", "true");
            $("#add_default_info_button").attr("disabled", "true");
            $(".remove_default_info_button").attr("disabled", "true");
        }
    };

    var check_for_empty = function($textfield) {
        if ($textfield.val().length > 0 ) {
            $('#add_default_info_button').removeAttr("disabled");
        } else {
            $('#add_default_info_button').attr("disabled", "true");
        }
    };

    var apply_default_info = function($button) {
        $.ajax({
            url    : $button.data('url'),
            type   : $button.data('method'),
            success: function(data) {
                start_updater(data['task']['uuid']);
            },
            error  : function(data) {
                // task didn't start correctly
                notices.displayNotice("error", window.JSON.stringify({ "notices": [i18n.default_info_apply_error] }));
            }
        });
    };

    var add_default_info = function($button) {
        var keyname = $("#new_default_info_keyname").val();

        $.ajax({
            url     : $button.data("url"),
            type    : $button.data("method"),
            dataType: 'json',
            data    : { "keyname" : keyname },
            success : function(data) {
                add_default_info_row(data);
                notices.displayNotice("success", window.JSON.stringify({ "notices": [i18n.default_info_create_success] }));
            },
            error   : function(data) {
                notices.displayNotice("error", window.JSON.stringify({ "notices": [$.parseJSON(data.responseText)["displayMessage"]] }));
            }
        });
    };

    var remove_default_info = function($button) {
        $.ajax({
            url    : $button.data("url"),
            type   : $button.data("method"),
            success: function(data) {
                remove_default_info_row($button.data("id"));
                notices.displayNotice("success", window.JSON.stringify({ "notices": [i18n.default_info_delete_success] }));
            }
        });
    };

    var remove_default_info_row = function(data_id) {
        $("tr[data-id='" + data_id + "']").remove();
        check_for_apply_button_enable();
    };

    var add_default_info_row = function(data) {
        var keyname = data["keyname"];
        var esc_keyname = escape(data["keyname"]);
        var _keyname = data["keyname"].replace(" ", "_");

        var informable_type = data["informable_type"];
        var org = data["organization"];
        var destroy_path = KT.routes.api_organization_destroy_default_info_path(org["name"], informable_type, esc_keyname);

        var new_row = "<tr class=\"primary_color\" data-id=\"default_info_" + _keyname + "\">" +
            "<td class=\"ra\">" +
            "<label for=\"default_info_" + _keyname + "\">" + keyname + "</label>" +
            "</td>" +
            "<td>" +
            "<input class=\"btn warning remove_default_info_button\" data-id=\"default_info_" + _keyname + "\" data-method=\"delete\" data-url=\"" + destroy_path + "\" type=\"submit\" value=\"" + i18n.remove + "\">" +
            "</td>" +
            "</tr>";

        $("#new_default_info_row").after(new_row);
        setTimeout(function() {$("tr[data-id='default_info_" + _keyname + "']").addClass("row_fade_in"); }, 1); // hax
        $("#new_default_info_keyname").val("");
        check_for_empty($("#new_default_info_keyname"));
        check_for_apply_button_enable();
    };

    $("#new_default_info_keyname").live("keydown", function(e) {
        if (e.keyCode === 13) { // if you press enter
            $("#add_default_info_button").trigger("click");
        }
    });

    $("#apply_default_info_button").live("click", function(e) {
        var button = $(this);
        e.preventDefault();
        KT.common.customConfirm({
            message     : i18n.default_info_warning,
            yes_callback: function() {
                apply_default_info(button);
            }
        });
    });

    $('#new_default_info_keyname').live('keyup', function(e) {
        check_for_empty($(this));
    });

    $('#add_default_info_button').live('click', function(e) {
        e.preventDefault();
        add_default_info($(this));
    });

    $('.remove_default_info_button').live('click', function(e) {
        e.preventDefault();
        remove_default_info($(this));
    });

    KT.panel.set_expand_cb(function() { async_panel_refresh(); });

})();
