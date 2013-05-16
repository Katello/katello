/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/
$(document).ready(function() {
    $(".toggle").live('click', function(){
       var btn = $(this);
       var parent = btn.parents(".product_entry");
       if(parent.hasClass("disabled")){
           return;
       }

       if (btn.hasClass("collapsed")){
        btn.addClass("expanded").removeClass("collapsed");
       }
       else {
        btn.removeClass("expanded").addClass("collapsed");
       }
       btn.parent().find(".options").toggle();

    });

    KT.panel.set_expand_cb(function(){
        KT.product_input.register();
    });
});

KT.product_input = (function(){

    var register = function() {

        var select = $('#product_select');
        if (select.length === 0){
            return;
        }

        KT.filter_renderer.render_products_repos();

        select.html(KT.filter_renderer.product_select_template());

        select.chosen({
            custom_compare:function(search, name, value){
                if (name.toUpperCase().indexOf(search.toUpperCase()) > -1){
                 return true;
                }
                else if(value.indexOf("PROD-") === 0)  {
                    var prod_id = value.split("-")[1];
                    var prod = KT.products[prod_id];
                    if(prod && prod.name === name){
                        var match = false;
                        $.each(prod.repos, function(index, item){
                             if (item.name.toUpperCase().indexOf(search.toUpperCase()) > -1){
                                 match = true;
                                 return false;
                             }
                        });
                        return match;
                    }
                }
            }
        });

        $("#add_product").click(function(e){
            var value;
            var add_btn = $("add_product");
            e.preventDefault();
            if (add_btn.hasClass("disabled")){
                return;
            }
            add_btn.addClass("disabled");

            value = select.val();
            if (value.indexOf("PROD-") === 0){
                value = value.substring(5);
                KT.filters.add_product(value);
            }
            else if(value.indexOf("REPO-") === 0){
                value = value.substring(5);
                KT.filters.add_repo(value, KT.filters.lookup_repo_product(value), true);
            }
        });

        $("#update_products").click(function(){
            var btn = $(this);
            if(btn.hasClass("disabled")){
                return;
            }
            btn.addClass("disabled");
            KT.filters.update_product_repos();
        });

        $("#revert_products").click(function(){
            KT.filters.revert_products();
        });

    },
    post_render_register = function() {
        $(".product_radio").unbind().change(function(){
            var radio = $(this),
                value = radio.val(),
                parent = radio.parents(".product_entry"),
                prod_id = parseInt(parent.attr("data-id"), 10),
                list = parent.find(".repos_list"),
                search = parent.find(".repos_search"),
                filter = KT.filters.get_current_filter(),
                repos;

            //if 'all was selected'
            if (value === "all"){
                list.hide(); //hide list and re-render message
                search.hide();
                KT.filter_renderer.render_product_message(prod_id, true);
                if (KT.utils.indexOf(filter.products, prod_id) === -1){
                    filter.products.push(prod_id); //add product to filter
                }
                //remove product from repos and cache it
                repos = filter.repos[prod_id];
                delete filter.repos[prod_id];
                if (repos){
                    KT.filters.get_repo_cache()[prod_id] = repos;
                }
            }
            else { //else 'select repos' was selected
                list.show(); //show list and rerender message
                search.show();
                KT.filters.pop_product(prod_id);

                filter.repos[prod_id] = [];
                repos = KT.filters.get_repo_cache()[prod_id];
                if (repos && repos.length > 0){
                    filter.repos[prod_id] =  repos;
                    delete KT.filters.get_repo_cache()[prod_id];
                }
                KT.filter_renderer.render_product_message(prod_id, false, KT.filters.get_current_filter().repos[prod_id]);

            }
        });

        $('.repo_select').chosen();

        $(".add_repo").unbind().click(function(){
            var select,id, repo_id, prod_id;
            select = $(this).siblings("select");
            repo_id = select.val();
            prod_id = select.attr("data-prod_id");
            KT.filters.add_repo(repo_id, prod_id);
        });

        $(".remove_repo").unbind().click(function(){
            var repo = $(this).parent(),
                repo_id = repo.attr("data-id"),
                parent = repo.parents('.product_entry'),
                prod_id = parseInt(parent.attr("data-id"), 10),
                filter = KT.filters.get_current_filter();

            KT.filters.pop_repo(prod_id, repo_id);
            repo.remove();
            KT.filter_renderer.rerender_repo_select(prod_id);
            KT.filter_renderer.render_product_message(prod_id, false, filter.repos[prod_id]);

        });

        $(".remove_product").unbind().click(function(){
            var parent = $(this).parents('.product_entry');
            var prod_id = parseInt(parent.attr("data-id"), 10);
            var filter = KT.filters.get_current_filter();
            KT.filters.pop_product(prod_id);
            delete filter.repos[prod_id];
            parent.remove();
            KT.filter_renderer.empty_check();
        });
    };

    return {
        register:register,
        post_render_register: post_render_register
    };
})();


