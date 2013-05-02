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

/*
 * User Options:
 *  breadcrumb { }  :   a hash making up the breadcrumb
 *  bbq_tag : the tag to use for this list for BBQ bookmarking/history
 *  default_tab : default entry in the hashtab to load upon initial page load
 *  prerender_cb : callback to happen just before rendering, once a new tab is selected
 *  tab_change_cb : callback to happen once a new tab is selected and rendered, the tab 'key' that was is the first paramter
 *  render_cb : callback to use for rendering if client_render is set to true in the crumb, the hash_id is
 *                      passed as a parameter, should return the html to display
 *  expand_cb : callback for extended scroll
 *  enable_search: enable search on init (before initial hashchange)
 */


KT.sliding_tree = KT.sliding_tree || {};
var sliding_tree = function(tree_id, options) {
    var container     = $('#' + tree_id),
        list         = container.find(".sliding_container .sliding_list"),
        breadcrumb     = container.find(".tree_breadcrumb"),
        sliders     = container.find('.sliders'),
        current_crumb,
        search;

    var prerender = function(id) {

            var crumb = settings.breadcrumb[id],

                newPanel = list.children('.no_content'),
                oldPanel = list.children('.has_content');

            settings.current_tab = id;
            settings.fetching = 0;
            reset_breadcrumb(id);

            //If we are really 'sliding' indicate what will actually have the content once we're done
            if (settings.direction) {
                oldPanel.removeClass("will_have_content");
                newPanel.addClass("will_have_content");
            }

            //If we aren't sliding, we only worry about 1 panel'
            if (!settings.direction) {
                newPanel = oldPanel;
            }

            settings.prerender_cb(id);

            render(id, newPanel);
        },
        render = function (id, newPanel) {
            if (settings.breadcrumb[id] === undefined) {
                id = settings.default_tab;
            }

            var crumb = settings.breadcrumb[id];

            if (search) {
                search.set_search_button_state(crumb);
                search.set_url(null);
            }

            if (crumb.client_render) {
                settings.render_cb(id, function(html) {
                        newPanel.html(html);
                        settings.tab_change_cb(id);
                        postrender(id);
                    });
            }
            else if (crumb.cache) { //If we are to use a cached copy, use it
                newPanel.html(crumb.content);
                settings.tab_change_cb(id);
                postrender(id);
            }
            else if (!crumb.searchable){
                    //Else fetch the data and place it in the new panel when we are done
                   //  we set fetching to the id, so once its done we know whether to actually
                   //  display the data, or throw it away.
                   // If the crumb is searchable, let the search module take care of this
                 settings.fetching = id;
                $.get(crumb.url, function(data) {
                    if (settings.fetching == id) {
                        newPanel.html(data.html ? data.html : data);
                        settings.fetching = 0;
                        settings.tab_change_cb(id);
                    }
                  });
                  postrender(id);
                  newPanel.html('<img src="' + KT.common.spinner_path() + '">');
            }
            else {
                search.set_url(crumb.url);
                $(document).trigger("slidingtree.initiatesearch");
                postrender(id);
            }
        },
        postrender = function(id) {
            var crumb = settings.breadcrumb[id],
                newPanel = list.children('.no_content'),
                oldPanel = list.children('.has_content');

            if (crumb.scrollable) {
                list.addClass("ajaxScroll");
                list.attr("data-scroll_url", crumb.url);
            }
            else {
                list.removeClass("ajaxScroll");
            }

            //If we have a direction, we need to slide
            if(settings.direction) {
                var leaving = settings.direction == "right" ? "left" : "right",
                    width = $('.sliding_container').width();
                //The old pane, we need to hide it away, remove the contents, and reset the classes


                if( leaving === 'left' ){
                    list.css({'left': 0});
                    oldPanel.after(newPanel);
                    list.animate({"left": -width}, 500,
                        function() {
                           oldPanel.html("");
                           oldPanel.removeClass("has_content");
                           oldPanel.addClass("no_content");
                           newPanel.addClass("has_content");
                           newPanel.removeClass("no_content");
                            $(document).trigger('tab_change_complete.slidingtree');
                       });
                } else {
                       list.css({'left': -width});
                       oldPanel.before(newPanel);
                       list.animate({"left": 0}, 500,
                        function() {
                           oldPanel.html("");
                           oldPanel.removeClass("has_content");
                           oldPanel.addClass("no_content");
                           newPanel.addClass("has_content");
                           newPanel.removeClass("no_content");

                            $(document).trigger('tab_change_complete.slidingtree');
                       });
                }


                settings.direction = undefined;
            }
        },
        content_clicked = function(link) {
            var element = link.find('.link_details');

            if(element.hasClass("slide_left")) {
              settings.direction = "left";
            }else {
              settings.direction = "right";
            }

            $(document).trigger('content_clicked.slidingtree');

            render_content(element.attr('id'));
        },
        render_content = function(id){
            var bbq = {};
            bbq[settings.bbq_tag] = id;
            if(search) {
                $.bbq.removeState(search.search_bbq());
            }
            $.bbq.pushState(bbq)
        },
        reset_breadcrumb = function(id) {
            var name;
            if (settings.breadcrumb[id] === undefined) {
                id = settings.default_tab;
            }
            var trail = settings.breadcrumb[id].trail,
                crumbs = trail,
                html = '<ul>';

            current_crumb = id;
            breadcrumb.html("");
            name = settings.breadcrumb[id].name;
            if (settings.breadcrumb[id].total_size){
                name += ' (' + settings.breadcrumb[id].total_size + ')';
            }


            if( settings.base_icon ){
                if( trail.length > 0) {
                    html += create_crumb(trail[0], undefined, settings.base_icon);
                } else {
                    html += create_crumb(id, true, settings.base_icon);
                }
                crumbs = trail.slice(1, trail.length);
            } else {
                if( trail.length === 0 ){
                    html += '<li class="fl"><span title="' + name + '" id="' + id +
                        '" class="currentCrumb one-line-ellipsis">' + name + '</span></li>';
                }
            }

            if( trail.length > 0){
                for(var i = 0; i < crumbs.length; i++) {
                    html += create_crumb(crumbs[i]);
                }
                html += '<li class="fl"><span title="' + name + '" id="' + id +
                    '" class="currentCrumb one-line-ellipsis">' + name + '</span></li>';
            }

            breadcrumb.append(html);
        },
        create_crumb = function(id, currentCrumb, icon) {
            var html = '<li class="slide_link fl">';
            var name = settings.breadcrumb[id].name;
            if (settings.breadcrumb[id].total_size){
                name += ' (' + settings.breadcrumb[id].total_size + ')';
            }

            if( icon ){
                if( currentCrumb ){
                    html += '<span title="' + name + '" class="crumb ' + icon + '">' + id + '</span>';
                } else {
                    html += '<span title="' + name + '" class="crumb ' + icon + '_inactive">' + id + '</span>';
                }
            }

            html += '<span title="' + name + '" class="one-line-ellipsis crumb link_details slide_left" id= "' + id + '">';

            if( !icon ){
                html += name;

            }

            html  += '</span>';

            if( currentCrumb === undefined ){
                html += '<span>\u2002\u00BB\u2002</span>';
            }

            return html + '</li>';
        },
        hash_change = function() {
            var newContent = $.bbq.getState(settings.bbq_tag) || settings.default_tab;
            if (settings.current_tab != newContent) {
                prerender(newContent);
                $(document).trigger('hashchange.' + tree_id, [newContent]);
            }
            else {
                signal_panel();
            }
        },
        reset_tree = function(new_breadcrumb) {
            // reset the current tree using a different breadcrumb.
            // this essentially allows us to use the same sliding tree w/ multiple sets of tree content
            settings.breadcrumb = new_breadcrumb;
            settings.current_tab = undefined;
            if ($.bbq.getState(settings.bbq_tag)) {
                // if the bbq tag already exists, remove it, triggering hash_change
                $.bbq.removeState(settings.bbq_tag);
            } else {
                // otherwise, render the content to the default tab
                render_content(settings.default_tab);
            }

            $.bbq.removeState(settings.bbq_tag);
            render_content(settings.default_tab);
        },
        signal_panel = function(){
            KT.panel.search_started();
        },
        setup_filter = function(){
             var bcs,
                 bcs_height = 0,
                 container,
                 container_height = 0,
                 filter_form = $('#filter_form'),
                 filter_input = $('#filter_input');

             filter_form.submit(function(){
                 filter_input.change();
                 return false;
             });

             $('#container .filter_button').toggle(
                 function() {
                     bcs = $('.breadcrumb_filter');
                     container = bcs.next();
                     container_height = container.height();
                     bcs_height = bcs.height();
                     container.animate({"height":container_height-40}, { duration: 200, queue: false });
                     bcs.animate({ "height": bcs_height+40}, { duration: 200, queue: false });
                     filter_input.css("margin-left", '4px');
                     filter_form.css("opacity", "0").show();
                     filter_form.animate({"opacity":"1"}, { duration: 200, queue: false });
                     filter_input.animate({"width": (bcs.width() - 60) + "px", "opacity":"1"}, { duration: 200, queue: false });
                     $(this).css({backgroundPosition: "-32px -16px"});
                     $(this).attr('title', i18n.close);

                     if( $('.remove_item').length ){
                         $('.remove_item').css({ top : 52 });
                     }

                     if( $('.close').length ){
                         $('.close').css({ top : 52 });
                     }
                 },function() {
                     filter_form.fadeOut("fast", function(){
                         container.animate({"height":container_height}, { duration: 200, queue: false });
                         bcs.animate({ "height": bcs_height }, "fast");
                         if( $('.remove_item').length ){
                             $('.remove_item').css({ top : 12 });
                         }
                         if( $('.close').length ){
                             $('.close').css({ top : 12 });
                         }
                     });
                     $(this).css({backgroundPosition: "0 -16px"});
                     $(this).attr('title', i18n.filter);
                     filter_input.val("").change();
                     $("#" + tree_id + " .has_content .filterable li").fadeIn('fast');
                 }
            ).tipsy({ fade : true, gravity : 's' });

             filter_input.live('change, keyup', function(){
                 if ($.trim($(this).val()).length >= 2) {
                     $("#" + tree_id + " .has_content .filterable li:not(:contains('" + $(this).val() + "'))").filter(':not').fadeOut('fast');
                     $("#" + tree_id + " .has_content .filterable li:contains('" + $(this).val() + "')").filter(':hidden').fadeIn('fast');
                 } else {
                     $("#" + tree_id + " .has_content .filterable li").fadeIn('fast');
                 }
             });
             filter_input.val("").change();
        },
        enable_search = function(){
            search = sliding_tree.search();
            search.init(this, list, options.expand_cb, settings.tab_change_cb);
        };

    var settings = {
          breadcrumb    : {},
          bbq_tag       : tree_id,
          default_tab   : "",
          current_tab   : undefined,
          direction     : undefined,
          base_icon     : false,
          tab_change_cb : function() {},
          prerender_cb  : function() {},
          render_cb     : function() {},
          fetching      : 0 //Used to control fetching, and ignore content when we've already mgirated off the page'
    };

    //Page items
    if ( options ) {
        $.extend( settings, options );
    }

    if( settings.enable_filter ){
        setup_filter();
    }

    if( settings.enable_float ){
        container.css('position', 'absolute');
        sliders.css('height', sliders.css('minHeight'));
    }


    $(window).unbind('hashchange.' + tree_id).bind( 'hashchange.' + tree_id, hash_change);

    //$(window).trigger( 'hashchange.' + tree_id );

    $('.crumb').tipsy({ fade : true, gravity : 's', live : true, delayIn : 500, hoverable : true, delayOut : 50 });
    $('.currentCrumb').tipsy({ fade : true, gravity : 's', live : true, delayIn : 500, hoverable : true, delayOut : 50 });
    $(document).bind('tab_change_complete.slidingtree', function(){
        $(document).trigger('close.tipsy');
    });

    container.find('.slide_link').live('click', function(event){
        if( event.target.nodeName === "A" ){
            return false;
        } else {
            content_clicked($(this));
        }
    });

    return {
        get_current_crumb    : function(){
            return current_crumb;
        },
        get_breadcrumbs     : function(){
            return settings.breadcrumb;
        },
        get_tree_id         : function(){
            return tree_id;
        },
        render_content        : render_content,
        rerender_content    : function() {
                render($.bbq.getState(settings.bbq_tag), list.children('.has_content'));
            },
        rerender_breadcrumb    : function() {
            reset_breadcrumb($.bbq.getState(settings.bbq_tag));
        },
        reset_tree         : reset_tree,
        enableSearch       : enable_search
    };
};

