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

update_content_views = function(env_id) {
    // update content view options
    $.ajax({  url: KT.routes.content_views_environment_path(env_id),
              type: "GET",
              success: function(data) {
                  options = {'': ''};
                  $.each(data, function(key, value) {
                       options[value.id] = value.name;
                  });
                  $("#distributor_content_view").data("options", options);
              }
            });
};


$(document).ready(function() {

    var select_settings = {
        select_mode:'single',
        submit_button_text: i18n.save,
        cancel_button_text: i18n.cancel,
        activate_on_click: true,
        library_select: true
    };
    path_select = KT.path_select('environment_path_selector', 'edit_select_distributor_environment', KT.available_environments,
        select_settings);

    $(document).bind(path_select.get_submit_event(), function(event, environments) {
        var selected_env_ids = KT.utils.values(path_select.get_selected());
        if (selected_env_ids.length < 1) {
            return;
        }

        var selector_element = $('#environment_path_selector');
        selector_element.find(".KT_path_select_submit_button").attr('disabled', 'disabled');

        var request = $.ajax({
            url: selector_element.attr('data-url'),
            type: 'PUT',
            data: {'distributor[environment_id]': selected_env_ids[0]['id'], authenticity_token: AUTH_TOKEN}
        });

        // disable the field temporarily
        $("#distributor_content_view").hide();

        request.done(function(msg) {
            selector_element.find('span:first').text(selected_env_ids[0]['name']);

            panel_element = $('input[data-ajax_url="' + selector_element.attr('data-url') + '"]');
            KT.panel.list.refresh(panel_element.attr('value'), panel_element.attr('data-ajax_url'));

            path_select.hide();
            selector_element.find(".KT_path_select_submit_button").removeAttr('disabled');

            path_select.clear_selected();
            notices.checkNotices();

            update_content_views(selected_env_ids[0]['id']);
            if($("#distributor_content_view").text() !== i18n.clickToEdit) {
                alert(i18n.contentViewReset);
                $("#distributor_content_view").text(i18n.clickToEdit);
            }
        });

        request.fail(function(jqXHR, textStatus) {
            path_select.hide();
            selector_element.find(".KT_path_select_submit_button").removeAttr('disabled');

            path_select.clear_selected();
            notices.checkNotices();
            $("#distributor_content_view").show();
        });
    });
});


