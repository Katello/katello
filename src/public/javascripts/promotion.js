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


var promotion_page = (function($){
    var types =             ["errata", "product", "package", "repo"],
        subtypes =          ["errata", "package", "repo"],
        changeset_queue =   [],
        changeset_data =    {},
        interval_id =       undefined,
        current_changeset = undefined,
        current_product =   undefined,
        changeset_tree =    undefined,
        
        start_timer = function() {
            interval_id = setInterval(push_changeset, 1000);
        },
        stop_timer = function() {
          clearInterval(interval_id);
          interval_id = undefined;
        },
        update_dep_size = function() {
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
        are_updates_complete = function() { //if there are no pending (and complete) updates, return true
            return changeset_queue.length === 0 && interval_id !== undefined;
        },
        //Finds the add/remove buttons in the left pane
        find_button = function(id, type) {
            return $("a[class~=content_add_remove][data-id=" + common.escapeId(id) + "][data-type=" + type + "]");
        },
        conflict = function(){
            //conflict object that stores conflict information
            var product_add = [],
                product_remove =[],
                products = {};

            var add_emtpy_product = function(name){
                products[name] = {name:name};
                $.each(subtypes, function(index, type){
                    products[name][type + "_" + "add"] = [];
                    products[name][type + "_" + "remove"] = [];
                });
            };

            return {
                products_added: product_add,
                products_removed: product_remove,
                products: products,
                size : function() {
                    var total = 0;
                        total += product_add.length + product_remove.length;
                        $.each(products, function(key, prod) {
                            $.each(subtypes, function(index, type) {
                                total += prod[type + "_add"].length + prod[type + "_remove"].length;
                            });
                        });
                    return total;
                },
                add_item : function(type, name, added, product_name) {
                    var action = added ? "add" : "remove";
                    if (type === 'product') {
                        var prod_array = added ? product_add : product_remove;
                        prod_array.push(name);
                    }
                    else {
                        if (products[product_name] === undefined) {
                            add_emtpy_product(product_name);
                        }
                        products[product_name][type + "_" + action].push(name);
                    }
                }
            }
        },
        calculate_conflict = function(old_changeset, new_changeset) {
            var myconflict = conflict();
            var old_products = {}; //save products as hash so we dont have to loop to look them up
            var new_products = {};
            var all_products = {};

            $.each(new_changeset.getProducts(), function(index, item) {
                new_products[item.id] = item;
                all_products[item.id] = item;
            });
            $.each(old_changeset.getProducts(), function(index, item) {
                old_products[item.id] = item;
                all_products[item.id] = item;
            });

            $.each(all_products, function(id, product){
                var old_p = old_products[id] || {};
                var new_p = new_products[id] || {};

                if (new_p && new_p.all && (!old_p || !old_p.all)) { //product added
                    myconflict.add_item('product', product.name, true);
                }
                else if(old_p && old_p.all && (!new_p || !new_p.all)) { //product removed
                    myconflict.add_item('product', product.name, false);
                }

                $.each(subtypes, function(index, type) {

                    var new_items = new_p[type] || [];
                    var old_items = old_p[type] || [];
                    var all_types = new_items.concat(old_items);

                    $.each(all_types, function(index, item){
                        var new_has = new_changeset.has_item(type, item.id, product.id);
                        var old_has = old_changeset.has_item(type, item.id, product.id);

                        if (new_has && !old_has) {
                            myconflict.add_item(type, item.name, true, product.name);
                        }
                        else if (!new_has && old_has) {
                            myconflict.add_item(type, item.name, false, product.name);
                        }
                    });
                });
            });
            return myconflict;

        },
        show_conflict = function(conflict) {
            $("#conflict-dialog").dialog({modal: true, width: 400});
            $("#conflict-accordion").html(promotionsRenderer.renderConflict(conflict));
        },
        show_conflict_details = function() {
            var accord = $("#conflict-accordion");
            accord.show();
            accord.accordion({fillSpace:true, beforeClose: hide_conflict});
        },
        hide_conflict = function() {
            $("#conflict-dialog").dialog('close');
            var accord = $("#conflict-accordion");
            accord.accordion("destroy");
            accord.html('');
            accord.hide();
        },
        push_changeset = function() {
    
            if(changeset_queue.length > 0 &&  current_changeset) {
                stop_timer();
                var data = [];
                while(changeset_queue.length > 0) {
                    data.push(changeset_queue.shift());
                }

                current_changeset.update(data,
                    function(data) {
                        if (changeset_queue.length !== 0 && data.changeset) {
                            //don't update timestamp
                        }
                        else {
                            if(data.changeset) {
                                var old_changeset = current_changeset;
                                current_changeset = changeset_obj(data.changeset);
                                reset_page();
                                changeset_tree.rerender_content();
                                var diff = calculate_conflict(old_changeset, current_changeset);
                                if (diff.size() > 0) {
                                    show_conflict(diff);
                                }
                                else {
                                    //console.log("Got newer changeset, but no differences");
                                }
                            }
                            else {
                                current_changeset.set_timestamp(data.timestamp);
                            }
                        }
                        start_timer();
                    },
                    throw_error);
            }
        },
        wait = function(break_cb, finished_cb) {
            $("#wait_dialog").dialog({
                closeOnEscape: false,
                modal: true,
                //Remove the close button
                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); }
            });
            if (!break_cb()) {
                setTimeout(function() {
                    wait(break_cb, finished_cb);
                }, 250);
            }
            else {
                $("#wait_dialog").dialog("close");
                finished_cb();
            }
        },
        throw_error = function() {
            $("#error_dialog").dialog({
                closeOnEscape: false,
                modal: true,
                //Remove the close button
                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); }
            });
    
        },
        modify_changeset = function(id, display, type, product_id) {
            var changeset = current_changeset;
            var adding = true;
            if ( changeset && changeset.has_item(type, id, product_id)) {
                adding = false;
            }
    
            var button = find_button(id, type);
            var product_name = content_breadcrumb['details_' + product_id].name;
            if (adding) {
                button.html(i18n.remove).addClass("remove_" + type).removeClass('add_'+type);
                if( type !== 'product'){
                    if( changeset.getProducts()[product_id] === undefined ){
                        add_product_breadcrumbs(changeset.id, product_id, product_name);
                    }
                }
                changeset.add_item(type, id, display, product_id, product_name);
                changeset_tree.rerender_content();
            }
            else {
                button.html(i18n.add).addClass("add_" + type).removeClass('remove_' + type);
                changeset.remove_item(type, id, product_id);
                if( type !== 'product' ){
                    var product = changeset.getProducts()[product_id];
                    if( !product.errata.length && !product.package.length && !product.repo.length ){
                        delete changeset.getProducts()[product_id];
                        changeset_tree.render_content('changeset_' + changeset.id);
                    } else {
                        changeset_tree.rerender_content();
                    }
                } else {
                    changeset_tree.rerender_content();       
                }
            }
            sort_changeset();
            draw_status();
            changeset_queue.push([type, id, display, adding, product_id]);
        },
        sort_changeset = function() {
            $(".right_tree .will_have_content").find("li").sortElements(function(a,b){
                    var a_html = $(a).find(".sort_attr").html();
                    var b_html = $(b).find(".sort_attr").html();
                    if (a_html && b_html ) {
                        return  a_html.toUpperCase() >
                                b_html.toUpperCase() ? 1 : -1;
                    }
            });
        },
        show_dependencies = function() {
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
        env_change = function(env_id, element) {
            var url = element.attr("data-url");
            window.location = url;
        },
        fetch_changeset = function(changeset_id, callback) {
    
                $("#changeset_loading").css("z-index", 300);
                $.ajax({
                    type: "GET",
                    url: "/changesets/" + changeset_id + "/object/",
                    cache: false,
                    success: function(data) {
                        $("#changeset_loading").css("z-index", -1);
                        current_changeset = changeset_obj(data);
                        reset_page();
                        $("#delete_changeset").removeClass("disabled");
                        callback();
                    }});
    
        },
        set_current_product = function(hash_id) {
            var id = hash_id.split("_");
            if (id.length > 1) {
                current_product = id[id.length - 1];
            }
            else {
                current_product = undefined; //reset product
            }
            reset_page();
    
        },
        draw_status = function() {
            if (current_changeset === undefined) {
                $('#changeset_status').html('');
            }
            else {
                //array of  [type, quantity] arrays
                var counts = [];

                var prod_count = 0;
                $.each(current_changeset.getProducts(), function(key, product){
                    if (product.all) {
                        prod_count+=1;
                    }
                });
                counts.push(["product", prod_count]);


                $.each(subtypes, function(index,type) {
                    var amount = 0;
                    $.each(current_changeset.getProducts(), function(key, product){
                        amount += product[type].length;
                    });
                    counts.push([type, amount]);
                });

                //convert counts into human readable format
                var strings = [];
                $.each(counts, function(index, item){
                     if (item[1] === 1) {
                        strings.push(item[1] + " " + i18n[item[0] + "_singular"]);
                    }
                    else if (item[1] > 1) {
                         strings.push(item[1] + " " + i18n[item[0] + "_plural"]);
                    }                   
                });

                if(strings.length === 0) {
                    $('#changeset_status').html(i18n.summary + " " + i18n.changeset_empty);
                }
                else {
                    $('#changeset_status').html(i18n.summary + " " + strings.join(", "));
                }
            }

        },
        /*
         *  Resets anything that is listed to have the correct button value
         *    if there is no changeset selected this will reset everything
         *    This will be called when a new changeset is loaded, or when the user
         *    moves from page to page in the content (left hand) side
         *    //TODO make more efficient by identify exactly which page we are on and only reseting those buttons
         */
        reset_page = function() {
            if (current_changeset) {
                if (current_product) {
                    var product = current_changeset.getProducts()[current_product];
                    if( product !== undefined && product.all !== undefined ){
                        disable_all(subtypes);
                    } else {
                        jQuery.each(subtypes, function(index, type){
                            var buttons = $('#list').find("a[class~=content_add_remove][data-type=" + type + "]");
                            buttons.html(i18n.add).removeClass('remove_' + type).addClass("add_" + type).show(); //reset all to 'add'
                            if (product) {
                                jQuery.each(product[type], function(index, item) {
                                    $("a[class~=content_add_remove][data-type=" + type+ "][data-id=" + item.id +"]").html(i18n.remove).removeClass('add_' + type).addClass("remove_" + type);
                                });
                            }
                        });
                    }
                } else {
                    var buttons = $('#list').find("a[class~=content_add_remove][data-type=product]");
                    buttons.html(i18n.add).removeClass("remove_product").addClass("add_product").removeClass('disabled');
                    $.each(current_changeset.getProducts(), function(index, product) {
                        $.each(buttons, function(button_index, button){
                            if( $(button).attr('id') === ('add_remove_product_' + product.id) ){ 
                                if( product.all === true){
                                    $(button).html(i18n.remove).removeClass('add_product').addClass("remove_product").removeClass("disabled");
                                } else {
                                    $(button).html('');
                                }
                            }
                        });
                    });
                }
            } else {
                disable_all(types);
            }
    
            //Reset the review/promote/cancel button

            var cancel_btn = $("#review_cancel");
            var status = $('#changeset_status');

            
            if (current_changeset) {
                status.show();
                $("#changeset_actions > div").removeClass("disabled");
                if (current_changeset.is_new()) {
                    cancel_btn.hide();
                    
                    $("#changeset_tree .tree_breadcrumb").removeClass("locked_breadcrumb");
                    $(".breadcrumb_search").removeClass("locked_breadcrumb_search");
                    $("#cslist").removeClass("locked");
                    $('#locked_icon').remove();
                    $(".content_add_remove").show();
                    $('#review_changeset > span').html(i18n.review);
                    $('#promote_changeset').addClass("disabled");
                }
                else { //in review stage
                    cancel_btn.show();
                    $("#changeset_tree .tree_breadcrumb").addClass("locked_breadcrumb");
                    $(".breadcrumb_search").addClass("locked_breadcrumb_search");
                    if( $('#locked_icon').length === 0 ){
                        $("#changeset_tree .tree_breadcrumb #changeset_" + current_changeset.id).prepend('<div id="locked_icon" class="locked_icon fl" >');
                    }
                    $("#cslist").addClass("locked");
                    $(".content_add_remove").hide();
                    $('#review_changeset > span').html(i18n.cancel_review);
                    $('#promote_changeset').removeClass("disabled");
                }
            }
            else {
                $(status.hide());
                $("#changeset_tree .tree_breadcrumb").removeClass("locked_breadcrumb");
                $(".breadcrumb_search").removeClass("locked_breadcrumb_search");
                $("#cslist").removeClass("locked");
                $('#locked_icon').remove();

                cancel_btn.hide();
                changesetEdit.close();

                $("#changeset_actions > div").addClass("disabled");
                
            }

            draw_status();
    }, 
    disable_all = function(types){
        var all_types = types || subtypes;
        jQuery.each(all_types, function(index, type){
            var buttons = $("a[class~=content_add_remove][data-type=" + type + "]");
            buttons.hide().html(i18n.add);
        });        
    },
    checkUsersInResponse = function(users) {
      if (users.length > 0) {
        var msg = users.join(", ") + ' ' + i18n.viewing;
        $('#changeset_users').html(msg).fadeIn(); 
      }
      else {
        $('#changeset_users').fadeOut("slow", function() { $(this).html(""); });
      }
    },
    add_product_breadcrumbs = function(changeset_id, product_id, product_name){
        var productBC = 'product-cs_' + changeset_id + '_' + product_id;
        var changesetBC = "changeset_" + changeset_id;
        changeset_breadcrumb[productBC] = {
            cache: null,
            client_render: true,
            name: product_name,
            trail: ['changesets', changesetBC],
            url: 'url'
        };
        changeset_breadcrumb['package-cs_' + changeset_id + '_' + product_id] = {
            cache: null,
            client_render: true,
            name: "Packages",
            trail: ['changesets', changesetBC, productBC],
            url: ''
        };
        changeset_breadcrumb['errata-cs_' + changeset_id + '_' + product_id] = {
            cache: null,
            client_render: true,
            name: "Errata",
            trail: ['changesets', changesetBC, productBC],
            url: ''
        };
        changeset_breadcrumb['repo-cs_' + changeset_id + '_' + product_id] = {
            cache: null,
            client_render: true,
            name: "Repositories",
            trail: ['changesets', changesetBC, productBC],
            url: ''
        };
    };
        
    return {
        subtypes:               subtypes,
        get_changeset_tree:     function(){return changeset_tree;},
        set_changeset_tree:     function(ct){changeset_tree = ct;},
        get_changeset:          function(){return current_changeset;},
        set_changeset:          function(cs){current_changeset = cs;},
        modify_changeset:       modify_changeset,
        sort_changeset:         sort_changeset,
        fetch_changeset:        fetch_changeset,
        set_current_product:    set_current_product,
        are_updates_complete:         are_updates_complete,
        show_dependencies:      show_dependencies,
        env_change:             env_change,
        checkUsersInResponse:   checkUsersInResponse,
        start_timer:            start_timer,
        reset_page:             reset_page,
        throw_error:            throw_error,
        wait:                   wait,
        calc_conflict:          calculate_conflict,
        hide_conflict:          hide_conflict,
        show_conflict_details:  show_conflict_details
    };
}(jQuery));


