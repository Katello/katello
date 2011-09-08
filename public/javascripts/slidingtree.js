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

/*
 * User Options:
 *  breadcrumb { }  :   a hash making up the breadcrumb
 *  bbq_tag : the tag to use for this list for BBQ bookmarking/history
 *  default_tab : default entry in the hashtab to load upon initial page load
 *  prerender_cb : callback to happen just before rendering, once a new tab is selected
 *  tab_change_cb : callback to happen once a new tab is selected and rendered, the tab 'key' that was is the first paramter
 *  render_cb : callback to use for rendering if client_render is set to true in the crumb, the hash_id is
 *                      passed as a parameter, should return the html to display
 */

var sliding_tree = function(tree_id, options) {
    var container = $('#' + tree_id),
        list = container.find(".sliding_container .sliding_list"),
        breadcrumb = container.find(".tree_breadcrumb"),
        current_crumb;

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
            var crumb = settings.breadcrumb[id];
    
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
            else { //Else fetch the data and place it in the new panel when we are done
                   //  we set fetching to the id, so once its done we know whether to actually
                   //  display the data, or throw it away.
                 settings.fetching = id;
                $.get(crumb.url, function(data) {
                    if (settings.fetching == id) {
                        newPanel.html(data);
                        settings.fetching = 0;
                        settings.tab_change_cb(id);
    
                    }
                  });
                  postrender(id);
                  newPanel.html("<img src='images/spinner.gif' >");
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
            render_content(element.attr('id'));
        },
        render_content = function(id){
            var bbq = {};
            bbq[settings.bbq_tag] = id;
            $.bbq.pushState(bbq);        
        },
        reset_breadcrumb = function(id) {
            var trail = settings.breadcrumb[id].trail,
                crumbs = trail,
                html = '<ul>';
            
            current_crumb = id;
            breadcrumb.html("");
            
            if( settings.base_icon ){
                if( trail.length > 0) {
                    html += create_crumb(trail[0], undefined, settings.base_icon);
                } else {
                    html += create_crumb(id, true, settings.base_icon);
                }
                crumbs = trail.slice(1, trail.length);
            } else {
                if( trail.length === 0 ){
                    html += '<li><div id="' + id + '" class="currentCrumb fl">' + settings.breadcrumb[id].name + '</div></li>';
                }
            }
    
            if( trail.length > 0){
                for(var i = 0; i < crumbs.length; i++) {
                    html += create_crumb(crumbs[i]);
                }
                html += '<li><div id="' + id + '" class="currentCrumb fl">' + settings.breadcrumb[id].name + '</div></li>';
            }
            
            breadcrumb.append(html);
        },
        create_crumb = function(id, currentCrumb, icon) {
            var html = '<li class="slide_link">';
    
            if( icon ){
                if( currentCrumb ){
                    html += '<div class="' + icon + ' fl">' + id + '</div>';
                } else {
                    html += '<div class="' + icon + '_inactive fl">' + id + '</div>';
                }
            }
    
            html += '<div class="fl crumb link_details slide_left" id= "' + id + '">';
    
            if( !icon ){
                html += settings.breadcrumb[id].name;
            }
            if( currentCrumb === undefined ){
                html += "\u2002\u00BB\u2002";
            }
    
            return html + '</div></li>';
        },
        hash_change = function() {
            var newContent = $.bbq.getState(settings.bbq_tag) || settings.default_tab;
            if (settings.current_tab != newContent) {
                prerender(newContent);
            }
        },
        setupSearch = function(){
             var bcs = null,
                 bcs_height = 0,
                 search_form = $('#search_form'),
                 search_filter = $('#search_filter');
             
             search_form.submit(function(){
                 search_filter.change();
                 return false;
             });
             
             $('.search_button').toggle(
                 function() {
                     bcs = $('.breadcrumb_search');
                     bcs_height = bcs.height();
                     bcs.animate({ "height": bcs_height+40}, { duration: 200, queue: false });
                     search_filter.css("margin-left", 0);
                     search_form.css("opacity", "0").show();
                     search_form.animate({"opacity":"1"}, { duration: 200, queue: false });
                     search_filter.animate({"width":"420px", "opacity":"1"}, { duration: 200, queue: false });
                     $(this).css({backgroundPosition: "-32px -16px"});
                     
                     if( $('.remove_item').length ){
                         $('.remove_item').css({ top : 52 });
                     }
                     
                     if( $('.close').length ){
                         $('.close').css({ top : 52 });
                     }
                 },function() {
                     search_form.fadeOut("fast", function(){
                         bcs.animate({ "height": bcs_height }, "fast");
                         if( $('.remove_item').length ){
                             $('.remove_item').css({ top : 12 });
                         }
                         if( $('.close').length ){
                             $('.close').css({ top : 12 });
                         }
                     });
                     $(this).css({backgroundPosition: "0 -16px"});
                     search_filter.val("").change();
                     $("#" + tree_id + " .has_content .filterable li").fadeIn('fast');
                 }
             );
             
             search_filter.live('change, keyup', function(){
                 if ($.trim($(this).val()).length >= 2) {
                     $("#" + tree_id + " .has_content .filterable li:not(:contains('" + $(this).val() + "'))").filter(':not').fadeOut('fast');
                     $("#" + tree_id + " .has_content .filterable li:contains('" + $(this).val() + "')").filter(':hidden').fadeIn('fast');
                 } else {
                     $("#" + tree_id + " .has_content .filterable li").fadeIn('fast');
                 }
             });
             search_filter.val("").change();
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
    
    if( settings.enable_search ){
        setupSearch();
    }

    $(window).unbind('hashchange.' + tree_id).bind( 'hashchange.' + tree_id, hash_change);
    $(window).trigger( 'hashchange.' + tree_id );

    container.find('.slide_link').live('click', function(event){
        if( event.target.nodeName === "A" ){
            return false;
        } else {
            content_clicked($(this));   
        }
    });

    return {
    	get_current_crumb	: function(){
    		return current_crumb;
    	},
        render_content		: render_content,
        rerender_content	: function() {
                render($.bbq.getState(settings.bbq_tag), list.children('.has_content'));
            },
        rerender_breadcrumb	: function() {
            reset_breadcrumb($.bbq.getState(settings.bbq_tag));
        }
    };
};

sliding_tree.ActionBar = function(toggle_list){
    var open_panel = undefined,
        
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
        add_to_toggle_list = function(addon){
            if( toggle_list[addon] !== undefined ){
                delete toggle_list[addon];
            }
            $.extend(toggle_list, addon);
        };
        
    return {
        toggle              :  toggle,
        close               :  close,
        reset               :  reset,
        add_to_toggle_list  :  add_to_toggle_list
    };
};
