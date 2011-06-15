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


var promotion_page = {
    types: ["errata", "product", "package", "repo"],
    changeset_queue:[],
    timestamp: undefined,
    interval_id: undefined,
    start_timer: function() {
        interval_id = setInterval(promotion_page.push_changeset, 1000);
    },
    stop_timer: function() {
      clearInterval(interval_id);
    },
    update_dep_size: function() {
        if ($('#depend_size').length) {
            $.ajax({
                type: "GET",
                url: $('#depend_size').attr("data-url"),
                cache: false,
                success: function(data) {
                    $('#depend_size').html(data);
                }
            })
        }
    },
    //Finds the add/remove buttons in the left pane
    find_button: function(id, type) {
        return $("a[class~=content_add_remove][data-id=" + common.escapeId(id) + "][data-type=" + type + "]")
    },
    //Finds the remove button/label in the right pane
    find_changeset_button: function(id, type) {
        return $("a[class~=changeset_remove][data-id=" + common.escapeId(id) + "][data-type=" + type + "]")
    },
    new_changeset_button: function(id, type, display_name) {
        return jQuery('<a/>', {
            'data-id': id,
            'data-type': type,
            'data-display_name':display_name,
            'class': 'changeset_remove changeset_remove_' + type, //These classes come from changesets/_changeset.html.haml
            'text': display_name
        });
    },
    push_changeset: function() {
        if(promotion_page.changeset_queue.length > 0) {
            promotion_page.stop_timer();
            data = [];
            while(promotion_page.changeset_queue.length > 0) {
                data.push(promotion_page.changeset_queue.shift());
            }
            
            var changeset_id = $('#changeset').attr("data-id");
            change_set.update(changeset_id, data, promotion_page.timestamp,
                function(data) {
                    if (promotion_page.changeset_queue.length == 0) {
                        if(data.changeset) {
                            promotion_page.reset_changeset(data.changeset);
                        }
                        promotion_page.timestamp = data.timestamp;
                    }
                    promotion_page.update_dep_size();
                    promotion_page.start_timer();
                },
                function() { //Got an error, revert
                    $("#error_dialog").dialog({
                        closeOnEscape: false,
                        modal: true,
                        //Remove the close button
                        open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); }
                    });


                });
        }

    },
    modify_changeset: function(id, display, type) {
        var changeset_id = $('#changeset').attr("data-id");
        var adding = true;
        if (promotion_page.find_changeset_button(id, type).length) {
            adding = false;
        }

        var ids = {};
        ids[id] = display;
        //can Remove when javascript handles changeset
        //$('#changeset-items').html("<img src='/images/spinner.gif'>");


        if (adding) {
            promotion_page.add_changeset_page_item(id, type, display);
            promotion_page.sort_changeset(type);
        }
        else {
            promotion_page.remove_changeset_page_item(id, type, display);
        }
        promotion_page.changeset_queue.push([type, id, display, adding]);
    },
    //Resets the changeset list from a given changeset hash
    reset_changeset: function(data) {
        //Reset the left panel buttons to 'add', they will get flipped to remove if needed
        $("a[class~=content_add_remove][data-id=" + id + "]").addClass("add_" + type).removeClass('remove_' + type);

        jQuery.each(promotion_page.types, function(index, type){
            $('#changeset-items-' + type).html("");
           jQuery.each(data[type], function(index, item) {
                promotion_page.add_changeset_page_item(item.id, type, item.name)
            });
        });
    },
    add_changeset_page_item: function(id,type, display) {
        var button = promotion_page.find_button(id, type);
        button.html('Remove').addClass("remove_" + type).removeClass('add_'+type);
        $('#changeset-items-' + type).append(promotion_page.new_changeset_button(id, type, display));
    },
    remove_changeset_page_item: function(id, type, display) {
        var button = promotion_page.find_button(id, type);
        button.html('Add').addClass("add_" + type).removeClass('remove_' + type);
        promotion_page.find_changeset_button(id, type).remove();
    },
    sort_changeset: function(type) {
        $('.changeset_remove_' + type).sortElements(function(a,b){
           return $(a).attr("data-display_name") > $(b).attr("data-display_name") ? 1 : -1;
        });
    },

    ids_in_changeset: function(type) {
        var ids = {};
        $("a[class~=changeset_remove][data-type=" + type + "]").each(function() {
            ids[$(this).attr("data-id")] = $(this).attr("data-display_name") || "";
        });
        return ids;
    },
    show_dependencies: function() {
        var dialog = $('#dialog_content');
        $.ajax({
            type: "GET",
            url: $(this).attr("data-url"),
            cache: false,
            success: function(data) {
                dialog.html(data);
                $('#deptabs').tabs();
            }
        });
        dialog.html("<img src='/images/spinner.gif'>");
        dialog.dialog({height:600, width:400});
    },
    env_change: function(env_id, element) {
        var url = element.attr("data-url");
        window.location = url;
    }
};






