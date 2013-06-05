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

/**
 * Helper functions that may be included and used from pages using
 * inline editing via jeditable.
 */
KT.editable = (function(){
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
        },
        initialize = function() {
            initialize_panel_element();
            initialize_ajaxfileupload();
            initialize_password();
            initialize_textfield();
            initialize_textfield_custom_info();
            initialize_textarea();
            initialize_multiselect();
            initialize_select();
            initialize_number();
            initialize_datepicker();
            initialize_timepicker();
        },
        initialize_panel_element = function() {
            $('.edit_panel_element').each(function() {
                $(this).editable('destroy');
                var settings = {
                    type        :  'text',
                    data        :  null,
                    width       :  270,
                    name        :  $(this).attr('name'),
                    onsuccess   :  function(result, status, xhr) {
                        var id = $('#panel_element_id');
                        KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
                    }
                };
                $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
            });
        },
        initialize_ajaxfileupload = function() {
            $('.ajaxfileupload').each(function() {
                $(this).editable('destroy');
                $(this).editable($(this).attr('url'), {
                    type        :  'ajaxupload',
                    data        :  null,
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
        },
        initialize_password = function() {
            $('.edit_password').each(function() {
                $(this).editable('destroy');
                var settings = {
                    type        :  'password',
                    data        :  null,
                    width       :  270,
                    name        :  $(this).attr('name')
                };
                $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
            });
        },
        initialize_textfield = function() {
            $('.edit_textfield').each(function() {
                $(this).editable('destroy');
                var settings = {
                    type        :  'text',
                    data        :  null,
                    width       :  270,
                    name        :  $(this).attr('name')
                };
                $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
            });
        },
        initialize_textfield_custom_info = function() {
            $('.edit_textfield_custom_info').each(function() {
                $(this).editable('destroy');
                var settings = {
                    type        :  'text',
                    data        :  null,
                    width       :  158,
                    name        :  $(this).attr('name')
                };
                $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
            });
        },
        initialize_textarea = function() {
            $('.edit_textarea').each(function() {
                $(this).editable('destroy');
                var element = $(this);
                var settings = {
                    type        :  'textarea',
                    data        :  null,
                    name        :  element.attr('name'),
                    rows        :  8,
                    cols        :  36,
                    maxlength   :  $(this).data('maxlength')
                };
                $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
            });
        },
        initialize_select = function() {
            $('.edit_select').each(function(){
                $(this).editable('destroy');
                var element = $(this);
                var settings = {
                    type            :  'select',
                    name            :  element.attr('name'),
                    data            :  jQuery.proxy(function() { return $(this).data("options"); }, this),
                    onsuccess       :  function(result, status, xhr){
                        var data = element.data('options');

                        data["selected"] = result;
                        element.html(data[result]);
                    }
                };
                $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
            });
        },
        initialize_multiselect = function() {
            $('.edit_multiselect').each(function() {
                $(this).editable('destroy');
                var element = $(this);
                var settings = {
                    type            :  'multiselect',
                    name            :  element.attr('name'),
                    data            :  jQuery.proxy(function() { return $(this).data("options"); }, this)
                };
                $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
            });
        },
        initialize_number = function() {
            $('.edit_number').each(function() {
                $(this).editable('destroy');
                var element = $(this);
                var settings = {
                    method          :  'POST',
                    type            :  'number',
                    data            :  null,
                    value           :  $.trim($(this).html()),
                    height          :  10,
                    width           :  35,
                    onblur          :  'ignore',
                    name            :  $(this).attr('name'),
                    min             :  $(this).data('min'),
                    max             :  $(this).data('max'),
                    unlimited       :  $(this).data('unlimited'),
                    image           :  $(this).css('background-image'),
                    submitdata      :  {authenticity_token: AUTH_TOKEN},
                    onsuccess       :  function(result, status, xhr){
                        element.css('background-image', settings.image);
                        if ($(this).data('unlimited') !== undefined) {
                            if (parseInt(result,10) === $(this).data('unlimited')) {
                                element.html(i18n.unlimited);
                            } else {
                                element.html(result);
                            }
                        } else {
                            element.html(result);
                        }
                    },
                    onresetcomplete : function(settings, original){
                        element.css('background-image', settings.image);
                    }
                };
                element.editable(element.attr('data-url'), $.extend(common_settings, settings));
            });
        },
        initialize_datepicker = function() {
            $('.edit_datepicker').each(function() {
                $(this).editable('destroy');
                var settings = {
                    type        :  'datepicker',
                    data        :  null,
                    width       :  100,
                    name        :  $(this).attr('name')
                };
                $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
            });
        },
        initialize_timepicker = function() {
            $('.edit_timepicker').each(function() {
                $(this).editable('destroy');
                $(this).editable($(this).attr('data-url'), {
                    type        :  'timepicker',
                    data        :  null,
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
        };

    initialize();

    return {
        initialize                       : initialize,
        initialize_panel_element         : initialize_panel_element,
        initialize_ajaxfileupload        : initialize_ajaxfileupload,
        initialize_password              : initialize_password,
        initialize_textfield             : initialize_textfield,
        initialize_textfield_custom_info : initialize_textfield_custom_info,
        initialize_textarea              : initialize_textarea,
        initialize_select                : initialize_select,
        initialize_multiselect           : initialize_multiselect,
        initialize_number                : initialize_number,
        initialize_datepicker            : initialize_datepicker,
        initialize_timepicker            : initialize_timepicker
    };
}());
