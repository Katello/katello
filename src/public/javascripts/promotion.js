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
    changeset_tree: undefined,
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
        return $("a[class~=content_add_remove][data-id=" + common.escapeId(id) + "][data-type=" + type + "]");
    },
    push_changeset: function() {

        if(promotion_page.changeset_queue.length > 0 &&  promotion_page.current_changeset) {
            promotion_page.stop_timer();
            data = [];
            while(promotion_page.changeset_queue.length > 0) {
                data.push(promotion_page.changeset_queue.shift());
            }
            
            //var changeset_id = promotion_page.current_changeset.id;
            promotion_page.current_changeset.update(data,
                function(data) {
                    if (promotion_page.changeset_queue.length !== 0 && data.changeset) {
                        //don't update timestamp
                    }
                    else {
                        if(data.changeset) {
                            promotion_page.current_changeset = changeset_obj(data.changeset);
                            console.log("Resetting page - after refresh");
                            promotion_page.reset_page();
                            promotion_page.changeset_tree.rerender_content();
                        }
                        else {
                            promotion_page.current_changeset.set_timestamp(data.timestamp);
                        }
                    }

                    //promotion_page.update_dep_size();
                    promotion_page.start_timer();
                },
                promotion_page.throw_error);
        }

    },
    throw_error: function() {
        $("#error_dialog").dialog({
            closeOnEscape: false,
            modal: true,
            //Remove the close button
            open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); }
        });

    },
    modify_changeset: function(id, display, type, product_id) {
        var changeset = promotion_page.current_changeset;
        var adding = true;
        if ( changeset && changeset.has_item(type, id, product_id)) {
            adding = false;
        }

        var button = promotion_page.find_button(id, type);
        if (adding) {
            button.html(i18n.remove).addClass("remove_" + type).removeClass('add_'+type);
            if( type !== 'product'){
                product_name = content_breadcrumb['details_' + product_id].name;
                if( changeset.productCount() === 0 ){
                    promotion_page.add_product_breadcrumbs(changeset.id, product_id, product_name);
                }
            }
            changeset.add_item(type, id, display, product_id, product_name);
        }
        else {
            button.html(i18n.add).addClass("add_" + type).removeClass('remove_' + type);
            changeset.remove_item(type, id, product_id);
        }
        promotion_page.changeset_tree.rerender_content();
        promotion_page.sort_changeset();
        promotion_page.changeset_queue.push([type, id, display, adding, product_id]);
    },
    sort_changeset: function() {
        return false;
        console.log("SORTING");
        $(".right_tree .will_have_content").find("li").sortElements(function(a,b){
            if (a && b) {
                return $(a).children("span").first().html().toUpperCase() >
                        $(b).children("span").first().html().toUpperCase() ? 1 : -1;
            }
        });
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
        else if (promotion_page.current_changeset === undefined) {
            
        }
        else if (id[0] === "changeset" && id[1] !==  promotion_page.current_changeset.id) {
           promotion_page.current_changeset = undefined;
        }
        else {
            promotion_page.reset_page();
        }
    },
    fetch_changeset: function(changeset_id, callback) {

            $("#changeset_loading").css("z-index", 300);
            $.ajax({
                type: "GET",
                url: "/changesets/" + changeset_id + "/object/",
                cache: false,
                success: function(data) {
                    $("#changeset_loading").css("z-index", -1);
                    promotion_page.current_changeset = changeset_obj(data);
                    promotion_page.reset_page();
                    $("#delete_changeset").removeClass("disabled");
                    callback();
                }});

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
        if (promotion_page.current_changeset) {
            if (promotion_page.current_product) {
                var product = promotion_page.current_changeset.products[promotion_page.current_product];
                if( product !== undefined && product.all !== undefined ){
                    promotion_page.disable_all();
                } else {
                    jQuery.each(promotion_page.subtypes, function(index, type){
                        var buttons = $('#list').find("a[class~=content_add_remove][data-type=" + type + "]");
                        buttons.html(i18n.add).removeClass('remove_' + type).addClass("add_" + type).removeClass("disabled");
                        if (product) {
                            jQuery.each(product[type], function(index, item) {
                                $("a[class~=content_add_remove][data-type=" + type+ "][data-id=" + item.id +"]").html(i18n.remove).removeClass('add_' + type).addClass("remove_" + type);
                            });
                        }
                    });
                }
            } else {
                var buttons = $('#list').find("a[class~=content_add_remove][data-type=product]");
                buttons.removeClass('disabled');
                $.each(promotion_page.current_changeset.products, function(index, item) {
                    if( buttons.attr('id') === ('add_remove_product_' + item.id) ){
                        buttons.html(i18n.remove).removeClass('add_product').addClass("remove_product").removeClass("disabled");
                    }
                });
            }
        } else {
            promotion_page.disable_all();
        }

        //Reset the review/promote/cancel button
        var action_btn =  $("#changeset_action");
        var cancel_btn = $("#review_cancel");
        if (promotion_page.current_changeset) {
           action_btn.show();
            if (promotion_page.current_changeset.is_new()) {
                cancel_btn.hide();
                action_btn.html(i18n.review);
            }
            else {
                cancel_btn.show();
                action_btn.html(i18n.promote);
            }
        }
        else {
            cancel_btn.hide();
            action_btn.hide();
        }


    },
    disable_all: function(){
        jQuery.each(promotion_page.types, function(index, type){
            var buttons = $("a[class~=content_add_remove][data-type=" + type + "]");
            buttons.addClass('disabled').html(i18n.add);
        });        
    },
    checkUsersInResponse: function(users) {
      if (users.length > 0) {
        var msg = users.join(", ") + ' ' + i18n.viewing;
        $('#changeset_users').html(msg).fadeIn(); 
      }
      else {
        $('#changeset_users').fadeOut("slow", function() { $(this).html(""); });
      }
    },
    add_product_breadcrumbs: function(changeset_id, product_id, product_name){
        var productBC = 'product-cs_' + changeset_id + '_' + product_id;
        changeset_breadcrumb[productBC] = {
            cache: null,
            client_render: true,
            name: product_name,
            trail: ['changesets', 'changeset_8'],
            url: 'url'
        };
        changeset_breadcrumb['package-cs_' + changeset_id + '_' + product_id] = {
            cache: null,
            client_render: true,
            name: "Packages",
            trail: ['changesets', 'changeset_8', productBC],
            url: ''
        };
        changeset_breadcrumb['errata-cs_' + changeset_id + '_' + product_id] = {
            cache: null,
            client_render: true,
            name: "Errata",
            trail: ['changesets', 'changeset_8', productBC],
            url: ''
        };
        changeset_breadcrumb['repo-cs_' + changeset_id + '_' + product_id] = {
            cache: null,
            client_render: true,
            name: "Repositories",
            trail: ['changesets', 'changeset_8', productBC],
            url: ''
        };
    },
    cs_filter : function(word){
        console.log($("li:contains('" + word + "')"));
        return false;
    }
};


