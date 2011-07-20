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

    $.editable.addInputType('password', {
        element : function(settings, original) {
            var input=$('<input type="password">');
            if(settings.width!='none') {
                input.width(settings.width);
            }
            if(settings.height!='none') {
                input.height(settings.height);
            }
            input.attr('autocomplete','off');
            $(this).append(input);
            return(input);
        }
    });

    // Create a custom input type for checkboxes
    $.editable.addInputType("checkbox", {
        element : function(settings, original) {
            var input = $('<input type="checkbox">');
            $(this).append(input);

            // Update <input>'s value when clicked
            $(input).click(function() {
                //var value = $(input).attr("checked") ? i18n.checkbox_yes : i18n.checkbox_no;
                var value = $(input).attr("checked") ? true : false;
                $(input).val(value);
            });
            return(input);
        },
        content : function(string, settings, original) {
            var checked = string.indexOf(i18n.checkbox_yes)!= -1 ? 1 : 0;
            var input = $(':input:first', this);
            $(input).attr("checked", checked);
            var value = $(input).attr("checked") ? i18n.checkbox_yes : i18n.checkbox_no;
            //var value = $(input).attr("checked") ? true : false;

            $(input).val(value);
        }
    });
    
    $('.edit_textfield').each(function() {
        $(this).editable('edit', {
            type        :  'text',
            width       :  270,                  
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            submitdata  :  {authenticity_token: AUTH_TOKEN},
            onerror     :  function(settings, original, xhr) {
            original.reset();
            $("#notification").replaceWith(xhr.responseText);
            }
        });
    });

    $('.edit_textarea').each(function() {
        $(this).editable('edit', {
            type        :  'textarea',
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            submitdata  :  {authenticity_token: AUTH_TOKEN},
            rows        :  8,
            cols        :  60,
            onerror     :  function(settings, original, xhr) {
            original.reset();
            $("#notification").replaceWith(xhr.responseText);
            }
        });
    });
});
