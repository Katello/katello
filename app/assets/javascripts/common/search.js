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


KT.favorite = function(form, input) {
    var success =  function(data) {
            form.find(".qdropdown").html(data);

            // process the elements of the list and truncate any that are too long with ellipsis (...) (e.g. jquery.text-overflow.js)
            $(".one-line-ellipsis").ellipsis();
        },
        error =  function(data) {
        },
        save = function(event) {
            // we want to submit the request using Ajax (prevent page refresh)
            event.preventDefault();

            var newFavorite = form.find('input').attr('value');
            var url = $(this).attr('data-url');

            // send a request to the server to save/create this favorite
            $.ajax({
                type: "POST",
                url: url,
                data: {"favorite": newFavorite},
                cache: false,
                success: success,
                error: error
            });

        },
        destroy = function (data) {
            var id  = $(this).attr('data-id');
            var url = $(this).attr('data-url');

            // send a request to the server to save/create this favorite
            client_common.destroy(url, success, error);
        },
        clear = function(data){
            var search_input = form.find('input');
            search_input.val('');
            search_input.change();
            form.find('.qdropdown').hide();
        };


    return {
        save: save,
        destroy: destroy,
        clear: clear

    }
};

/**
 *
 * @param input_id  id of the search input
 * @param list_id   id of the list
 * @param list_module  module that provides the following api:
 *      replace_list(html, args) //insert a new list
 *      append(html)       //append new data to the list
 *      update_counts(current, total, results, clear) //update counts
 *      full_spinner()    //clear list and show full list spinner (for full list reload/search)
 *      current_count()  //returns # of items in list (used for offset)
 *
 * @param params   list of options:
 *          disable_fancy  - disable fancy queries
 *
 * @param extra_params list of extra parameters to pass along with search
 */
