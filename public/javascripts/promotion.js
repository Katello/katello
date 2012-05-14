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
    var types =             ["errata", "product", "package", "repo", "template", "distribution"],
        subtypes =          ["errata", "package", "repo", "distribution"],
        changeset_queue =   [],
        changeset_data =    {},
        interval_id,
        current_changeset,
        current_product,
        changeset_tree,
        content_tree,
        
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
                });
            }
        },
        are_updates_complete = function() { //if there are no pending (and complete) updates, return true
            return changeset_queue.length === 0 && interval_id !== undefined;
        },
        //Finds the add/remove buttons in the left pane
        find_button = function(id, type) {
            return $("a[class~=content_add_remove][data-id=" + KT.common.escapeId(id) + "][data-type=" + type + "]");
        },
        conflict = function(){
            //conflict object that stores conflict information
            var product_add = [],
                product_remove =[],
                products = {};

            var add_empty_product = function(name){
                products[name] = {name:name};
                $.each(subtypes, function(index, type){
                    products[name][type + "_" + "add"] = [];
                    products[name][type + "_" + "remove"] = [];
                });
            };

            var template_add = [],
                template_remove =[];

            return {
                templates_added: template_add,
                templates_removed: template_remove,
                products_added: product_add,
                products_removed: product_remove,
                products: products,
                size : function() {
                    var total = 0;
                        total += product_add.length + product_remove.length + template_add.length + template_remove.length;
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
                    else if (type == 'template') {
                         var template_array = added ? template_add : template_remove;
                         template_array.push(name);
                    }
                    else {
                        if (products[product_name] === undefined) {
                            add_empty_product(product_name);
                        }
                        products[product_name][type + "_" + action].push(name);
                    }
                }
            };
        },
        calculate_conflict = function(old_changeset, new_changeset) {
            var myconflict = conflict(),
            old_products = {}, //save products as hash so we dont have to loop to look them up
            new_products = {},
            all_products = {},
            old_templates = {}, //save products as hash so we dont have to loop to look them up
            new_templates= {},
            all_templates = {};

            $.each(new_changeset.getProducts(), function(index, item) {
                new_products[item.id] = item;
                all_products[item.id] = item;
            });
            $.each(old_changeset.getProducts(), function(index, item) {
                old_products[item.id] = item;
                all_products[item.id] = item;
            });

            $.each(all_products, function(id, product){
                var old_p = old_products[id];
                var new_p = new_products[id];

                if (new_p && new_p.all && (!old_p || !old_p.all)) { //product added
                    myconflict.add_item('product', product.name, true);
                }
                else if(old_p && old_p.all && (!new_p || !new_p.all)) { //product removed
                    myconflict.add_item('product', product.name, false);
                }

                $.each(subtypes, function(index, type) {

                    var new_items = [];
                    if(new_p) {
                      new_items = new_p[type];
                    }

                    var old_items = [];
                    if(old_p) {
                      old_items = old_p[type];
                    }
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

            $.each(new_changeset.getTemplates(), function(index, item) {
                new_templates[item.id] = item;
                all_templates[item.id] = item;
            });
            $.each(old_changeset.getTemplates(), function(index, item) {
                old_templates[item.id] = item;
                all_templates[item.id] = item;
            });

            $.each(all_templates, function(id, item){
                var old_t = old_templates[id];
                var new_t = new_templates[id];

                if (new_t && !old_t) { //template added
                    myconflict.add_item('template', item.name, true);
                }
                else if(old_t && !new_t) { // template removed
                    myconflict.add_item('template', item.name, false);
                }
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
                        if (changeset_queue.length === 0 || !data.changeset) {
                            if(data.changeset) {
                                var old_changeset = current_changeset;
                                current_changeset = changeset_obj(data.changeset);
                                reset_page();
                                changeset_tree.rerender_content();
                                var diff = calculate_conflict(old_changeset, current_changeset);
                                if (diff.size() > 0) {
                                    show_conflict(diff);
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
            var i = 0,
                length;
            
            if( KT.utils.isArray(product_id) ){
                length = product_id.length;

                for(i = 0; i < length; i += 1){
                    process_changeset_modification(id, display, type, product_id[i]);
                }
            } else {
                process_changeset_modification(id, display, type, product_id);
            }
        },
        process_changeset_modification = function(id, display, type, product_id){
            var changeset = current_changeset,
                adding = true,
                button = find_button(id, type),
                product_name = '';

            if ( changeset && changeset.has_item(type, id, product_id) ){
                adding = false;
            }

            if (product_id) {
              product_name = content_breadcrumb['details_' + product_id].name;
            }

            if (adding) {
                button.html(i18n.remove).addClass("remove_" + type).removeClass('add_'+type);
                if( type !== 'product'){
                    if (type === "template") {
                      if (changeset.getTemplates()[id] === undefined) {
                        add_template_breadcrumbs(changeset.id, id, display);
                      }
                    }
                    else if( changeset.getProducts()[product_id] === undefined ){
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
                    if (type === "template") {
                      delete changeset.getTemplates()[id];
                      changeset_tree.rerender_content();
                    }
                    else {
                      var product = changeset.getProducts()[product_id];
                      if( !product.errata.length && !product['package'].length && !product.repo.length && !product.distribution.length){
                          delete changeset.getProducts()[product_id];
                          changeset_tree.render_content('changeset_' + changeset.id);
                      } else {
                          changeset_tree.rerender_content();
                      }
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
            $(".right_tree .will_have_content").find("li").each(function(index, element){
                $(element).find('li').sortElements(function(a,b){
                        var a_html = $(a).find(".sort_attr").html();
                        var b_html = $(b).find(".sort_attr").html();
                        if (a_html && b_html ) {
                            return  a_html.toUpperCase() >
                                    b_html.toUpperCase() ? 1 : -1;
                        }
                });
            });
        },
        init_changeset_list = function(){
            var changeset, id;
            sort_changeset();
            if( !current_changeset ){
                for( id in changeset_breadcrumb ){
                    if( changeset_breadcrumb.hasOwnProperty(id) ){
                        if( id.split("_")[0] === "changeset" ){
                            changeset = changeset_breadcrumb[id];
                            if ( changeset.state === "failed") {
                                changesetStatusActions.initProgressBar(id, changeset.progress, i18n.promotion_failed);
                            }else if( !changeset.is_new && ( changeset.progress === null || changeset.progress === undefined ) ){
                                changesetStatusActions.setLocked(id);
                            } else if( changeset.progress !== null && changeset.progress !== undefined ){
                                changesetStatusActions.initProgressBar(id, changeset.progress);
                                changesetStatusActions.checkProgressTask(id.split("_")[1]);
                            }
                        }
                    }
                }
            }
        },
        env_change = function(env_id, element) {
            var url = element.attr("data-url");
            window.location = url;
        },
        fetch_changeset = function(changeset_id, callback) {
                $("#tree_loading").css("z-index", 300);
                $.ajax({
                    type: "GET",
                    url: KT.common.rootURL() + "changesets/" + changeset_id + "/object/",
                    cache: false,
                    success: function(data) {
                        $("#tree_loading").css("z-index", -1);
                        current_changeset = changeset_obj(data);
                        reset_page();
                        callback();
                    }});

    
        },
        set_current_product = function(hash_id) {
            var product_id = content_breadcrumb[hash_id].product_id;

            if ( content_breadcrumb[hash_id].product_id ) {
                current_product = product_id;
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

                //count how many products are in the changeset
                var prod_count = 0;
                $.each(current_changeset.getProducts(), function(key, product){
                    if (product.all) {
                        prod_count+=1;
                    }
                });
                //push the i18n string to lookup and the count
                counts.push(["product", prod_count]);

                //count how many system templates are in the changeset
                var template_count = 0;
                $.each(current_changeset.getTemplates(), function(key, template){
                  template_count+=1;
                });
                //push the i18n string to lookup and the count
                counts.push(["system_template", template_count]);

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
            if (current_changeset && permissions.manage_changesets) {

                if ( current_product ) {
                    var product = current_changeset.getProducts()[current_product];
                    if( product !== undefined && product.all !== undefined ){
                        disable_all(subtypes);
                    } else {
                        $.each(subtypes, function(index, type){
                            var buttons = $('#list').find("a[class~=content_add_remove][data-type=" + type + "]");
                            buttons.html(i18n.add).removeClass('remove_' + type).addClass("add_" + type).show(); //reset all to 'add'
                            if (product) {
                                $.each(product[type], function(index, item) {
                                    $("a[class~=content_add_remove][data-type=" + type+ "][data-id=" + KT.common.escapeId(item.id + "") +"]").html(i18n.remove).removeClass('add_' + type).addClass("remove_" + type);
                                });
                            }
                        });
                    }
                } else{
                  var buttons = $('#list').find("a[class~=content_add_remove][data-type=product]");

                  buttons.html(i18n.add).removeClass('remove_product').addClass("add_product").show(); //reset all to 'add'
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

                 buttons = $('#list').find("a[class~=content_add_remove][data-type=template]");
                 buttons.html(i18n.add).removeClass('remove_template').addClass("add_template").show(); //reset all to 'add'
                  $.each(current_changeset.getTemplates(), function(index, template) {
                    $.each(buttons, function(button_index, button){
                      if( $(button).attr('id') === ('add_remove_template_' + template.id) ){ 
                        $(button).html(i18n.remove).removeClass('add_template').addClass("remove_template").removeClass("disabled");
                      }
                    });
                  });

                 buttons = $('#list').find("a[class~=content_add_remove][data-type=errata]");
                 buttons.html(i18n.add).removeClass('remove_errata').addClass("add_errata").show(); //reset all to 'add'
                  $.each(current_changeset.getErrata(), function(index, erratum) {
                    $.each(buttons, function(button_index, button){
                      if( $(button).attr('id') === ('add_remove_errata_' + erratum.id) ){
                        if( KT.utils.intersection(erratum["product_ids"], $.parseJSON($(button).data("product_id"))).length === 0 ){
                            $(button).html(i18n.remove).removeClass('add_errata').addClass("remove_errata").removeClass("disabled");
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
                $("#sliding_tree_actionbar > div").removeClass("disabled");
                if (!permissions.manage_changesets) {
                    $('#edit_changeset').addClass("disabled");
                    $('#delete_changeset').addClass("disabled");
                    $('#review_changeset').addClass("disabled");
                }

                if (current_changeset.is_new() || current_changeset.state() === "failed") {
                    cancel_btn.hide();
                    
                    $("#changeset_tree .tree_breadcrumb").removeClass("locked_breadcrumb");
                    $(".breadcrumb_filter").removeClass("locked_breadcrumb_filter");
                    $("#cslist").removeClass("locked");
                    $('#locked_icon').remove();
                    $('#review_changeset > span').html(i18n.review);
                    $('#promote_changeset').addClass("disabled");
                }
                else if( current_changeset.state() === "promoted" || current_changeset.state() === "promoting" ){
                    $("#changeset_tree .tree_breadcrumb").addClass("locked_breadcrumb");
                    $(".breadcrumb_filter").addClass("locked_breadcrumb_filter");
                    if( $('#locked_icon').length === 0 ){
                        $("#changeset_tree .tree_breadcrumb #changeset_" + current_changeset.id).prepend('<div id="locked_icon" class="locked_icon fl" >');
                    }
                    $("#cslist").addClass("locked");
                    $(".content_add_remove").hide();
                    $("#sliding_tree_actionbar > div").addClass("disabled");
                } else { //in review stage
                    cancel_btn.show();
                    $("#changeset_tree .tree_breadcrumb").addClass("locked_breadcrumb");
                    $(".breadcrumb_filter").addClass("locked_breadcrumb_filter");
                    if( $('#locked_icon').length === 0 ){
                        $("#changeset_tree .tree_breadcrumb #changeset_" + current_changeset.id).prepend('<div id="locked_icon" class="locked_icon fl" >');
                    }
                    $("#cslist").addClass("locked");
                    $(".content_add_remove").hide();

                    $('#review_changeset > span').html(i18n.cancel_review);

                    if (permissions.promote_changesets) {
                        $('#promote_changeset').removeClass("disabled");
                    }
                    else {
                        $('#promote_changeset').addClass("disabled");
                    }
                }
            }
            else {
                $(status.hide());
                $("#changeset_tree .tree_breadcrumb").removeClass("locked_breadcrumb");
                $(".breadcrumb_filter").removeClass("locked_breadcrumb_filter");
                $("#cslist").removeClass("locked");
                $('#locked_icon').remove();

                cancel_btn.hide();
                changesetEdit.close();

                $("#sliding_tree_actionbar > div").addClass("disabled");
                
            }

            if (!permissions.manage_changesets) {
                disable_all(types);
            }

            draw_status();
        }, 
        disable_all = function(types){
            var all_types = types || subtypes;
            $.each(all_types, function(index, type){
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
        add_template_breadcrumbs = function(changeset_id, id, name){
          var changesetBC = "changeset_" + changeset_id;
          var templateBC = 'template-cs_' + changeset_id + '_' + id;
          changeset_breadcrumb[templateBC] = {
                cache: null,
                client_render: true,
                name: name,
                trail: ['changesets', changesetBC],
                url: 'url'
          };
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
            changeset_breadcrumb['distribution-cs_' + changeset_id + '_' + product_id] = {
                cache: null,
                client_render: true,
                name: "Distributions",
                trail: ['changesets', changesetBC, productBC],
                url: ''
            };
        },
        add_dependencies= function() {
           if (current_changeset === undefined) {
               return false;
           }
           $.each(current_changeset.getProducts(), function(product_id, product) {
               var hash = "deps-cs_" + current_changeset.id + "_" + product_id;
               
               if (changeset_breadcrumb[hash] === undefined) {
                var productBC = 'product-cs_' + current_changeset.id + '_' + product_id;
                var changesetBC = "changeset_" + current_changeset.id;
                changeset_breadcrumb[hash] = {
                    cache: null,
                    client_render: true,
                    name: "Dependencies",
                    trail: ['changesets', changesetBC, productBC],
                    url: ''
                };
               }
           });
           return true; 
            //changeset_breadcrumb
        },
        remove_dependencies = function() {
            if (current_changeset === undefined) {
    
                return false;
            }
    
            $.each(changeset_breadcrumb, function(key, value) {
               if (key.indexOf("deps-cs_") === 0) {
                    delete changeset_breadcrumb[key];
               }
            });
            return true;
        };
        
    return {
        subtypes:               subtypes,
        get_changeset_tree:     function(){return changeset_tree;},
        set_changeset_tree:     function(ct){changeset_tree = ct;},
        get_content_tree:       function(){return content_tree;},
        set_content_tree:       function(ct){content_tree = ct;},
        get_changeset:          function(){return current_changeset;},
        set_changeset:          function(cs){current_changeset = cs;},
        modify_changeset:       modify_changeset,
        sort_changeset:         sort_changeset,
        fetch_changeset:        fetch_changeset,
        set_current_product:    set_current_product,
        are_updates_complete:   are_updates_complete,
        env_change:             env_change,
        checkUsersInResponse:   checkUsersInResponse,
        start_timer:            start_timer,
        reset_page:             reset_page,
        throw_error:            throw_error,
        wait:                   wait,
        calc_conflict:          calculate_conflict,
        hide_conflict:          hide_conflict,
        show_conflict_details:  show_conflict_details,
        add_dependencies:       add_dependencies,
        remove_dependencies:    remove_dependencies,
        init_changeset_list:    init_changeset_list
    };
}(jQuery));


var changeset_obj = function(data_struct) {
    var id = data_struct["id"],
        timestamp = data_struct["timestamp"],
        products = data_struct.products,
        templates = data_struct.system_templates,
        is_new = data_struct.is_new,
        state = data_struct.state,
        has_failed = false, // used to indicate if there was a previous failed promo attempt since the page loaded
        name = data_struct.name,
        description = data_struct.description;

    var change_state = function(new_state, on_success, on_error) {
          $.ajax({
            contentType:"application/json",
            type: "PUT",
            url: KT.common.rootURL() + "changesets/" + id,
            data: JSON.stringify({timestamp:timestamp, state:new_state}),
            cache: false,
            success: function(data) {
                timestamp = data.timestamp;
                is_new = (new_state === "new");
                state = new_state;
                on_success();
            },
            error: function(data) {
                if (data.changeset) {
                    promotion_page.set_changeset( changeset_obj(data.changeset) );
                }
                else {
                    promotion_page.throw_error();
                }
            }
          });
        },
        dep_solve = function() {

            $.ajax({
                type: "GET",
                url: KT.common.rootURL() + "changesets/" + id + "/dependencies",
                cache: false,
                success: function(data) {
                    $.each(data, function(key, value) {
                       products[key].deps = value;
                    });
                    promotion_page.get_changeset_tree().rerender_content();
                }
            });
        },
        productCount = function(){
            var count = 0;
            
            for( var item in products ){
                if( products.hasOwnProperty(item) ){
                    count += 1;
                }
            }
            return count;
        };

    if (!is_new) {
        dep_solve();
    }


    return {
        id:id,
        productCount: productCount,
        getName: function(){return name;},
        setName: function(newName){
            name = newName;
            changeset_breadcrumb["changeset_" + id].name = newName;
        },
        getDescription: function(){return description;},
        setDescription: function(newDesc){description = newDesc;},
        getProducts: function(){return products;},
        getTemplates: function() {return templates;},
        is_new : function() {return is_new;},
        state : function() {return state;},
        has_failed : function() {return has_failed;},
        set_timestamp:function(ts) { timestamp = ts; },
        timestamp: function(){return timestamp;},
        getErrata: function(){
            var product, item, errata, erratum_id,
                collection = {},
                i, length,
                product_count = productCount();

            for( item in products ){
                product = products[item];
                errata = product.errata;
                length = errata.length;

                for( i = 0; i < length; i += 1){
                    erratum_id = errata[i]["id"];

                    if( collection[erratum_id] ){
                        collection[erratum_id]["product_ids"].push(product.id);
                    } else {
                        errata[i]["product_ids"] = [product.id];
                        collection[erratum_id] = errata[i];
                    }
                }
            }
   
            return collection;
        },
        has_item: function(type, id, product_id) {
            var found = undefined;
            if (type === 'template') {
               if( templates.hasOwnProperty(id) ){
                    return true;
                }
            }
            if( type === 'product'){
                if( products.hasOwnProperty(id) ){
                    return true;
                }
            }
            if( products.hasOwnProperty(product_id) ){
                $.each(products[product_id][type], function(index, item) {
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
                products[id] = {'name': display_name, 'id': id, 'package':[], 'errata':[], 'repo':[], 'distribution':[], 'all': true};
            } else if (type === 'template') {
                templates[id] = {'name': display_name, 'id': id};
            } else { 
                if ( products[product_id] === undefined ) {
                    products[product_id] = {'name': product_name, 'id': product_id, 'package':[], 'errata':[], 'repo':[], 'distribution':[]};
                }
                products[product_id][type].push({name:display_name, id:id});
            } 
        },
        remove_item:function(type, id, product_id) {
            if( type === 'product' ){
                delete products[id];
            } else if (type == 'template') {
              delete templates[id];
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
            var success = function() {
                on_success();
                dep_solve();
            };

            change_state("review", success, on_error);
            changeset_breadcrumb['changeset_' + id].is_new = false;
            promotion_page.add_dependencies();
        },
        cancel_review: function(on_success, on_error) {
            change_state("new", on_success, on_error);
            changeset_breadcrumb['changeset_' + id].is_new = true;
        },
        promote: function(on_success, on_error, confirm) {
         var data = {},
             cs = this;
         if(confirm){
             data.confirm = confirm;
         }
         $.ajax({
            type: "POST",
            url: KT.common.rootURL() + "changesets/" + id + "/promote",
            cache: false,
            data: data,
            success: function(data) {
                if(data.warnings){ //if there is a warning, make the user confirm
                    var warn_elem = $("#warning_dialog");
                    var buttons = {};
                    warn_elem.find(".warning").html(data.warnings);
                    buttons[i18n.cancel] = function(){$(this).dialog('close'); on_error();};
                    buttons[i18n.continue_promotion] =function(){
                        $(this).dialog('close');
                        cs.promote(on_success, on_error, true)
                    };
                    warn_elem.dialog({
                        closeOnEscape: false,
                        modal: true,
                        title: i18n.warning,
                        buttons: buttons,
                        open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); }
                    })
                }
                else {
                    if (on_success) {
                        on_success();
                    }
                    changeset_breadcrumb['changeset_' + id].is_new = true;
                    changeset_breadcrumb['changeset_' + id].state = "new";
                    changeset_breadcrumb['changeset_' + id].progress = 0;
                    promotion_page.get_changeset_tree().render_content('changesets');
                    promotion_page.get_content_tree().render_content('content');
                }
            },
            error: function() {
                if(on_error) {
                    on_error();
                }
            }
            });
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
            url: KT.common.rootURL() + "changesets/" + id,
            data: JSON.stringify({data:data, timestamp:timestamp}),
            cache: false,
            success: on_success,
            error: on_error
          });
        }
    };
};

//doc ready
var registerEvents = function(){
    $('#save_changeset_button').live('click', function(){
        var button = $(this);
        if(button.hasClass("disabled")){return false;}
        button.addClass("disabled");
        $.ajax({
          type: "POST",
          url: button.attr('data-url'),
          data: $('#new_changeset').serialize(),
          cache: false,
          success: function(data){
              $.extend(changeset_breadcrumb, data.breadcrumb);
              promotion_page.set_changeset(changeset_obj(data.changeset));
              promotion_page.get_changeset_tree().render_content('changeset_' + data.id);
              KT.panel.closePanel($('#panel'));
          },
          error: function(){ button.removeClass("disabled");}
        });
        return true;
    });
    
    $("#delete_changeset").click(function() {
        var button = $(this);
        if (button.hasClass('disabled')){
            return false;
        }
        var id = promotion_page.get_changeset().id;
        KT.common.customConfirm(button.attr('data-confirm-text'), function(){
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
        });
        return true;
    });


    $("#review_changeset").live('click', function() {
       var button = $(this);
        if (button.hasClass('disabled')){
            return false;
        }
        button.addClass("disabled");
        var cs = promotion_page.get_changeset();
        if(cs.is_new() || cs.state() === "failed") { //move to review
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
                promotion_page.remove_dependencies();
            });
        }
        return true;
    });

    $("#promote_changeset").live('click', function() {
        if ($(this).hasClass("disabled")) {
            return false;
        }
        $(this).addClass("disabled");
        $("#sliding_tree_actionbar > div").addClass("disabled");
        var cs = promotion_page.get_changeset();
        var after = function() {$(this).removeClass("disabled");};
        var error = function(){
            after();
            $("#sliding_tree_actionbar > div").removeClass("disabled");
        };
        cs.promote(after, error);
        return true;
    });



    //Ask the user if they really want to leave the page if updates aren't finished
    window.onbeforeunload = function(){
        if(!promotion_page.are_updates_complete()){
            return i18n.leave_page;
        }
    };

    $('#conflict_close').click(promotion_page.hide_conflict);
    $('#conflict-details').click(promotion_page.show_conflict_details);

    $('#edit_changeset').live('click', function() {
        if ($(this).hasClass('disabled')){
            return false;
        }
        changesetEdit.toggle();
        return true;
    });

    KT.tipsy.custom.promotion_filter_tooltip();
};

var changesetEdit = (function(){

    var opened = false;

    var toggle = function(delay){
        var edit_window = $('#changeset_edit'),
        name_box = $('.edit_name_text'),
        edit_button = $('#edit_changeset > span'),
        description = $('.edit_description'),
        changeset = promotion_page.get_changeset(),
        animate_time = 500;

        if (delay != undefined){
            animate_time = delay;
        }

        opened = !opened;

        var after_function = undefined;
        if (opened) {
            name_box.html(changeset.getName());
            edit_button.html(i18n.close_details);
            description.html(changeset.getDescription());
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
        
        var changeset = promotion_page.get_changeset(),
        url = KT.common.rootURL() + "changesets/" + changeset.id,
        name_box = $('.edit_name_text'),
        description = $('.edit_description');
        
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

           description.each(function() {
                $(this).editable(url , {
                    type        :  'textarea',
                    method      :  'PUT',
                    name        :  $(this).attr('name'),
                    cancel      :  i18n.cancel,
                    submit      :  i18n.save,
                    indicator   :  i18n.saving,
                    tooltip     :  i18n.clickToEdit,
                    placeholder :  i18n.clickToEdit,
                    submitdata  :  {authenticity_token: AUTH_TOKEN},
                    rows        :  5,
                    cols        :  30,
                    onsuccess   :  function(data) {
                          var parsed = $.parseJSON(data);
                          $('.edit_description').html(parsed.description);
                          changeset.setDescription(data.description);
                          changeset.set_timestamp(parsed.timestamp);
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
                var split = hash.split("_"),
                page = split[0],
                changeset_id = split[1],
                product_id = split[2],
                cs = promotion_page.get_changeset();

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
                inReviewPhase = (!changeset.is_new() && (changeset.state() !== "failed"));
            
            if (key === 'package-cs'){
                return templateLibrary.listItems(changeset.getProducts(), "package", product_id, !inReviewPhase);
            }
            else if (key === 'errata-cs'){
                return templateLibrary.listItems(changeset.getProducts(), "errata", product_id, !inReviewPhase);
            }
            else if (key === 'repo-cs'){
                return templateLibrary.listItems(changeset.getProducts(), "repo", product_id, !inReviewPhase);
            }
            else if (key === 'distribution-cs'){
                return templateLibrary.listItems(changeset.getProducts(), "distribution", product_id, !inReviewPhase);
            }
            else if (key === 'deps-cs'){
                return templateLibrary.dependencyItems(changeset.getProducts(), product_id);
            }
            else if (key === 'product-cs'){

                //var types = promotion_page.subtypes;
                var types = promotion_page.subtypes.slice(0); //copy the array
                if (!promotion_page.get_changeset().is_new()) {
                    types.push("deps");
                } 
                return templateLibrary.productDetailList(changeset.getProducts()[product_id], types, changeset_id);
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
            html += templateLibrary.conflictTemplates(conflict.templates_added, conflict.templates_removed);
            return html;
        };

    return {
        render: render,
        renderConflict: renderConflict
    };
})();

var templateLibrary = (function(){
    var changesetsListItem = function(id, name){
            var html ='<li class="slide_link">' + '<div class="simple_link link_details" id="' + id + '">';

            html += '<span class="sort_attr">'+ name + '</span></div></li>';
            return html;
        },
        changesetsList = function(changesets){
            var html = '<ul class="filterable">';
            $.each(changesets, function(item){
                if( changesets.hasOwnProperty(item) ){
                    //do the search filter here
                    if( item.split("_")[0] === "changeset" ){
                        html += changesetsListItem(item, changesets[item].name);
                    }
                }
            });
            html += '</ul>';
            return html;
        },
        productDetailList = function(product, subtypes, changeset_id) {
            var html = '<ul class="filterable">';
             $.each(subtypes, function(index, type) {
                 if (product[type]) {
                    html += '<li class="slide_link"><div class="simple_link link_details"';
                 } else {
                     html += '<li><div ';
                 }

                 html += 'id=' + type +'-cs_' + changeset_id + '_' + product.id + '>';

                html += '<span class="sort_attr">' + i18n[type];
                if (product[type]) {
                    html += ' (' + product[type].length  + ')';
                }
                else {
                    html += "<img class='fr' src='" + KT.common.spinner_path() + "'>";
                }

                html += '</span></li>';
             });
            html += '</ul>';
            return html;
        },
        dependencyItems = function(products, product_id) {
            if (!products[product_id].deps) {
                return i18n.loading_deps + "&nbsp;" + "<img  src='" + KT.common.spinner_path() + "'>";
            }

            var html = '<ul class="filterable">';
            $.each(products[product_id].deps, function(index, item) {
                html += '<li><div class="no_slide"><span class="sort_attr">'  + item.name + ' ' + '</span>';
               // html += '<div class="dependency_of">' + i18n.dep_of + "&nbsp;" + item.dep_of + "</div>";
                html += '</div></li>';

            });
            html += '</ul>';
            return html;
        },
        listItems = function(products, type, product_id, showButton) {
            var html = '<ul class="filterable">';
            var items = products[product_id][type];
            if (items.length === 0) {
                return i18n["no_" + type]; //no_errata no_package no_repo no_distribution
            }
            $.each(items, function(index, item) {
               //for item names that mach item.name from search hash
               html += listItem(item.id, item.name, type, product_id, showButton, item.filtered);
            });
            html += '</ul>';
            return html;
        },
        listItem = function(id, name, type, product_id, showButton, isFiltered) {
            var anchor = "", 
                filter_repo_class = "";
            if ( showButton && permissions.manage_changesets){
                anchor = '<a ' + 'class="fr content_add_remove remove_' + type + ' + st_button"' +
                                 'data-type="' + type + '" data-product_id="[' + product_id +  ']" data-id="' + id + '">';
                            anchor += i18n.remove + "</a>";
            }
            if(type === "repo" && isFiltered) {
                filter_repo_class = '<span class="filter_warning_icon fl promotion_tipsify"' + " data-content_id=\"" +
                            id +"\" data-content_type=\"repo\""  + '>&nbsp;</span> ';
            }


            return '<li>' + anchor + '<div class="no_slide">' + filter_repo_class + '<span class="sort_attr">'  + name + '</span></div></li>';

        },
        productList = function(changeset, changeset_id, showButton){
            var ul_start = '<ul class="filterable">',
                ul_end = '</ul>',
                html = ul_start,
                all_list = '',
                partial_list = '',
                system_templates_list = '',
                product, provider,
                products = changeset.getProducts(),
                templates = changeset.getTemplates();

            if( changeset.productCount() === 0 ){
                html += '<h5>'+i18n.product_plural+'</h5>';
                html += '<div class="empty_list">' + i18n['no_products'] + '</div>';
                //html += i18n['no_products'];
            } else {
                for( key in products ){
                    if( products.hasOwnProperty(key) ){
                        product = products[key];
                        provider = (product.provider === 'REDHAT') ? 'rh' : 'custom';
                        toSlide = product.all ? 'no_slide' : 'slide_link';
                        if( product.all ){
                          all_list += productListItem(changeset_id, key, product.name, provider, toSlide, showButton, product.filtered);
                        }
                        else {
                            partial_list += productListItem(changeset_id, key, product.name, provider, toSlide, false, product.filtered);
                        }
                    }
                }
            }



            for(key in templates) {
               if(templates.hasOwnProperty(key) ){
                  template = templates[key];
                  system_templates_list += templateItem(changeset_id, key, template.name, showButton);
               }
            }
            html += ul_end + ul_start;

            html += all_list ? ('<h5>'+i18n.full_product+'</h5>' + all_list) : '';
            html += ul_end + ul_start;
            html += partial_list ? ('<h5>'+i18n.partial_product+'</h5>' + partial_list) : '';
            html += ul_end + ul_start;
            html += '<h5>'+i18n.system_template_plural+'</h5>';
            html += system_templates_list ? system_templates_list : '<div class="empty_list">' + i18n['no_system_templates'] + '</div>';
            html += ul_end;
            return html;
        },
        templateItem = function(changeset_id, id, name, showButton){
            var anchor = "",
                html = '';
            if ( showButton ){
                anchor = '<a class="st_button content_add_remove fr remove_template" data-display_name="' +
                    name +'" data-id="' + id + '" data-type="template" id="add_remove_template_' + id +
                    '" data-template_id="' + id +
                    '">' + i18n.remove + '</a>';
            }
            html += '<li class="clear">' + anchor;
            html += '<div id="simple_link template-cs_' + changeset_id + '_' + id + '">' +
                    '<span class="template-icon sort_attr" >' + name + '</span>' +
                    '</div></li>';

            return html;
        },
        conflictTemplates = function(added, removed) {
            if (added.length === 0 && removed.length === 0) {
                return "";
            }
            var html = "<h3>"+ i18n.templates +"</h3>";
            html +="<div>";
            html += conflictAccordianListItem(true, added);
            html += conflictAccordianListItem(false, removed);
            html += "</div>";
            return html;
        },
        productListItem = function(changeset_id, product_id, name, provider, slide_link, showButton, isFiltered){
            var anchor = "",
                html = '';

            if ( showButton ){
                anchor = '<a class="st_button content_add_remove fr remove_product" data-display_name="' +
                    name +'" data-id="' + product_id + '" data-type="product" id="add_remove_product_' + product_id +
                    '" data-product_id="[' + product_id +
                    ']">' + i18n.remove + '</a>';
            }
            html += '<li class="clear ' + slide_link + '">' + anchor + '<div class="simple_link ';
            html += (slide_link === 'slide_link') ? 'link_details' : '';
            html += '" id="product-cs_' + changeset_id + '_' + product_id + '">';
            if (isFiltered) {
                html += '<span class="filter_warning_icon fl promotion_tipsify"' + " data-content_id=\"" +
                            product_id +"\" data-content_type=\"product\""  + '>&nbsp;</span> ';
            }
            html += '<span class="' + provider + '-product-sprite"></span>' +
                    '<span class="sort_attr" >' + name + '</span>' +
                    '</div></li>';

            return html;
        },
        conflictFullProducts = function(added, removed) {
            if (added.length === 0 && removed.length === 0) {
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
                html += "<li class='conflict_item'>" + item +  "</li>";
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
        conflictTemplates: conflictTemplates,
        conflictProduct: conflictProduct,
        dependencyItems: dependencyItems
    };
})();

var changesetStatusActions = (function($){
    var set_margins = function(){
            if( $('.progressbar').length ) {
                $('#cslist .slider .link_details:not(:has(.progressbar)):not(:has(.locked_icon))').css('margin-left', '43px');
                $('#cslist .slider .link_details:not(:has(.progressbar)) .locked_icon').css({'margin-left': '9px', 'margin-right' : '22px'});
            } else if( $('#cslist .locked_icon').length ){
                $('#cslist .slider .link_details:not(:has(.progressbar)):not(:has(.locked_icon))').css('margin-left', '20px');
            }
        },
        initProgressBar = function(id, status, status_text){
            var changeset = $('#' + id),
                status_title = status_text;

            if (status_text === undefined) {
                status_text = i18n.promoting;
                status_title = i18n.changeset_progress;
            }

            changeset.css('margin-left', '0');
            changeset.prepend('<span class="changeset_status"><span class="progressbar"></span><label></label></span>');
            changeset.find('.changeset_status label').text(status + '%');
            //changeset.find('.progressbar').progressbar({value: status});
            changeset.addClass('being_promoted');
            changeset.attr('title', status_title);
            changeset.find('.changeset_status label').text(status_text);
            set_margins();
        },
        setProgress = function(id, progress){
            var changeset = $('#' + id);  
            //changeset.find(".progressbar").progressbar({value: progress});
            //changeset.find('.changeset_status label').text(progress + '%');
        },
        finish = function(id){
            var changeset = $('#' + id);
            changeset.find(".changeset_status label").text(i18n.promoted);
            changeset.attr('title', i18n.promoted);
            /*changeset.parent().fadeOut(3000, function(){
                changeset.parent().remove();
                if( !$('.changeset_status').length ){
                    $('#cslist .slider .link_details').animate({'margin-left' : '0'}, 200);
                }
            });*/
        },
        failed = function(id){
            // if the promotion failed, check the server for additional details (via notices)
            notices.checkNotices();

            var changeset = $('#' + id);
            changeset.find(".changeset_status label").text(i18n.promotion_failed);
            changeset.attr('title', i18n.promotion_failed);

            changeset_breadcrumb[id].has_failed = true;
        },
        setLocked = function(id){
            var changeset = $('#' + id);
            changeset.css('margin-left', '0');
            changeset.prepend('<img class="fl locked_icon" src="' + KT.common.rootURL() + '/images/icons/locked.png">');
            set_margins();
        },
        removeLocked = function(id){
            var changeset = $('#' + id);
            changeset.find('img').remove();
            changeset.css('margin-left', '20px');
            if( !$('#cslist .locked_icon').length ){
                $('#cslist .slider .link_details').css('margin-left', '0');
            }
        },
        checkProgressTask = function(id){
            var timeout = 8000;
            var updater = $.PeriodicalUpdater(KT.common.rootURL() + 'changesets/' + id + '/promotion_progress/', {
                method: 'GET',
                type: 'JSON',
                cache: false,
                global: false,
                minTimeout: timeout,
                maxTimeout: timeout
            }, function(data, success){

                setProgress(data.id, data.progress);

                if (success === "notmodified") {
                  // received a 304 not modified...
                  var changeset_id = 'changeset_' + id;
                  if (changeset_breadcrumb[changeset_id].has_failed === true) {
                      // attempting to promote this changeset previously failed..., so if the promotion progress
                      // remains 'not modified' that implies that it failed again...
                      failed(changeset_id);
                      updater.stop();
                  }
                } else if ((data.progress === 100) || (data.state === 'promoted')){
                    delete changeset_breadcrumb['changeset_' + id];
                    finish(data.id);
                    updater.stop();
                } else if (data.state === 'failed') {
                    failed(data.id);
                    updater.stop();
                }
            });
        };
        
    return {
        initProgressBar     : initProgressBar,
        setProgress         : setProgress,
        finishProgess       : finish,
        checkProgressTask   : checkProgressTask,
        setLocked           : setLocked,
        removeLocked        : removeLocked
    };
})(jQuery);

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
          var prod_id = $.parseJSON($(this).attr('data-product_id'));
          promotion_page.modify_changeset(id, display, type, prod_id);
       }
    });
    
    $('#changeset_users').hide();

    //initiate the left tree
    var contentTree = sliding_tree("content_tree", {
                                        breadcrumb      :  content_breadcrumb,
                                        default_tab     :  "content",
                                        bbq_tag         :  "content",
                                        base_icon       :  'home_img',
                                        tab_change_cb   :  promotion_page.set_current_product,
                                        expand_cb       :  promotion_page.reset_page //need to reset page during the extended scroll
                                    });
    contentTree.enableSearch();
    promotion_page.set_content_tree(contentTree);

    $(document).bind('search_complete.slidingtree', promotion_page.reset_page);

    promotion_page.set_changeset_tree( sliding_tree("changeset_tree", { 
                                        breadcrumb      :  changeset_breadcrumb,
                                        default_tab     :  "changesets",
                                        bbq_tag         :  "changeset",
                                        base_icon       :  'home_img',
                                        render_cb       :  promotionsRenderer.render,
                                        enable_filter   :  true,
                                        enable_float	:  true,
                                        tab_change_cb   :  function(hash_id) {
                                          promotion_page.init_changeset_list();
                                        }
                                    }));


    $(window).trigger('hashchange');

    //when loading the new panel item, if its new, we need to add a form submit handler
    KT.panel.set_expand_cb(function(id) {
        if (id === 'new') {
          $('#new_changeset').submit(function(e) {
              e.preventDefault();
              $('#save_changeset_button').trigger('click');
          });
        }
    });

    //set function for env selection callback
    env_select.click_callback = promotion_page.env_change;

    registerEvents();

    $(document).ajaxComplete(function(event, xhr, options){
        var userHeader = xhr.getResponseHeader('X-ChangesetUsers');
        if(userHeader !== null && userHeader !== undefined) {
          var userj = $.parseJSON(userHeader); 
          promotion_page.checkUsersInResponse(userj);
        }
    });

   	KT.panel.registerPanel($('#changeset_tree'), $('#content_tree').width() + 50);
   	
   	var tupane = $('#panel');
   	$(document).bind('hash_change.slidingtree', function(){
   		if( tupane.hasClass('opened') ){
   			KT.panel.closePanel(tupane);
   		}
   	});

});