var changeset_obj = function(data_struct) {
    var id = data_struct["id"],
        timestamp = data_struct["timestamp"],
        products = data_struct.products,
        is_new = data_struct.is_new,
        name = data_struct.name;


    var change_state = function(state, on_success, on_error) {
          $.ajax({
            contentType:"application/json",
            type: "PUT",
            url: "/changesets/" + id,
            data: JSON.stringify({timestamp:timestamp, state:state}),
            cache: false,
            success: function(data) {
                timestamp = data.timestamp;
                is_new = (state === "new");
                on_success();
            },
            error: function(data) {
                if (data.changeset) {
                    alert("The changeset has changed");
                    promotion_page.set_changeset( changeset_obj(data.changeset) );
                }
                else {
                    promotion_page.throw_error();
                }
            }
          });
    };

    return {
        id:id,
        getName: function(){return name},
        setName: function(newName){
            name = newName;
            changeset_breadcrumb["changeset_" + id].name = newName;
        },
        getProducts: function(){return products},
        is_new : function() {return is_new},
        set_timestamp:function(ts) { timestamp = ts; },
        timestamp: function(){return timestamp},
        productCount: function(){
            var count = 0;
            
            for( var item in products ){
                if( products.hasOwnProperty(item) ){
                    count += 1;
                }
            }
            return count;
        },
        has_item: function(type, id, product_id) {
            var found = undefined;
            if( type === 'product'){
                if( products.hasOwnProperty(id) ){
                    return true;
                }
            }
            if( products.hasOwnProperty(product_id) ){
                jQuery.each(products[product_id][type], function(index, item) {
                    if(item.id === id){
                        found = true;
                        return false;
                    }
                });
            }
            return found !== undefined;
        },
        add_item:function (type, id, display_name, product_id, product_name) {
            if( type === 'product' ){
                products[id] = {'name': display_name, 'id': id, 'package':[], 'errata':[], 'repo':[], 'all': true}
            } else { 
                if ( products[product_id] === undefined ) {
                    products[product_id] = {'name': product_name, 'id': product_id, 'package':[], 'errata':[], 'repo':[]}
                }
                products[product_id][type].push({name:display_name, id:id})
            } 
        },
        remove_item:function(type, id, product_id) {
            if( type === 'product' ){
                delete products[id];
            } else if (products[product_id] !== undefined) {
                $.each(products[product_id][type], function(index,item) {
                    if (item.id === id) {
                        products[product_id][type].splice(index,1);
                        return false;//Exit out of the loop
                    }  
                });
            }
        },
        review: function(on_success, on_error) {
            change_state("review", on_success, on_error);
            changeset_breadcrumb['changeset_' + id].is_new = false;
        },
        cancel_review: function(on_success, on_error) {
            change_state("new", on_success, on_error);
            changeset_breadcrumb['changeset_' + id].is_new = true;
        },
        promote: function(on_success, on_error) {
         $.ajax({
            type: "POST",
            url: "/changesets/" + id + "/promote",
            cache: false,
            success: function(data) {
                if (on_success) {
                    on_success();
                }
                window.location = data;

            }});
        },
        update: function(items, on_success, on_error) {
          var data = [];
          $.each(items, function(index, value) {
              var item = {};
              item["type"] = value[0];
              item["item_id"] = value[1];
              item["item_name"] = value[2];
              item["adding"] = value[3];
              if (value[4]) {
                  item["product_id"] = value[4];
              }
              data.push(item);
            });
          $.ajax({
            contentType:"application/json",
            type: "PUT",
            url: "/changesets/" + id,
            data: JSON.stringify({data:data, timestamp:timestamp}),
            cache: false,
            success: on_success,
            error: on_error
          });
        }
    }
};

