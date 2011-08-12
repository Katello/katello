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

/*
 * A small javascript file needed to load things whenever a role is opened for editing
 *
 */
var roles_tree = {};

var roleActions = (function($){
    var opened = false,
        open_panel = undefined,
        current_crumb = undefined,
        current_organization = undefined,
        toggle_list = {
            'role_edit' : function(){
                var name_box = $('.edit_name_text'),
                    edit_button = $('#edit_role > span'),
                    description = $('.edit_description'),    
                    after_function = undefined,
                    nameBreadcrumb = $('.tree_breadcrumb'),
                    options = {};
        
                opened = !opened;
        
                if (opened) {
                    edit_button.html(i18n.close_role_details);
                    edit_button.parent().addClass("highlighted");
                    options['after_function'] = setup_edit;
                }
                else {
                    edit_button.html(i18n.edit_role_details);
                    edit_button.parent().removeClass("highlighted");
                }
                
                return options;
            },
            'permission_add' : function(){
                var options = {},
                    set_types = function(){
                        var types = roles_breadcrumb[current_organization].permission_details,
                            types_select = $('#resource_type');
                        
                        types_select.empty();
                        for( type in types ){
                            if( types.hasOwnProperty(type) ){
                                if( current_crumb.split('_')[0] === 'organization' ){
                                    if( !types[type].global ){
                                        types_select.append('<option value="' + type + '">' + types[type].name + '</option>');
                                    }
                                } else {
                                    types_select.append('<option value="' + type + '">' + types[type].name + '</option>');
                                }
                            }
                        }    
                    },
                    set_verbs_and_tags = function(type){
                        var i, length=0,
                            verbs_select = $('#verbs'),
                            tags_select = $('#tags'),
                            verbs = roles_breadcrumb[current_organization].permission_details[type].verbs,
                            tags = roles_breadcrumb[current_organization].permission_details[type].tags;
                    
                        length = verbs.length;
                        verbs_select.empty();
                        for( i=0; i < length; i+= 1){
                            verbs_select.append('<option value="' + verbs[i].name + '">' + verbs[i].display_name + "</option>");
                        }
                        
                        if( type !== 'organizations' && current_organization !== "global" ){
                            length = tags.length;
                            tags_select.empty();
                            for( i=0; i < length; i+= 1){
                                tags_select.append('<option value="' + tags[i].name + '">' + tags[i].display_name + "</option>");
                            }
                            tags_select.parent().show();
                        } else {
                            tags_select.parent().hide();
                        }
                    };
                    
                opened = !opened;
                
                if( opened ){
                    set_types();
                    set_verbs_and_tags('organizations');
                }
                                
                $('#resource_type').change(function(event){
                    set_verbs_and_tags(event.currentTarget.value);
                });
                
                if( current_organization === "global" ){
                    $('#permission_add_header').html(i18n.add_header_global);
                } else {
                    $('#permission_add_header').html(i18n.add_header_org + ' ' + roles_breadcrumb[current_organization].name);
                }
                
                return options;
            }
        },

        toggle = function(id){
            var animate_time = 500,
                slide_window = $('#' + id),
                options = {};
            
            if( open_panel !== id && open_panel !== undefined ){
                toggle_list[open_panel]();
                $("#" + open_panel).slideToggle(animate_time);
                open_panel = id;
            } else if( open_panel !== undefined ){
                open_panel = undefined;
            } else {
                open_panel = id;
            }

            options = toggle_list[id]();
            slide_window.slideToggle(animate_time, options.after_function);
        }, 
        setup_edit = function() {
            var url = "/roles/" + $('#role_id').val(),
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
                          roles_breadcrumb.roles.name = parsed.name;
                          $('.edit_name_text').html(parsed.name);
                          roles_tree.rerender_breadcrumb();
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
                    },
                    onerror     :  function(settings, original, xhr) {
                        original.reset();
                    }
                });
            });
        },
        close = function() {
            if( open_panel ){
                toggle(open_panel);
            }
        },
        setCurrentCrumb = function(hash_id){
            current_crumb = hash_id;
        },
        setCurrentOrganization = function(hash_id){
            current_organization = hash_id;
        },
        getPermissionDetails = function(hash_id){
            var id = hash_id.split('_');
            
            if( !roles_breadcrumb[hash_id].permission_details ){
                $.ajax({
                    type    : "GET",
                    url     : '/roles/' + id + '/resource_type/verbs_and_scopes',
                    cache   : false,
                    dataType: 'json',
                    success : function(data){
                        roles_breadcrumb[hash_id].permission_details = data;
                    }
                });
            }
        },
        savePermission = function(){
            var org_id = current_crumb.split('_')[1],
                form = $('#add_permission_form');
            
            form.find("#organization_id").val(org_id);
            
            $.ajax({
               type     : "PUT",
               url      : "/roles/" + $('#role_id').val() + "/create_permission/",
               cache    : false,
               data     : $('#add_permission_form').serialize(),
               dataType : 'json',
               success  : function(data){
                   $.extend(roles_breadcrumb, data);
                   roles_tree.rerender_content();
                   toggle('permission_add');
               }
            });
        },
        remove_permission = function(element){
            var id = element.attr('data-id');
            
            $.ajax({
               type     : "DELETE",
               url      : "/roles/" + $('#role_id').val() + "/permission/" + id.split('_')[2] + "/destroy_permission/",
               cache    : false,
               dataType : 'json',
               success  : function(data){
                    delete roles_breadcrumb[id];
                    roles_tree.rerender_content();
               }
            });
        },
        edit_user = function(element, adding){
            var submit_data = { update_users : { adding : adding, user_id : element.attr('data-id').split('_')[1] }};

            $.ajax({
               type     : "PUT",
               url      : "/roles/" + $('#role_id').val(),
               cache    : false,
               data     : $.param(submit_data),
               dataType : 'json',
               success  : function(data){
                    if( adding ){
                        roles_breadcrumb[element.attr('data-id')].has_role = true;
                    } else {
                        roles_breadcrumb[element.attr('data-id')].has_role = false;
                    }
                    roles_tree.rerender_content();
               }
            });
        },
        handleContentAddRemove = function(element){
            if( element.attr('data-type') === 'permission' ){
                if( element.hasClass('remove_permission') ){
                    remove_permission(element);
                }
            } else if( element.attr('data-type') === 'user'){
                if( element.hasClass('add_user') ){
                    edit_user(element, true);
                } else if( element.hasClass('remove_user') ){
                    edit_user(element, false);
                }
            }
        };

    return {
        toggle                  :  toggle,
        close                   :  close,
        getPermissionDetails    :  getPermissionDetails,
        setCurrentCrumb         :  setCurrentCrumb,
        savePermission          :  savePermission,
        handleContentAddRemove  :  handleContentAddRemove,
        setCurrentOrganization  :  setCurrentOrganization
    };
    
})(jQuery);

