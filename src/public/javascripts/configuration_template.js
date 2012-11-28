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

KT.panel.list.registerPage('configuration_templates', {create: 'new_configuration_template'});

KT.configuration_templates_page = (function() {
    checkboxChanged = function() {
        var checkbox = $(this);
        var name = $(this).attr("name");
        var options = {};
        options[name] = translateCheckBoxValue(checkbox.attr("checked"));
        var url = checkbox.attr("data-url");
        $.ajax({
            type: "PUT",
            url: url,
            data: options,
            cache: false
        });
        return false;
    };

    addRemoveOperatingSystem = function() {
        var checkboxes = $('#configuration_template_operatingsystem_ids_:checked');
        var ids = [];
        checkboxes.each( function(index, item) { ids.push($(item).attr("value")); });
        var url = $(this).attr("data-url");
        $.ajax({
            type: "PUT",
            url: url,
            data: {'configuration_template[operatingsystem_ids]': ids},
            cache: false
        });
        return false;
    };

    changeType = function() {
        var url = $(this).attr("data_url");
        $.ajax({
            type: "PUT",
            url: url,
            data: {'configuration_template[template_kind][id]': $(this).val()},
            cache: false
        });
        return false;
    };

    translateCheckBoxValue = function(value) {
        return value !== undefined ?  "true" : "false";
    };

    uploadTemplate = function(){
        $('#update_upload_template').attr('disabled', 'disabled');
        $('#clear_upload_template').attr('disabled', 'disabled');

        $('#edit_config_template').ajaxSubmit({
            url 	: $(this).data('data_url'),
            type 	: 'PUT',
            beforeSubmit: function(arr, $form, options) {
                for (i = 0; i < arr.length; i++) {
                    if (arr[i]['name'] == 'configuration_template[snippet]') {
                        arr[i]['value'] = translateCheckBoxValue(arr[i]['value']);
                    }
                }
            },
            success	: function(data, status, xhr){
                $('#configuration_template_text').text(data['template']);
                $('#configuration_template_file').val('');
                notices.checkNotices();
                $('#update_upload_template').removeAttr('disabled');
                $('#clear_upload_template').removeAttr('disabled');
            },
            error	: function(){
                $('#update_upload_template').removeAttr('disabled');
                $('#clear_upload_template').removeAttr('disabled');
                notices.checkNotices();
            }
        });
    };

    register = function() {
        $('#configuration_template_snippet').bind('change', checkboxChanged);
        $('#configuration_template_template_kind_id').live('change', changeType);
        $('#configuration_template_operatingsystem_ids_').live('change', addRemoveOperatingSystem);
        $('#update_upload_template').live('click', uploadTemplate);
        $('#configuration_template_file').live('change', function(){
            if( $(this).val() !== '' ){
                $('#update_upload_template').removeAttr('disabled');
                $('#clear_upload_template').removeAttr('disabled');
            } else {
                $('#update_upload_template').attr('disabled', 'disabled');
                $('#clear_upload_template').attr('disabled', 'disabled');
            }
        });
        $('#clear_upload_template').live('click', function(){
            $('#update_upload_template').attr('disabled', 'disabled');
            $('#clear_upload_template').attr('disabled', 'disabled');
            $('#configuration_template_file').val('');
        });
    };

    return {
        register: register
    }
}());

$(document).ready(function() {
    KT.panel.set_expand_cb(function() {
        KT.configuration_templates_page.register();
    });
});