KT.search = function(form_id, list_id, list_module, params, extra_params){

    var form = $('#' + form_id),
    input = form.find('input'),
    list_elem = $('#' + list_id),
    url = params.url,
    search_key = "_search",
    search_hash = list_id + search_key,
    event_name = list_id + ".search",
    extend_event_name = list_id + ".search.extend",
    url_param = "search",
    favorite = KT.favorite(form, input),
    current_search = {},
    retrievingNewContent = false,
    trigger_name = params.trigger || "hashchange", //custom event to trigger search
    extra_params,


    init = function(){

        $(window).scroll(extend);
        $(window).bind(trigger_name, hash_change);

        if (!params.disable_fancy) {
            form.fancyQueries();
        }

        setupSearch();
        //TODO make these classes
        form.delegate('#search_favorite_save', "click", favorite.save);
        form.delegate('#search_favorite_destroy', "click", favorite.destroy);
        form.delegate('#search_clear', "click", favorite.clear);
        form.delegate('.search_query', 'click', function(){
    		input.val($(this).html());
    		form.find('button').click();
    		form.find('.qdropdown').hide();
    	});

        reset_current_search();

    },
    search_bbq = function(){
      return search_hash;
    },
    search_event = function(){
        return event_name;
    },
    extend_event = function(){
        return extend_event_name;
    },
    hash_change = function(event, args){
        if (url){
            start_search(args);
        }
    },
    set_url = function(url_in){
        if (url != url_in){
            reset_current_search();
            url = url_in;
        }
    },
    reset_current_search = function(){
        current_search = {};
        current_search[search_hash] = null;
    },
    refresh_search = function() {
        reset_current_search();
        start_search({});
    },
    setupSearch = function() {
        var button = form.find('button');
        button.click(function(){
            var value = input.val();
            if( button.attr('disabled') !== "disabled" ){
                if( value === "" ){
                    $.bbq.removeState(search_hash);
                } else {
                    var obj = {};
                    obj[search_hash] = value;
                    $.bbq.pushState(obj);
                }
            }
        });
        input.live('change', function(){
            if( $(this).val() === "" ){
                $.bbq.removeState(search_hash);
            }
        }).live('keypress', function(event){
                if( event.keyCode === 13 ){
                    event.preventDefault();
                    button.click();
                    return false;
                }
        });

        form.live('submit', function(e){
            e.preventDefault();
            start_search();
        });
    },
    start_search = function(args){
        var button = form.find('button'),
            data = get_params(),
            search_val = $.bbq.getState(search_hash),
            event = $.Deferred(),
            pre_state,
            params_changed = function(){
                var changed = KT.utils.all(current_search, function(item, index){
                    return item === $.bbq.getState(index);
                });
                return !changed;
            };

        if (params.pre_search_state){
            pre_state = params.pre_search_state();
        }

        //search already in process, or already searched for
        if ( !params_changed() ){
            $(document).trigger(event_name);
            return;
        }

        current_search[search_hash] = search_val;
        input.val(search_val);

        $(document).trigger(event_name, [event.promise()]);

        list_module.full_spinner();
        button.attr("disabled", "disabled");

        if(search_val) {
            data[url_param] = search_val;
        }

        if (extra_params) {
            $.each(extra_params, function(index, item){
                var item_id = item['hash_id'];

                data[item_id] = $.bbq.getState(item_id);
                current_search[item_id] = $.bbq.getState(item_id);
            });
        }

        $.ajax({
            url: url,
            data: data,
            cache: false,
            success: function (data) {
                var to_append = data.html ? data.html : data;
                list_module.replace_list(to_append, pre_state);
                button.removeAttr('disabled');
                list_module.update_counts(data['current_items'], data['total_items'], data['results_count'], true, pre_state);

                $('.ui-autocomplete').hide();
                list_elem.addClass("ajaxScroll");
                event.resolve();
            },
            error: function (e) {
                button.removeAttr('disabled');
                event.fail();
            }
        });
    },
    get_params = function(){
         return KT.panel.queryParameters();
    },
    extend = function(){
        var offset = list_module.current_count(),
            page_size = list_elem.attr("data-page_size"),
            search = $.bbq.getState(search_hash),
            pre_state = params.pre_search_state ? params.pre_search_state() : undefined,
            ajax_params = {
                "offset": offset
            },
            expand_list = list_elem.hasClass("expand_list") ? list_elem : list_elem.find(".expand_list");

        if (!url) {
            return;
        }

        if (list_elem.hasClass("ajaxScroll") && !retrievingNewContent && KT.common.scrollTop() >= ($(document).height() - $(window).height()) - 700) {
            retrievingNewContent = true;
            if (parseInt(page_size) > parseInt(offset)) {
                return; //If we have fewer items than the pagesize, don't try to fetch anything else
            }

            $.extend(ajax_params, get_params());
            if (search) {
                $.extend(ajax_params, {search:search});
            }
            expand_list.append('<div class="list-spinner"> <img src="' + KT.common.spinner_path() + '" class="ajax_scroll">  </div>');

            $.ajax({
                type: "GET",
                url: url,
                data: ajax_params,
                cache: false,
                success: function (data) {
                    retrievingNewContent = false;
                    expand_list.find('.list-spinner').remove();
                    list_module.append(data['html'], pre_state);
                    if (data['current_items'] + offset >= data["total_items"]) {
                        list_elem.removeClass("ajaxScroll");
                    }
                    list_module.update_counts(data['current_items'], 0, 0);
                    $(window).trigger(extend_event_name);
                },
                error: function () {
                    expand_list.find('.list-spinner').remove();
                    retrievingNewContent = false;
                }
            });
        }
    },
	enableAutoComplete = function(params){
        var url = params['url'],
            data = params['data'],
		    request_issued = false,
            getAutoCompleteData;

            if(url) {
                getAutoCompleteData = function(request, response){
                    if( !request_issued ){
                        request_issued = true;
                        $.getJSON(url, { search	: request.term },
                            function(json){
                                request_issued = false;
                                response(json);
                            })
                            .error(function(){
                                request_issued = false;
                            });
                    }
                };
            }
            else {
                getAutoCompleteData = data;
            }
        autocomplete_override();
        input.catcomplete({
            source	: getAutoCompleteData,
            minLength: 0,
            delay	: 200,
            search	: function(event, ui) { $(".auto_complete_clear").hide(); },
            open	: function(event, ui) { $(".auto_complete_clear").show(); }
        });

        input.focus(function( event ) {
            if( $( this )[0].value == "" ) {
                $( this ).catcomplete( "search" );
            }
        });
	},
    autocomplete_override = function(){
        $.widget( "custom.catcomplete", $.ui.autocomplete, {
            _renderMenu: function( ul, items ) {
                var self = this,
                    currentCategory = "";

                $.each( items, function( index, item ) {
                    if ( item.category != undefined && item.category != currentCategory ) {
                        ul.append( "<li class='ui-autocomplete-category'>" + item.category + "</li>" );
                        currentCategory = item.category;
                    }
                    if ( item.error != undefined ) {
                        ul.append( "<li class='ui-autocomplete-error'>" + item.error + "</li>" );
                    }
                    if( item.completed != undefined ) {
                        $( "<li></li>" ).data( "item.autocomplete", item )
                            .append( "<a>" + "<strong class='ui-autocomplete-completed'>" + item.completed + "</strong>" + item.part + "</a>" )
                            .appendTo( ul );
                        } else {
                            self._renderItem( ul, item );
                        }
                });
            }
        });
    };


    init();

	return {
		enableAutoComplete	: enableAutoComplete,
        search_event : search_event,
        extend_event : extend_event,
        search_bbq   : search_bbq,
        set_url      : set_url,
        refresh_search : refresh_search
	};

};
