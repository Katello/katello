
/*
 * User Options:
 *  breadcrumb { }  :   a hash making up the breadcrumb
 *  bbq_tag : the tag to use for this list for BBQ bookmarking/history
 *  default_tab : default entry in the hashtab to load upon initial page load
 *  tab_change_cb : callback to happen once a new tab is selected, the tab 'key' that was is the first paramter
 */

var sliding_tree = function(id, options) {

    //functions
    var change_content = function(id) {
        
        settings.current_tab = id;
        settings.fetching = 0;
        reset_breadcrumb(id);
        var url = settings.breadcrumb[id].url;
        var newPanel = list.children('.no_content');
        var oldPanel = list.children('.has_content');

        //If we aren't sliding, we only worry about 1 panel'
        if (!settings.direction) {
            newPanel = oldPanel;
        }

        //If we are to use a cached copy, use it
        if (settings.breadcrumb[id].cache) {
            newPanel.html(settings.breadcrumb[id].content)
        }
        else { //Else fetch the data and place it in the new panel when we are done
        //we set fetching to the id, so once its done we know whether to actually
        // display the data, or throw it away.
        settings.fetching = id;
            $.get(url, function(data) {
                if (settings.fetching == id) {
                    newPanel.html(data);
                    settings.fetching = 0;
                }
              });
              newPanel.html("<img src='/images/spinner.gif' >");
        }

        if (settings.breadcrumb[id].scrollable) {
            list.addClass("ajaxScroll");
            list.attr("data-scroll_url", url);
        }
        else {
            list.removeClass("ajaxScroll");
        }


        //If we have a direction, we need to slide
        if(settings.direction) {
            var leaving = settings.direction == "right"? "left" : "right";
            //The old pane, we need to hide it away, remove the contents, and reset the classes
            oldPanel.css({"position":"absolute"}).hide("slide" ,{"direction":leaving}, 500, function() {
                                                               oldPanel.html("");
                                                               oldPanel.removeClass("has_content");
                                                               oldPanel.addClass("no_content");
                                                               oldPanel.css({"position":"relative"})});
            //the new pane, move it into view
            newPanel.css({"position":"absolute"}).effect("slide" ,{"direction":settings.direction}, 500, function() {
                                                              newPanel.removeClass("no_content");
                                                              newPanel.addClass("has_content");
                                                              newPanel.css({"position":"relative"})});

            settings.direction = undefined;
        }


        settings.tab_change_cb(id);
        return false
    };
    var content_clicked = function() {
        var element = $(this);
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
        //Clear the breadcrumb
        var trail = settings.breadcrumb[id].trail;
        breadcrumb.html("");
        for(var i = 0; i < trail.length; i++) {
            breadcrumb.append(create_crumb(trail[i]))
        }
        breadcrumb.append(settings.breadcrumb[id].name)
    }
    var create_crumb = function(id) {
        return jQuery('<div/>', {
            id:id,
            "class": 'slide_link slide_left',
            text: settings.breadcrumb[id].name +  "\u2002\u00BB\u2002"
        });

    };
    var hash_change = function() {
        var newContent = $.bbq.getState(settings.bbq_tag) || settings.default_tab;
        if (settings.current_tab != newContent) {
            change_content(newContent);
            reset_breadcrumb(newContent);
        }
    };

    var settings = {
          breadcrumb : {},
          bbq_tag : id,
          default_tab : "",
          current_tab: undefined,
          direction  : undefined,
          tab_change_cb: function() {},
          fetching   : 0 //Used to control fetching, and ignore content when we've already mgirated off the page'
    };

    //Page items
    var container = $('#' + id);
    var list = container.children(".sliding_list");
    var breadcrumb = container.children(".tree_breadcrumb");

    
    if ( options ) {
        $.extend( settings, options );
    }

    $(window).bind( 'hashchange', hash_change);
    $(window).trigger( 'hashchange' );

    container.find('.slide_link').live('click', content_clicked);

    return {
        render_content: render_content
    };  //Nothing public at the moment
    
};