var templateLibrary = (function($){
    var listItem = function(id, name, count, no_slide){
            var html ='<li>';
            
            if( no_slide ){
                html += '<div class="no_slide" id="' + id + '">'; 
            } else {
                html += '<div class="slide_link" id="' + id + '">';
            }
   
            if( count !== undefined && count !== null && count !== false ){
                html += '<span class="sort_attr">'+ name + ' (' + count + ')</span></div></li>';
            } else {
                html += '<span class="sort_attr">'+ name + '</span></div></li>';
            }
            return html;
        },
        list = function(items, type, options){
            var html = '<ul>',
                options = options ? options : {};
            for( item in items){
                if( items.hasOwnProperty(item) ){
                    if( item.split("_")[0] === type ){
                        html += listItem(item, items[item].name, false, options.no_slide);
                    }
                }
            }
            html += '</ul>';
            return html;
        },
        organizationsList = function(items, type, options){
            var html = '<ul>',
                options = options ? options : {};
            
            html += listItem('global', items['global'].name, items['global'].count, false);
            
            for( item in items){
                if( items.hasOwnProperty(item) ){
                    if( item.split("_")[0] === type ){
                        html += listItem(item, items[item].name, items[item].count, options.no_slide);
                    }
                }
            }
            html += '</ul>';
            return html;
        },
        permissionsList = function(permissions, organization_id){
            var html = '<ul>';
            
            for( item in permissions){
                if( permissions.hasOwnProperty(item) ){
                    if( item.split("_")[0] === "permission" && permissions[item].organization === 'organization_' + organization_id ){
                        html += permissionsListItem(item, permissions[item].name, true);
                    }
                }
            }
            html += '</ul>';
            return html;
        },
        permissionsListItem = function(permission_id, name, showButton) {
            var anchor = "";
            
            if ( showButton ){
                anchor = '<a ' + 'class="fr content_add_remove remove_permission st_button"'
                                + 'data-type="permission" data-id="' + permission_id + '">';
                            anchor += i18n.remove + "</a>";
                        
            }
            
            return '<li>' + anchor + '<div class="slide_link" id="' + permission_id + '"><span class="sort_attr">'  + name + '</span></div></li>';
        },
        permissionItem = function(permission){
            var i = 0, length = 0,
                html = '<div class="permission_detail">';
            
            html += '<div class="permission_detail_container"><label class="grid_3 ra">Name: </label><span>' + permission.name + '</span></div>';
            html += '<div class="permission_detail_container"><label class="grid_3 ra">Description: </label><span>' + permission.description + '</span></div>';
                
            html += '<div class="permission_detail_container"><label class="grid_3 ra">Permission For: </label><span>' + permission.type + '</span></div>';
            
            html += '<div class="permission_detail_container"><label class="grid_3 ra">Verb(s): </label><span>'
            length = permission.verbs.length;
            for( i=0; i < length; i += 1){
                html += permission.verbs[i].verb;
                if( i !== length-1 ){
                    html += ',';
                }
            }
            html += '</span></div><div class="permission_detail_container"><label class="grid_3 ra">On:</label><span>';
            
            length = permission.tags.length;
            for( i=0; i < length; i += 1){
                html += permission.tags[i].name;
                if( i !== length-1 ){
                    html += ',';
                }
            }
            html += '</span></div></div>';

            return html;
        },
        usersListItem = function(user_id, name, has_role, showButton) {
            var anchor = "";
            
            if ( showButton ){
                anchor = '<a ' + 'class="fr content_add_remove ';
                anchor += has_role ? 'remove_user' : 'add_user';
                anchor += ' st_button" data-type="user" data-id="' + user_id + '">';
                anchor += has_role ? (i18n.remove + "</a>") : (i18n.add + "</a>");
            }
            
            return '<li>' + anchor + '<div class="no_slide"><span class="sort_attr">'  + name + '</span></div></li>';
        },
        usersList = function(users, options){
            var html = '<ul>',
                user = undefined;
            
            for( item in users){
                if( users.hasOwnProperty(item) ){
                    user = item.split("_");
                    if( user[0] === "user" ){
                        html += usersListItem(item, users[item].name, users[item].has_role, options.no_slide);
                    }
                }
            }
            html += '</ul>';
            return html;
        },
        globalsList = function(globals, options){
            var html = '<ul>';
            
            for( item in globals ){
                if( globals.hasOwnProperty(item) ){
                    if( item.split("_")[0] === "permission" && globals[item].global === true ){
                        html += permissionsListItem(item, globals[item].name, options.no_slide);
                    }
                }
            }
            
            html += '</ul>';
            return html;
        };
    
    return {
        list                :    list,
        organizationsList   :    organizationsList,
        permissionsList     :    permissionsList,
        usersList           :    usersList,
        globalsList         :    globalsList,
        permissionItem      :    permissionItem
    }
}(jQuery));

