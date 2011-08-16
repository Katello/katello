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

/**
 * Helper functions that may be included and used from pages using
 * inline editing via jeditable.
 */
$(document).ready(function() {
    var common_settings = {
            method          :  'PUT',
            cancel          :  i18n.cancel,
            submit          :  i18n.save,
            indicator       :  i18n.saving,
            tooltip         :  i18n.clickToEdit,
            placeholder     :  i18n.clickToEdit,
            submitdata      :  {authenticity_token: AUTH_TOKEN},
            onerror         :  function(settings, original, xhr) {
                original.reset();
                $("#notification").replaceWith(xhr.responseText);
            }
        };

    $.editable.addInputType('number', {
       element  :   function(settings, original){
            var width = settings.width ? settings.width : '40',
                input = jQuery('<input type="number" min="0"' +
                                'max="' + settings.max + '"' + 
                                'value="' + settings.value + 
                                '" style="width:' + width + 'px;">');
            $(this).append(input);
            $(original).css('background-image', 'none');
            return(input);    
       },
       content :    function(string, settings, original){
           $(':input:first', this).val(settings.value);
       }
    });

    $('.ajaxfileupload').each(function() {
        $(this).editable($(this).attr('url'), {
            type        :  'ajaxupload',
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.upload,
            indicator   :  i18n.uploading,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            submitdata  :  {authenticity_token: AUTH_TOKEN},
            onerror     :  function(settings, original, xhr) {
            original.reset();
                $("#notification").replaceWith(xhr.responseText);
            }
        });
    });

    $('.edit_panel_element').each(function() {
        var settings = {
            type        :  'text',
            width       :  270,
            name        :  $(this).attr('name'),
            onsuccess   :  function(result, status, xhr) {
                var id = $('#panel_element_id');
                list.refresh(id.attr('value'), id.attr('data-ajax_url'));
            }
        };
        $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
    });

    $('.edit_password').each(function() {
        var settings = {
            type        :  'password',
            width       :  270,
            name        :  $(this).attr('name'),
        };
        $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
    });

    $('.edit_textfield').each(function() {
        var settings = {
            type        :  'text',
            width       :  270,                  
            name        :  $(this).attr('name'),
        };
        $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
    });

    $('.edit_textarea').each(function() {
        var settings = { 
                type            :  'textarea',
                name            :  $(this).attr('name'),
                rows            :  8,
                cols            :  36
        }; 
        $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings)); 
    });
    
    $('.edit_number').each(function() {
        var element = $(this);
        var settings = {
            method          :  'POST',
            type            :  'number',
            value           :  $.trim($(this).html()),
            height          :  10,           
            width           :  35,       
            name            :  $(this).attr('name'),
            max             :  $.trim($(this).parent().find('.available').html()),
            image           :  $(this).css('background-image'),
            submitdata      :  {authenticity_token: AUTH_TOKEN, "subscription_id" : element.attr('id')},
            onsuccess       :  function(result, status, xhr){
                element.css('background-image', settings.image);
                element.html(result);
            },
            onresetcomplete : function(settings, original){
                element.css('background-image', settings.image);
            }
        };
        element.editable(element.attr('data-url'), $.extend(common_settings, settings));
    });
});
