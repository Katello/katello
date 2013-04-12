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

$(document).ready(function(){
    var common_settings = {
        method          :  'PUT',
        cancel          :  i18n.cancel,
        submit          :  i18n.save,
        indicator       :  i18n.saving,
        tooltip         :  i18n.clickToEdit,
        placeholder     :  i18n.clickToEdit,
        submitdata      :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
        onerror         :  function(settings, original, xhr) {
            original.reset();
            $("#notification").replaceWith(xhr.responseText);
            notices.checkNotices();
        }
    };
    
    $('.gpg_ajaxfileupload').editable($(this).attr('url'), {
        type        :  'ajaxupload',
        method      :  'PUT',
        name        :  $(this).attr('name'),
        cancel      :  i18n.cancel,
        submit      :  i18n.upload,
        indicator   :  i18n.uploading,
        tooltip     :  i18n.clickToEdit,
        placeholder :  i18n.clickToEdit,
        submitdata  :  {authenticity_token: AUTH_TOKEN},
        onsuccess	:  function(result, status, xhr){
        	
        },
        onerror     :  function(settings, original, xhr) {
        	original.reset();
            $("#notification").replaceWith(xhr.responseText);
        }
    });
    
	$('.edit_textarea').each(function() {
        var settings = { 
                type            :  'textarea',
                name            :  $(this).attr('name'),
                height			:  '300',
                width			:  $(this).width() - 20
        }; 
        $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings)); 
    });
    
    $('.edit_panel_element').each(function() {
        var settings = {
            type        :  'text',
            width       :  270,
            height		:  20,
            name        :  $(this).attr('name'),
            onsuccess   :  function(result, status, xhr) {
                var id = $('#panel_element_id');	
                KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
            }
        };
        $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
    });

});