var sliding_tree = (function() { return {
    current_tab: undefined,
	direction : undefined,
	fetching: 0, //Used to control fetching, and ignore content when we've already mgirated off the page'
	change_content : function(id) {
          sliding_tree.current_tab = id;
		  sliding_tree.fetching = 0;
	      sliding_tree.reset_breadcrumb(id);
	      var url = breadcrumb[id].url;
	      var newPanel = $('.no_content');
	      var oldPanel = $('.has_content');
          var list = $('#list');
	      
	      //If we aren't sliding, we only worry about 1 panel'
	      if (!sliding_tree.direction) {
	      	newPanel = oldPanel;
	      }
	      
	      //If we are to use a cached copy, use it
	      if (breadcrumb[id].cache) {
	        newPanel.html(breadcrumb[id].content)
	      }
	      else { //Else fetch the data and place it in the new panel when we are done
	      	//we set fetching to the id, so once its done we know whether to actually
	      	// display the data, or throw it away.
	      	sliding_tree.fetching = id;
	        $.get(url, function(data) {
	        	if (sliding_tree.fetching == id) {
	                newPanel.html(data);
	                sliding_tree.fetching = 0;
	            }
	          });
	         newPanel.html("<img src='/images/spinner.gif' >");
	      }

         if (breadcrumb[id].scrollable) {
            list.addClass("ajaxScroll");
            list.attr("data-scroll_url", url);
         }
         else {
            list.removeClass("ajaxScroll");
         }


	      //If we have a direction, we need to slide
		  if(sliding_tree.direction) {
		  	  var leaving = sliding_tree.direction == "right"? "left" : "right";
		      //The old pane, we need to hide it away, remove the contents, and reset the classes
		      oldPanel.css({"position":"absolute"}).hide("slide" ,{"direction":leaving}, 500, function() {
		                                                           oldPanel.html("");
		                                                           oldPanel.removeClass("has_content");
		                                                           oldPanel.addClass("no_content");
		                                                           oldPanel.css({"position":"relative"})});
		      //the new pane, move it into view
		      newPanel.css({"position":"absolute"}).effect("slide" ,{"direction":sliding_tree.direction}, 500, function() {
		                                                          newPanel.removeClass("no_content");
		                                                          newPanel.addClass("has_content");
		                                                          newPanel.css({"position":"relative"})});
		                                                          
		      sliding_tree.direction = undefined;
	      }
	      
	      return false  
	},
	content_clicked: function() {
      	if($(this).hasClass("slide_left")) {
          sliding_tree.direction = "left";
        }else {
          sliding_tree.direction = "right";
        }
		$.bbq.pushState({tab:this.id});
	},

	reset_breadcrumb: function(id) {
	    //Clear the breadcrumb
	    var trail = breadcrumb[id].trail;
	    $("#breadcrumb").html("");
	    for(var i = 0; i < trail.length; i++) {
	        $("#breadcrumb").append(sliding_tree.create_crumb(trail[i]))
	    }
	    $("#breadcrumb").append(breadcrumb[id].name)
	},

	create_crumb: function(id) {
	    return jQuery('<div/>', {
	        id:id,
	        "class": 'slide_link slide_left',
	        text: breadcrumb[id].name +  "\u2002\u00BB\u2002"
	    });    
	    
	},

	hash_change: function() {
        var newContent = $.bbq.getState("tab") || "content";
        if (sliding_tree.current_tab != newContent) {
            sliding_tree.change_content(newContent);
            sliding_tree.reset_breadcrumb(newContent);
        }
	}
}})();


$(document).ready(function() {

    promotion_page.update_dep_size();
    promotion_page.start_timer();

    $(".content_add_remove").live('click', function() {
	
      var environment_id = $(this).attr('data-environment_id');
      var id = $(this).attr('data-id');
      var display = $(this).attr('data-display_name');
      var type = $(this).attr('data-type');
      
      promotion_page.modify_changeset(id, display, type);
    });
    
    
    $(".changeset_remove").live('click', function() {
    
      var id = $(this).attr('data-id');
      var display = $(this).attr('data-display_name');
      var type = $(this).attr('data-type');
      
      promotion_page.modify_changeset(id, display, type);
    });     

    $('.slide_link').live('click', sliding_tree.content_clicked);
  	
  	$(window).bind( 'hashchange', sliding_tree.hash_change);
  	$(window).trigger( 'hashchange' );

    $('#depend_list').live('click', promotion_page.show_dependencies);

    //set function for env selection callback
    env_select.click_callback = promotion_page.env_change;

    promotion_page.timestamp = $('#changeset').attr("data-timestamp");

});


