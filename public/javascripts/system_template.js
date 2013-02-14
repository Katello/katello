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

KT.options = {
    action_bar: undefined,
    template_tree: undefined,
    content_tree: undefined,
    current_template: undefined,
    templates: undefined
};

KT.templates = function() {
    var buttons = {
        edit: undefined,
        remove: undefined,
        save: undefined,
        download: undefined,
        discard_dialog: undefined,
        save_dialog: undefined
    },
    fetch_template = function(template_id, callback) {
        $("#tree_loading").css("z-index", 300);
        $.ajax({
            type: "GET",
            url: KT.common.rootURL() + "system_templates/" + template_id + "/object/",
            cache: false,
            success: function(data) {
                $("#tree_loading").css("z-index", -1);
                KT.options.current_template = data;
                callback();
            }});
    },
    set_current_name = function(name) {
        var id = KT.options.current_template.id;
        KT.options.current_template.name = name;
        KT.template_breadcrumb["details_" + id].name = name;
        $.each(KT.options.templates, function(index, item){
            if (item.template_id === id) {
                item.template_name = name;
                return true;
            }
        });
    },
    set_current_description = function(desc) {
        KT.options.current_template.description = desc;
    },
    remove_template = function(id) {
        delete KT.template_breadcrumb["details_" + id];
        $.each(KT.options.templates, function(index, item){
            if (item && item.template_id === id) {
                KT.options.templates.splice(index, 1);
                return true;
            }
        });
        KT.options.current_template = undefined;
        KT.options.template_tree.render_content("templates");
    },
    add_new_template = function(id, name) {
        var hash = {template_name:name, template_id:id};
        KT.options.templates.push(hash);
        add_new_template_bcs(id, name);
        KT.options.template_tree.render_content("details_" + id);
    },
    add_new_template_bcs = function(id, name) {
        var bc = KT.template_breadcrumb;
        var template_root = 'details_' + id;
        bc[template_root] = {
            cache: null,
            client_render: true,
            name: name,
            trail: ['templates'],
            url: 'url'
        };
        bc['packages_' + id] = {
            cache: null,
            client_render: true,
            name: i18n.packages,
            trail: ['templates', template_root],
            url: ''
        };
        bc['repos_' + id] = {
            cache: null,
            client_render: true,
            name: i18n.repos,
            trail: ['templates', template_root],
            url: ''
        };
        bc['distribution_' + id] = {
            cache: null,
            client_render: true,
            name: i18n.selected_distribution,
            trail: ['templates', template_root],
            url: ''
        };
        bc['products_' + id ] = {
            cache: null,
            client_render: true,
            name: i18n.products,
            trail: ['templates', template_root],
            url: ''
        };
        bc['comps_' + id ] = {
            cache: null,
            client_render: true,
            name: i18n.package_groups,
            trail: ['templates', template_root],
            url: ''
        };
    },
    in_array =  function(name, array) {
        var to_ret = -1;
        $.each(array, function(index, item) {
            if (item.name === name) {
                to_ret = index;
                return false;
            }
        });
        return to_ret;
    },
    has_package = function(name) {
        return in_array(name, KT.options.current_template.packages) > -1;
    },
    add_package = function(name) {
      var pkgs = KT.options.current_template.packages;
      if (!has_package(name)) {
        pkgs.push({name:name});
      }

      KT.options.current_template.modified = true;
      KT.options.template_tree.rerender_content();
    },
    generic_remove = function(name, array) {
        var loc = in_array(name, array);
        if (loc > -1) {
            array.splice(loc, 1);
            KT.options.current_template.modified = true;
            change_content_toggle(name, false);
            KT.options.template_tree.rerender_content();
        }
    },
    remove_package = function(name) {
        generic_remove(name, KT.options.current_template.packages);
    },
    has_package_group = function(name) {
        return in_array(name, KT.options.current_template.package_groups) > -1;
    },
    add_package_group = function(name) {
      var grps = KT.options.current_template.package_groups;
      if (!has_package_group(name)) {
        grps.push({name:name});
      }
      KT.options.current_template.modified = true;
      KT.options.template_tree.rerender_content();
    },
    remove_package_group = function(name) {
        generic_remove(name, KT.options.current_template.package_groups);
    },
    in_repo_array = function(id) {
        var to_ret = -1;
        $.each(KT.options.current_template.repos, function(index, item) {
            if (item.id  + "" === id + "") {
                to_ret = index;
                return false;
            }
        });
        return to_ret;
    },
    has_repo = function(id) {
        return in_repo_array(id) > -1;
    },
    add_repo = function(name, id) {
        if (!has_repo(id)) {
          KT.options.current_template.repos.push({name:name, id:id});
          KT.options.current_template.modified = true;
          KT.options.template_tree.rerender_content();
        }
    },
    remove_repo = function(name, id) {
        var repos = KT.options.current_template.repos;
        var loc = in_repo_array(id);
        if (loc > -1) {
            repos.splice(loc, 1);
            KT.options.current_template.modified = true;
            KT.options.template_tree.rerender_content();
        }
    },
    reset_page = function() {
        
        if (KT.options.current_template === undefined || !KT.permissions.editable) {
            buttons.edit.addClass("disabled");
            buttons.remove.addClass("disabled");
            buttons.save.addClass("disabled");
            buttons.download.addClass("disabled");
            buttons.download.tipsy('hide');
            $('.package_add_remove').hide();
            $('.package_group_add_remove').hide();
            $('.repo_add_remove').hide();
            $('.product_add_remove').hide();
        }
        else {
            buttons.edit.removeClass("disabled");
            buttons.remove.removeClass("disabled");
            if (KT.options.current_template.modified) {
                buttons.download.tipsy('show')
                buttons.download.addClass("disabled");
                buttons.save.removeClass("disabled");
            }
            else {
                buttons.download.tipsy('hide')
                buttons.download.removeClass("disabled");
                buttons.save.addClass("disabled");
            }

            //handle packages, groups & repos
            $.each( [["package", KT.options.current_template.packages],
                     ["package_group", KT.options.current_template.package_groups],
                     ["repo", KT.options.current_template.repos]], function(index, item) {

                var type = item[0],
                    array = item[1];
                
                $('.' + type + '_add_remove').not('.working').show().text(i18n.add_plus); //reset all add/remove to add
                $.each(array, function(index, item){
                    var btn = undefined;
                    if (type === "repo") {
                        btn = $('a[data-name="' + item.name + '"][data-id="' + item.id +'"].' + type + '_add_remove').not('.working');
                    } else {
                        btn = $('a[data-name="' + item.name + '"].' + type + '_add_remove').not('.working');
                    }
                    if (btn.length > 0) {
                        btn.text(i18n.remove);
                    }
                });
            });

            //handle products
            $('.product_add_remove').not('.working').show().text(i18n.add_plus); //reset all add/remove to add
            $.each(KT.options.current_template.products, function(index, item){
                var btn = $('a[data-id=' + item.id + '].product_add_remove').not('.working');
                if (btn.length > 0) {
                    btn.text(i18n.remove);
                }
            });
        }
        sort_content();
    },
    throw_error = function() {
        $("#error_dialog").dialog({
            closeOnEscape: false,
            modal: true,
            //Remove the close button
            open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); }
        });

    },
    sort_content = function() {
        $(".right_tree .will_have_content").find("li").sortElements(function(a,b){
                var a_html = $(a).find(".sort_attr").html();
                var b_html = $(b).find(".sort_attr").html();
                if (a_html && b_html ) {
                    return  a_html.toUpperCase() >
                            b_html.toUpperCase() ? 1 : -1;
                }
        });
    },
    change_content_toggle = function(pkg_name, adding) {
        var btn = $("a[data-name='" + pkg_name + "']");
        if (btn.length > 0) {
            if (adding) {
                btn.text(i18n.remove);
            }
            else {
                btn.text(i18n.add_plus);
            }
        }
    },
    in_product_array = function(id) {
        var to_ret = -1;
        $.each(KT.options.current_template.products, function(index, item) {
            if (item.id  + "" === id + "") {
                to_ret = index;
                return false;
            }
        });
        return to_ret;
    },
    add_product = function(name, id) {
        if (!has_product(name, id)) {
          KT.options.current_template.products.push({name:name, id:id});
          KT.options.current_template.modified = true;
          KT.options.template_tree.rerender_content();
        }
    },
    has_product = function(name, id) {
        return in_product_array(id) > -1;
    },
    remove_product = function(name, id) {
        var products = KT.options.current_template.products;
        var loc = in_product_array(id);
        if (loc > -1) {
            products.splice(loc, 1);
            KT.options.current_template.modified = true;
            KT.options.template_tree.rerender_content();
        }
    },
    set_distro = function(id) {
        KT.options.current_template.distribution = id;
        KT.options.current_template.modified = true;
        KT.templates.reset_page();
    };
    
    return {
        fetch_template: fetch_template,
        add_new_template: add_new_template,
        remove_template: remove_template,
        set_current_name: set_current_name,
        set_current_description: set_current_description,
        reset_page: reset_page,
        buttons: buttons,
        throw_error: throw_error,
        sort_content: sort_content,
        add_package: add_package,
        remove_package: remove_package,
        has_package: has_package,
        add_repo: add_repo,
        remove_repo: remove_repo,
        has_repo: has_repo,
        add_product: add_product,
        remove_product: remove_product,
        has_product: has_product,
        has_package_group: has_package_group,
        add_package_group: add_package_group,
        remove_package_group: remove_package_group,
        set_distro: set_distro
    };
}();


