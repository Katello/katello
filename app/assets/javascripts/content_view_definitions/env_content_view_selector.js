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
KT.env_content_view_selector = (function(){
    var settings,

    initialize = function(params) {
        /**
         * params:
         *   override_save        // (default: true) if false, perform save on form submit
         *   override_cancel      // (default: true) if false, perform cancel when cancel button clicked
         *   cv_change_cb()       // callback function to perform custom logic after user selects content view
         *   save_success_cb()    // callback function to perform custom logic after a successful save
         *   save_error_cb()      // callback function to perform custom logic after an unsuccessful save
         *   cancel_success_cb()  // callback function to perform custom logic after a successful cancel
         *   cancel_success_cb()  // callback function to perform custom logic after an unsuccessful cancel
         */
        var pane = $(".env_content_view_selector");
        if (pane.length === 0){
            return;
        }

        settings = params;
        disable_buttons();

        //Set the callback on the environment selector
        env_select.click_callback = function(env_id) {
            save_selected_environment(env_id);
            get_content_views();
        };

        $('#content_view_id').unbind('change');
        $('#content_view_id').change(function() {
            highlight_content_views(false);
            enable_buttons();

            if (settings.cv_change_cb) {
                settings.cv_change_cb();
            }
        });

        if (settings.override_save === false) {
            $('#update_form').unbind('submit');
            $('#update_form').submit(function(e) {
                e.preventDefault();
                save($(this));
            });
        }

        if (settings.override_cancel === true) {
            $('#cancel_button').unbind('click');
            $('#cancel_button').click(function(e) {
                e.preventDefault();
                cancel($(this));
            });
        }
    },
    disable_buttons = function() {
        $('#cancel_button').attr("disabled","disabled");
        $('input[id^=save_button]').attr("disabled","disabled");
    },
    enable_buttons = function() {
        $('#cancel_key').removeAttr('disabled');
        $('input[id^=save_button]').removeAttr('disabled');
    },
    save = function(data) {
        disable_buttons();

        data.ajaxSubmit({
            success: function(data) {
                highlight_content_views(false);
                enable_buttons();
                if (settings.save_success_cb) {
                    settings.save_success_cb();
                }
            }, error: function(e) {
                highlight_content_views(false);
                enable_buttons();
                if (settings.save_error_cb) {
                    settings.save_error_cb();
                }
            }});
    },
    cancel = function(data) {
        var url = $('#cancel_button').attr('data-url');
        if (url !== undefined) {
            disable_buttons();

            $.ajax({
                type: "GET",
                url: url,
                cache: false,
                success: function(response) {
                    $('.panel-content').html(response);
                    if (settings.cancel_success_cb) {
                        settings.cancel_success_cb();
                    }
                },
                error: function(data) {
                    initialize_edit();
                    if (settings.cancel_error_cb) {
                        settings.cancel_error_cb();
                    }
                }
            });
        } else {
            if (settings.cancel_success_cb) {
                settings.cancel_success_cb();
            }
        }
    },
    save_selected_environment = function(env_id) {
        // save the id of the env selected
        $("#environment_id").attr('value', env_id);
    },
    get_content_views = function() {
        // this function will retrieve the views associated with a given environment and
        // update the views box with the results
        var url = $('.path_link.active').attr('data-content_views_url');
        if (url !== undefined) {
            disable_buttons();
            $.ajax({
                type: "GET",
                url: url,
                cache: false,
                success: function(response) {
                    // update the appropriate content on the page
                    var options = '';
                    var opt_template = KT.utils.template("<option value='<%= key %>'><%= text %></option>");

                    // create an html option list using the response
                    options += opt_template({key: "", text: i18n.no_content_view});
                    $.each(response, function(key, item) {
                        options += opt_template({key: item.id, text: item.name});
                    });

                    $("#content_view_id").html(options);

                    if (response.length > 0) {
                        highlight_content_views(true);
                    }
                    enable_buttons();
                },
                error: function(data) {
                    enable_buttons();
                }
            });
        }
    },
    highlight_content_views = function(add_highlight) {
        highlight_input("#content_view_id", add_highlight);
    },
    highlight_input = function(element_id, add_highlight) {
        var select_input = $(element_id);
        if (add_highlight) {
            if( !select_input.next('span').hasClass('highlight_input_text')) {
                select_input.addClass('highlight_input');
                select_input.after('<span class ="highlight_input_text">' + i18n.select_content_view + '</span>');
            }
        } else {
            select_input.removeClass('highlight_input');
            $('.highlight_input_text').remove();
        }
    };
    return {
        initialize: initialize,
        save: save,
        cancel: cancel
    }
})();