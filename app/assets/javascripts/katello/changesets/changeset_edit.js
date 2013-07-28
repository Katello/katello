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

    $('#accordion').accordion({});

    $("#changeset_history_tabs .clickable").click(function(){

        $(this).parents(".content_group").children(".cs_content").slideToggle();

        var arrow = $(this).parent().find('img');
        if(arrow.attr("src").indexOf("collapsed") === -1){
          arrow.attr("src", "icons/expander-collapsed.png");
        } else {
          arrow.attr("src", "icons/expander-expanded.png");
        }
    });

    $('.edit_textfield').each(function() {
        $(this).editable($(this).attr('data-url'), {
            type        :  'text',
            width       :  270,
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            submitdata  :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
            onsuccess   :  function(data) {
               var parsed = $.parseJSON(data);
               $(this).html(parsed.name);
               changeset_page.signal_rename($(this).attr("data-id"));
               notices.checkNotices();
            },
            onerror     :  function(settings, original, xhr) {
                             original.reset();
            }
        });
    });

    $('.edit_description').each(function() {
        $(this).editable($(this).attr('data-url'), {
            type        :  'textarea',
            method      :  'PUT',
            name        :  $(this).attr('name'),
            maxlength   :  $(this).data('maxlength'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            submitdata  :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
            rows        :  10,
            cols        :  30,
            onsuccess   :  function(data) {
                  var parsed = $.parseJSON(data);
                  $(this).html(parsed.description);
                  notices.checkNotices();
            },
            onerror     :  function(settings, original, xhr) {
                original.reset();
            }
        });
    });
});