KT.template_renderer = function() {

    //responsible for checking if we need a new template, if not
    //  then unload the old
    var template_check = function(id, cb) {
        var current = KT.options.current_template;

        if (id === undefined) {
            KT.options.current_template = undefined;
            cb();
        }
        else if (current === undefined || current.id != id) {
            KT.templates.fetch_template(id, function() {
                cb();
            });
        }
        else {
            cb();
        }
    },
    render_hash = function(hash_id, render_cb) {
        var node = hash_id.split('_')[0],
            template_id = hash_id.split('_')[1],
            curr_t = KT.options.current_template,
            modified = false;

        if(curr_t && (hash_id === "templates" ||  template_id + "" !== curr_t.id + "")) {
            modified = curr_t.modified;
        }

        var after_cb = function() {
            template_check(template_id, function() {
                var content = "";
                if (hash_id === "templates") {
                    content = template_list();
                }
                else if(node === "details") {
                    content = details(template_id);
                }
                else if (node === "packages") {
                    content = packages();
                }
                else if (node == "repos") {
                    content = repos();
                }
                else if (node === "products") {
                    content = products();
                }
                else if (node === "comps") {
                    content = comps();
                }
                else if(node === "distribution"){
                    content = distros();
                }
                render_cb(content);
            });
        };
        if (modified) {
            KT.actions.open_modified_dialog(function(){
                KT.templates.buttons.save.click();
            }, after_cb);
        }
        else {
            after_cb();
        }
    },
    list_item = function(id, text, is_slide_link) {
        var html = '<li class="' + (is_slide_link ? 'slide_link' : '')  + '">';
        html += '<div class="link_details simple_link one-line-ellipsis" id="' + id + '">';
        html += '<span class="sort_attr">' + text + '</span>';
        html += "</div></li>";
        return html ;
    },
    package_item = function(pkg_name) {
        var html = '<li class="">';
        html += '<div class="simple_link" id=pkg_"' + pkg_name + '">';
        if (KT.permissions.editable) {
            html += '<a id="" class="fr st_button remove_package">' + i18n.remove + '</a>';
        }
        html += '<span class="sort_attr">' + pkg_name + '</span>';
        html += "</div></li>";
        return html ;
    },
    packages = function() {
        var html = "";
        if (KT.permissions.editable) {
            html += '<ul ><li class="content_input_item"><form id="add_package_form">';
            html += '<input id="add_package_input" type="text" size="33"><form>  ';
            html += '<a id="add_package" class="fr st_button ">' + i18n.add_plus + '</a>';
            html += ' </li></ul>';
        }

        html +=  '<ul class="filterable">';
        $.each(KT.options.current_template.packages, function(index, item) {
            html += package_item(item.name);
        });
        return html + "</ul>";
    },
    repo_item = function(name, id) {
        var html = '<li class="">';
        html += '<div class="simple_link" id=repo_"' + id + '">';
        if (KT.permissions.editable) {
            html += '<a id="" class="fr st_button remove_repo" data-id="' + id + '" data-name="'+ name + '">';
            html += i18n.remove + '</a>';
        }
        html += '<span class="sort_attr">' + name + '</span>';
        html += "</div></li>";
        return html ;
    },
    repos = function() {
        var html = "";
        if (KT.permissions.editable) {
            html += '<ul><li class="content_input_item"><form id="add_repo_form">';
            html += '<input id="add_repo_input" type="text" size="33"><form>  ';
            html += '<a id="add_repo" class="fr st_button ">' + i18n.add_plus + '</a>';
            html += '<input id="add_repo_input_id" type="hidden">';
            html += ' </li></ul>';
        }
        html +=  '<ul class="filterable">';
        $.each(KT.options.current_template.repos, function(index, item) {
            html += repo_item(item.name, item.id);
        });
        return html + "</ul>";
    },
    product_item = function(name, id) {
        var html = '<li class="">';
        html += '<div class="simple_link" id=prod_"' + id + '">';
        if (KT.permissions.editable) {
            html += '<a id="" class="fr st_button remove_product" data-id="' + id + '" data-name="'+ name + '">';
            html += i18n.remove + '</a>';
        }
        html += '<span class="sort_attr">' + name + '</span>';
        html += "</div></li>";
        return html ;
    },
    products = function() {
        var html = "";
        if (KT.permissions.editable) {
            html += '<ul><li class="content_input_item"><form id="add_product_form">';
            html += '<input id="add_product_input" type="text" size="33"><form>  ';
            html += '<a id="add_product" class="fr st_button ">' + i18n.add_plus + '</a>';
            html += ' </li></ul>';
        }
        html +=  '<ul class="filterable">';
        $.each(KT.options.current_template.products, function(index, item) {
            html += product_item(item.name, item.id);
        });
        return html + "</ul>";
    },
    comps = function() {
        var html = "";
        if (KT.permissions.editable) {
            html += '<ul ><li class="content_input_item"><form id="add_package_group_form">';
            html += '<input id="add_package_group_input" type="text" size="33"><form>  ';
            html += '<a id="add_package_group" class="fr st_button ">' + i18n.add_plus + '</a>';
            html += ' </li></ul>';
        }

        html +=  '<ul class="filterable">';
        $.each(KT.options.current_template.package_groups, function(index, item) {
            html += comps_item(item.name);
        });
        return html + "</ul>";
    },
    comps_item = function(pkg_name) {
        var html = '<li class="">';
        html += '<div class="simple_link" id=group_"' + pkg_name + '">';
        if (KT.permissions.editable) {
            html += '<a id="" class="fr st_button remove_package_group">' + i18n.remove + '</a>';
        }
        html += '<span class="sort_attr">' + pkg_name + '</span>';
        html += "</div></li>";
        return html ;
    },
    distros = function(prod_id){
        var html = "",
            distros = [],
            current = KT.options.current_template,
            selected;

        if (current.products.length === 0 && current.repos.length === 0){
            return i18n.need_product_or_repo;
        }

        $.each(current.products, function(index, prod){
           $.each(KT.product_distributions[prod.id], function(index, dist){
               // if the distro was already added, skip it...
               if (distros.indexOf(dist.id) === -1) {
                   distros.push(dist.id);
               }
           });
        });

        $.each(current.repos, function(index, repo) {
            $.each(KT.repo_distributions[repo.id], function(index, dist){
                // if the distro was already added, skip it...
                if (distros.indexOf(dist.id) === -1) {
                    distros.push(dist.id);
                }
            });
        });

        if (distros.length == 0){
            return i18n.need_distro_product_or_repo;
        }

        html = '<ul>';
        $.each(distros, function(index, dist){
            selected = (dist === current.distribution)  ? " checked " : "";
            
            html +=  '<li class="no_hover">';
            html += '<input ' + selected + 'type="radio" class="distro_select" name="distro" value="' + dist + '" id="' + dist + '"> ';
            html += '<span class="sort_attr"><label for="' + dist + '">' + dist + '</label></span>';
            html += '</li>';
        });
        html += '</ul>';
        return html;
    },
    details = function(t_id) {
        var html = "<ul>";
        //bz 796239
        $.each([/*['products_', i18n.products],*/ ['repos_', i18n.repos], ['packages_', i18n.packages], ['comps_', i18n.package_groups],
            ['distribution_', i18n.selected_distribution]],
            function(index, item_set) {
                html += list_item(item_set[0] + t_id, item_set[1], true);
            }
        );
        return html + "</ul>";
    },
    template_list = function() {
        var templates = KT.options.templates;
        if (templates.length === 0) {
            return i18n.templates_empty;
        }

        var html = '<ul class="filterable">';
        $.each(templates, function(index, template) {
            html += list_item("details_" + template.template_id, template.template_name, true);
        });
        html += "</ul>";
        return html;
    };

    return {
        render_hash: render_hash
    };
}();