KT.sliding_tree.list = function(parent, bcs, sliding_tree){

    var current_items = 0,
    replace_list = function(html, args){
        if (!args || args === sliding_tree.get_current_crumb()){
            parent.children('.will_have_content').html(html);
        }
    },
    append = function(html, args) {

        if (!args || args === sliding_tree.get_current_crumb()){
            var expand_list = parent.find('.has_content').find('.expand_list');
            expand_list.append(html);
        }
    },
    update_counts = function(current, total, results, clear){
        if (clear){
            current_items = current;
            bcs.find('.current_items_count').text(current_items);
            bcs.find('.total_results_count').text(results);
            sliding_tree.get_breadcrumbs()[sliding_tree.get_current_crumb()].total_size = total;
            sliding_tree.rerender_breadcrumb();
        }
        else {
            current_items += current;
            bcs.find('.current_items_count').text(current_items);
        }
    },
    current_count = function(){
        return current_items;
    },
    full_spinner = function(){
        var panel = parent.children('.will_have_content');
        if (panel.length === 0){
            panel = parent.children('.has_content');
        }
        panel.html('<img src="' + KT.common.spinner_path() + '">');
    };

    return {
        replace_list  : replace_list,
        append        : append,
        update_counts : update_counts,
        full_spinner  : full_spinner,
        current_count : current_count
    }
};

