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
        breadcrumb = container.find(".tree_breadcrumb");

    var prerender = function(id) {
        settings.current_tab = id;
        settings.fetching = 0;
        reset_breadcrumb(id);
        var crumb = settings.breadcrumb[id];
        var newPanel = list.children('.no_content');
        var oldPanel = list.children('.has_content');

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

    };
    var render = function (id, newPanel) {
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
              newPanel.html("<img src='/images/spinner.gif' >");
        }
    };
    var postrender = function(id) {
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
            var leaving = settings.direction == "right"? "left" : "right";
            //The old pane, we need to hide it away, remove the contents, and reset the classes

            var width = 448;
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
    };

    var content_clicked = function(link) {
        var element = link.find('.link_details');
        
        if(element.hasClass("slide_left")) {
          settings.direction = "left";
        }else {
          settings.direction = "right";
        }
        render_content(element.attr('id'));
    };
    var render_content = function(id){
        var bbq = {};
        bbq[settings.bbq_tag] = id;
        $.bbq.pushState(bbq);        
    };
    var reset_breadcrumb = function(id) {
        var trail = settings.breadcrumb[id].trail,
            crumbs = trail,
            html = '<ul>';
        
        breadcrumb.html("");
        
        if( settings.base_icon ){
            if( trail.length > 0) {
                html += create_crumb(trail[0], undefined, settings.base_icon);
            } else {
                html += create_crumb(id, true, settings.base_icon);
            }
            crumbs = trail.slice(1, trail.length);
        }

        if( trail.length > 0){
            for(var i = 0; i < crumbs.length; i++) {
                html += create_crumb(crumbs[i]);
            }
            html += '<li><div id="' + id + '" class="currentCrumb fl">' + settings.breadcrumb[id].name + '</div></li>';
        }
        
        breadcrumb.append(html);
    };
    var create_crumb = function(id, currentCrumb, icon) {
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
    };
    var hash_change = function() {
        var newContent = $.bbq.getState(settings.bbq_tag) || settings.default_tab;
        if (settings.current_tab != newContent) {
            reset_breadcrumb(newContent);
            prerender(newContent);
        }
    };

    var settings = {
          breadcrumb : {},
          bbq_tag : tree_id,
          default_tab : "",
          current_tab: undefined,
          direction  : undefined,
          base_icon: false,
          tab_change_cb: function() {},
          prerender_cb: function() {},
          render_cb: function() {},
          fetching   : 0 //Used to control fetching, and ignore content when we've already mgirated off the page'
    };

    //Page items

    if ( options ) {
        $.extend( settings, options );
    }

    $(window).bind( 'hashchange', hash_change);
    $(window).trigger( 'hashchange' );

    container.find('.slide_link').live('click', function(event){
        if( event.target.nodeName === "A" ){
            return false;
        } else {
            content_clicked($(this));   
        }
    });

    return {
        render_content: render_content,
        rerender_content: function() {
                render($.bbq.getState(settings.bbq_tag), list.children('.has_content'));
            },
        rerender_breadcrumb: function() {
            reset_breadcrumb($.bbq.getState(settings.bbq_tag));
        }
    };
};
