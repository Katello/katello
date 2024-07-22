/**
 * @param div_id   -  id of div to house env_selector
 * @param name    -  the name of this env selector ( in case there is more than one)
 * @param environments - array of environment paths
 *                         each path being an array of hashes
 *                          containing  'id', 'name', 'selectable' (optional)
 * @param options_in
 *      inline (false)     -    Add all the paths inline, instead of a hidable panel
 *      select_mode (none)     -  selection mode ('single', 'none', 'multi')
 *      link_first (true)      -  if select_mode is not none, all the first nodes
 *                                in the path are 'linked' so checking one checks all
 *      submit_button_text (none)     - if set, a button is rendered with the specified text,
 *                                 clicking the button generates a message
 *      submit_event (path_#{name})    - if button exists, clicking it will trigger this event
 *                                       if no button and not inline, hovering out will trigger this event
 *      expand (true)           -  enable/disable the expanding of path nodes (disable for debugging)
 *
 */
KT.path_select = function(div_id, name, environments, options_in){

    var div,
        scroll_obj,
        paths_id,
        path_selector,
        options = {},
        utils = KT.utils,
        init = function(){
            div = $('#' + KT.common.escapeId(div_id));
            paths_id = "path_select_" + name;
            options.inline = default_opt(options_in.inline, false);
            options.activate_on_click = default_opt(options_in.activate_on_click, false);
            options.select_mode = default_opt(options_in.select_mode, 'none');

            options.submit_button_text = default_opt(options_in.submit_button_text, undefined);
            options.cancel_button_text = default_opt(options_in.cancel_button_text, undefined);
            options.submit_event = default_opt(options_in.submit_event, ('submit_paths_' + name));
            options.cancel_event = default_opt(options_in.cancel_event, ('cancel_paths_' + name));
            options.select_event = default_opt(options_in.select_event, ('selected_cell_' + name));
            options.link_first = default_opt(options_in.link_first, true);
            options.expand = default_opt(options_in.expand, true);
            options.footer = default_opt(options_in.footer, false);
            options.readonly = default_opt(options_in.readonly, false);

            options.selected = default_opt(options_in.selected, undefined);

            $(div).append(KT.path_select_template.selector(environments, paths_id, options.submit_button_text, options.cancel_button_text, options.footer));
            path_selector = $("#" + paths_id);
            path_selector.find('.node_select').not(':checked').hide();

            if(options.select_mode !== 'none'){
                setup_input_actions();
            }

            if(options.submit_button_text){
                path_selector.find('.KT_path_select_submit_button').on("click", function(e){
                    if(!options.inline) {
                        path_selector.hide();
                    }
                    $(document).trigger(options.submit_event, [get_selected()]);
                });
            }

            if(options.cancel_button_text){
                path_selector.find('.KT_path_select_cancel_button').on("click", function(e){
                    clear_selected();
                    if(!options.inline) {
                        path_selector.hide();
                    }
                    $(document).trigger(options.cancel_event);
                    return false;
                });
            }

            if(!options.inline){
                path_selector.addClass("hover_selector");

                path_selector.hide();

                if(options.activate_on_click)  {
                    div.on("click", function(e) { path_selector.show(); });
                } else {
                    div.hoverIntent({
                        over:function(){ path_selector.show(); },
                        timeout:500,
                        interval: 200,
                        out:hover_out
                    });
                }
            }

            if (options.selected) {
                select(options.selected);
            }

            if (options.readonly) {
                disable_all();
            }

            $(document).on("mouseup", function(e){
                if(path_selector.has(e.target).length === 0 && !options.inline) {
                    path_selector.hide();
                }
            });

            scroll_obj = KT.env_select_scroll({});
            recalc_scroll();
        },
        reposition_left = function(){
            var selector_width, pos;

            if(options.inline){
                return false;
            }
            //This is a hack for IE, sadly

            path_selector.css('visibility', 'hidden');
            path_selector.show();

            selector_width = path_selector.outerWidth();
            pos = div.outerWidth()  - selector_width - 1;

            path_selector.css('left', pos + 'px');

            path_selector.hide();
            path_selector.css('visibility', 'visible');
        },
        hover_out = function(){
            path_selector.hide();
            $(document).trigger(options.submit_event, [get_selected()]);
        };
        reposition_right = function(){
            var margin = 10,
                window_width, selector_width, button_start, pos, top;

            if(options.inline){
                return false;
            }
            window_width = $(window).width();
            selector_width = path_selector.outerWidth()  ;
            button_start = div.offset().left;



            if(button_start + selector_width + margin > window_width){
                pos = window_width - (selector_width + margin);
                pos = pos - button_start;
            }
            else{
                pos = 0;
            }
            path_selector.css('left', pos + 'px');
        },
        default_opt = function(attribute, default_value){
            return attribute === undefined ? default_value : attribute;
        },
        setup_input_actions = function(){
            var anchors = path_selector.find('li'),
                nodes = path_selector.find('.node_select'),
                first_nodes = path_selector.find('ul').find('li:first'),
                on_select, on_deselect;

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


            on_select = function(select_elem, fire_event){
                select_nodes(select_elem);
                if(options.select_mode === 'single'){
                    unselect_nodes(nodes);
                    select_nodes(select_elem);
                }
                if(options.link_first && select_elem.parents('li').is(':first-child')){
                    select_nodes(first_nodes.find('input:checkbox').not(':checked'));
                }

                if (fire_event !== false) {
                    $(document).trigger(options.select_event, [true, $(this).data('node_id'), $(this).data('next_node_id')]);
                }
            };
            on_deselect = function(select_elem){
                unselect_nodes(select_elem);
                if(options.select_mode === 'single'){
                    nodes.removeAttr('disabled');
                }
                if(options.link_first && select_elem.parents('li').is(':first-child')){
                    unselect_nodes(first_nodes.find('input:checkbox:checked').hide());
                }
                $(document).trigger(options.select_event, [false, $(this).data('node_id'), $(this).data('next_node_id')]);
            };
            nodes.change(function(){
                if ($(this).is(':checked')) {
                    on_select($(this));
                } else {
                    on_deselect($(this));
                }
            });

        },
        select_nodes = function(checkbox_list){
            var checkbox;

            checkbox = checkbox_list.prop('checked', true).attr('checked', 'checked').show();
            checkbox_list.parents('label').addClass('active');

            if (options.select_mode === 'single') {
                checkbox.attr('disabled', 'disabled');
            }
        },
        unselect_nodes = function(checkbox_list){
            checkbox_list.removeAttr('checked').removeAttr('disabled');
            checkbox_list.parents('label').removeClass('active');
        },
        disable_all = function() {
            path_selector.find('input:checkbox').attr('disabled', 'disabled');
        },
        enable_all = function() {
            path_selector.find('input:checkbox').removeAttr('disabled');
        },
        get_selected = function(){
            var selected = path_selector.find('input:checked'),
                to_ret = {};
            KT.utils.each(selected, function(item){
                var data = $(item).data();
                if(!options.link_first || to_ret[data.node_id] === undefined){
                    to_ret[data.node_id] = { 'id' : data.node_id, name:data.node_name,
                            next_id:data.next_node_id};
                }
            });
            return to_ret;
        },
        get_paths = function(){
            var flattened = utils.flatten(environments),
                tmp_hash = {};
            if (options.link_first){
                KT.utils.each(flattened, function(item){
                    tmp_hash[item.id] = item;
                });
                return KT.utils.values(tmp_hash);
            }
            else{
                return flattened;
            }
        },
        recalc_scroll = function(){
           if(!options.expand){
               return false;
           }
           if(!options.inline){
               path_selector.show();
               scroll_obj.on('#' + KT.common.escapeId(paths_id));
               path_selector.hide();
           }
           else {
               scroll_obj.on('#' + KT.common.escapeId(paths_id));
           }
        },
        get_submit_event = function(){
            return options.submit_event;
        },
        get_cancel_event = function(){
            return options.cancel_event;
        },
        get_select_event = function(){
            return options.select_event;
        },
        clear_selected = function(){
            path_selector.find('input:disabled').removeAttr('disabled');
            unselect_nodes(path_selector.find('input:checked').hide());
        },
        set_selected = function(id) {
            var nodes = path_selector.find('.node_select'),
                first_nodes = path_selector.find('ul').find('li:first'),
                selected_node = path_selector.find('input:checkbox[data-node_id=' + id + ']');

            select_nodes(selected_node);

            if(options.select_mode === 'single'){
                unselect_nodes(nodes);
                select_nodes(selected_node);
            }
            if(options.link_first && selected_node.parents('li').is(':first-child')){
                select_nodes(first_nodes.find('input:checkbox').not(':checked'));
            }
        },
        select = function(id, next_id){
            var nodes = path_selector.find('input:checkbox[data-node_id=' + id + ']');

            if(nodes.length > 1 && !options.link_first){
                nodes.and('[data-next_node_id=' + next_id + ']').not(':checked').click();
            } else {
                nodes.first().not(':checked').click();
            }
        };

    init();

    return {
        get_paths   : get_paths,
        get_selected: get_selected,
        get_submit_event : get_submit_event,
        get_select_event : get_select_event,
        clear_selected: clear_selected,
        select:select,
        set_selected: set_selected,
        reposition_left: reposition_left,
        paths_id: paths_id,
        disable_all: disable_all,
        enable_all: enable_all,
        hide: function() {path_selector.hide();}
    };
};


