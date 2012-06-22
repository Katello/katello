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

    KT.widgets = {repos:{id:"repos_selector", autocomplete:'repo_autocomplete_list', search:'repo_search'},
                  packages:{id:"packages_selector", autocomplete:'package_autocomplete_list', search:'package_search'},
                  products:{id:"products_selector", autocomplete:'product_autocomplete_list'},
                  errata:{id:"errata_selector", search:'errata_search'}};

    KT.mapping = {products:['products'], repos:['products', 'repos'], packages:['products', 'repos', 'packages'],
                    errata:['products', 'repos', 'errata']};

    var search = KT.content_search(KT.available_environments);

});


KT.content_search = function(paths){
    var browse_box, old_search_params, env_select, comparison_grid;
    var init = function(){
        var initial_search = $.bbq.getState('search'),
            initial_envs = $.bbq.getState('environments');

        comparison_grid = KT.comparison_grid();
        if(!initial_envs && paths[0]){
            initial_envs = [paths[0][0]] ;
        }
        env_select = KT.path_select('grid_env_selector', 'env', paths,
            {select_mode:'multi', button_text:"Go", link_first: true});

        comparison_grid.init();
        comparison_grid.add_columns(env_select.get_paths());

        browse_box = KT.widget.browse_box("content_selector", KT.widgets, KT.mapping, initial_search);
        $(document).bind(browse_box.get_event(), search_initiated);
        bind_search_event();

        $(document).bind(env_select.get_event(), function(event, environments) {
            $.bbq.pushState({environments:KT.utils.values(environments)});
            comparison_grid.show_columns(environments);
            env_select.reposition();
        });

        if (initial_envs) {
            select_envs(initial_envs);
        }
        if(initial_search){
            browse_box.trigger_search();
        }
    },
    search_initiated = function(e, search_params){
        var old_params = $.bbq.getState('search');
        $.bbq.pushState({search:search_params});
        search_params =  $.bbq.getState("search"); //refresh params, to get trim empty entries
        //A search was forced, but if everything was equal, nothing would happen, so force it
        if(KT.utils.isEqual(old_params, search_params)){
            do_search(search_params);
        }
    },
    /*
        select environments manually, from a list of environment objects
     */
    select_envs = function(environment_list){
        var env_obj = {};
        KT.utils.each(environment_list, function(env){
            env_obj[env.id] = env;
            env_select.select(env.id)
        });
        comparison_grid.show_columns(env_obj);
        env_select.reposition();
    },
    bind_search_event = function(){
        $(window).bind('hashchange.search', function(event) {
            var search_params = $.bbq.getState('search');
            if (search_params &&  !KT.utils.isEqual(old_search_params, search_params)) {

                do_search(search_params);
            }
        });
    },
    do_search = function(search_params){
        var urls = {errata:KT.routes.errata_content_search_index_path(),
                    repos:KT.routes.repos_content_search_index_path(),
                    products:KT.routes.products_content_search_index_path(),
                    packages:KT.routes.packages_content_search_index_path()};
        old_search_params = $.bbq.getState('search');
        if (urls[search_params.content_type] ){

            $.ajax({
                type: 'POST',
                contentType:"application/json",
                url: urls[search_params.content_type],
                data: JSON.stringify(search_params),
                success: handle_response
            })
        }
        else{
            console.log(search_params);
        }
    },
    handle_response = function(data){
        $(document).trigger('draw.comparison_grid', [data]);
    };


    init();
    return {
    }
};




/**
 *
 */ 
