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
        add: undefined,
        edit: undefined,
        remove: undefined
    },
    fetch_template = function(template_id, callback) {
        $("#tree_loading").css("z-index", 300);
        $.ajax({
            type: "GET",
            url: "/system_templates/" + template_id + "/object/",
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
            if (item.template_id === id) {
                KT.options.templates.splice(index, 1);
                return true;
            }
        });
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
        bc['products_' + id ] = {
            cache: null,
            client_render: true,
            name: i18n.products,
            trail: ['templates', template_root],
            url: ''
        };
        
    },
    add_package = function(name) {
      var pkgs = KT.options.current_template.packages;
      if ($.inArray(name, pkgs) === -1) {
        pkgs.push(name);
      }
      KT.options.template_tree.rerender_content();
    },
    remove_package = function(name) {
        var pkgs = KT.options.current_template.packages;
        var loc = $.inArray(name, pkgs);
        if (loc > -1) {
            pkgs.splice(loc, 1);
        }
    },
    reset_page = function() {

        if (KT.options.current_template === undefined) {
            buttons.edit.addClass("disabled");
            buttons.remove.addClass("disabled");
        }
        else {
            buttons.edit.removeClass("disabled");
            buttons.remove.removeClass("disabled");
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
        remove_package: remove_package
    }


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
        console.log(hash_id);
        var node = hash_id.split('_')[0];
        var template_id = hash_id.split('_')[1];

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
            else {
                console.log("Can't render: " +  id);
            }
            render_cb(content);
        });

    },
    list_item = function(id, text, is_slide_link) {
        var html = '<li class="' + (is_slide_link ? 'slide_link' : '')  + '">';
        html += '<div class="link_details" id="' + id + '">';
        html += '<span class="sort_attr">' + text + '</span>';
        html += "</div></li>";
        return html ;
    },
    package_item = function(pkg_name) {
        var html = '<li class="">';
        html += '<div class="" id=pkg_"' + pkg_name + '">';
        html += '<span class="sort_attr">' + pkg_name + '</span>';
        html += '<a id="" class="fr st_button remove_package">' + i18n.remove + '</a>';
        html += "</div></li>";
        return html ;
    },
    packages = function() {
        var html = '<ul><li><form id="add_package_form"><input id="add_package_input" type="text" size="35"><form>  ';
        html += '<a id="add_package" class="fr st_button ">' + i18n.add_plus + '</a>';
        html += ' </li></ul>';

        html +=  "<ul>";
        $.each(KT.options.current_template.packages, function(index, item) {
            html += package_item(item);//TODO do ths correctly
            
        });

        
        return html + "</ul>";
    },
    details = function(t_id) {
        var html = "<ul>";
        $.each([['products_', i18n.products], ['packages_', i18n.packages]], function(index, item_set) {
            html += list_item(item_set[0] + t_id, item_set[1], true);
        });
        return html + "</ul>";
    },
    template_list = function() {
        var templates = KT.options.templates;
        if (templates.length === 0) {
            return i18n.templates_empty;
        }

        var html = "<ul>";
        $.each(templates, function(index, template) {
            html += list_item("details_" + template.template_id, template.template_name, true);
        });
        html += "</ul>";
        return html;
    };

    
    return {
        render_hash: render_hash
    }
}();