//make jQuery Contains case insensitive
$.expr[':'].Contains = function(a, i, m) {
  return $(a).text().toUpperCase()
      .indexOf(m[3].toUpperCase()) >= 0;
};
$.expr[':'].contains = function(a, i, m) {
  return $(a).text().toUpperCase()
      .indexOf(m[3].toUpperCase()) >= 0;
};

var registerEvents = function(){

    $('#save_changeset_button').live('click', function(){
        var button = $(this);
        if(button.hasClass("disabled")){return false;}
        button.addClass("disabled");


        $.ajax({
          type: "POST",
          url: "/changesets/",
          data: $('#new_changeset').serialize(),
          cache: false,
          success: function(data){
              $.extend(changeset_breadcrumb, data.breadcrumb);
              promotion_page.set_changeset(changeset_obj(data.changeset));
              promotion_page.get_changeset_tree().render_content('changeset_' + data.id);
              panel.closePanel($('#panel'));
          },
          error: function(){ button.removeClass("disabled");}
        });
    });
    
    $("#delete_changeset").click(function() {
        var button = $(this);
        if (button.hasClass('disabled')){
            return false;
        }
        var id = promotion_page.get_changeset().id;
        var answer = confirm(button.attr('data-confirm-text'));
        if (answer) {
            button.addClass('disabled');
            $.ajax({
                type: "DELETE",
                url: button.attr('data-url') + '/' + id,
                cache: false,
                success: function(data){
                    delete changeset_breadcrumb['changeset_' + id];
                    promotion_page.set_changeset('changesets');
                    promotion_page.get_changeset_tree().render_content('changesets');
                }
            });
       }
    });


    $("#review_changeset").live('click', function() {
       var button = $(this);
        if (button.hasClass('disabled')){
            return false;
        }
        button.addClass("disabled");
        var cs = promotion_page.get_changeset();
        if(cs.is_new()) {
            var review_func = function() {
                cs.review(function() {
                    button.removeClass("disabled");
                    promotion_page.reset_page();
                    promotion_page.get_changeset_tree().rerender_content();
                });                
            };
            if (!promotion_page.are_updates_complete()) {
                promotion_page.wait(promotion_page.are_updates_complete, review_func);
            }
            else {
                review_func();
            }
        }
        else {
            cs.cancel_review(function() {
                button.removeClass("disabled");
                promotion_page.reset_page();
                promotion_page.get_changeset_tree().rerender_content();
            });
        }
    });

    $("#promote_changeset").live('click', function() {
        if ($(this).hasClass("disabled")) {
            return;
        }
        var cs = promotion_page.get_changeset();
             cs.promote(function() {});
    });



    //Ask the user if they really want to leave the page if updates aren't finished
    window.onbeforeunload = function(){
        if(!promotion_page.are_updates_complete()){
            return i18n.leave_page;
        }
    };

    $('#conflict_close').click(promotion_page.hide_conflict);
    $('#conflict-details').click(promotion_page.show_conflict_details);

    $('#edit_changeset').click(function() {
        if ($(this).hasClass('disabled')){
            return false;
        }
        changesetEdit.toggle();
    });


};