KT.path_select_template = {
    selector : function(paths, div_id, submit_button_text, cancel_button_text, footer){
        var html = '<div id="' + div_id + '" class="path_selector"><form>';
        if(cancel_button_text){
            html += '<div class="action_buttons">';
            html += KT.path_select_template.button("KT_path_select_cancel_button", cancel_button_text);
        }
        if(submit_button_text){
            html += KT.path_select_template.button("KT_path_select_submit_button", submit_button_text);
            html += '</div>';
        }

        html += KT.path_select_template.paths(paths);

        html += '</form>';

        if( footer ){
            html += KT.path_select_template.footer(footer);
        }

        html += '</div>';
        return html;
    },
    button : function(clazz, text){
        return '<input type="button" class="button ' + clazz +'" value="' + text + '">';
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
        html += '<div><ul>';
        for(var i = 0; i < path.length; i += 1){
            html += KT.path_select_template.path_node(path[i], path[i+1]);
        }
        html += '</ul></div>';
        return html;
    },
    path_node: function(node, next){
        var html = '',
            next_node =  next  ? ('data-next_node_id="' + next.id + '"') : '',
            input = node.select ? '<span class="checkbox_holder"><input class="node_select" type="checkbox" ' +
                next_node +' data-node_id="' + node.id + '" data-node_name="' + node.name + '"></span>' : '';

        html += '<li data-node_id="' + node.id + '">'+ '<label><div>' + input +  node.name +  '</div></label></li>';
        return html;
    },
    footer : function(content){
        var html = '<footer>' + content + '</footer>';

        return html;
    }
};
