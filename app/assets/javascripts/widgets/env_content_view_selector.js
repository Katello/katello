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

KT.env_content_view_selector = (function() {
    var env_div,
        content_view_div,
        env_select,
        content_view_select,
        saved_env_id,
        saved_content_view_id,
        performing_cancel = false,

        init = function(name, env_div_id, envs, current_env_id,
                        content_view_div_id, content_views, current_content_view_id) {

            // initialize the environment selector
            env_div = $('#' + env_div_id);
            content_view_div = $('#' + content_view_div_id);
            saved_env_id = current_env_id;
            saved_content_view_id = current_content_view_id;

            env_select = KT.path_select(env_div_id, name, envs, {select_mode:'single', inline: true});
            $(document).unbind(env_select.get_select_event());

            // select the current environment
            env_select.select(current_env_id);

            // if the user changes the environment, update the available content views
            $(document).bind(env_select.get_select_event(), function(event) {
                update_content_views(KT.utils.keys(env_select.get_selected()));
            });

            // render the content view selector and the save/cancel buttons
            render_selector(content_view_div, content_views, current_content_view_id);

            register_cancel();
            register_save();
        },
        register_cancel = function() {
            var cancel_button = $('.cancel_env_content_view');
            cancel_button.unbind('click').click(function(e) {
               var current_env = KT.utils.values(env_select.get_selected());

                if ((current_env.length === 0) || (current_env[0]['id'] !== saved_env_id)) {
                    env_select.clear_selected();
                    env_select.select(saved_env_id);
                    performing_cancel = true;
                } else {
                    content_view_select.val(saved_content_view_id);
                    remove_content_view_highlight();
                }
            });
        },
        register_save = function() {
            var save_button = $('.save_env_content_view');
            save_button.unbind('click').click(function(e) {
                e.preventDefault();

                var env_param = env_div.data('name'),
                    view_param = content_view_div.data('name'),
                    data = {};
                data[env_param] = get_selected_env_id();
                data[view_param] = get_selected_content_view_id();
                data["authenticity_token"] = AUTH_TOKEN;
                $.ajax({
                    type: 'PUT',
                    url: content_view_div.data('url'),
                    data: data,
                    cache: false,
                    success: function(html) {
                        remove_content_view_highlight();
                        saved_env_id = get_selected_env_id();
                        saved_content_view_id = get_selected_content_view_id();
                    },
                    error: function() {
                    }
                });
            });

        },
        get_selected_content_view_id = function() {
            return content_view_select.val();
        },
        get_selected_env_id = function() {
            return KT.utils.values(env_select.get_selected())[0]['id'];
        },
        update_content_views = function(env_ids) {
            if (env_ids.length === 0) {
                clear_content_views();
            } else {
                // retrieve the list of views in this environment and update the options
                $.ajax({
                    url: KT.routes.content_views_environment_path(env_ids[0]),
                    type: "GET",
                    data: {'include_default': 'true'},
                    success: (function(response) {
                        var options = '', highlight_text;
                        var opt_template = KT.utils.template("<option value='<%= key %>'><%= text %></option>");

                        if (response.length > 0) {
                            // create an html option list using the response
                            $.each(response, function(key, item) {
                                options += opt_template({key: item.id, text: item.name});
                            });
                            highlight_text = performing_cancel === true ? undefined : i18n.select_content_view;
                        } else {
                            // this environment doesn't have any views, warn the user
                            highlight_text = i18n.no_content_views_available;
                        }
                        content_view_select.html(options);

                        if (highlight_text !== undefined) {
                            highlight_content_views(highlight_text);
                        } else {
                            content_view_select.val(saved_content_view_id);
                            remove_content_view_highlight();
                        }
                        performing_cancel = false;
                    })
                });
            }
        },
        clear_content_views = function() {
            remove_content_view_highlight();
            $("#content_view_select").html('');
        },
        highlight_content_views = function(text){
            var highlight_text = content_view_select.next('span.highlight_input_text');

            content_view_select.addClass('highlight_input');
            if (highlight_text.length > 0) {
                highlight_text.html(text);
            } else {
                content_view_select.after('<span class ="highlight_input_text">' + text + '</span>');
            }
        },
        remove_content_view_highlight = function() {
            content_view_select.removeClass('highlight_input');
            content_view_select.next('span.highlight_input_text').remove();
        },
        render_selector = function(content_view_div, available_views, current_view) {
            render_select(content_view_div, current_view, available_views);
            render_buttons(content_view_div);
            content_view_select = $('#content_view_select');
        },
        render_select = function(content_view_div, current_view, available_views) {
            var opt_template = KT.utils.template("<option <%= selected %> value='<%= key %>'><%= text %></option>"),
                name = content_view_div.data('name'),
                html;

            html = '<form><select id="content_view_select" name="' + name + '">';
            $.each(available_views, function(key, item) {
                if (item.id === current_view) {
                    html += opt_template({key: item.id, text: item.name, selected: 'selected'});
                } else {
                    html += opt_template({key: item.id, text: item.name, selected: ''});
                }
            });
            html += '</select></form>';
            content_view_div.append(html);
        },
        render_buttons = function(content_view_div) {
            var button_template = KT.utils.template("<input type='button' class='button <%= clazz %>' value='<%= text %>' > "),
                html;

            html = '<div class="fr">';
            html += button_template({clazz: 'save_env_content_view', text: 'Save'});
            html += button_template({clazz: 'cancel_env_content_view', text: 'Cancel'});
            html += '</div>';
            content_view_div.after(html);
        };

    return {
        init : init
    };
}());