var changesetEdit = (function(){

    var opened = false;

    var toggle = function(delay){
        var edit_window = $('#changeset_edit');
        var name_box = $('.edit_name_text');
        var edit_button = $('#edit_changeset > span');
        var changeset = promotion_page.get_changeset();
        var animate_time = 500;
        if (delay != undefined){
            animate_time = delay;
        }

        opened = !opened;

        var after_function = undefined;
        if (opened) {
            name_box.html(changeset.getName());
            edit_button.html(i18n.close_details);
            edit_button.parent().addClass("highlighted");
            after_function = setup_edit;

        }
        else {
            edit_button.html(i18n.edit_details);
            edit_button.parent().removeClass("highlighted");
        }

        edit_window.slideToggle(animate_time, after_function);
    },
    setup_edit = function() {
        
        var changeset = promotion_page.get_changeset();
        var url = "/changesets/" + changeset.id;
        var name_box = $('.edit_name_text');
        
        name_box.each(function() {
                $(this).editable( url, {
                    type        :  'text',
                    width       :  270,
                    method      :  'PUT',
                    name        :  $(this).attr('name'),
                    cancel      :  i18n.cancel,
                    submit      :  i18n.save,
                    indicator   :  i18n.saving,
                    tooltip     :  i18n.clickToEdit,
                    placeholder :  i18n.clickToEdit,
                    
                    submitdata  :  {authenticity_token: AUTH_TOKEN},
                    onsuccess   :  function(data) {
                          var parsed = $.parseJSON(data);
                          changeset.setName(parsed.name);
                          $('.edit_name_text').html(parsed.name);
                          changeset.set_timestamp(parsed.timestamp);
                          promotion_page.get_changeset_tree().rerender_breadcrumb();
                    },
                    onerror     :  function(settings, original, xhr) {
                                     original.reset();
                    }
                });
            });
    },
    close = function() {
        if (opened) {
            toggle(0);
        }
    };

    return {
        toggle: function() {toggle();},
        close: close
    };
})();


