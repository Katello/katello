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

/*
 * A small javascript file needed to load things whenever a provider is opened for editing
 */

$(document).ready(function() {
	var list = KT.panel.list;
	
    $('.edit_datepicker').each(function() {
        $(this).editable($(this).attr('data-url'), {
            type        :  'datepicker',
            width       :  300,
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            submitdata  :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
            onsuccess   :  function(result, status, xhr) {
                var plan_date = $("#plan_date").text();
                var current_plan = $("#current_plan").text();
                if (plan_date != current_plan) {
                    $("#current_plan").text(plan_date);
                }
                var id = $('#plan_id');
                list.refresh(id.attr('value'), id.attr('data-ajax_url'));
            },
            onerror     :  function(settings, original, xhr) {
              original.reset();
              $("#notification").replaceWith(xhr.responseText);
            }
        });
    });

    $('.edit_timepicker').each(function() {
        $(this).editable($(this).attr('data-url'), {
            type        :  'timepicker',
            width       :  300,
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            submitdata  :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
            onsuccess   :  function(result, status, xhr) {
                var plan_time = $("#plan_time").text();
                var current_plan = $("#current_plan").text();
                if (plan_time !== current_plan) {
                    $("#current_plan").text(plan_time);
                }
                var id = $('#plan_id');
                list.refresh(id.attr('value'), id.attr('data-ajax_url'));
            },
            onerror     :  function(settings, original, xhr) {
              original.reset();
              $("#notification").replaceWith(xhr.responseText);
            }
        });
    });

    $('.edit_planname').each(function() {
        $(this).editable($(this).attr('data-url'), {
            type        :  'text',
            width       :  300,
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            submitdata  :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
            onsuccess   :  function(result, status, xhr) {
                var plan_name = $("#plan_name").text();
                var current_plan = $("#current_plan").text();
                if (plan_name !== current_plan) {
                    $("#current_plan").text(plan_name);
                }
                var id = $('#plan_id');
                list.refresh(id.attr('name'), id.attr('data-ajax_url'));
            },
            onerror     :  function(settings, original, xhr) {
            original.reset();
            $("#notification").replaceWith(xhr.responseText);
            }
        });
    });

    $('.edit_planinterval').each(function() {
        $(this).editable($(this).attr('data-url'), {
            type        :  'select',
            width       :  300,
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            submitdata  :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
            data        :  "{'none': 'None','hourly':'Hourly','daily':'Daily', 'weekly':'Weekly'}",
            onsuccess   :  function(result, status, xhr) {
                var id = $('#plan_id');
                list.refresh(id.attr('value'), id.attr('data-ajax_url'));
            },
            onerror     :  function(settings, original, xhr) {
            original.reset();
            $("#notification").replaceWith(xhr.responseText);
            }
        });
    });
});