var rolesRenderer = (function($){
    var render = function(hash, render_cb){
            if( hash === 'role_permissions' ){
                render_cb(templateLibrary.organizationsList(roles_breadcrumb, 'organization'));
            } else if( hash === 'roles' ) {
                render_cb(templateLibrary.list(roles_breadcrumb, 'role'));
            } else if( hash === 'role_users' ){
                render_cb(templateLibrary.usersList(roles_breadcrumb, { no_slide : true }));
            } else if( hash === 'global' ) {
                render_cb(templateLibrary.globalsList(roles_breadcrumb, { no_slide : false }));
            } else {
                var split = hash.split("_"),
                    page = split[0],
                    organization_id = split[1];

                render_cb(getContent(page, hash, organization_id));
            }
        },
        getContent = function(key, hash, organization_id){
            if( key === 'organization' ){
                return templateLibrary.permissionsList(roles_breadcrumb, organization_id);
            } else if( key === 'permission' ){
                return templateLibrary.permissionItem(roles_breadcrumb[hash]);
            }
        },
        sort = function(hash_id) {
            $(".will_have_content").find("li").sortElements(function(a,b){
                    var a_html = $(a).find(".sort_attr").html();
                    var b_html = $(b).find(".sort_attr").html();
                    if (a_html && b_html ) {
                        return  a_html.toUpperCase() >
                                b_html.toUpperCase() ? 1 : -1;
                    }
            });
          
            if( hash_id === "role_permissions" ){
                $('#global').parent().prependTo($(".will_have_content ul"));  
            }
        },
        setTreeHeight = function(){
            var height = $('.left').height();
            $('.sliding_list').css({ 'height' : height - 20 });
            $('.slider').css({ 'height' : height - 20 });
            $('#panel_main').height(height);
            $('#panel_main .jspPage').height(height);
        },
        setSizing = function(){
            var width = $('.panel-custom').width();
            width -= 2;
            $('.sliding_container').width(width);
            $('.breadcrumb_search').width(width);
            $('.slider').width(width);
            $('.sliding_list').width(width * 2);
            $('.slide_up_container').width(width);
        },
        init = function(){
            setSizing();
            $('.left').resize(function(){
                setSizing();
            });
        },
        setStatus = function(hash_id){
            if( hash_id === 'roles' ){
                $('#roles_status').html(i18n.rolesStatus);
            } else if( hash_id === 'role_users' ){
                $('#roles_status').html(i18n.usersStatus);
            }
        },
        handleButtons = function(hash_id){
            var type = hash_id.split('_')[0];

            if( type === 'organization' || type === 'permission' || type === 'global' ){
                $('#add_permission').removeClass('disabled');
                roleActions.getPermissionDetails(hash_id);
                roleActions.setCurrentOrganization(hash_id);
            } else {
                $('#add_permission').addClass('disabled');
                roleActions.setCurrentOrganization(false);
            }
        };
    
    return {
        init            :   init,
        render          :   render,
        sort            :   sort,
        setTreeHeight   :   setTreeHeight,
        setStatus       :   setStatus,
        handleButtons   :   handleButtons
    }
    
}(jQuery));