var promotionsRenderer = (function(){
    var render = function(hash, render_cb){
            if( hash === 'changesets'){
                var post_wait_function = function() {
                    promotion_page.set_changeset(undefined);
                    $("#delete_changeset").addClass("disabled");
                    render_cb(templateLibrary.changesetsList(changeset_breadcrumb));
                };
                //any pending updates, if so wait!
                if (!promotion_page.are_updates_complete()) {
                    promotion_page.wait(promotion_page.are_updates_complete, function() {
                        post_wait_function();
                    });
                }
                else {
                    post_wait_function();
                }
            }
            else {
                var split = hash.split("_");
                var page = split[0];
                var changeset_id = split[1];
                var product_id = split[2];
                var cs = promotion_page.get_changeset();

                //if we've come to a page with a different changset than what we have, clear the current changeset
                if (page === "changeset" && cs !== undefined && changeset_id !==  cs.id) {
                   promotion_page.set_changeset(undefined);
                }
                
                if (promotion_page.get_changeset() === undefined) {
                    promotion_page.fetch_changeset(changeset_id, function() {
                        render_cb(getContent(page, changeset_id, product_id));
                    });
                }
                else {
                    render_cb(getContent(page, changeset_id, product_id));
                }
            }
            promotion_page.reset_page();
        },
        getContent =  function(key, changeset_id, product_id) {
             //changeset_id = hash.split("_")[1];
             //   product_id = hash.split("_")[2],
             //   key = hash.split("_")[0],
            var    changeset = promotion_page.get_changeset(),
                inReviewPhase = !changeset.is_new();
            
            if (key === 'package-cs'){
                return templateLibrary.listItems(changeset.getProducts(), "package", product_id, !inReviewPhase);
            }
            else if (key === 'errata-cs'){
                return templateLibrary.listItems(changeset.getProducts(), "errata", product_id, !inReviewPhase);
            }
            else if (key === 'repo-cs'){
                return templateLibrary.listItems(changeset.getProducts(), "repo", product_id, !inReviewPhase);
            }
            else if (key === 'product-cs'){
                return templateLibrary.productDetailList(changeset.getProducts()[product_id], promotion_page.subtypes, changeset_id);
            }
            else if (key === 'changeset'){
                return templateLibrary.productList(changeset, changeset.id, !inReviewPhase);
            }
        },
        renderConflict = function(conflict) {
            var html = templateLibrary.conflictFullProducts(conflict.products_added, conflict.products_removed);
            $.each(conflict.products, function(key, product){
                html += templateLibrary.conflictProduct(key, product);
            });
            return html;
        };

    return {
        render: render,
        renderConflict: renderConflict
    };
})();

