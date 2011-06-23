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
    subtypes: ["errata", "package", "repo"],
    changeset_queue:[],
    changeset_data: {},
    interval_id: undefined,
    current_changeset: undefined,
    current_product: undefined,
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
        if(promotion_page.changeset_queue.length > 0 &&  promotion_page.current_changeset) {
            promotion_page.stop_timer();
            data = [];
            while(promotion_page.changeset_queue.length > 0) {
                data.push(promotion_page.changeset_queue.shift());
            }
            
            var changeset_id = promotion_page.current_changeset.id;
            change_set.update(changeset_id, data, promotion_page.current_changeset.timestamp,
                function(data) {
                    if (promotion_page.changeset_queue.length === 0) {
                        if(data.changeset) {
                            promotion_page.reset_changeset(data.changeset);
                        }
                        promotion_page.current_changeset.timestamp = data.timestamp;
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
        var adding = true;
        if (promotion_page.find_changeset_button(id, type).length) {
            adding = false;
        }

        var ids = {};
        ids[id] = display;


        if (adding) {
            promotion_page.add_changeset_page_item(id, type, display);
            promotion_page.sort_changeset(type);
        }
        else {
            promotion_page.remove_changeset_page_item(id, type, display);
        }
        promotion_page.changeset_queue.push([type, id, display, adding, promotion_page.current_product]);
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
    },
    set_current_changeset: function(hash_id) {
        var id = hash_id.split("_");
        if (id[0] === "changeset") {
            $.ajax({
                type: "GET",
                url: "/changesets/" + id[1] + "/object/",
                cache: false,
                success: function(data) {
                    promotion_page.current_changeset = changeset_obj(data);
                    promotion_page.reset_page();
                }
            });
        }
        else if (id[0] === "changesets") {
            promotion_page.current_changeset = undefined;
            promotion_page.reset_page();
        }
    },
    set_current_product: function(hash_id) {
        var id = hash_id.split("_");
        if (id.length > 1) {
            promotion_page.current_product = id[id.length - 1];
        }
        else {
            promotion_page.current_product = undefined; //reset product
        }
        promotion_page.reset_page();

    },
    /*
     *  Resets anything that is listed to have the correct button value
     *    if there is no changeset selected this will reset everything
     *    This will be called when a new changeset is loaded, or when the user
     *    moves from page to page in the content (left hand) side
     *    //TODO make more efficient by identify exactly which page we are on and only reseting those buttons
     */
    reset_page: function() {
        if (promotion_page.current_product) {
            if (promotion_page.current_changeset) {
                var product = promotion_page.current_changeset.products[promotion_page.current_product];
                jQuery.each(promotion_page.subtypes, function(index, type){
                    var buttons = $("a[class~=content_add_remove][data-type=" + type + "]");
                    buttons.html(i18n.add).removeClass('remove_' + type).addClass("add_" + type).removeClass("disabled");
                    jQuery.each(product[type], function(index, item) {
                        $("a[class~=content_add_remove][data-type=" + type+ "][data-id=" + item.id +"]").html(i18n.remove).removeClass('add_' + type).addClass("remove_" + type);
                    });
                });
            }
            else {
                jQuery.each(promotion_page.subtypes, function(index, type){
                    var buttons = $("a[class~=content_add_remove][data-type=" + type + "]");
                    buttons.addClass('disabled');
                });
            }
        }
    },
    /*
     *
     */
    reset_changeset: function() {

    }
};


var changeset_obj = function(data_struct) {
    var id = data_struct["id"];
    var timestamp = data_struct["timestamp"];

    return {
        id:id,
        products: data_struct,
        set_timestamp:function(ts) { timestamp = ts},
        timestamp: function(){return timestamp}
    }
}


$(document).ready(function() {

    //promotion_page.update_dep_size();
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

    //initiate the left tree
  	var contentTree = sliding_tree("content_tree", {breadcrumb:content_breadcrumb,
                                      default_tab:"content",
                                      bbq_tag:"content",
                                      tab_change_cb: promotion_page.set_current_product});

  	var changesetTree = sliding_tree("changeset_tree", {breadcrumb:changeset_breadcrumb,
                                      default_tab:"changesets",
                                      bbq_tag:"changeset",
                                      tab_change_cb: promotion_page.set_current_changeset});
  	

    $('#depend_list').live('click', promotion_page.show_dependencies);

    //set function for env selection callback
    env_select.click_callback = promotion_page.env_change;

    registerEvents(changesetTree);

});

var registerEvents = function(changesetTree){
    $('#save_changeset_button').live('click', function(){
        $.ajax({
          type: "POST",
          url: "/changesets/",
          data: $('#new_changeset').serialize(),
          cache: false,
          success: function(data){
              var split;
              if( $('#cslist').length !== 0){
                $('#cslist').append(data.html);
              } else {
                  split = changeset_breadcrumb['changesets'].content.split('</ul>');
                  split = split[0] + data.html + '</ul>';
                  changeset_breadcrumb['changesets'].content = split;
              }
              $.extend(changeset_breadcrumb, data.breadcrumb);
              changesetTree.render_content('changeset_' + data.id);
              panel.closePanel($('#panel'));
          }
        });
    });
};