sliding_tree.search = function(){
    var bcs,
        bcs_height = 0,
        search_form, search_input, search_button, search_box,
        breadcrumbs, search_obj,

        init = function(sliding_tree, parent, expand_cb, tabchange_cb){
            var tree_id = sliding_tree.get_tree_id();

            search_form = $('#search_form');
            search_input = $('#search_input');
            bcs = $('.breadcrumb_search');
            search_button = bcs.find('.search_button');
            search_box = bcs.find('.search_box');
            bcs_height = bcs.height();
            breadcrumbs = sliding_tree.get_breadcrumbs();

            search_obj = KT.search("search_form", "list", KT.sliding_tree.list(parent, bcs, sliding_tree),
                {disable_fancy: true, trigger_name:"slidingtree.initiatesearch",
                 pre_search_state:sliding_tree.get_current_crumb});

            $(document).bind(search_obj.search_event(), KT.panel.search_started);
            $(document).bind(search_obj.search_event(), function(e, promise){
                if (promise){
                    promise.done(function(){
                        tabchange_cb(sliding_tree.get_current_crumb());
                    });
                }
                else {
                  tabchange_cb(sliding_tree.get_current_crumb());
                }
            });

            if (expand_cb) {
                $(window).bind(search_obj.extend_event(), expand_cb);
            }

            search_button.toggle(
                 function() {
                    if( !search_button.hasClass('disabled') ){
                        open();
                    }
                 },function() {
                    if( !search_button.hasClass('disabled') ){
                        close();
                    }
                 }
            ).tipsy({ fade : true, gravity : 's' });
        },
        set_search_url = function(url) {
            search_obj.set_url(url);
        },
        set_search_button_state = function(current_crumb){
            toggle_search_button(current_crumb.searchable);
        },
        toggle_search_button = function(searchable){
            close();
            if( !searchable ){
                search_button.css({ backgroundPosition : "0 0" });
                search_button.addClass('disabled');
                search_button.attr('title', i18n.disabled_search);
            } else {
                search_button.css({backgroundPosition: "0 -16px"});
                search_button.removeClass('disabled');
                search_button.attr('title', i18n.search);
                //if there is a search, open the search bar
                if($.bbq.getState(search_obj.search_bbq())){
                    open();
                }
            }
        },
        open = function(){
             bcs.animate({ "min-height": bcs_height+40}, { duration: 200, queue: false });
             search_input.css("margin-left", '4px');
             search_box.css("opacity", "0").show();
             search_box.animate({"opacity":"1"}, { duration: 200, queue: false });
             search_input.animate({"width": (bcs.width() - 60) + "px", "opacity":"1"}, { duration: 200, queue: false });
             search_button.css({backgroundPosition: "-32px -16px"});
             search_button.attr('title', i18n.close);
        },
        close = function(){
             search_box.fadeOut("fast", function(){
                 bcs.animate({ "min-height" : bcs_height }, "fast");
             });
             search_button.css({ backgroundPosition : "0 -16px" });
             search_button.attr('title', i18n.search);
        };


    return {
        init    : init,
        open    : open,
        close   : close,
        set_url : set_search_url,
        search_bbq : function(){return search_obj.search_bbq()},
        set_search_button_state : set_search_button_state
    };
};