var templateLibrary = (function(){
    var changesetsListItem = function(id, name){
            var html ='<li>' + '<div class="slide_link" id="' + id + '">'
            if (!changeset_breadcrumb[id].is_new) {
                html += '<img  class="fl locked_icon" src="/images/icons/locked.png">'
            }

            html += '<span class="sort_attr">'+ name + '</span></div></li>';
            return html;
        },
        changesetsList = function(changesets){
            var html = '<ul>';
            for( item in changesets){
                if( changesets.hasOwnProperty(item) ){
                    //do the search filter here
                    if( item.split("_")[0] === "changeset" ){
                        html += changesetsListItem(item, changesets[item].name);
                    }
                }
            }
            html += '</ul>';
            return html;
        },
        productDetailList = function(product, subtypes, changeset_id) {
            var html = '<ul>';
             jQuery.each(subtypes, function(index, type) {
                html += '<li><div class="slide_link" id="' + type +'-cs_' + changeset_id + '_' + product.id + '">';
                html += '<span class="sort_attr">' + i18n[type] + ' (' + product[type].length
                        + ')</span></li>';
             });
            html += '</ul>';
            return html;
        },
        listItems = function(products, type, product_id, showButton) {
            var html = '<ul>';
            var items = products[product_id][type];
            if (items.length === 0) {
                return i18n["no_" + type]; //no_errata no_package no_repo
            }
            jQuery.each(items, function(index, item) {
               //for item names that mach item.name from search hash
               html += listItem(item.id, item.name, type, product_id, showButton);
            });
            html += '</ul>';
            return html;
        },
        listItem = function(id, name, type, product_id, showButton) {
            var anchor = "";
            if ( showButton ){
                anchor = '<a ' + 'class="fr content_add_remove remove_' + type + ' + st_button"'
                                + 'data-type="' + type + '" data-product_id="' + product_id +  '" data-id="' + id + '">';
                            anchor += i18n.remove + "</a>";
                        
            }
            return '<li>' + anchor + '<div class="no_slide"><span class="sort_attr">'  + name + '</div></span></li>';

        },
        productList = function(changeset, changeset_id, showButton){
            var html = '<ul>',
                all_list = '',
                partial_list = '',
                product, provider,
                products = changeset.getProducts();
            
            if( changeset.productCount() === 0 ){
                html += '<div class="empty_list">' + i18n['no_products'] + '</div>';
                //html += i18n['no_products'];
            } else {
                for( key in products ){
                    if( products.hasOwnProperty(key) ){
                        product = products[key];
                        provider = (product.provider === 'REDHAT') ? 'rh' : 'custom';
                        toSlide = product.all ? 'no_slide' : 'slide_link';
                        if( product.all ){
                            if( showButton ){
                                all_list += productListItem(changeset_id, key, product.name, provider, toSlide, showButton);
                            } else {
                                all_list += productListItem(changeset_id, key, product.name, provider, toSlide, showButton);
                            }
                        }
                        else {
                            partial_list += productListItem(changeset_id, key, product.name, provider, toSlide, false);
                        }
                    }
                }
            }
            
            html += all_list ? ('<h5>'+i18n.full_product+'</h5>' + all_list) : '';
            html += partial_list ? ('<h5>'+i18n.partial_product+'</h5>' + partial_list) : '';
            html += '</ul>';
            return html;
        },
        productListItem = function(changeset_id, product_id, name, provider, slide_link, showButton){
            var anchor = "";
            if ( showButton ){
                anchor = '<a class="st_button content_add_remove fr remove_product" data-display_name="' +
                    name +'" data-id="' + product_id + '" data-type="product" id="add_remove_product_' + product_id +
                    '" data-product_id="' + product_id +
                    '">' + i18n.remove + '</a>';
            }
            return '<li class="clear">' + anchor +
                    '<div class="' + slide_link + '" id="product-cs_' + changeset_id + '_' + product_id + '">' +
                    '<span class="' + provider + '-product-sprite"></span>' +
                    '<span class="product-icon sort_attr" >' + name + '</span>' +
                    '</div></li>';
        },
        conflictFullProducts = function(added, removed) {
            if (added.length == 0 && removed.length == 0) {
                return "";
            }
            var html = "<h3>"+ i18n.full_product +"</h3>";
            html +="<div>";
            html += conflictAccordianListItem(true, added);
            html += conflictAccordianListItem(false, removed);
            html += "</div>";
            return html;
        },    
        conflictProduct = function(product_name, conflict_product) {
            var html = '<h3><a href="#">'+ product_name+ '</a></h3>';
            html +="<div>";
            $.each(promotion_page.subtypes, function(index, type){
                var added = conflict_product[type + "_add"];
                var removed = conflict_product[type + "_remove"];

                if (added.length > 0 || removed.length > 0) {
                    html += '<div>' + i18n[type] + ':</div>';
                    html += conflictAccordianListItem(true, added);
                    html += conflictAccordianListItem(false, removed);
                }
            });
            html += "</div>";
            return html;
        },
        conflictAccordianListItem = function(added, items) {
            if (items.length === 0) {
                return "";
            }

            var html = '<div class="conflict_item_type"><div>' + (added ? i18n.added : i18n.removed) + '</div>';
            html += '<ul>';
            $.each(items, function(index, item) {
                html += "<li class='conflict_item'>" + item +  "</li>"
            });
            html += '</ul></div>';
            return html;
        };
        
    return {
        changesetsList: changesetsList,
        productList: productList,
        listItems : listItems,
        productDetailList: productDetailList,
        conflictFullProducts: conflictFullProducts,
        conflictProduct: conflictProduct
    };
})();