KT.widget.finder_box = function(container_id, search_id, autocomplete_id){


    var container,
        utils = KT.utils,
        ac_obj,
        ac_container,
        search_container,
        search_input,
    init = function(){
        container = $('#' + container_id);
        setup_search(search_id);
        setup_autocomplete(autocomplete_id)
        if(search_id && autocomplete_id){
            //if we have both, select one
            search_container.find('input:radio').click();
        }
    },
    setup_search = function(search_id){
        if (search_id){
            search_container = $('#' + search_id);
            search_input = search_container.find('input:text');
            search_container.find('input:radio').change(radio_search_select);
        }
    },
    setup_autocomplete = function(auto_id){
       if (!auto_id) {
          return;
       }       
       ac_container = $("#" + auto_id);
       ac_container.delegate('.remove', 'click', function(){
          $(this).parent().remove();
          if (ac_container.find('li').not('.all').length === 0){
            ac_container.find('.all').show();
          }
       });
       ac_container.find('input:radio').change(radio_auto_select);

       ac_obj = KT.auto_complete_box(
           {values:ac_container.data('url'),
            input: ac_container.find('input:text'),
            add_btn: ac_container.find('.button'),
            add_text: i18n.add,
            selected_input: ac_container.find('.hidden_selection'),
            add_cb: function(item, id, cleanup){
              auto_select(item, id);
              cleanup();
            }
       });

    },
    radio_search_select = function(){
        if(ac_container){
            ac_container.find('input:text').attr('disabled', 'disabled');
            ac_container.find('.button').attr('disabled', 'disabled');
            ac_container.find('ul').addClass('disabled');
        }    
        search_input.removeAttr('disabled');
    },
    radio_auto_select = function(){
        if(search_input){
            search_input.attr('disabled', 'disabled');
        }
        ac_container.find('input:text').removeAttr('disabled');
        ac_container.find('.button').removeAttr('disabled');
        ac_container.find('ul').removeClass('disabled');
    },
    auto_select = function(name, id){
        if(!id){
            return;
        }
        var list = ac_container.find('ul');
        list.find('.all').hide();
        if (ac_container.find('li[data-id=' + id + ']').length === 0){
            list.prepend('<li data-name="'+ name + '" data-id="' + id + '">' + name + '<a class="remove">-</a></li>');
        }

    },
    get_results = function(){
        if(search_input && !search_input.attr('disabled')){
            return {'search': search_input.val() };
        }
        else if(ac_obj){
           var ids = [];
           utils.each(ac_container.find('li').not('.all'), function(item, index){
               ids.push({id:$(item).data('id'), name: $(item).data('name')});
           });
           return {autocomplete: ids};
        }
        else {
            return {}
        }
    },
    set_results = function(results){
        if(!results){
            return;
        }
        if(search_input && results.search){
            search_input.val(results.search);
        }
        else if(ac_container && results.autocomplete){
            utils.each(results.autocomplete, function(item, index){
                auto_select(item.name, item.id);
            });
        }
    };
    

    init();
    return {
      get_results: get_results,
      set_results: set_results
    };
};


/**
 * Browse Box object
 * @param selector_id   -  id of selector for different widgets
 * @param widgets       -  list of hashes of widgets.  Format:
 *                             name {id: dom_id
 *                               object: object }
 * @param mapping       -  selector value to widget mapping
 *
 */
KT.widget.browse_box = function(selector_id, widgets, mapping, initial_values){

    var selector,
        utils = KT.utils,
        event_name, 
        init = function(){
            event_name = 'browse_box_' + selector_id;
            selector = $("#" + selector_id).find('select');
            selector.change(function(){
                change_selection($(this).val());
            });
            utils.each(widgets, function(widget, key){
                widget.finder = KT.widget.finder_box(widget.id, widget.search, widget.autocomplete);
            });

            selector.parents('form').submit(function(e){
                 e.preventDefault();
                 submit(selector.val());
            });

            if (initial_values && initial_values.content_type){
                selector.val(initial_values.content_type);
                utils.each(widgets, function(widget, key){
                    widget.finder.set_results(initial_values[key])
                });
            }
            selector.change();
        },
        trigger_search = function(){
            submit(selector.val());
        },
        submit = function(content_type){
            var needed = mapping[content_type],
                query = {};
            utils.each(needed, function(value, index){
                var type_search = {};
                query[value] = widgets[value].finder.get_results();
            });
            query.content_type = content_type;
            $(document).trigger(event_name, query);
        },
        change_selection = function(selected){
            var needed = mapping[selected],
                element;

            utils.each(widgets, function(value, key){
                element = $('#' + value.id);
                if (utils.include(needed, key)){
                    element.show();
                }
                else {
                    //clear data
                    element.hide();
                }
            });
        };
      

    init();
    return {
        change_selection: change_selection,
        trigger_search : trigger_search,
        get_event: function(){return event_name;}
    }
};



