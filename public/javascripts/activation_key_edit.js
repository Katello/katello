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

var activation_key_edit_page = {
    highlight_environment : function(data) {
        // locate the enviroment id... use it to highlight the environment
        var env_id = data.find("#activation_key_default_environment").attr('value');

        // highlight the selected environment
        data.first("#promotion_paths").find("a[data-env_id=" + env_id + "]").addClass("selected");
    }
}

$(document).ready(function() {
    activation_key_edit_page.highlight_environment($(this));

    $('.edit_system_template').each(function() {
        var button = $(this);
        $(this).editable(button.attr('data-url'), {
            type        :  'select',
            width       :  440,
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            style       :  "inherit",
            data        :  $('input[id^=system_templates]').attr("value"),
            onsuccess   :  function(data) {
                $(".edit_system_template").html(data);
            },
            onerror     :  function(settings, original, xhr) {
                original.reset();
                $("#notification").replaceWith(xhr.responseText);
            }
        });
    });
});