KT.product_actions = (function() {
    var current_input = undefined,
    
    register_autocomplete = function() {
        current_input = KT.auto_complete_box({
            values:       Object.keys(KT.product_hash),
            default_text: i18n.product_search_text,
            input_id:     "add_product_input",
            form_id:      "add_product_form",
            add_btn_id:   "add_product",
            add_cb:       verify_add_product
        });
    },
    verify_add_product = function(name, name_id, cleanup_cb) {
        var names = Object.keys(KT.product_hash);
        
        if ($.inArray(name, names) > -1) {        
            KT.templates.add_product(name, KT.product_hash[name]);
        }
        else {
            current_input.error();
        }
        cleanup_cb();
    },
    register_events = function() {
        $(".remove_product").live('click', function() {
            var btn = $(this),
                id = btn.attr("data-id"),
                name = btn.attr("data-name");

            if (name && id) {
                KT.templates.remove_product(name, id);
            }
        });
        $(".product_add_remove").live('click', function(){
            var btn = $(this),
                name = btn.attr("data-name"),
                id = btn.attr("data-id");

            if (KT.templates.has_product(name, id)) {
                //need to remove
                KT.templates.remove_product(name, id);
            }
            else {
                //need to add
                btn.html("<img  src='images/embed/icons/spinner.gif'>");
                current_input.manually_add(name, KT.product_hash[name]);
            }
        });
    };

    return {
        register_autocomplete: register_autocomplete,
        register_events: register_events
    };

})();

