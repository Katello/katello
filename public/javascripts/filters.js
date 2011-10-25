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

$(document).ready(function() {


    $('#new_filter').live('submit', function(e) {
        // disable submit to avoid duplicate clicks
        $('input[id^=filter_save]').attr("disabled", true);

        e.preventDefault();
        $(this).ajaxSubmit({success:KT.filters.success_create , error:KT.filters.failure_create});
    });

  

    $("#container").delegate("#remove_packages", 'click', function(e){
        KT.filters.remove_packages();

    });

    $(".toggle").live('click', function(){
       var btn = $(this);
       if (btn.hasClass("collapsed")){
        btn.addClass("expanded").removeClass("collapsed");
       }
       else {
        btn.removeClass("expanded").addClass("collapsed");
       }
       btn.parent().find(".options").toggle();

    });

    KT.panel.set_expand_cb(function(){
        KT.package_input.register_autocomplete();
        KT.product_input.register();
        KT.filter_renderer.render_products_repos();
    });

    

});

KT.package_input = (function() {
    var current_input = undefined;

    var register_autocomplete = function() {
        current_input = KT.auto_complete_box({
            values:       KT.routes.auto_complete_locker_packages_path(),
            default_text: i18n.package_search_text,
            input_id:     "package_input",
            form_id:      "add_package_form",
            add_btn_id:   "add_package",
            add_cb:       KT.filters.add_package
        });
    };

    return {
        register_autocomplete:register_autocomplete
    };
})();

KT.product_input = (function(){

    
    var register = function() {

        var select = $('#product_select');
        var form = $("#add_product_form");

        
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

        form.submit(function(e){
           var value;
           e.preventDefault();
           value = select.val();
           if (value.indexOf("PROD-") === 0){
             value = value.substring(5);
             KT.filters.add_product(value);
           }
           else if(value.indexOf("REPO-") === 0){
            value = value.substring(5);
            KT.filters.add_repo(value, KT.filters.lookup_repo_product(value));
           }

        });
    };
    
    return {
        register:register
    };
})();


KT.filter_renderer = (function(){
    var render_products_repos =  function(){
        var div = $("#product_list");
        div.html(products_template());
    },
    product_select_template = function() {
        var html = "";
        $.each(KT.products, function(id, prod){
            html += '<option value="PROD-' + prod.id+'">' + prod.name +'</option>';
            if (prod.repos.length > 0){
                $.each(prod.repos, function(index, repo){
                    html += '<option value="REPO-' + repo.id +'"> - ' + repo.name + " </option>";
                });
            }
        });
        return html;
    },
    product_template = function(id, name, is_full, repos){
        var html = '<tr><td><div class="product_entry">';
        html += '<div class="small_col"><input type="checkbox" data-type="product" value="' + id + '"/></div>';
        html += '<div  class="small_col toggle collapsed"></div>';
        html += '<div class="large_col">';
            html += '<span>' + name + "</span>";
            html += product_options(id, name, is_full, repos);
        html += '</div>';
        html += "</div></td></tr>";
        return html;
    },
    product_options = function(id, name, is_full, repos) {
        var all_checked = is_full ? 'checked' : '';
        var repos_checked = !is_full ? 'checked' : '';
        var html = '<div class="options"><div>';
            html += '<input type="radio" ' +all_checked + ' name="PROD-' +id+ '" value="all"/>' + i18n.all_repos;
            html += '<input type="radio" '+ repos_checked + ' name="PROD-' +id+ '"  value="select"/>' + i18n.select_repos +'</div>';
            $.each(repos, function(index, repo_id){
                html += repo(id, repo_id);
            });
            html += '</div>';
        return html;
    },
    repo = function(prod_id, repo_id) {
        var name;
        var html = '';
        $.each(KT.products[prod_id].repos, function(index, repo){
            if(repo.id === repo_id){
                name = repo.name;
                return false;
            }
        });
        html += '<div><input type="checkbox" data-type="repo" value="' + repo_id + '"/>';
        html += name;
        html += '</div>';
        return html;
    },
    products_template = function(){
      var html = "";
      var filter = KT.filters.get_current_filter();
      if (!filter){return ""}
      if (Object.keys(filter.repos).length === 0 && filter.products.length === 0){
          html += "<tr><td>" + i18n.no_products_repos  +"</td></tr>"
      }
      else{

          var all_products = filter.products.concat(Object.keys(filter.repos));
          console.log(all_products);

          $.each(all_products , function(index, id){
            console.log(filter.products);
              console.log(id);
            var repos = [];
            if (filter.products.indexOf(id) > -1){
                html += product_template(id, KT.products[id].name, true, repos);
            }
            else {
                repos = filter.repos[id];
                html += product_template(id, KT.products[id].name, false, repos);
            }
          });
      }
        return html;
    };

    return {
        render_products_repos:render_products_repos,
        product_select_template: product_select_template
    }

})();


KT.filters = (function(){
    var current_filter;
    
    var success_create  = function(data){
        list.add(data);
        KT.panel.closePanel($('#panel'));        
    },
    failure_create = function(){
        $('input[id^=filter_save]').attr("disabled", false);

    },
    add_package = function(name, cleanup_cb){
        var input = $("#package_input");

        //verify the package isn't already displayed
        if ($(".package_select[value=" + name + "]").length !== 0){
            cleanup_cb();
            return;
        }
        
        disable_package_inputs();

        $.ajax({
            type: "POST",
            url: input.attr("data-url"),
            data: {packages:[name]},
            cache: false,
            success: function(data) {
                var table = $("#package_filter").find("table");
                $.each(data, function(index, item){
                    var html = "<tr><td>";
                    html+= '<input type="checkbox" class="package_select" value="' + item + '">';
                    html += item + '</td></tr>';
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
        var btn = $("#remove_packages");
        var pkgs = [];
        var checked = $(".package_select:checked");

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
            type: "POST",
            url: btn.attr("data-url"),
            data: {packages:pkgs},
            cache: false,
            success: function(data) {
                checked.parents("tr").remove();
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
        current_filter = filter_in
    },
    update_product_repos = function() {
        var repos = [];
        $.ajax({
            type: "POST",
            url: KT.routes.update_products_filter_path(current_filter.id),
            data: {products:current_filter.products, repos:repos},
            cache: false,
            success: function(){
                KT.filter_renderer.render_products_repos();
            }
        });
    },
    add_product = function(prod_id){
        if ($.inArray( parseInt(prod_id), current_filter.products) === -1){
            current_filter.products.push(parseInt(prod_id));
            update_product_repos();
        }
    },
    add_repo = function(repo_id, prod_id){
        if ($.inArray( parseInt(prod_id), current_filter.products) > -1){
            current_filter.products.pop(parseInt(prod_id));
        }
        if (current_filter.repos[prod_id] === undefined){
            current_filter.repos[prod_id] = [];
        }
        current_filter.repos[prod_id].push(repo_id);
        update_product_repos();
    },
    lookup_repo_product = function(repo_id){
      var found = undefined;
      $.each(KT.products, function(index, prod){
        $.each(prod.repos, function(index, repo){
           if (repo.id === repo_id){
               found = prod.id;
               return false;
           }
        });
      });
      return found;
    };
    


    return {
        success_create: success_create,
        failure_create: failure_create,
        add_package: add_package,
        remove_packages: remove_packages,
        get_current_filter: get_current_filter,
        set_current_filter: set_current_filter,
        add_repo: add_repo,
        add_product: add_product,
        lookup_repo_product: lookup_repo_product
    };
})();