var changeset_obj = function(data_struct) {
    var id = data_struct["id"],
        timestamp = data_struct["timestamp"],
        products = data_struct.products;
        is_new = data_struct.is_new;

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
                console.log("ISNEW: " + is_new);
                on_success();
            },
            error: function(data) {
                if (data.changeset) {
                    alert("The changeset has changed");
                    promotion_page.current_changeset = changeset_obj(data.changeset);
                }
                else {
                    promotion_page.throw_error();
                }
            }
          });
    };

    return {
        id:id,
        is_new : function() {return is_new},
        products: products,
        set_timestamp:function(ts) { timestamp = ts},
        timestamp: function(){return timestamp},
        productCount: function(){
            var count = 0;
            
            for( item in products ){
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
                    if(item.id == id){
                        found = true;
                        return false;
                    }
                });
            }
            return found !== undefined;
        },
        add_item:function (type, id, display_name, product_id, product_name) {
            if( type === 'product' ){
                products[id] = {'name': display_name, 'package':[], 'errata':[], 'repo':[], 'all': true}
            } else { 
                if ( products[product_id] === undefined ) {
                    products[product_id] = {'name': product_name, 'package':[], 'errata':[], 'repo':[]}
                }
                products[product_id][type].push({name:display_name, id:id})
            } 
        },
        remove_item:function(type, id, product_id) {
            console.log(type + "," + id + "," + product_id);

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
        },
        cancel_review: function(on_success, on_error) {
            change_state("new", on_success, on_error);
        },
        promote: function() {

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

//doc ready
$(document).ready(function() {

    //promotion_page.update_dep_size();
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
                                      tab_change_cb: promotion_page.set_current_product});

  	promotion_page.changeset_tree = sliding_tree("changeset_tree", {breadcrumb:changeset_breadcrumb,
                                      default_tab:"changesets",
                                      bbq_tag:"changeset",
                                      //render_cb: promotion_page.set_current_changeset,
                                      render_cb: promotionsRenderer.render,
                                      //use this do do anything before the next changeset or pane is rendered
                                      prerender_cb: function() {
                                          promotion_page.set_current_changeset
                                      },
                                      tab_change_cb: function(hash_id) {
                                          //promotion_page.set_current_changeset(hash_id);
                                          promotion_page.sort_changeset();
                                      }});



    $('#depend_list').live('click', promotion_page.show_dependencies);

    //set function for env selection callback
    env_select.click_callback = promotion_page.env_change;

    registerEvents(promotion_page.changeset_tree);

    $(document).ajaxComplete(function(event, xhr, options){
        var userHeader = xhr.getResponseHeader('X-ChangesetUsers');
        if(userHeader != null) {
          var userj = $.parseJSON(userHeader); 
          promotion_page.checkUsersInResponse(userj);
        }
    });

    //click and animate the filter for changeset
    var bcs = null;
    var bcs_height = 0;
    $('.search_button').toggle(
        function() {
            bcs = $('.breadcrumb_search');
            bcs_height = bcs.height();
            bcs.animate({ "height": bcs_height+36}, { duration: 200, queue: false });
            $("#search_form").css("opacity", "0").show();
            $("#search_form").animate({"width":"240px", "opacity":"1"}, { duration: 200, queue: false });
            $(this).animate({backgroundPosition:"-32px 0"}, { duration: 200, queue: false });
        },function() {
            $("#search_form").fadeOut('fast', function(){bcs.animate({ "height": bcs_height }, 'fast');});
            $(this).animate({backgroundPosition:"0 0"}, { duration: 200, queue: false });
        }
    );

    //bind to the #search_form to make it useful
    $('#search_form').submit(function(){
        $('#search').keyup();
        return false;
    });

    $('#search').live('keyup', function(){
        if ($.trim($(this).val()).length >= 2) {
            $("#cslist .has_content li:not(:contains('" + $(this).val() + "'))").filter(':not').fadeOut();
        } else {
            $(".has_content li").fadeIn();
        }
    });
    $('#search').val("").keyup();
        
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
              promotion_page.current_changeset = changeset_obj(data.changeset);
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

    $("#changeset_action").live('click', function() {
       var button = $(this);
        if (button.hasClass('disabled')){
            return false;
        }
        button.addClass("disabled");
        var cs = promotion_page.current_changeset;
        if(cs.is_new()) {
            cs.review(function() {
                $("#changeset_action").html(i18n.promote).attr("data-confirm", i18n.promote_confirm);
                $("#review_cancel").show();
                button.removeClass("disabled");
            });
        }
        else {
            cs.promote();
        }
    });

    $("#review_cancel").live('click', function() {
        $("#review_cancel").addClass("disabled");
        var cs = promotion_page.current_changeset;
        cs.cancel_review(function() {
            $("#changeset_action").html(i18n.review);
            $("#review_cancel").hide();
            $("#review_cancel").removeClass("disabled");
        });
    });

};

