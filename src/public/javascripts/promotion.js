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


var promotion_page = (function(){
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
        //Finds the add/remove buttons in the left pane
        find_button = function(id, type) {
            return $("a[class~=content_add_remove][data-id=" + common.escapeId(id) + "][data-type=" + type + "]");
        },
        push_changeset = function() {
    
            if(changeset_queue.length > 0 &&  current_changeset) {
                stop_timer();
                data = [];
                while(changeset_queue.length > 0) {
                    data.push(changeset_queue.shift());
                }
                
                //var changeset_id = current_changeset.id;
                current_changeset.update(data,
                    function(data) {
                        if (changeset_queue.length !== 0 && data.changeset) {
                            //don't update timestamp
                        }
                        else {
                            if(data.changeset) {
                                current_changeset = changeset_obj(data.changeset);
                                console.log("Resetting page - after refresh");
                                reset_page();
                                changeset_tree.rerender_content();
                            }
                            else {
                                current_changeset.set_timestamp(data.timestamp);
                            }
                        }
    
                        //update_dep_size();
                        start_timer();
                    },
                    throw_error);
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
                    if( changeset.productCount() === 0 ){
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
                    var product = changeset.products[product_id];
                    if( !product.errata.length && !product.package.length && !product.repo.length ){
                        delete changeset.products[product_id];
                        changeset_tree.render_content('changeset_' + changeset.id);
                    } else {
                        changeset_tree.rerender_content();
                    }
                } else {
                    changeset_tree.rerender_content();       
                }
            }
            sort_changeset();
            changeset_queue.push([type, id, display, adding, product_id]);
        },
        sort_changeset = function() {
            console.log("SORTING");
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
        set_current_changeset = function(hash_id) {
            var id = hash_id.split("_");
            if (id[0] === "changesets") {
                current_changeset = undefined;
                reset_page();
                $("#delete_changeset").addClass("disabled");
            }
            else if (current_changeset === undefined) {
                
            }
            else if (id[0] === "changeset" && id[1] !==  current_changeset.id) {
               current_changeset = undefined;
            }
            else {
                reset_page();
            }
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
                    var product = current_changeset.products[current_product];
                    if( product !== undefined && product.all !== undefined ){
                        disable_all(subtypes);
                    } else {
                        jQuery.each(subtypes, function(index, type){
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
                    $.each(current_changeset.products, function(index, item) {
                        if( buttons.attr('id') === ('add_remove_product_' + item.id) ){
                            buttons.html(i18n.remove).removeClass('add_product').addClass("remove_product").removeClass("disabled");
                        }
                    });
                }
            } else {
                disable_all(types);
            }
    
            //Reset the review/promote/cancel button
            var action_btn =  $("#changeset_action");
            var cancel_btn = $("#review_cancel");
            if (current_changeset) {
               action_btn.show();
                if (current_changeset.is_new()) {
                    cancel_btn.hide();
                    action_btn.html(i18n.review);
                    $("#changeset_tree .tree_breadcrumb").removeClass("locked_breadcrumb");
                    $("#cslist").removeClass("locked");
                    $('#locked_icon').remove();
                    $(".content_add_remove").show();
                }
                else { //in review stage
                    cancel_btn.show();
                    action_btn.html(i18n.promote);
                    $("#changeset_tree .tree_breadcrumb").addClass("locked_breadcrumb");
                    $("#changeset_tree .tree_breadcrumb").append('<img id="locked_icon" class="fl locked_icon" src="/images/icons/locked.png">');
                    $("#cslist").addClass("locked");
                    $(".content_add_remove").hide();
                }
            }
            else {
                $("#changeset_tree .tree_breadcrumb").removeClass("locked_breadcrumb");
                $("#cslist").removeClass("locked");
                $('#locked_icon').remove();
                $(".content_add_remove").show();
                cancel_btn.hide();
                action_btn.hide();
            }
    
    
    
    
        },
        disable_all = function(types){
            var types = types || subtypes;
            jQuery.each(types, function(index, type){
                var buttons = $("a[class~=content_add_remove][data-type=" + type + "]");
                buttons.addClass('disabled').html(i18n.add);
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
            changeset_breadcrumb[productBC] = {
                cache: null,
                client_render: true,
                name: product_name,
                trail: ['changesets', 'changeset_8'],
                url: 'url'
            }
            changeset_breadcrumb['package-cs_' + changeset_id + '_' + product_id] = {
                cache: null,
                client_render: true,
                name: "Packages",
                trail: ['changesets', 'changeset_8', productBC],
                url: ''
            }
            changeset_breadcrumb['errata-cs_' + changeset_id + '_' + product_id] = {
                cache: null,
                client_render: true,
                name: "Errata",
                trail: ['changesets', 'changeset_8', productBC],
                url: ''
            }
            changeset_breadcrumb['repo-cs_' + changeset_id + '_' + product_id] = {
                cache: null,
                client_render: true,
                name: "Repositories",
                trail: ['changesets', 'changeset_8', productBC],
                url: ''
            }
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
        set_current_changeset:  set_current_changeset,
        set_current_product:    set_current_product,
        show_dependencies:      show_dependencies,
        env_change:             env_change,
        checkUsersInResponse:   checkUsersInResponse,
        start_timer:            start_timer,
        reset_page:             reset_page,
        throw_error:            throw_error
    };
}());


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
        products: products,
        is_new : function() {return is_new},
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
            changeset_breadcrumb['changeset_' + id].is_new = false;
        },
        cancel_review: function(on_success, on_error) {
            change_state("new", on_success, on_error);
            changeset_breadcrumb['changeset_' + id].is_new = true;
        },
        promote: function(on_success, on_error) {
         $.ajax({
            contentType:"application/json",
            type: "POST",
            url: "/changesets/" + id + "/promote",
            cache: false,
            success: function(data) {
                on_success();
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

  	promotion_page.set_changeset_tree( sliding_tree("changeset_tree", {breadcrumb:changeset_breadcrumb,
                                      default_tab:"changesets",
                                      bbq_tag:"changeset",
                                      //render_cb: promotion_page.set_current_changeset,
                                      render_cb: promotionsRenderer.render,
                                      prerender_cb: promotion_page.set_current_changeset,
                                      tab_change_cb: function(hash_id) {
                                          //promotion_page.set_current_changeset(hash_id);
                                          promotion_page.sort_changeset();
                                      }}));

    //need to reset page during the extended scroll
    panel.extended_cb = promotion_page.reset_page;

    $('#depend_list').live('click', promotion_page.show_dependencies);

    //set function for env selection callback
    env_select.click_callback = promotion_page.env_change;

    registerEvents(promotion_page.get_changeset_tree());

    $(document).ajaxComplete(function(event, xhr, options){
        var userHeader = xhr.getResponseHeader('X-ChangesetUsers');
        if(userHeader != null) {
          var userj = $.parseJSON(userHeader); 
          promotion_page.checkUsersInResponse(userj);
        }
    });
    
     var container = $('#container');
     var original_top = Math.floor($('.left').position(top).top);
     if(container.length > 0){
         var bodyY = parseInt(container.offset().top, 10) - 20;
         $(window).scroll(function () {
             panel.handleScroll($('#changeset_tree'), container, original_top, bodyY, 0);
         });
    }
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
              promotion_page.set_changeset(changeset_obj(data.changeset));
              changesetTree.render_content('changeset_' + data.id);
              panel.closePanel($('#panel'));
          }
        });
    });
    
    $("#delete_changeset").click(function() {
        var button = $(this);
        var id = promotion_page.get_changeset().id;
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
        var cs = promotion_page.get_changeset();
        if(cs.is_new()) {
            cs.review(function() {
                $("#changeset_action").html(i18n.promote).attr("data-confirm", i18n.promote_confirm);
                $("#review_cancel").show();
                button.removeClass("disabled");
                promotion_page.reset_page();
                promotion_page.get_changeset_tree().rerender_content();
            });
        }
        else {
            cs.promote(function() {
                
            });
        }
    });

    $("#review_cancel").live('click', function() {
        $("#review_cancel").addClass("disabled");
        var cs = promotion_page.get_changeset();
        cs.cancel_review(function() {
            $("#changeset_action").html(i18n.review);
            $("#review_cancel").hide();
            $("#review_cancel").removeClass("disabled");
            promotion_page.reset_page();
            promotion_page.get_changeset_tree().rerender_content();
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

                if (promotion_page.get_changeset() === undefined) {
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
                product_id = hash.split("_")[2],
                key = hash.split("_")[0],
                changeset = promotion_page.get_changeset(),
                reviewPhase = changeset.is_new();
            
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
                return templateLibrary.productList(changeset, changeset.id, reviewPhase);
            }
        };

    return {
        render: render
    };
})(jQuery);

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
        productDetailList = function(product_id, changeset_id) {
            var html = '<ul>';
             jQuery.each(promotion_page.subtypes, function(index, type) {
                html += '<li><div class="slide_link" id="' + type +'-cs_' + changeset_id + '_' + product_id + '">';
                html += '<span class="sort_attr">' + i18n[type] + ' (' + promotion_page.get_changeset().products[product_id][type].length
                        + ')</span></li>';
             });
            html += '</ul>';
            return html;
        },
        listItems = function(type, product_id, changeset_id) {
            var html = '<ul>';
            var items = promotion_page.get_changeset().products[product_id][type];
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
            var anchor = "";
            if (promotion_page.get_changeset().is_new()){
                anchor = '<a ' + 'class="fr content_add_remove remove_' + type + ' + st_button"'
                                + 'data-type="' + type + '" data-product_id="' + product_id +  '" data-id="' + id + '">';
                            anchor += i18n.remove + "</a>";
                        
            }
            return '<li>' + anchor + '<div class="no_slide"><span class="sort_attr">'  + name + '</div></span></li>';

        },
        productList = function(changeset, changeset_id, showButton){
            var html = '<ul>', 
                product, provider,
                all, 
                products = changeset.products;
            
            if( changeset.productCount() === 0 ){
                html += i18n['no_products'];
            } else {
                for( key in products ){
                    if( products.hasOwnProperty(key) ){
                        product = products[key];
                        provider = (product.provider === 'REDHAT') ? 'rh' : 'custom';
                        all = product.all ? 'no_slide' : 'slide_link';
                        html += productListItem(changeset_id, key, product.name, provider, all, showButton)
                    }
                }
            }
            
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
        };
    
    return {
        changesetsList: changesetsList,
        productList: productList,
        listItems : listItems,
        productDetailList: productDetailList
    };
})();
