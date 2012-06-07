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

    KT.my_env_select = KT.path_select('my_env_selector', 'env', KT.available_environments,
        {select_mode:'multi', button_text:"Go", link_first: true});

    comparison_grid = KT.comparison_grid();
    comparison_grid.init();
    comparison_grid.add_columns(KT.my_env_select.get_paths());

    $(document).bind(KT.my_env_select.get_event(), function(event, environments) {
        comparison_grid.show_columns(environments);
    });

    KT.widgets = {repos:{id:"repos_selector", autocomplete:'repo_autocomplete_list'},
                    packages:{id:"packages_selector"},
                    products:{id:"products_selector", autocomplete:'product_autocomplete_list'},
                    errata:{id:"errata_selector", search:'errata_search'}};

    KT.mapping = {products:['products'], repos:['products', 'repos'], packages:['products', 'repos', 'packages'],
        errata:['products', 'repos', 'errata']};

    var search = KT.content_search();
});


KT.content_search = function(){
    var browse_box;
    var init = function(){
        browse_box = KT.widget.browse_box("content_selector", KT.widgets, KT.mapping);
        $(document).bind(browse_box.get_event(), submit);

    };
    var submit = function(e, search_params){
        var urls = {errata:KT.routes.errata_content_search_index_path(),
                    products:KT.routes.products_content_search_index_path()};
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
        ac_obj,
        ac_container,
        search_input,
    init = function(){
        container = $('#' + container_id);
        setup_search(search_id);
        setup_autocomplete(autocomplete_id)
    },
    setup_search = function(search_id){
        if (search_id){
            search_input = $('#' + search_id).find('input:text');
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
    auto_select = function(name, id){
        if(!id){
            return;
        }
        var list = ac_container.find('ul');
        list.find('.all').hide();
        if (ac_container.find('li[data-id=' + id + ']').length === 0){
            list.prepend('<li data-id="' + id + '">' + name + '<a class="remove">-</a></li>');
        }

    },
    get_results = function(){
        if(search_input){
            return {'search': search_input.val() };
        }
        else if(ac_obj){
           var ids = [];
           KT.utils.each(ac_container.find('li').not('.all'), function(item, index){
               ids.push($(item).data('id'));
           });
           return {autocomplete: ids};
        }
        else {
            return {}
        }
    };

    init();
    return {
      get_results: get_results
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
KT.widget.browse_box = function(selector_id, widgets, mapping){

    var selector,
        event_name, 
        init = function(){
            event_name = 'browse_box_' + selector_id;
            selector = $("#" + selector_id).find('select');
            selector.change(function(){
                change_selection($(this).val());
            });
            selector.change();
            selector.parents('form').submit(function(e){
                 e.preventDefault();
                 submit(selector.val());
            });
            KT.utils.each(widgets, function(widget, key){
                widget.finder = KT.widget.finder_box(widget.id, widget.search, widget.autocomplete);
            });
        },
        submit = function(content_type){
            var needed = mapping[content_type],
                query = {};
            KT.utils.each(needed, function(value, index){
                var type_search = {};
                query[value] = widgets[value].finder.get_results();
            });
            query.content_type = content_type;
            $(document).trigger(event_name, query);
        },
        change_selection = function(selected){
            var needed = mapping[selected],
                element;

            KT.utils.each(widgets, function(value, key){
                element = $('#' + value.id);
                if (KT.utils.include(needed, key)){
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
        get_event: function(){return event_name;}
    }
};



