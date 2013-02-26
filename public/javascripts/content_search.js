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
                  packages:{id:"packages_selector", search:'package_search'},
                  products:{id:"products_selector", autocomplete:'product_autocomplete_list'},
                  views:{id:"views_selector", autocomplete:'view_autocomplete_list'},
                  errata:{id:"errata_selector", search:'errata_search'}};

    KT.mapping = {products:['products'], repos:['products', 'repos'], packages:['products', 'repos', 'packages'],
                    errata:['products', 'repos', 'errata'], views:['views']};

    var search = KT.content_search(KT.available_environments);

    $('#content_selector select').chosen();

    Spinner({lines: 13, width: 4}).spin($('.large_spinner').get(0));
});



KT.content_search = function(paths_in){
    var browse_box, old_search_params, env_select, paths,
        cache = KT.content_search_cache,
        utils = KT.utils,
        comparison_grid,
    subgrids = {
        repo_packages:{id:'repo_packages',
                       name:i18n.packages,
                       url:KT.routes.repo_packages_content_search_index_path(),
                       cols:{description:{id:'description', name:i18n.description, span : "5"}},
                       selector:['repo_packages', 'repo_errata']

        },
        repo_errata  :{id:'repo_errata',
                       name:i18n.errata,
                       url:KT.routes.repo_errata_content_search_index_path(),
                       cols:{
                           title : {id:'title', name:i18n.title, span: "2"},
                           type  : {id:'type', name:i18n.type},
                           severity : {id:'severity', name:i18n.severity}
                         },
                        selector:['repo_packages', 'repo_errata']
        },
        compare_packages:{id:'compare_packages',
                           name:i18n.packages,
                           url:KT.routes.repo_compare_packages_content_search_index_path(),
                           selector:['compare_packages', 'compare_errata'],
                           modes: true
        },
        compare_errata:{id:'compare_errata',
                       name:i18n.errata,
                       url:KT.routes.repo_compare_errata_content_search_index_path(),
                       selector:['compare_packages', 'compare_errata'],
                       modes: true
        }
    },
    search_modes = [{id:'all', name:i18n.union},
                    {id:'shared', name:i18n.intersection},
                    {id:'unique', name:i18n.difference}
                   ],
    search_pages = {errata:{url:KT.routes.errata_content_search_index_path(), modes:true},
                    repos:{url:KT.routes.repos_content_search_index_path(), modes:true, comparable:true},
                    products:{url:KT.routes.products_content_search_index_path(), modes:true},
                    views:{url:KT.routes.views_content_search_index_path(), modes:true},
                    packages:{url:KT.routes.packages_content_search_index_path(), modes:true}
    },
    more_results_urls = {
        errata:   {method:"POST", url:KT.routes.errata_items_content_search_index_path(), include_search:true},
        packages: {method:"POST", url:KT.routes.packages_items_content_search_index_path(), include_search:true},
        repo_packages:{method:"GET", url:KT.routes.repo_packages_content_search_index_path(), include_search:false},
        repo_errata: {method:"GET", url:KT.routes.repo_errata_content_search_index_path(), include_search:false},
        compare_packages: {method:"GET", url:KT.routes.repo_compare_packages_content_search_index_path(), include_search:false},
        compare_errata: {method:"GET", url:KT.routes.repo_compare_errata_content_search_index_path(), include_search:false}
    };


    var init = function(){
        var initial_search = $.bbq.getState('search'),
            footer;
        paths = paths_in;
        
        if( KT.permissions.current_organization.editable ){
            footer = $('<a/>', { "href" : KT.routes.organizations_path('#panel=organization_' + KT.permissions.current_organization['id'] + '&panelpage=edit')});
            footer.append($('<i/>', { "class" : "gears_icon", "data-change_on_hover" : "dark" }));
            footer.append($('<span/>').html(i18n.manage_environments));
            footer = footer[0].outerHTML;
        } else {
            footer = "";
        }

        env_select = KT.path_select('column_selector', 'env', paths,
            {select_mode:'multi', link_first: true, footer: footer });
        env_select.reposition_left(); 
        init_tipsy();

        comparison_grid = KT.comparison_grid();
        comparison_grid.init();
        comparison_grid.controls = comparison_grid.controls();
        comparison_grid.set_columns(env_select.get_paths(), true);

        browse_box = KT.widget.browse_box("content_selector", KT.widgets, KT.mapping, initial_search);
        $(document).bind(browse_box.get_event(), search_initiated);

        select_envs(get_initial_environments());

        bind_search_event();
        bind_env_events();
        bind_hover_events();
        bind_load_more_event();
        bind_selectors();
        bind_repo_comparison();

        $(document).bind('return_to_results.comparison_grid', remove_subgrid);


        if(initial_search){
            search_initiated(initial_search);
        }
    },
    get_initial_environments = function(){
        var env_ids = get_initial_environment_ids(),
            to_ret = {};

        KT.utils.each(paths, function(path){
           KT.utils.each(path, function(env){
              if(KT.utils.include(env_ids, env.id.toString())){
                  to_ret[env.id] = env;
              }
           });
        });
        to_ret = KT.utils.values(to_ret);

        return to_ret;
    },
    get_initial_environment_ids = function(){
        var env_ids = $.bbq.getState('envs');
        if(!env_ids && paths[0]){
            KT.utils.each(paths[0], function(item){
               if(!env_ids && item.select){
                   env_ids = [item.id.toString()];
               }
            });
        }
        else if(!env_ids) {
            return [];
        }
        return env_ids;
    },
    search_initiated = function(e, search_params){ //'go' button was clicked
        var old_params = $.bbq.getState('search');
        KT.content_search_cache.clear_state();
        $.bbq.pushState({search:search_params, subgrid:{}, envs:get_initial_environment_ids()}); //Clear the subgrid
        search_params =  $.bbq.getState("search"); //refresh params, to get trim empty entries
        //A search was forced, but if everything was equal, nothing would happen, so force it
        if(utils.isEqual(old_params, search_params)){
            do_search(search_params);
        }
    },
    select_envs = function(environment_list){
        var env_obj = {};

        utils.each(environment_list, function(env){
            env_obj[env.id] = env;
            env_select.select(env.id)
        });
        comparison_grid.show_columns(env_obj);
    },
    bind_load_more_event = function(){
      $(document).bind('load_more.comparison_grid', function(event){
        var search = $.bbq.getState('search'),
            data_out = event.cell_data,
            type = search.content_type;
            ajax_type = undefined; 
        if (search.subgrid && search.subgrid.type){
            type = search.subgrid.type;
        }

        data_out.offset = event.offset;
        if(more_results_urls[type].include_search){ 
            data_out = utils.extend(data_out, search);
            ajax_type = "application/json";
            data_out = JSON.stringify(data_out);
        }
        $.ajax({
          type: more_results_urls[type].method,
          contentType:ajax_type,
          url: more_results_urls[type].url,
          cache: false,
          data: data_out,
          success: function(data){
            $(document).trigger('show_more.comparison_grid', [data.rows]);
            close_tipsy();
          }
        })
      });
    },
    bind_search_event = function(){
        $(window).bind('hashchange.search', function(event) {
            var search_params = $.bbq.getState('search');
            if (!utils.isEqual(old_search_params, search_params)) {
                do_search(search_params);
            }
        });
    },
    do_search = function(search_params){

        old_search_params = $.bbq.getState('search');
        
        if (search_params === undefined){
            draw_grid([]);
        }
        else if(search_params.subgrid && subgrids[search_params.subgrid.type]){
            subgrid_search(search_params);
        }
        else if (search_pages[search_params.content_type] ){
            main_search(search_params);
        }
    },
    main_search = function(search_params){
        var options = {};
        close_tipsy();

        options.show_compare_btn = search_pages[search_params.content_type].comparable;


        search_params = populate_state(search_params);

        if (cache.get_state(search_params)){
            comparison_grid.import_data(cache.get_state(search_params));
            comparison_grid.set_mode("results", options);
            select_envs(get_initial_environments());
        }
        else {
            $(document).trigger('loading.comparison_grid');
            $.ajax({
                type: 'POST',
                contentType:"application/json",
                url: search_pages[search_params.content_type].url,
                data: JSON.stringify(search_params),
                success: function(data){
                    if (search_pages[search_params.content_type].modes){
                        options.right_selector = true;
                        comparison_grid.set_right_select(search_modes, search_params.mode || search_modes.first.id);
                    }

                    comparison_grid.set_columns(env_select.get_paths());
                    select_envs(get_initial_environments());
                    comparison_grid.set_title(data.name);
                    comparison_grid.set_mode("results", options);
                    draw_grid(data.rows);
                    cache.save_state(comparison_grid, search_params);
                }
            });
        }
    },
    subgrid_search = function(search_params){
        var type = search_params.subgrid.type,
            subgrid = subgrids[search_params.subgrid.type];
        close_tipsy();
        comparison_grid.controls.comparison.hide();
        $(document).trigger('loading.comparison_grid');
        $.ajax({
            type: 'GET',
            contentType:"application/json",
            url: subgrid.url,
            cache: false,
            data: search_params.subgrid,
            success: function(data){
                var options = {left_selector:true};
                if(subgrid.modes){
                    options.right_selector = true;
                    comparison_grid.set_right_select(search_modes, search_params.subgrid.mode);
                }

                var cols = data.cols ? data.cols : subgrid.cols;
                comparison_grid.set_mode("details", options);
                comparison_grid.set_columns(cols);
                comparison_grid.show_columns(cols);
                comparison_grid.set_title(data.name);
                comparison_grid.set_left_select(subgrid_selector_items(type), type);
                draw_grid(data.rows);
            }
        });
    },
    populate_state = function(search_params){
        /**
         * Populate the search params with extra data needed for querying and
         *   for saving cache
         */
        if (search_params === undefined){
            return undefined;
        }
        if (search_params.mode === undefined){
            search_params.mode = search_modes[0].id;
        }
        search_params.environments = [];
        utils.each(get_initial_environments(), function(item){
            search_params.environments.push(item.id);
        });
        return search_params;
    },
    close_tipsy = function(){
      $(document).trigger("close.tipsy");
    },
    draw_grid = function(data){
        comparison_grid.set_rows(data, true);
    },
    bind_hover_events = function(){
        var grid = $('#comparison_grid');
        grid.delegate(".subgrid_link", 'click', function(){
            var search = $.bbq.getState('search');
            search.subgrid = $(this).data();
            $.bbq.pushState({search:search});
        }, 'json');
    },
    bind_repo_comparison = function(){
        $(document).bind('compare.comparison_grid', function(event){
            var formatted = [],
                search = $.bbq.getState('search');
            if(event.selected.length  === 0){
                return;
            }
            utils.each(event.selected, function(item){
                formatted.push({env_id:item.col_id, repo_id:item.row_id.split('_')[1]})
            });
            search.subgrid = {
                type: 'compare_packages',
                repos: formatted
            };
            $.bbq.pushState({search:search});
        });
    },
    bind_env_events = function(){
        var envs_changed = false;
        //submit event
        $(document).bind(env_select.get_submit_event(), function(event, environments) {
            var search = $.bbq.getState('search');
            if (envs_changed && search && search.mode && search.mode !== 'all'){
                search_initiated(undefined, search);
                envs_changed = false;
            }
            cache.save_state(comparison_grid, populate_state(search));
        });
        //select event
        $(document).bind(env_select.get_select_event(), function(event){
            var environments = env_select.get_selected(),
                env_ids = KT.utils.keys(environments);

            comparison_grid.show_columns(environments);
            $.bbq.pushState({envs:env_ids});
            envs_changed = true;
        });
    },
    bind_selectors = function(){
        $(document).bind('left_select.comparison_grid', function(event){
            change_subgrid_type(event.value);
        });
        $(document).bind('right_select.comparison_grid', function(event){
            change_grid_mode(event.value);
        });        
    },
    change_subgrid_type = function(type){
        var search = $.bbq.getState('search');
        if(search.subgrid){
            search.subgrid.type = type;
            $.bbq.pushState({search:search});
        }
    },
    change_grid_mode = function(mode){
        var search = $.bbq.getState('search');
        if(search.subgrid){
            search.subgrid.mode = mode;
        }
        else {
            search.mode = mode;
        }
        $.bbq.pushState({search:search});
    },
    remove_subgrid = function(){
        var search = $.bbq.getState('search');
        if(search.subgrid){
            delete search['subgrid'];
            $.bbq.pushState({search:search});
        }
    },
    init_tipsy = function(){
        var find_text = function(){ return $(this).find('.hidden-text').html();};
        $('.browse_tipsy').tipsy({html:true, gravity:'w', className:'content-tipsy',
            title:find_text});
        $('.view_tipsy').tipsy({html:true, gravity:'s', className:'content-tipsy',
                    title:find_text});
        KT.tipsy.custom.url_tooltip($('.tipsify-errata'), 'w');

    },
    subgrid_selector_items = function(type) {
        var to_ret = [],
            items = subgrids[type].selector;
        utils.each(items, function(item){
            to_ret.push(subgrids[item]);
        });
        return to_ret;
    };

    init();

    return {
        change_subgrid_type:change_subgrid_type,
        remove_subgrid: remove_subgrid,
        get_initial_environments: get_initial_environments,
        get_initial_environment_ids:get_initial_environment_ids,
    }
};

/**
 * Singleton for caching search data
 */
KT.content_search_cache = (function(){
    var utils = KT.utils,
        saved_search = undefined,
        saved_data = undefined;

    var save_state = function(grid, search){
        saved_search = $.extend(true, {}, search);
        saved_data = grid.export_data();
    },
    get_state = function(search){
        if(utils.isEqual(search, saved_search)){
            return saved_data;
        }
    },
    clear_state = function(){
        saved_search = undefined;
        saved_data = undefined;
    },
    get_data = function(){ return saved_data};
    return {
      save_state: save_state,
      get_state: get_state,
      clear_state: clear_state,
      get_data: get_data  
    };
}());




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
            require_select: true,
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
            list.prepend('<li data-name="'+ name + '" data-id="' + id + '"><i class="remove x_icon-black clickable"/><span>' + name + '</span></li>');
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
            get_submit_btn().val(i18n.refresh_results);
        },
        get_submit_btn = function(){
            return selector.parents('form').find('input[type=submit]');
        },
        change_selection = function(selected){
            var needed = mapping[selected],
                element;
            get_submit_btn().val(i18n.search);
             
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