var pageActions = (function($){
    var registerEvents = function(){
        $('#edit_role').live('click', function() {
            if ($(this).hasClass('disabled')){
                return false;
            }
            roleActions.toggle('role_edit');
        });
        
        $('#add_permission').live('click', function() {
            if ($(this).hasClass('disabled')){
                return false;
            }
            roleActions.toggle('permission_add');
        });
        
        $('#save_permission_button').click(function(){
            roleActions.savePermission();
        });
        
        $('.content_add_remove').live('click', function(){
            roleActions.handleContentAddRemove($(this));
        });
        
        panel.contract_cb = function(name){
                    $.bbq.removeState("role_edit"); 
                };
    };
    
    return {
        registerEvents  :  registerEvents
    };
    
})(jQuery);

$(function() {
  
  roles_tree = sliding_tree("roles_tree", { 
                          breadcrumb      :  roles_breadcrumb,
                          default_tab     :  "roles",
                          bbq_tag         :  "role_edit",
                          render_cb       :  rolesRenderer.render,
                          enable_search   :  true,
                          tab_change_cb   :  function(hash_id) {
                                rolesRenderer.sort(hash_id);
                                rolesRenderer.setTreeHeight();
                                rolesRenderer.setStatus(hash_id);
                                rolesRenderer.handleButtons(hash_id);
                                roleActions.setCurrentCrumb(hash_id);
                                roleActions.close();
                          }
                      });
                 
    rolesRenderer.init();
    pageActions.registerEvents();

});