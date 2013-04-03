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

KT.custom_info = (function() {

    $("#new_custom_info_keyname").live("keyup", function() {
        check_for_empty($(this));
    });

    $(".remove_custom_info_button").live('click', function(e) {
        e.preventDefault();
        remove_custom_info($(this));
    });

    $("#create_custom_info_button").live('click', function(e) {
        e.preventDefault();
        create_custom_info($(this));
    });

    function check_for_empty($textfield) {
        $button = $("#create_custom_info_button");
        if ($textfield.val().length > 0 ) {
            $button.removeAttr("disabled");
        } else {
            $button.attr("disabled", "true");
        }
    }

    function remove_custom_info($button) {
        $.ajax({
            url    : $button.data("url"),
            type   : $button.data("method"),
            success: function() {
                remove_custom_info_row($button.data("id"));
            },
            error  : function(data) {
                notices.displayNotice("error", window.JSON.stringify({ "notices": [$.parseJSON(data.responseText)["displayMessage"]] }));
            }
        });
    }

    function create_custom_info($button) {
        var keyname = $("#new_custom_info_keyname").val();
        var value = $("#new_custom_info_value").val();

        $.ajax({
            url     : $button.data("url"),
            type    : $button.data("method"),
            dataType: 'json',
            data    : { "keyname": keyname, "value": value },
            success : function(data) {
                add_custom_info_row(data);
            },
            error   : function(data) {
                notices.displayNotice("error", window.JSON.stringify({ "notices": [$.parseJSON(data.responseText)["displayMessage"]] }));
            }
        });
    }

    function remove_custom_info_row(data_id) {
        $("tr[data-id='" + data_id + "']").remove();
    }

    function add_custom_info_row(data) {
        var esc_keyname = escape(data["keyname"]);
        var _keyname = data["keyname"].replace(" ", "_");
        var value = data["value"];
        var informable_type = data["informable_type"];
        var informable_id = data["informable_id"];
        var update_path = KT.routes.api_update_custom_info_path(informable_type, informable_id, esc_keyname);
        var destroy_path = KT.routes.api_destroy_custom_info_path(informable_type, informable_id, esc_keyname);

        var new_row = "<tr class=\"primary_color\" data-id=\"custom_info_" + _keyname + "\">"
        + "<td class=\"ra\">"
        + "<label for=\"custom_info_" + _keyname + "\">" + data["keyname"] + "</label>"
        + "</td>"
        + "<td>"
        + "<div class=\"editable edit_textfield\" data-method=\"put\" data-url=\"" + update_path + "\" name=\"value\" style title=\"Click to edit\">" + value + "</div>"
        + "</td>"
        + "<td>"
        + "<input class=\"btn warning remove_custom_info_button\" data-id=\"custom_info_" + _keyname + "\" data-method=\"delete\" data-url=\"" + destroy_path + "\" type=\"submit\" value=\"remove\">"
        + "</td>"
        + "</tr>";

        $("#new_custom_info_row").after(new_row);
        setTimeout(function() { $("tr[data-id='custom_info_" + _keyname + "']").addClass("row_fade_in"); }, 1);
        $("#new_custom_info_keyname").val("");
        $("#new_custom_info_value").val("");
        check_for_empty($("#new_custom_info_keyname"));

        var $new_editable = $("tr[data-id='custom_info_" + _keyname + "']").find(".editable");
        var common_settings = {
            method     :  'PUT',
            cancel     :  i18n.cancel,
            submit     :  i18n.save,
            indicator  :  i18n.saving,
            tooltip    :  i18n.clickToEdit,
            placeholder:  i18n.clickToEdit,
            submitdata :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
            onerror    :  function(settings, original, xhr) {
                original.reset();
                $("#notification").replaceWith(xhr.responseText);
                notices.checkNotices();
            }
        };
        var settings = {
            type :  'text',
            width:  270,
            name :  $new_editable.attr('name')
        };
        $new_editable.editable($new_editable.attr('data-url'), $.extend(common_settings, settings));
    }

})();
