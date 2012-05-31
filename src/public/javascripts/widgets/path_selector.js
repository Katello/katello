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
            options.library_select = options_in.library_select || true;
            options.inline = options_in.inline || false;
            options.select_mode = options_in.select_mode || 'none';

            div.append(KT.env_select_template.selector(environments, paths_id));
            path_selector = $("#" + paths_id);
            path_selector.find('input').hide();

            if(options.select_mode !== 'none'){
                setup_input_hover();
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
        setup_input_hover = function(){

            var anchors = path_selector.find('li');//.find('a');

            anchors.hover(function(){
                            var input = $(this).find('input');
                            if (!input.is(':visible')){
                                input.fadeIn(200);
                            }
                        },
                        function(){
                            var input = $(this).find('input');
                                if(!input.is(":checked")){
                                   input.fadeOut(200);
                                }
                        }

            );
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
        };



    init();


    return {


    };
};


KT.env_select_template = {
    selector : function(paths, new_div_id){
        var html = '<div id="' + new_div_id + '" class="path_selector">';
        html += KT.env_select_template.paths(paths);
        html += '</div>';
        return html;
    },
    paths : function(paths){
        var html ='';

        KT.utils.each(paths, function(item){
            html += KT.env_select_template.path(item);
        });
        return html ;
    },
    path : function(path){
        var html = '';
        html += '<ul>';
        KT.utils.each(path, function(env){
            html+= KT.env_select_template.environment(env);
        });
        html += '</ul>';
        return html;
    },
    environment : function(env){
        var html = '',
            input = env.select ? '<input type="checkbox">' : '';

        html += '<li data-env_id="' + env.id + '">'+ '<a><div>' + input + env.name + '</div></a></li>';
        return html;
    }
};