KT.repo_actions = (function() {
    var current_input = undefined,

    //called everytime 'repos is loaded'
    register_autocomplete = function() {
        current_input = KT.auto_complete_box({
            values:       KT.routes.auto_complete_library_repositories_path(),
            default_text: i18n.repo_search_text,
            input_id:     "add_repo_input",
            selected_input_id: "add_repo_input_id",
            form_id:      "add_repo_form",
            add_btn_id:   "add_repo",
            add_cb:       verify_add_repo
        });
    },
    verify_add_repo = function(name, name_id, cleanup_cb){
        $.ajax({
            type: "GET",
            url: KT.routes.auto_complete_library_repositories_path(),
            data: {term:name},
            cache: false,
            success: function(data){
                // the response will be an array containing a json structure consisting of repo name/id...
                var found = false;

                if (name_id !== undefined) {
                    // user entered repo name from the template tree
                    $.each(data, function(index, item) {
                        if ((item.id === name_id) && (item.value === name)) {
                            KT.templates.add_repo(item.value, item.id);
                            found = true;
                            return false;  // found, stop looping
                        }
                    });
                }
                if (!found) {
                    // either user selected repo from the content tree or
                    // they selected it from template tree autocomplete results, but then retyped
                    // a repo name (overriding a previous selection)
                    $.each(data, function(index, item) {
                        if (item.value === name) {
                            KT.templates.add_repo(item.value, item.id);
                            found = true;
                            return true;  // continue looping
                        }
                    });
                }

                if (!found) {
                    current_input.error();
                }
                cleanup_cb();
            },
            error: KT.templates.throw_error
        });
    },
    //called once on page load
    register_events = function() {
        $(".remove_repo").live('click', function() {
            var btn = $(this),
                id = btn.attr("data-id"),
                name = btn.attr("data-name");

            if (name && id) {
                KT.templates.remove_repo(name, id);
            }
        });

        $(".repo_add_remove").live('click', function(){
            var btn = $(this),
                name = btn.attr("data-name"),
                id = btn.attr("data-id");

            if (KT.templates.has_repo(id)) {
                //need to remove
                KT.templates.remove_repo(name, id);
            }
            else {
                //need to add
                btn.html("<img  src='images/embed/icons/spinner.gif'>");
                current_input.manually_add(name, id);
            }
        });
    };
    return {
        register_events: register_events,
        register_autocomplete: register_autocomplete
    };
})();

