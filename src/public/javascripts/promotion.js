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
        return $(".right").find("a[data-id=" + common.escapeId(id) + "][data-type=" + type + "]")
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
    modify_changeset: function(id, display, type, product_id) {
        var changeset = promotion_page.current_changeset;
        var adding = true;
        if ( changeset && changeset.has_item(type, id, product_id)) {
            adding = false;
        }

        if (adding) {
            changeset.add_item(type, id, display, product_id);
            //promotion_page.add_changeset_page_item(id, type, display);
            //promotion_page.sort_changeset(type);
        }
        else {
            changeset.remove_item(type, id, product_id);
            //promotion_page.remove_changeset_page_item(id, type, display);
        }
        promotion_page.changeset_queue.push([type, id, display, adding, product_id]);
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
        $(".right_tree").find("li").sortElements(function(a,b){
            return $(a).children().first().html() > $(b).children().first().html() ? 1 : -1;
           //return $(a).attr("data-display_name") > $(b).attr("data-display_name") ? 1 : -1;
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
        if (id[0] === "changesets") {
            promotion_page.current_changeset = undefined;
            promotion_page.reset_page();
            $("#delete_changeset").addClass("disabled");
        }
        else if (id[0] === "changeset" || promotion_page.current_changeset === undefined) {
            $.ajax({
                type: "GET",
                url: "/changesets/" + id[1] + "/object/",
                cache: false,
                async: false,
                success: function(data) {
                    promotion_page.current_changeset = changeset_obj(data);
                    promotion_page.reset_page();
                    $("#delete_changeset").removeClass("disabled");
                    return promotionsRenderer.renderPromotionsContent(hash_id);
                }
            });
        }
        return promotionsRenderer.renderPromotionsContent(hash_id);
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
                    var buttons = $('#list').find("a[class~=content_add_remove][data-type=" + type + "]");
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

    },
    checkUsersInResponse: function(users) {
      //TODO: update the div for which users are editing
      var l = users.length
      var user = users[0];
      return;
    }
};


var changeset_obj = function(data_struct) {
    var id = data_struct["id"];
    var timestamp = data_struct["timestamp"];

    return {
        id:id,
        products: data_struct,
        set_timestamp:function(ts) { timestamp = ts},
        timestamp: function(){return timestamp},
        has_item: function(type, id, product) {
            var found = undefined;
            jQuery.each(data_struct[product][type], function(index, item) {
                if(item.id == id){
                    found = true;
                    return false;
                }
            });
            return found !== undefined;
        },
        add_item:function (type, id, display_name, product_id) {
            if (data_struct[product_id] === undefined) {
                data_struct[product_id] = {'package':[], 'errata':[], 'repo':[]}
            }
            data_struct[product_id][type].push({name:display_name, id:id})
        },
        remove_item:function(type, id, product_id) {
            if (data_struct[product_id] !== undefined) {
                jQuery.each(data_struct[product_id][type], function(index,item) {
                    if (item.id === id) {
                        data_struct[product_id][type].splice(index,index+1);
                        return false;//Exit out of the loop
                    }
                });


            }
        }
    }
};


$(document).ready(function() {

    //promotion_page.update_dep_size();
    promotion_page.start_timer();

    $(".content_add_remove").live('click', function() {
	
      var environment_id = $(this).attr('data-environment_id');
      var id = $(this).attr('data-id');
      var display = $(this).attr('data-display_name');
      var type = $(this).attr('data-type');
      var prod_id = $(this).attr('data-product_id');
      
      promotion_page.modify_changeset(id, display, type, prod_id);
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
                                      render_cb: promotion_page.set_current_changeset,
                                      tab_change_cb: promotion_page.sort_changeset});
  	

    $('#depend_list').live('click', promotion_page.show_dependencies);

    //set function for env selection callback
    env_select.click_callback = promotion_page.env_change;

    registerEvents(changesetTree);

    $(document).ajaxComplete(function(event, xhr, options){
        var userHeader = xhr.getResponseHeader('X-ChangesetUsers');
        if(userHeader != null) {
          var userj = $.parseJSON(userHeader); 
          promotion_page.checkUsersInResponse(userj);
        }
    });
        
});

var registerEvents = function(changesetTree){
    $('#save_changeset_button').live('click', function(){
        $.ajax({
          type: "POST",
          url: "/changesets/",
          data: $('#new_changeset').serialize(),
          cache: false,
          success: function(data){
              $.extend(changeset_breadcrumb, data.breadcrumb);
              changesetTree.render_content('changeset_' + data.id);
              panel.closePanel($('#panel'));
          }
        });
    });
    
    $("#delete_changeset").click(function() {
        var button = $(this);
        var id = promotion_page.current_changeset.id;
        if (button.hasClass('disabled')){
            return false;
        }
        var answer = confirm(button.attr('data-confirm-text'));
        if (answer) {
            button.addClass('disabled');
            $.ajax({
                type: "DELETE",
                url: button.attr('data-url') + '/' + id,
                cache: false,
                success: function(data){
                    delete changeset_breadcrumb['changeset_' + id];
                    promotion_page.set_current_changeset('changesets');
                    changesetTree.render_content('changesets');
                }
            });
       }
    });
};

var promotionsRenderer = (function($){
    var renderChangesets = function(){
            return templateLibrary.changesetsList(changeset_breadcrumb);
        },
        renderPromotionsContent = function(hash){
            if( hash === 'changesets'){
                return renderChangesets();
            }
            else if (hash.split("_")[0] === 'packages-cs'){
                var product_id = hash.split("_")[2]; 
                return templateLibrary.listItems("package", product_id);
                

            }
        }

    
    return {
        renderPromotionsContent: renderPromotionsContent  
    };
})(jQuery);

var templateLibrary = (function(){
    var changesetsListItem = function(id, name){
            return '<li>' + '<div class="slide_link" id="' + id + '">'
                    + name + '</div></li>';    
        },
        changesetsList = function(changesets){
            var html = '<ul>';
            for( item in changesets){
                if( changesets.hasOwnProperty(item) ){
                    if( changesets[item].name !== 'Changesets' ){
                        html += changesetsListItem(item, changesets[item].name);
                    }
                }
            }
            html += '</ul>';
            return html;
        },
        listItems = function(type, product_id) {
            if (promotion_page.current_changeset === undefined) {
                console.log("No current");
                return false;
            }

            var html = '<ul>';
            jQuery.each(promotion_page.current_changeset.products[product_id][type], function(index, item) {
               html += listItem(item.id, item.name, type, product_id);
            });
            html += '</ul>';
            return html;
        },
        listItem = function(id, name, type, product_id) {
            return '<li>' + '<div class="slide_link"' + 'data-type="' + type + '" data-product_id="' + product_id
                    + '" data-id="' + id + '">'  + name + '</div></li>';

        }

    
    return {
        changesetsList: changesetsList,
        listItems : listItems
    };
})();