KT.filter_renderer = (function(){
    var render_products_repos =  function(){
        var div = $("#product_list");
        div.html(products_template());
        KT.product_input.post_render_register();

        div.find("tr").not(".no_sort").sortElements(function(a,b){
                var a_html = $.trim($(a).find('.text').text());
                var b_html = $.trim($(b).find('.text').text());
                if (a_html && b_html ) {
                    return  a_html.toUpperCase() >
                            b_html.toUpperCase() ? 1 : -1;
                }
        });
        empty_check();

    },
    render_single_product = function(prod_id){
        prod_id = parseInt(prod_id, 10);
        $('.product_entry[data-id=' + prod_id + ']').remove();
        $("#product_list").prepend(single_product(prod_id));
        $('.product_entry[data-id=' + prod_id + ']').hide();
        $('.product_entry[data-id=' + prod_id + ']').fadeIn(500);
        KT.product_input.post_render_register();
        empty_check();
    },
    render_single_repo = function(prod_id, repo_id){
        var list = $('.product_entry[data-id=' + prod_id + ']').find(".repos_list");
        list.append(repo_template(prod_id, repo_id, true));
        KT.product_input.post_render_register();
        render_product_message(prod_id, false);
        rerender_repo_select(prod_id);
        empty_check();
    },
    render_product_message = function(prod_id, is_full) {
        var msg = product_message(prod_id, is_full, KT.filters.get_current_filter().repos[prod_id]);
        $(".product_entry[data-id=" + prod_id + "]").find(".prod_message").text(msg);
    },
    rerender_repo_select = function(prod_id){
        var select = $('.product_entry[data-id=' + prod_id + ']').find("select");
        select.html(repo_search_items(prod_id));
        select.trigger("liszt:updated"); //update the chosen select
    },
    product_select_template = function() {
        var html = "";
        $.each(KT.editable_products, function(id, prod){
            html += '<option value="PROD-' + prod.id+'">' + prod.name +'</option>';
            if (prod.repos.length > 0){
                $.each(prod.repos, function(index, repo){
                    html += '<option value="REPO-' + repo.id +'"> - ' + repo.name + " </option>";
                });
            }
        });
        return html;
    },
    product_options = function(id, name, editable, is_full, repos) {
        var style = is_full ? 'style="display:none;"' : '';
        var html_name = "PROD-" + id;
        var search_box = editable ? repo_search(id) : "";
        var html = '<div class="options">';
            html += '<div>' + product_radio('all' + html_name, html_name, i18n.all_repos, editable, is_full, 'all') + '</div>';
            html += '<div>' + product_radio('sel' + html_name, html_name, i18n.select_repos, editable, !is_full, 'sel') +
                        '<span ' + style + 'class="repos_search">' + search_box +  '</span>' +
                    '</div>';
            html += '<div class="repos_list">';
            $.each(repos, function(index, repo_id){
                html += repo_template(id, repo_id, editable);
            });
            html += '</div></div>';
        return html;
    },
    product_radio = function(id, name, label, editable, is_checked, value){
      var checked = is_checked ? "checked" : "";
      var disabled = editable ? "" : "disabled=disabled" ;
      var html = "";
      html += '<input type="radio" ' + disabled + " " + checked + ' id="'+ id +'" name="' +name+ '" ' +
          'value="' + value + '" class="product_radio"/>';
      html += '<label for="' + id + '">' + label + '</label>';
      return html;
    },
    product_message = function(prod_id, is_full, repos){
        var message = i18n.entire_selected;
        if (!is_full){
            message = i18n.x_of_y_repos(KT.utils.size(repos), KT.utils.size(KT.products[prod_id].repos));
        }
        return message;
    },
    repo_template = function(prod_id, repo_id, editable) {
        var name, repo,
            html = '';

        repo = KT.utils.find(KT.products[prod_id].repos, function(repo){
            return repo.id.toString() === repo_id;
        });

        html += '<div class="repo" data-id="'  + repo_id + '">';
        html += repo.name;

        if (editable){
            html += '<a class="remove_repo"> &nbsp;' + i18n.remove + '</a>';
        }

        html += '</div>';
        return html;
    },
    repo_search = function(prod_id){
        var html = '<select style="width: 250px;" class="repo_select" data-prod_id="' + prod_id + '">';
        html += repo_search_items(prod_id);
        html += '</select>';
        html += '<a class="add_repo"> &nbsp;' + i18n.add_plus + '</a>';
        return html;
    },
    repo_search_items = function(prod_id){
        var html = "";
        $.each(KT.products[prod_id].repos, function(index, item){
            var used = KT.filters.get_current_filter().repos[prod_id] || [];
            if (used[item.id] === undefined) {
                html+= '<option value="' + item.id + '">' + item.name + '</option>';
            }
        });
        return html;
    },
    single_product = function(prod_id) {
        var filter = KT.filters.get_current_filter();
        var repos = [];
        var editable = KT.utils.indexOf(Object.keys(KT.editable_products), prod_id + "") > -1;
        if (KT.utils.indexOf(filter.products, prod_id) > -1){
            //render the cached repos if we want to
            if (KT.filters.get_repo_cache()[prod_id]){
                repos = KT.filters.get_repo_cache()[prod_id];
            }
            return product_template(prod_id, KT.products[prod_id].name, editable,  true, repos);
        }
        else {
            repos = filter.repos[prod_id];
            return product_template(prod_id, KT.products[prod_id].name, editable, false, repos);
        }
    },
    product_template = function(id, name, editable, is_full, repos){
        var html = '<tr><td class="no_padding"><div data-id="' + id + '" class="product_entry">';
        html += '<div  class="small_col toggle collapsed" data-id="' + id +'"></div>';
        html += '<div class="large_col">';
            html += '<span class="text">' + name + " <span class='prod_message'>" + product_message(id, is_full, repos) + '</span>';
            if (editable){
                html += '<a class="remove_product">&nbsp;' + i18n.remove + '</a>';
            }
            html += '</span>';
            html += product_options(id, name, editable, is_full, repos);
        html += '</div>';
        html += "</div></td></tr>";
        return html;
    },
    empty_check = function(){
        var filter = KT.filters.get_current_filter();
        if (filter.products.length === 0 && Object.keys(filter.repos).length === 0){
            var html = '<tr id="empty_message"><td>' + i18n.no_products_repos  + '</td></tr>';
            $("#product_list").html(html);
        }
        else {
            $("#empty_message").remove();
        }
    },
    products_template = function(){
        var html = "";
        var filter = KT.filters.get_current_filter();
        if (!filter){return "";}
        var all_products = filter.products.concat(Object.keys(filter.repos));
        $.each(all_products , function(index, id){
            html += single_product(id);
        });
        return html;
    };

    return {
        render_products_repos:render_products_repos,
        product_select_template: product_select_template,
        render_product_message: render_product_message,
        render_single_product : render_single_product,
        render_single_repo : render_single_repo,
        rerender_repo_select: rerender_repo_select,
        empty_check: empty_check
    };

})();