KT.package_actions = (function() {
    var current_input = undefined,

    //called everytime 'packages is loaded'
    register_autocomplete = function() {
        current_input = KT.auto_complete_box({
            values:       KT.routes.auto_complete_library_packages_path(),
            default_text: i18n.package_search_text,
            input_id:     "add_package_input",
            form_id:      "add_package_form",
            add_btn_id:   "add_package",
            add_cb:       verify_add_package
        });
    },
    verify_add_package = function(name, name_id, cleanup_cb){
        $.ajax({
            type: "GET",
            url: KT.routes.validate_name_library_packages_path(),
            data: {term:name},
            cache: false,
            success: function(data){
                if (data > 0) {
                    KT.templates.add_package(name);
                }
                else {
                    current_input.error();
                }
                cleanup_cb();
            },
            error: KT.templates.throw_error
        });
    },
    auto_complete_call = function(req, response_cb) {
        $.ajax({
            type: "GET",
            url: auto_complete_package,
            data: {term:req.term},
            cache: false,
            success: function(data){
                response_cb(data.splice(0, 20)); //only show 20 packages at a time
            },
            error: KT.templates.throw_error
        });
    },
    //called once on page load
    register_events = function() {
        $(".remove_package").live('click', function() {
            var pkg = $(this).siblings("span").text();
            if (pkg && pkg.length > 0) {
                KT.templates.remove_package(pkg);
            }
        });
        
        $(".package_add_remove").live('click', function(){
            var btn = $(this);
            var name = btn.attr("data-name");
            if (KT.templates.has_package(name)) {
                //need to remove
                KT.templates.remove_package(name);
            }
            else {
                //need to add
                btn.html("<img  src='images/embed/icons/spinner.gif'>");
                current_input.manually_add(name);
            }
        });
    };
    return {
        register_events: register_events,
        register_autocomplete: register_autocomplete
    };
})();


