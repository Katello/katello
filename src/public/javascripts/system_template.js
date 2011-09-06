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
        remove: undefined,
        save: undefined,
        discard_dialog: undefined,
        save_dialog: undefined

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
    in_pkg_array = function(name) {
        var to_ret = -1;
        $.each(KT.options.current_template.packages, function(index, item) {
            if (item.name === name) {
                to_ret = index;
                return false;
            }
        });
        return to_ret;
    },
    has_package = function(name) {
        return in_pkg_array(name) > -1;
    },
    add_package = function(name) {
      var pkgs = KT.options.current_template.packages;
      if (!has_package(name)) {
        pkgs.push({name:name});
      }
      KT.options.current_template.modified = true;
      KT.options.template_tree.rerender_content();
    },
    remove_package = function(name) {
        var pkgs = KT.options.current_template.packages;
        var loc = in_pkg_array(name);
        if (loc > -1) {
            pkgs.splice(loc, 1);
            KT.options.current_template.modified = true;
            change_content_toggle(name, false);
            KT.options.template_tree.rerender_content();
        }
    },
    reset_page = function() {
        if (KT.options.current_template === undefined) {
            buttons.edit.addClass("disabled");
            buttons.remove.addClass("disabled");
            buttons.save.addClass("disabled");
            $('.content_add_remove').hide();
        }
        else {
            buttons.edit.removeClass("disabled");
            buttons.remove.removeClass("disabled");
            if (KT.options.current_template.modified) {
                buttons.save.removeClass("disabled");
            }
            else {
                buttons.save.addClass("disabled");
            }
            $('.content_add_remove').not('.working').show().text(i18n.add_plus); //reset all add/remove to add
            $.each(KT.options.current_template.packages, function(index, item){
                var btn = $('a[data-name=' + item.name + ']').not('.working');
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
        var btn = $("a[data-name=" + pkg_name + "]");
        if (btn.length > 0) {
            if (adding) {
                btn.text(i18n.remove);
            }
            else {
                btn.text(i18n.add_plus);
            }
        }
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
        has_package: has_package
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
        var node = hash_id.split('_')[0];
        var template_id = hash_id.split('_')[1];
        var curr_t = KT.options.current_template;
        var modified = false;

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
                else {
                    console.log("Can't render: " +  id);
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
        var html = '<ul><li id="package_input_item"><form id="add_package_form"><input id="add_package_input" type="text" size="35"><form>  ';
        html += '<a id="add_package" class="fr st_button ">' + i18n.add_plus + '</a>';
        html += ' </li></ul>';

        html +=  "<ul>";
        $.each(KT.options.current_template.packages, function(index, item) {
            html += package_item(item.name);//TODO do ths correctly
            
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
    toggle_list = {
            'edit_template_container'   :  toggle_edit,
            'add_template_container'   :  toggle_new
    },
    verify_add_package = function(name, btn, focus){
            var input = $("#add_package_input");
            
            if (btn.hasClass("working") || name.length === 0){
                return;
            }
            btn.addClass("working");

            btn.html("<img  src='/images/spinner.gif'>");
            input.attr("disabled", "disabled");
            input.autocomplete('disable');
            input.autocomplete('close');

            $.ajax({
                type: "GET",
                url: '/system_templates/auto_complete_package',
                data: {name:name},
                cache: false,
                success: function(data){
                    btn.removeClass('working');
                    btn.html(i18n.add_plus);
                    input.removeAttr('disabled');
                    input.autocomplete('enable');
                    if ($.inArray(name, data) > -1) {
                        KT.templates.add_package(name);
                    }
                    else {
                        input.addClass("error");
                    }
                    if (focus) {
                        $("#add_package_input").focus();
                    }
                },
                error: KT.templates.throw_error
            });


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
            var btn = $("#add_package");
            var input = $("#add_package_input");
            var pkg = input.attr("value");
            if (pkg === i18n.default_search_text) {
                return;
            }

            e.preventDefault();
            verify_add_package(pkg, btn, true);

        };
        $("#add_package").live('click', add_package);
        $(".right_tree").delegate( "#add_package_form", "submit", add_package);
        $(".remove_package").live('click', function() {
            var pkg = $(this).siblings("span").text();
            if (pkg && pkg.length > 0) {
                KT.templates.remove_package(pkg);
            }
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
                    products: current.products
                };
                $.ajax({
                    type: "PUT",
                    contentType:"application/json",
                    url: '/system_templates/' + options.current_template.id + '/update_content/',
                    data: JSON.stringify(data),
                    cache: false,
                    success: function(data){
                        $("#tree_saving").css("z-index", -1);
                        KT.options.current_template = data;
                    },
                    error: KT.templates.throw_error
                });
        });

        $(".content_add_remove").live('click', function(){
            var btn = $(this);
            var name = btn.attr("data-name");
            if (KT.templates.has_package(name)) {
                //need to remove
                KT.templates.remove_package(name);
            }
            else {
                //need to add
                verify_add_package(name, btn, false);
            }

        });

    },
    register_autocomplete = function() {
        var input = $("#add_package_input");
        input.val(i18n.default_search_text);
        input.autocomplete({
            source: function(req, response_cb){
                    $.ajax({
                        type: "GET",
                        url: '/system_templates/auto_complete_package',
                        data: {name:req.term},
                        cache: false,
                        success: function(data){
                            response_cb(data.splice(0, 20)); //only show 20 packages at a time
                        },
                        error: KT.templates.throw_error
                    });
            } 
        });
        input.focus(function() {
            if (input.val() === i18n.default_search_text) {
                input.val("");
            }
        });
        input.blur(function() {
            if(input.val() === "") {
                input.val(i18n.default_search_text);
            }

        });

    };
    



    return {
        toggle_list: toggle_list,
        register_events: register_events,
        register_autocomplete: register_autocomplete,
        open_modified_dialog: open_modified_dialog
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
    buttons.save = $("#save_template");
    buttons.save_dialog = $("#save_dialog");
    buttons.discard_dialog = $("#discard_dialog");

    $("#modified_dialog").dialog({modal: true, width: 400, autoOpen: false});



    KT.options.templates = KT.template_breadcrumb["templates"].templates

    KT.options.content_tree = sliding_tree("content_tree", {
                            breadcrumb      :  KT.content_breadcrumb,
                            default_tab     :  "products",
                            bbq_tag         :  "products",
                            base_icon       :  'home_img',
                            enable_search   :  false,
                            tab_change_cb   :  function(hash_id) {
                                KT.templates.reset_page();
                            }
                        });

    KT.options.template_tree = sliding_tree("template_tree", {
                            breadcrumb      :  KT.template_breadcrumb,
                            default_tab     :  "templates",
                            bbq_tag         :  "template",
                            base_icon       :  'home_img',
                            render_cb       :  KT.template_renderer.render_hash,
                            tab_change_cb   :  function(hash) {
                                KT.actions.register_autocomplete();
                                KT.templates.reset_page();
                            },
                            enable_search   :  true
                        });

 

    KT.options.action_bar = sliding_tree.ActionBar(KT.actions.toggle_list);
    KT.actions.register_events();


    var container = $('#container');
    var original_top = Math.floor($('.left').position(top).top);
    if(container.length > 0){
        var bodyY = parseInt(container.offset().top, 10) - 20;
        var offset = $('#template_tree').width() + 50;
        $(window).scroll(function () {
            panel.handleScroll($('#template_tree'), container, original_top, bodyY, 0, offset);
        });
        $(window).resize(function(){
           panel.handleScrollResize($('#template_tree'), container, original_top, bodyY, 0, offset);
        });
    }

});