KT.filters = (function(){
    var current_filter,
    saved_filter,
    repo_cache = {};

    add_package = function(name, item_id, cleanup_cb){
        var input = $("#package_input");

        //verify the package isn't already displayed
        if ($(".package_select[value=" + KT.common.escapeId(name) + "]").length !== 0){
            cleanup_cb();
            return;
        }

        disable_package_inputs();

        $.ajax({
            type: "PUT",
            url: input.data("url"),
            data: {packages:[name]},
            cache: false,
            success: function(data) {
                var table = $("#package_filter").find("table");
                $(".empty_message").remove();
                $.each(data, function(index, item){
                    var html = "<tr><td>";
                    html+= '<input type="checkbox" id="' + item + '" class="package_select" value="' + item + '">';
                    html += '&nbsp;<label for="' + item + '">' + item + '</label></td></tr>';
                    table.append(html);
                });
                table.find("tr").not(".no_sort").sortElements(function(a,b){
                        var a_html = $.trim($(a).find('td').text());
                        var b_html = $.trim($(b).find('td').text());
                        if (a_html && b_html ) {
                            return  a_html.toUpperCase() >
                                    b_html.toUpperCase() ? 1 : -1;
                        }
                });
                cleanup_cb();
                enable_package_inputs();
            }
        });
    },
    remove_packages = function() {
        var btn = $("#remove_packages"),
        pkgs = [],
        checked = $(".package_select:checked");

        if (btn.hasClass("disabled")){
            return;
        }

        checked.each(function(index, item){
            pkgs.push($(item).val());
        });
        if (pkgs.length === 0){
            return;
        }
        disable_package_inputs();

        $.ajax({
            type: "PUT",
            url: btn.data("url"),
            data: {packages:pkgs},
            cache: false,
            success: function(data) {
                var html = '<tr class="empty_message"><td>' + i18n.no_packages + '</td></tr>';
                checked.parents("tr").remove();
                if ($("#package_filter").find("tr").not(".no_sort").length === 0){
                    $("#package_filter").find("table").append(html);
                }
                enable_package_inputs();
            }
        });
    },
    disable_package_inputs = function(){
        $("#package_filter").find("input").addClass("disabled");

    },
    enable_package_inputs = function(){
        $("#package_filter").find("input").removeClass("disabled");
    },
    get_current_filter = function(){
        return current_filter;
    },
    set_current_filter = function(filter_in) {
        current_filter = filter_in;
        saved_filter = $.parseJSON(JSON.stringify(filter_in));
    },
    revert_products = function() {
      current_filter =   $.parseJSON(JSON.stringify(saved_filter));
      KT.filter_renderer.render_products_repos();
    },
    update_product_repos = function() {
        var repos = [];
        $.ajax({
            type: "PUT",
            contentType: "application/json",
            url: $("#update_products").data("url"),
            data: JSON.stringify({products:current_filter.products, repos:current_filter.repos}),
            cache: false,
            success: function(){
                repo_cache = []; //clear repo cache
                $("#update_products").removeClass("disabled");
                KT.filter_renderer.render_products_repos();
                saved_filter = $.parseJSON(JSON.stringify(current_filter));
            }
        });
    },
    add_product = function(prod_id){
        prod_id = parseInt(prod_id, 10);
        if ($.inArray( prod_id, current_filter.products) === -1 &&
             current_filter.repos[prod_id] === undefined){
            repo_cache[prod_id] = [];
            current_filter.products.push(prod_id);
            KT.filter_renderer.render_single_product(prod_id);
            expand_product(prod_id);
        }
    },
    pop_product = function(prod_id){
      var index = KT.utils.indexOf(current_filter.products, parseInt(prod_id, 10));
        if (index > -1) {
            current_filter.products.splice(index, 1);
        }

    },
    pop_repo = function(prod_id, repo_id){
        var repos = current_filter.repos[parseInt(prod_id, 10)],
        index;
        if(repos) {
            index = KT.utils.indexOf(repos, repo_id);
            repos.splice(index, 1);
        }

    },
    add_repo = function(repo_id, prod_id, bump_up){
        if(repo_id === null || repo_id === undefined) {
            return;
        }
        prod_id = parseInt(prod_id, 10);
        if ($.inArray( prod_id, current_filter.products) > -1){
            KT.filters.pop_product(prod_id);
        }

        //clear the repo cache
        if (repo_cache[prod_id] !== undefined){
            repo_cache[prod_id] = [];
        }
        if (current_filter.repos[prod_id] === undefined){
            current_filter.repos[prod_id] = [];
        }

        if (KT.utils.indexOf(current_filter.repos[prod_id], repo_id) === -1) {
            current_filter.repos[prod_id].push(repo_id);
            if (bump_up){
                KT.filter_renderer.render_single_product(prod_id);
            }
            else {
                KT.filter_renderer.render_single_repo(prod_id, repo_id);
            }
        }
        expand_product(prod_id);
    },
    lookup_repo_product = function(repo_id){
      var found;

      $.each(KT.products, function(index, prod){
        $.each(prod.repos, function(index, repo){
           if (repo.id.toString() === repo_id){
               found = prod.id;
               return false;
           }
        });
      });
      return found;
    },
    expand_product = function(id){
        $(".product_entry").find('.collapsed.toggle[data-id='  + id + ']').click();
    },
    collapse_product = function(id){
        $(".product_entry").find('.expanded.toggle[data-id='  + id + ']').click();
    },
    get_repo_cache = function(){
        return repo_cache;
    };

    return {
        add_package     : add_package,
        remove_packages : remove_packages,
        get_current_filter: get_current_filter,
        set_current_filter: set_current_filter,
        add_repo        : add_repo,
        pop_repo        : pop_repo,
        add_product     : add_product,
        pop_product     : pop_product,
        lookup_repo_product: lookup_repo_product,
        expand_product  : expand_product,
        collapse_product: collapse_product,
        get_repo_cache  : get_repo_cache,
        update_product_repos: update_product_repos,
        revert_products : revert_products
    };
})();