var promotionsRenderer = (function($){
    var render = function(hash, render_cb){
            if( hash === 'changesets'){
                render_cb(templateLibrary.changesetsList(changeset_breadcrumb));
            }
            else {
                var changeset_id = hash.split("_")[1];
                var product_id = hash.split("_")[2]; 

                if (promotion_page.current_changeset === undefined) {
                    promotion_page.fetch_changeset(changeset_id, function() {
                        render_cb(getContent(hash));
                    });
                }
                else {
                    render_cb(getContent(hash));
                }
            }
        },
        getContent =  function(hash) {
            var changeset_id = hash.split("_")[1];
            var product_id = hash.split("_")[2];
            var key = hash.split("_")[0];
            if (key === 'package-cs'){
                return templateLibrary.listItems("package", product_id, changeset_id);
            }
            else if (key === 'errata-cs'){
                return templateLibrary.listItems("errata", product_id, changeset_id);
            }
            else if (key === 'repo-cs'){
                return templateLibrary.listItems("repo", product_id, changeset_id);
            }
            else if (key === 'product-cs'){
                return templateLibrary.productDetailList(product_id, changeset_id);
            }
            else if (hash.split("_")[0] === 'changeset'){
                return templateLibrary.productList(promotion_page.current_changeset.products, promotion_page.current_changeset.id);
            }
        };

    return {
        render: render
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
                    //do the search filter here
                    if( item.split("_")[0] === "changeset" ){
                        html += changesetsListItem(item, changesets[item].name);
                    }
                }
            }
            html += '</ul>';
            return html;
        },
        productDetailList = function(product_id, changeset_id) {
            var html = '<ul>';
             jQuery.each(promotion_page.subtypes, function(index, type) {
                html += '<li><div class="slide_link" id="' + type +'-cs_' + changeset_id + '_' + product_id + '">';
                html += '<span>' + i18n[type] + ' (' + promotion_page.current_changeset.products[product_id][type].length
                        + ')</span></li>';
             });
            html += '</ul>';
            return html;
        },
        listItems = function(type, product_id, changeset_id) {
            var html = '<ul>';
            var items = promotion_page.current_changeset.products[product_id][type];
            if (items.length === 0) {
                return i18n["no_" + type]; //no_errata no_package no_repo
            }
            jQuery.each(items, function(index, item) {
               //for item names that mach item.name from search hash
               html += listItem(item.id, item.name, type, product_id);
            });
            html += '</ul>';
            return html;
        },
        listItem = function(id, name, type, product_id) {
            var anchor = '<a ' + 'class="fl content_add_remove remove_' + type + ' + button"'
                + 'data-type="' + type + '" data-product_id="' + product_id +  '" data-id="' + id + '">';
            anchor += i18n.remove + "</a>";
            return '<li>' + anchor + '<span class="item">'  + name + '</span></li>';

        },
        productList = function(products, changeset_id){
            var html = '<ul>', 
                product, provider,
                all, 
                count = 0;
            
            for( key in products ){
                if( products.hasOwnProperty(key) ){
                    product = products[key];
                    provider = (product.provider === 'REDHAT') ? 'rh' : 'custom';
                    all = product.all ? 'no_slide' : 'slide_link';
                    html += productListItem(changeset_id, key, product.name, provider, all)
                }
                count += 1;
            }
            if( count === 0 ){
                html += i18n['no_products'];
            }
            html += '</ul>';
            return html;
        },
        productListItem = function(changeset_id, product_id, name, provider, slide_link){
            return '<li class="clear">' + 
                    '<a class="content_add_remove button fl remove_product" data-display_name="' + 
                    name +'" data-id="' + 
                    product_id + '" data-type="product" id="add_remove_product_' + product_id + 
                    '">Remove</a>' +
                    '<div class="' + slide_link + '" id="product-cs_' + changeset_id + '_' + product_id + '">' +
                    '<span class="' + provider + '-product-sprite"></span>' +
                    '<span class="product-icon" >' + name + '</span>' +
                    '</div></li>';
        };
    
    return {
        changesetsList: changesetsList,
        productList: productList,
        listItems : listItems,
        productDetailList: productDetailList
    };
})();