KT.package_group_actions = (function() {
    var current_input = undefined;

    //called everytime 'packages is loaded'
    var register_autocomplete = function() {
        current_input = KT.auto_complete_box({
            values:       KT.package_groups,
            default_text: i18n.package_group_search_text,
            input_id:     "add_package_group_input",
            form_id:      "add_package_group_form",
            add_btn_id:   "add_package_group",
            add_cb:       verify_add_group
        });
    },
    verify_add_group = function(name, name_id, cleanup_cb){
        if ($.inArray(name, KT.package_groups) > -1) {
            KT.templates.add_package_group(name);
        }
        else {
            current_input.error();
        }
        cleanup_cb();
    },
    auto_complete_call = function(req, response_cb) {
        $.ajax({
            type: "GET",
            url: KT.common.rootURL() + '/system_templates/auto_complete_package_groups',
            data: {name:req.term},
            cache: false,
            success: function(data){
                response_cb(data.splice(0, 20)); //only show 20 packages at a time
            },
            error: KT.templates.throw_error
        });
    },
    //called once on page load
    register_events = function() {
        $(".remove_package_group").live('click', function() {
            var pkg = $(this).siblings("span").text();
            if (pkg && pkg.length > 0) {
                KT.templates.remove_package_group(pkg);
            }
        });

        $(".package_group_add_remove").live('click', function(){
            var btn = $(this);
            var name = btn.attr("data-name");
            if (KT.templates.has_package_group(name)) {
                //need to remove
                KT.templates.remove_package_group(name);
            }
            else {
                //need to add
                btn.html("<img  src='images/embed/icons/spinner.gif'>");
                current_input.manually_add(name);
            }
        });

    };
    return {
        register_events: register_events,
        register_autocomplete: register_autocomplete
    };
})();