KT.actions =  (function(){
    var options = KT.options;
    var buttons = KT.templates.buttons;
    var toggle_new = function(is_opening) {
        var text = i18n.add_close_label;

        if (is_opening) {
            $("#system_template_name").attr("value", "");
            $("#system_template_description").attr("value", "");
        }
        else {
            text = i18n.add_label;
        }
        buttons.add.find(".text").text(text);

        return {};
    },
    toggle_edit = function(is_opening) {
        var text = i18n.edit_close_label;
        if (is_opening) {
            var curr = KT.options.current_template;
            $("#edit_template_name").text(curr.name);
            $("#edit_template_description").text(curr.description);
            KT.editable.setup_editable_name(curr.id, function(name){
                KT.templates.set_current_name(name);
                KT.options.template_tree.rerender_breadcrumb();
            });
            KT.editable.setup_editable_description(curr.id, function(desc){
                KT.templates.set_current_description(desc);
            })
        }
        else {
            text = i18n.edit_label;
        }
        buttons.edit.find(".text").text(text);

        return {};
    },
    toggle_list = {
            'edit_template_container'   :  toggle_edit,
            'add_template_container'   :  toggle_new
    },
    register_events = function() {

        $('form[id^=new_system_template]').live('submit', function(e) {
            var button = $('#template_save');
            var  slide_button = $('#add_template');
            
            e.preventDefault(); //disable submit
            button.attr('disabled', 'disabled');
            slide_button.addClass("disabled");

            $(this).ajaxSubmit({
                    success:function(data) {
                        button.removeAttr("disabled");
                        slide_button.removeClass("disabled");
                        options.action_bar.toggle('add_template_container');
                        KT.templates.add_new_template(data.id, data.name);
                    },
                    error:function() {
                        button.removeAttr("disabled");
                        slide_button.removeClass("disabled");
                    }
            });
        });



        buttons.add.click(function(){
            if ( $(this).hasClass('disabled') ){
                return false;
            }
            options.action_bar.toggle('add_template_container');
        });
        buttons.edit.click(function(){
            if ( $(this).hasClass('disabled') || !KT.options.current_template){
                return false;
            }
            options.action_bar.toggle('edit_template_container');
        });
        buttons.remove.click(function(){
            if ( $(this).hasClass('disabled') || !KT.options.current_template ){
                return false;
            }
            common.customConfirm($(this).attr('data-confirm-text'), function(){
                $.ajax({
                    type: "DELETE",
                    url: '/system_templates/' + options.current_template.id,
                    cache: false,
                    success: function(data){
                        KT.templates.remove_template(options.current_template.id)
                    },
                    error: KT.templates.throw_error
                });
            });
        });
        var add_package = function(e) {
            var input = $("#add_package_input");
            e.preventDefault();
            var pkg = input.attr("value");
            if (pkg.length > 0) {
                KT.templates.add_package(pkg);
            }
            //Why doesn't jquery work here!!!!
            document.getElementById("add_package_input").focus();
            //input.focus();
        };
        $("#add_package").live('click', add_package);
        $(".right_tree").delegate( "#add_package_form", "submit", add_package);
        $(".remove_package").live('click', function() {
            var pkg = $(this).siblings("span").text();
            if (pkg && pkg.length > 0) {
                KT.templates.remove_package(pkg);
            }
            $(this).closest("li").remove();
        });
        

    };



    return {
        toggle_list: toggle_list,
        register_events: register_events
    };
})();




//Setup jeditable stuff
KT.editable = {
    setup_editable_name : function(id, success) {
        $('.edit_template_name').each(function() {
            $(this).editable("/system_templates/" + id, {
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
            $(this).editable("/system_templates/" + id, {
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
    
    var buttons =KT.templates.buttons;
    buttons.edit = $("#edit_template");
    buttons.add = $("#add_template");
    buttons.remove = $("#remove_template");

    KT.options.templates = KT.template_breadcrumb["templates"].templates

    KT.options.content_tree = sliding_tree("content_tree", {
                            breadcrumb      :  KT.content_breadcrumb,
                            default_tab     :  "products",
                            bbq_tag         :  "products",
                            base_icon       :  'home_img',
                            enable_search   :  false,
                            tab_change_cb   :  function(hash_id) {
                            }
                        });

    KT.options.template_tree = sliding_tree("template_tree", {
                            breadcrumb      :  KT.template_breadcrumb,
                            default_tab     :  "templates",
                            bbq_tag         :  "template",
                            base_icon       :  'home_img',
                            enable_search   :  false,
                            render_cb       :  KT.template_renderer.render_hash,
                            tab_change_cb   :  KT.templates.reset_page,
                            enable_search   :  true
                        });

 

    KT.options.action_bar = sliding_tree.ActionBar(KT.actions.toggle_list);
    KT.actions.register_events();




});