//doc ready
$(document).ready(function() {

    $('.left').resizable('destroy');
    
    promotion_page.start_timer();

    $(".content_add_remove").live('click', function() {
    
       if( !$(this).hasClass('disabled') ){


          var environment_id = $(this).attr('data-environment_id');
          var id = $(this).attr('data-id');
          var display = $(this).attr('data-display_name');
          var type = $(this).attr('data-type');
          var prod_id = $(this).attr('data-product_id');
          promotion_page.modify_changeset(id, display, type, prod_id);
       }
    });
    
    $('#changeset_users').hide();

    //initiate the left tree
    var contentTree = sliding_tree("content_tree", {breadcrumb:content_breadcrumb,
                                      default_tab:"content",
                                      bbq_tag:"content",
                                      base_icon: 'home_img',
                                      tab_change_cb: promotion_page.set_current_product});

    promotion_page.set_changeset_tree( sliding_tree("changeset_tree", {breadcrumb:changeset_breadcrumb,
                                      default_tab:"changesets",
                                      bbq_tag:"changeset",
                                      base_icon: 'home_img',
                                      render_cb: promotionsRenderer.render,
                                      tab_change_cb: function(hash_id) {
                                          promotion_page.sort_changeset();
                                      }}));

    //need to reset page during the extended scroll
    panel.extended_cb = promotion_page.reset_page;

    //when loading the new panel item, if its new, we need to add a form submit handler
    panel.expand_cb = function(id) {
        if (id === 'new') {
          $('#new_changeset').submit(function(e) {
              e.preventDefault();
              $('#save_changeset_button').trigger('click');
          });
        }
    };

    $('#depend_list').live('click', promotion_page.show_dependencies);

    //set function for env selection callback
    env_select.click_callback = promotion_page.env_change;

    registerEvents();

    $(document).ajaxComplete(function(event, xhr, options){
        var userHeader = xhr.getResponseHeader('X-ChangesetUsers');
        if(userHeader != null) {
          var userj = $.parseJSON(userHeader); 
          promotion_page.checkUsersInResponse(userj);
        }
    });

    //bind to the #search_form to make it useful
    $('#search_form').submit(function(){
        $('#search').change();
        return false;
    });

    $('#search').live('change, keyup', function(){
        if ($.trim($(this).val()).length >= 2) {
            $("#cslist .has_content li:not(:contains('" + $(this).val() + "'))").filter(':not').fadeOut('fast');
            $("#cslist .has_content li:contains('" + $(this).val() + "')").filter(':hidden').fadeIn('fast');
        } else {
            $("#cslist .has_content li").fadeIn('fast');
        }
    });
    $('#search').val("").change();

    //click and animate the filter for changeset
    var bcs = null;
    var bcs_height = 0;
    $('.search_button').toggle(
        function() {
            bcs = $('.breadcrumb_search');
            bcs_height = bcs.height();
            bcs.animate({ "height": bcs_height+40}, { duration: 200, queue: false });
            $("#search_form #search").css("margin-left", 0);
            $("#search_form").css("opacity", "0").show();
            $("#search_form").animate({"opacity":"1"}, { duration: 200, queue: false });
            $("#search").animate({"width":"420px", "opacity":"1"}, { duration: 200, queue: false });
            $(this).css({backgroundPosition: "-32px -16px"});
        },function() {
            $("#search_form").fadeOut("fast", function(){bcs.animate({ "height": bcs_height }, "fast");});
            $(this).css({backgroundPosition: "0 -16px"});
            $("#search").val("").change();
            $("#cslist .has_content li").fadeIn('fast');
        }
    );
        
    
     var container = $('#container');

     var original_top = Math.floor($('.left').position(top).top);
     if(container.length > 0){
         var bodyY = parseInt(container.offset().top, 10) - 20;
         $(window).scroll(function () {
             panel.handleScroll($('#changeset_tree'), container, original_top, bodyY, 0);
         });
    }
});