//Actions related with templates (CRUD)
KT.actions =  (function(){
    var options = KT.options;
    var buttons = KT.templates.buttons;
    var toggle_edit = function(is_opening) {
        var text = i18n.edit_close_label;
        if (is_opening.opening) {
            var curr = KT.options.current_template;
            $("#edit_template_name").text(curr.name);
            $("#edit_template_description").text(curr.description);
            KT.editable.setup_editable_name(curr.id, function(name){
                KT.templates.set_current_name(name);
                KT.options.template_tree.rerender_breadcrumb();
            });
            KT.editable.setup_editable_description(curr.id, function(desc){
                KT.templates.set_current_description(desc);
            });
        }
        else {
            text = i18n.edit_label;
        }
        reset_buttons();
        buttons.edit.find(".text").text(text);

        return {};
    },
    toggle_download = function(is_opening) {
        var text = i18n.edit_close_label;
        if (is_opening.opening) {
            var curr = KT.options.current_template;
            var options = '';

            // create an html option list
            envs = curr.environments
            if (envs.length == 0) {
                // TODO: Localize this
                options += '<option value="">' + 'i18n.noEnvironments' + '</option>';
            }
            else{
                for (var i = 0; i < envs.length; i++) {
                    options += '<option value="' + envs[i].id + '">' + envs[i].name + '</option>';
                }
            }
            // add the options to the system template select... this select exists on an insert form
            // or as part of the environment edit dialog
            $("#system_template_environment_id").html(options);
        }
        return {};
    },
    close_modified_dialog = function() {
        $("#modified_dialog").dialog('close');
         buttons.save_dialog.unbind('click');
        buttons.save_dialog.unbind('click');
    },
    open_modified_dialog = function(save_cb, next_cb) {
        var text = i18n.modify_message;
        text = text.replace("$TEMPLATE", options.current_template.name);
        
       $("#modified_dialog").dialog('open');
       $("#modified_dialog").find(".text").text(text);

       buttons.save_dialog.click(function() {
           close_modified_dialog();
           save_cb();
           next_cb();
       });
       buttons.discard_dialog.click(function() {
           close_modified_dialog();
           next_cb();
       });
    },
    reset_buttons = function() {
        buttons.edit.find(".text").text(i18n.edit_label);
    },
    toggle_list = {
        'template_edit': { container 	: 'edit_template_container',
                        button		: 'edit_template',
                        setup_fn	: toggle_edit

        },
        'template_download': { container 	: 'download_template_container',
                            button		: 'download_template',
                            setup_fn: toggle_download
        }
    },
    register_events = function() {
        $("#panel").delegate('form[id^=new_system_template]', 'submit', function(e) {
            var button = $('#template_save');
            var  slide_button = $('#add_template');
            
            e.preventDefault(); //disable submit
            button.attr('disabled', 'disabled');
            slide_button.addClass("disabled");

            $(this).ajaxSubmit({
                    success:function(data) {
                        button.removeAttr("disabled");
                        slide_button.removeClass("disabled");
                        KT.panel.closePanel($("#panel"));
                        KT.templates.add_new_template(data.id, data.name);
                    },
                    error:function() {
                        button.removeAttr("disabled");
                        slide_button.removeClass("disabled");
                    }
            });
        });
        buttons.remove.click(function(){
            if ( $(this).hasClass('disabled') || !KT.options.current_template ){
                return false;
            }
            KT.common.customConfirm({
                message: $(this).attr('data-confirm-text'),
                yes_callback: function(){
                    $.ajax({
                        type: "DELETE",
                        url: KT.routes.system_template_path(options.current_template.id),
                        cache: false,
                        success: function(data){
                            KT.templates.remove_template(options.current_template.id);
                        },
                        error: KT.templates.throw_error
                    });
                }
            });
            return false;
        });
        $('#download_key').live('click', function(e){
            e.preventDefault();  //stop the browser from following
            environment_id = $("#system_template_environment_id").attr('value');
            validate_url = KT.routes.validate_system_template_path(options.current_template.id) +
                    '?environment_id=' + environment_id;
            $.get(validate_url, function(){
                url = KT.routes.download_system_template_path(options.current_template.id) +
                        '?environment_id=' + environment_id;
                window.location.href = url;
            });
        });
        $('#save_template').live('click', function(){
            if ($(this).hasClass("disabled")) {
                return false;
            }
            $('#save_template').addClass("disabled");
            $("#tree_saving").css("z-index", 300);
            var current = KT.options.current_template;
            var data = {
                packages: current.packages,
                repos: current.repos,
                products: current.products,
                package_groups: current.package_groups,
                distribution: current.distribution
            };
            $.ajax({
                type: "PUT",
                contentType:"application/json",
                url: KT.routes.update_content_system_template_path(options.current_template.id),
                data: JSON.stringify(data),
                cache: false,
                success: function(data){
                    $("#tree_saving").css("z-index", -1);
                    KT.options.current_template = data;
                },
                error: KT.templates.throw_error
            });
            return false;
        });
    },
    register_distro_select = function(){
        $(".distro_select").change(function(){
            KT.templates.set_distro($(this).attr("id"));
        });
    };

    return {
        toggle_list: toggle_list,
        register_events: register_events,
        open_modified_dialog: open_modified_dialog,
        register_distro_select: register_distro_select
    };
})();

