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
 * @param div_id   -  id of div to house env_selector
 * @param name    -  the name of this env selector ( in case there is more than one)
 * @param environments - array of environment paths
 *                         each path being an array of hashes
 *                          containing  'id', 'name', 'selectable' (optional)
 * @param options_in
 *      initial_select (true)  -  Allow the library to be selected
 *      inline (false)     -    Add all the paths inline, instead of a hidable panel
 *      select_mode (none)     -  selection mode ('single', 'none', 'multi')
 *      link_first (true)      -  if select_mode is not none, all the first nodes
 *                                in the path are 'linked' so checking one checks all
 *      button_text (none)     - if set, a button is rendered with the specified text,
 *                                 clicking the button generates a message
 *      button_event (path_#{name})    - if button exists, clicking it will trigger this event
 *
 */
KT.path_select = function(div_id, name, environments, options_in){

    var div,
        scroll_obj,
        paths_id,
        path_selector,
        options = {},
        init = function(){
            div = $('#' + KT.common.escapeId(div_id));
            paths_id = "path_select_" + name;
            options.library_select = default_opt(options_in.library_select, true);
            options.inline = default_opt(options_in.inline, false);
            options.select_mode = default_opt(options_in.select_mode, 'none');
            options.button_text = default_opt(options_in.button_text, undefined);
            options.button_event = default_opt(options_in.button_event, ('paths_' + name));
            options.link_first = default_opt(options_in.link_first, true);



            div.append(KT.path_select_template.selector(environments, paths_id, options.button_text));
            path_selector = $("#" + paths_id);
            path_selector.find('.node_select').not(':checked').hide();

            if(options.select_mode !== 'none'){
                setup_input_actions();
            }

            if(options.button_text){
                path_selector.find('form').submit(function(e){
                    e.preventDefault();
                    if(!options.inline) {
                        path_selector.hide();
                    }
                    $(document).trigger(options.button_event, get_selected());
                });
            }

            if(!options.inline){
                path_selector.addClass("hover_selector");

                path_selector.hide();
                div.hoverIntent({
                            over:function(){ path_selector.show(); },
                            timeout:500,
                            interval: 200,
                            out:function(){ path_selector.hide(); }
                        });
            }
            scroll_obj = KT.env_select_scroll({});
            recalc_scroll();
        },
        default_opt = function(attribute, default_value){
            return attribute === undefined ? default_value : attribute;
        },
        setup_input_actions = function(){
            var anchors = path_selector.find('li');
            anchors.hover(
                function(){
                    var input = $(this).find('.node_select');
                    if (!input.is(':visible')){
                        input.show();
                    }
                },
                function(){
                    var input = $(this).find('.node_select');
                        if(!input.is(":checked")){
                           input.hide();
                        }
                }
            );

            var nodes = path_selector.find('.node_select');
            var first_nodes = path_selector.find('ul').find('li:first');
            var on_select = function(select_elem){
                select_nodes(select_elem);
                if(options.select_mode === 'single'){
                    nodes.attr('disabled', 'disabled');
                    select_elem.removeAttr('disabled');
                }
                if(options.link_first && select_elem.parents('li').is(':first-child')){
                    select_nodes(first_nodes.find('input:checkbox').not(':checked'))
                }
            };
            var on_deselect = function(select_elem){
                unselect_nodes(select_elem);
                if(options.select_mode === 'single'){
                    nodes.removeAttr('disabled');
                }
                if(options.link_first && select_elem.parents('li').is(':first-child')){
                    unselect_nodes(first_nodes.find('input:checkbox:checked').hide());
                }
            };
            nodes.change(function(){
                    if ($(this).is(':checked')){
                        on_select($(this));
                    }
                    else {
                        on_deselect($(this));
                    }
            });

        },
        select_nodes = function(checkbox_list){
            checkbox_list.attr('checked', 'checked').show();
            checkbox_list.parents('a').addClass('active');
        },
        unselect_nodes = function(checkbox_list){
            checkbox_list.removeAttr('checked');
            checkbox_list.parents('a').removeClass('active');
        },
        get_selected = function(){
            var selected = path_selector.find('input:checked'),
                to_ret = {};

            KT.utils.each(selected, function(item){
                item = $(item);
                to_ret[item.data('node_id')] = {text:item.parent().text(),
                                                next_id:item.data('next_node_id')};
            });
            return to_ret;
        },
        recalc_scroll = function(){
           if(!options.inline){
               path_selector.show();
               scroll_obj.bind('#' + KT.common.escapeId(paths_id));
               path_selector.hide();
           }
           else {
               scroll_obj.bind('#' + KT.common.escapeId(paths_id));
           }
        },
        get_event = function(){
            return options.button_event;
        },
        clear_selected = function(){
            unselect_nodes(path_selector.find('input:checked').hide());
        },
        select = function(id, next_id){
           var nodes = path_selector.find('input:checkbox[data-node_id=' + id + ']');
           if(nodes.length > 1 && !options.link_first){
               nodes.and('[data-next_node_id=' + next_id + ']').click();
           }
           else{
               nodes.click();
           }
        }

    init();

    return {
        get_selected: get_selected,
        get_event : get_event,
        clear_selected: clear_selected,
        select:select 
    };
};


KT.path_select_template = {
    selector : function(paths, div_id, button_text){
        var html = '<div id="' + div_id + '" class="path_selector"><form>';
        html += KT.path_select_template.paths(paths);
        if(button_text){
            html += KT.path_select_template.button(button_text);
        }
        html += '</form></div>';
        return html;
    },
    button : function(text){
        return '<input type="submit" class="button" value="' + text + '">';
    },
    paths : function(paths){
        var html ='';

        KT.utils.each(paths, function(item){
            html += KT.path_select_template.path(item);
        });
        return html ;
    },
    path : function(path){
        var html = '';
        html += '<ul>';
        for(var i = 0; i < path.length; i++){
            html += KT.path_select_template.path_node(path[i], path[i+1]);
        }
        html += '</ul>';
        return html;
    },
    path_node: function(node, next){
        var html = '',
            next_node =  next  ? ('data-next_node_id="' + next.id + '"') : '',
            input = node.select ? '<span class="checkbox_holder"><input class="node_select" type="checkbox" ' +
                next_node +' data-node_id="' + node.id + '"></span>' : '';


        html += '<li data-node_id="' + node.id + '">'+ '<a><div>' + input + node.name + '</div></a></li>';
        return html;
    }
};

