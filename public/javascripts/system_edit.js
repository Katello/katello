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

$(document).ready(function() {

    var common_settings = {
            method          :  'PUT',
            cancel          :  i18n.cancel,
            submit          :  i18n.save,
            indicator       :  i18n.saving,
            tooltip         :  i18n.clickToEdit,
            placeholder     :  i18n.systemReleaseVerDefault,
            submitdata      :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
            onerror         :  function(settings, original, xhr) {
                original.reset();
                $("#notification").replaceWith(xhr.responseText);
                notices.checkNotices();
            }
        };

    $('.edit_select_system_releasever').each(function(){
        var element = $(this),
            settings = {
                type            :  'select',
                name            :  element.attr('name'),
                data            :  element.data('options'),
                onsuccess       :  function(result, status, xhr){
                    notices.checkNotices();
                },
                onerror         :  function(result, status, xhr){
                    notices.checkNotices();
                }
            };
        $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
    });

    $('.edit_select_system_releasever_message').each(function(){
        var element = $(this),
            settings = {
                type            :  'textarea',
                name            :  element.attr('name'),
                data            :  element.data('message'),
                rows            :  8,
                cols            :  36,
                submit          :  false,
                onsuccess       :  function(result, status, xhr){
                    notices.checkNotices();
                },
                onerror         :  function(result, status, xhr){
                    notices.checkNotices();
                }
            };
        $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
    });

    path_select = KT.path_select('environment_path_selector', 'edit_select_system_environment', KT.available_environments,
        {select_mode:'single', submit_button_text: i18n.save, cancel_button_text: i18n.cancel, activate_on_click: true});

    $(document).bind(path_select.get_submit_event(), function(event, environments) {
        var selected_env_ids = KT.utils.values(path_select.get_selected())
        if (selected_env_ids.length < 1) {
            return;
        }

        var selector_element = $('#environment_path_selector');
        selector_element.find(".KT_path_select_submit_button").attr('disabled', 'disabled');

        var request = $.ajax({
            url: selector_element.attr('data-url'),
            type: 'PUT',
            data: {'system[environment_id]': selected_env_ids[0]['id'], authenticity_token: AUTH_TOKEN}
        });

        request.done(function(msg) {
            selector_element.find('span:first').text(selected_env_ids[0]['name']);

            panel_element = $('input[data-ajax_url="' + selector_element.attr('data-url') + '"]');
            KT.panel.list.refresh(panel_element.attr('value'), panel_element.attr('data-ajax_url'));

            path_select.hide();
            selector_element.find(".KT_path_select_submit_button").removeAttr('disabled');

            path_select.clear_selected();
            notices.checkNotices();
        });

        request.fail(function(jqXHR, textStatus) {
            path_select.hide();
            selector_element.find(".KT_path_select_submit_button").removeAttr('disabled');

            path_select.clear_selected();
            notices.checkNotices();
        });
    });
});