KT.template_download = {
    setup_environment_names : function(id, success) {
        alert("in setup");
        // update the appropriate content on the page
        var options = '';

        // create an html option list using the response
        options += '<option value="">' + i18n.noTemplate + '</option>';
        for (var i = 0; i < response.length; i++) {
            options += '<option value="' + response[i].id + '">' + response[i].name + '</option>';
        }

        // add the options to the system template select... this select exists on an insert form
        // or as part of the environment edit dialog
        $("#activation_key_system_template_id").html(options);
     }
};

//Setup jeditable stuff
KT.editable = {
    setup_editable_name : function(id, success) {
        $('.edit_template_name').each(function() {
            $(this).editable('destroy');
            $(this).editable(KT.common.rootURL() + "/system_templates/" + id, {
                type        :  'text',
                width       :  250,
                method      :  'PUT',
                name        :  $(this).attr('name'),
                cancel      :  i18n.cancel,
                submit      :  i18n.save,
                indicator   :  i18n.saving,
                tooltip     :  i18n.clickToEdit,
                placeholder :  i18n.clickToEdit,
                submitdata  :  {authenticity_token: AUTH_TOKEN},
                onsuccess   :  success,
                onerror     :  function(settings, original, xhr) {
                    original.reset();
                }
            });
        });
    },
    setup_editable_description : function(id, success) {
        $('.edit_template_description').each(function() {
            $(this).editable('destroy');
            $(this).editable(KT.common.rootURL() + "/system_templates/" + id, {
                type        :  'textarea',
                rows        :  6,
                cols        : 30,
                method      :  'PUT',
                name        :  $(this).attr('name'),
                cancel      :  i18n.cancel,
                submit      :  i18n.save,
                indicator   :  i18n.saving,
                tooltip     :  i18n.clickToEdit,
                placeholder :  i18n.clickToEdit,
                submitdata  :  {authenticity_token: AUTH_TOKEN},
                onsuccess   :  success,
                onerror     :  function(settings, original, xhr) {
                    original.reset();
                }
            });
        });
    }
};

$(document).ready(function() {
    $('.left').resizable('destroy');
    var buttons =KT.templates.buttons;
    buttons.edit = $("#edit_template");
    buttons.remove = $("#remove_template");
    buttons.download = $("#download_template");
    buttons.save = $("#save_template");
    buttons.save_dialog = $("#save_dialog");
    buttons.discard_dialog = $("#discard_dialog");

    $("#modified_dialog").dialog({modal: true, width: 400, autoOpen: false});

    buttons.download.tipsy({gravity:'n', trigger:'manual'})
    KT.options.templates = KT.template_breadcrumb["templates"].templates;

    KT.options.content_tree = sliding_tree("content_tree", {
                            breadcrumb      :  KT.content_breadcrumb,
                            default_tab     :  "products",
                            bbq_tag         :  "products",
                            base_icon       :  'home_img',
                            enable_filter   :  false,
                            tab_change_cb   :  function(hash_id) {
                                KT.templates.reset_page();
                            },
                            expand_cb      :  KT.templates.reset_page
                        });
    KT.options.content_tree.enableSearch();

    KT.options.template_tree = sliding_tree("template_tree", {
                            breadcrumb      :  KT.template_breadcrumb,
                            default_tab     :  "templates",
                            bbq_tag         :  "template",
                            base_icon       :  'home_img',
                            render_cb       :  KT.template_renderer.render_hash,
                            tab_change_cb   :  function(hash) {
                                KT.package_actions.register_autocomplete();
                                KT.repo_actions.register_autocomplete();
                                KT.product_actions.register_autocomplete();
                                KT.package_group_actions.register_autocomplete();
                                KT.templates.reset_page();
                                KT.actions.register_distro_select();
                            },
                            enable_filter   :  true,
                            enable_float	:  true
                        });

    KT.options.action_bar = sliding_tree.ActionBar(KT.actions.toggle_list);
    KT.actions.register_events();
    KT.package_actions.register_events();
    KT.repo_actions.register_events();
    KT.product_actions.register_events();
    KT.package_group_actions.register_events();

    //Handle scrolling
    KT.panel.registerPanel($('#template_tree'), $('#template_tree').width() + 50);

    //Ask the user if they really want to leave the page if the template isn't saved
    window.onbeforeunload = function(){
        if(KT.options.current_template && KT.options.current_template.modified){
            return i18n.leave_page.replace("$TEMPLATE",  KT.options.current_template.name);
        }
    };
    $(window).trigger('hashchange');

    $(document).bind('open_panel.tupane', function(){
        KT.options.action_bar.reset();
    });
});