sliding_tree.ActionBar = function(toggle_list){
    var open_panel     = undefined,
        toggle_list    = toggle_list || {},

        toggle = function(id, options){
            var options = options || {};

            options.animate_time = 500;

            if( open_panel !== id && open_panel !== undefined ){
                options.opening = false;
                toggle_list[open_panel].setup_fn(options);

                $("#" + toggle_list[open_panel].container).slideToggle(options.animate_time, function(){
                    open_panel = id;
                    options.opening = true;
                    handle_toggle(options, id);
                });
            } else if( open_panel !== undefined ){
                open_panel = undefined;
                options.opening = false;
                handle_toggle(options, id);
            } else {
                open_panel = id;
                options.opening = true;
                handle_toggle(options, id);
            }
        },
        handle_toggle = function(options, id){
            var slide_window = $('#' + toggle_list[id].container);

            options = toggle_list[id].setup_fn(options);
            slide_window.slideToggle(options.animate_time, options.after_function);
        },
        close = function() {
            if( open_panel ){
                toggle(open_panel, { opening: false });
            }
        },
        reset = function(){
            close();
        },
        add_to_toggle_list = function(id, properties){
            if( toggle_list[id] !== undefined ){
                delete toggle_list[id];
            }
            toggle_list[id] = properties;
            register_toggle(id, properties);
        },
        register_toggle = function(id, properties){
           $('#' + properties.button).unbind('click').click(function() {
                if ($(this).hasClass('disabled')){
                    return false;
                }
                toggle(id, properties.options);
            });
           $('#' + properties.button).unbind('keypress').keypress(function(event) {
                   event.preventDefault();
                if ($(this).hasClass('disabled')){
                    return false;
                }
                if( event.which === 13 ){
                    toggle(id, properties.options);
                }
            });
        };

    $.each(toggle_list, function(item){
      register_toggle(item, toggle_list[item]);
    });

    $(document).bind('content_clicked.slidingtree', function(){
        close();
    });

    return {
        toggle              :  toggle,
        close               :  close,
        reset               :  reset,
        add_to_toggle_list  :  add_to_toggle_list
    };
};
