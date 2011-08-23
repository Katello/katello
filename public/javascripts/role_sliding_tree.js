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
var ROLES = {};

ROLES.permissionWidget = function(){
    var current_stage       = undefined,
        next_button         = $('#next_button'),
        previous_button     = $('#previous_button'),
        done_button         = $('#save_permission_button'),
        all_types_button    = $('#all_types'),
        all_verbs_button    = $('#all_verbs'),
        all_tags_button     = $('#all_tags'),
        
        flow = {
            'name'          :   { previous  : false,
                                  next      : 'description', 
                                  container : $('#name_container'),
                                  validate  : function(){
                                        if( $("#permission_name").val() === "" ){
                                            if( !$('#name_container').find('span').hasClass('validation_error') ){
                                                $('#name_container').append('<div class="permission_add_container"><span class="validation_error">' + i18n.name_validation + '</span></div>');
                                            }
                                            return false;
                                        }  else {
                                            $('#name_container').find('span').remove();
                                            return true;
                                        }
                                  },
                                  actions   : function(){
                                        previous_button.hide();
                                  }
                                },
            'description'   :   { previous  : 'name', 
                                  next      : 'resource_type',
                                  container : $('#description_container'),
                                  validate  : function(){
                                        return true;  
                                  },
                                  actions   : function(){
                                        previous_button.show();
                                        if( all_types_button.hasClass('selected') ){
                                            handleAllTypes();
                                        }
                                  }
                                },
            'resource_type' :   { previous  : 'description', 
                                  next      : 'verbs',
                                  container : $('#resource_type_container'),
                                  input     : $('#resource_type'),
                                  validate  : function(){
                                      return true;
                                  },
                                  actions   : function(){
                                      if( done_button.is(":visible") ){
                                          done_button.hide();
                                          next_button.show();
                                      }
                                  }
                                },
            'verbs'         :   { previous  : 'resource_type',
                                  next      : 'tags',
                                  container : $('#verbs_container'),
                                  input     : $('#verbs'),
                                  validate  : function(){
                                        if( $('#verbs').val() === null && !all_verbs_button.hasClass('selected') ){
                                            if( !$('#verbs_container').find('span').hasClass('validation_error') ){ 
                                                $('#verbs_container').append('<div class="permission_add_container"><span class="validation_error">' + i18n.verb_validation + '</span></div>');
                                            }
                                            return false;
                                        } else {
                                            $('.validation_error').parent().remove();
                                            return true;
                                        }
                                  },
                                  actions   : function(){
                                        if( $('#resource_type').val() === 'organizations' || roleActions.getCurrentOrganization() === 'global' ){
                                            next_button.hide();
                                            done_button.show();        
                                        } else {
                                            done_button.hide();
                                            next_button.show();
                                        }
                                  }
                                }, 
            'tags'          :   { previous  : 'verbs',
                                  next      : false,
                                  container : $('#tags_container'),
                                  input     : $('#tags'),
                                  validate  : function(){
                                        return true;
                                  },
                                  actions   : function(){
                                        next_button.hide();
                                        done_button.show();
                                  }
                                }
        },
    
        init = function(){
            previous_button.hide();
            done_button.hide();
            next_button.unbind('click').click(handleNext);
            previous_button.unbind('click').click(handlePrevious);
            done_button.unbind('click').click(handleDone);
            all_types_button.unbind('click').click(function(){ handleAllTypes(); });
            all_verbs_button.unbind('click').click(function(){ handleAllVerbs(); });
            all_tags_button.unbind('click').click(function(){ handleAllTags(); });
            current_stage = 'name';
        },
        reset = function(){
            for( item in flow ){
                if( flow.hasOwnProperty(item) && item !== 'name' ){
                    flow[item].container.hide();
                }
            }
            all_types_button.removeClass('selected');
            all_types_button.html(i18n.all);
            all_verbs_button.removeClass('selected');
            all_verbs_button.html(i18n.all);
            all_tags_button.removeClass('selected');
            all_tags_button.html(i18n.all);
            previous_button.hide();
            next_button.show();
            done_button.hide();
            flow['verbs'].input.removeAttr('disabled');
            flow['tags'].input.removeAttr('disabled');
            current_stage = 'name';
            $('#add_permission_form')[0].reset();
            $('.validation_error').remove();
        },
        handleNext = function(){
            var next = flow[current_stage].next; 

            if( flow[current_stage].validate() ){
                flow[next].container.show();
                flow[next].actions();
                current_stage = next;   
            }
        },
        handlePrevious = function(){
            var previous = flow[current_stage].previous; 
            
            flow[current_stage].container.hide();
            flow[previous].actions();
            current_stage = previous;
        },
        handleDone = function(){
            roleActions.savePermission(function(){
                current_stage = 'name';
                reset();
            });
        },
        permission_add = function(opening){
            var options                 = {},
                current_organization    = roleActions.getCurrentOrganization(),
                button                  = $('#add_permission'),
                
                set_types = function(){
                    var types           = roles_breadcrumb[current_organization].permission_details,
                        types_select    = flow['resource_type'].input,
                        html            = "";
                    
                    types_select.empty();
                    for( type in types ){
                        if( types.hasOwnProperty(type) ){
                            if( type !== "all" ){
                                if( current_organization.split('_')[0] === 'organization' ){
                                    if( !types[type].global ){
                                        html += '<option value="' + type + '">' + types[type].name + '</option>';
                                    }
                                } else {
                                    html += '<option value="' + type + '">' + types[type].name + '</option>';
                                }
                            } else {
                                html += '<option class="hidden" value="all">All</option>';
                            }
                        }
                    }

                    types_select.append(html);
                },
                set_verbs_and_tags = function(type){
                    var i, length=0,
                        verbs_select = flow['verbs'].input,
                        tags_select = flow['tags'].input,
                        verbs = roles_breadcrumb[current_organization].permission_details[type].verbs,
                        tags = roles_breadcrumb[current_organization].permission_details[type].tags,
                        html = '';
                
                    length = verbs.length;
                    verbs_select.empty();
                    for( i=0; i < length; i+= 1){
                        html += '<option value="' + verbs[i].name + '">' + verbs[i].display_name + "</option>";
                    }
                    verbs_select.append(html);
                    
                    html = '';
                    if( type !== 'organizations' && current_organization !== "global" ){
                        length = tags.length;
                        tags_select.empty();
                        for( i=0; i < length; i+= 1){
                            html += '<option value="' + tags[i].name + '">' + tags[i].display_name + "</option>";
                        }
                        tags_select.append(html);
                    }
                };
            
            if( opening ){
                reset();
                set_types();
                set_verbs_and_tags(flow['resource_type'].input.val());
                button.children('span').html(i18n.close_add_permission);
                button.addClass("highlighted");
                flow['resource_type'].input.change(function(event){
                    set_verbs_and_tags(event.currentTarget.value);
                    if( current_stage !== 'resource_type' ){
                        flow['verbs'].actions();
                        current_stage = 'verbs';
                        flow['tags'].container.hide();
                    }
                    if( all_verbs_button.hasClass('selected') ){
                        handleAllVerbs();
                    }
                    if( all_tags_button.hasClass('selected') ){
                        handleAllTags();
                    }
                });
            
                if( current_organization === "global" ){
                    $('#permission_add_header').html(i18n.add_header_global);
                } else {
                    $('#permission_add_header').html(i18n.add_header_org + ' ' + roles_breadcrumb[current_organization].name);
                }
            } else {
                button.children('span').html(i18n.add_permission);
                button.removeClass("highlighted");
            }
            
            return options;
        },
        handleAllTypes = function(selected){
            selected = selected || all_types_button.hasClass('selected');
            
            if( !selected ){
                next_button.hide();
                done_button.show();
                flow['verbs'].container.hide();
                flow['tags'].container.hide();
                current_stage = 'resource_type';
                flow['verbs'].container.hide();
                flow['tags'].container.hide();
                flow['resource_type'].container.hide();
                flow['resource_type'].input.val('all');
                $('<span id="all_types_selected">' + i18n.all_types_selected + '</span>').insertBefore(all_types_button);
                all_types_button.html(i18n.cancel);
                all_types_button.addClass('selected');
            } else {
                next_button.show();
                done_button.hide();
                flow['verbs'].container.show();
                flow['resource_type'].container.show();
                $('#all_types_selected').remove();
                flow['resource_type'].input.val('organizations').change();
                all_types_button.html(i18n.all);
                all_types_button.removeClass('selected');
            }
        },
        handleAllVerbs = function(selected){
            selected = selected || all_verbs_button.hasClass('selected');
            
            if( !selected ){
                flow['verbs'].input.attr('disabled', 'disabled');
                all_verbs_button.html(i18n.cancel);
                all_verbs_button.addClass('selected');
            } else {
                flow['verbs'].input.removeAttr('disabled');
                all_verbs_button.html(i18n.all);
                all_verbs_button.removeClass('selected');
            }
        },
        handleAllTags = function(selected){
            selected = selected || all_tags_button.hasClass('selected');
            
            if( !selected ){
                flow['tags'].input.attr('disabled', 'disabled');
                all_tags_button.html(i18n.cancel);
                all_tags_button.addClass('selected');
            } else {
                flow['tags'].input.removeAttr('disabled');
                all_tags_button.html(i18n.all);
                all_tags_button.removeClass('selected');
            }
        };
        
    return {
        permission_add  :  permission_add,
        init            :  init
    };
    
};

var roleActions = (function($){
    var current_crumb = undefined,
        current_organization = undefined,

        role_edit = function(opening){
            var name_box        = $('.edit_name_text'),
                edit_button     = $('#edit_role > span'),
                description     = $('.edit_description'),    
                after_function  = undefined,
                nameBreadcrumb  = $('.tree_breadcrumb'),
                options         = {},
                
                setup_edit = function() {
                    var url = "/roles/" + $('#role_id').val(),
                        name_box = $('.edit_name_text'),
                        description = $('.edit_description'),
                        common = {
                            method      : 'PUT',
                            cancel      :  i18n.cancel,
                            submit      :  i18n.save,
                            indicator   :  i18n.saving,
                            tooltip     :  i18n.clickToEdit,
                            placeholder :  i18n.clickToEdit,
                            submitdata  :  {authenticity_token: AUTH_TOKEN},
                            onerror     :  function(settings, original, xhr) {
                                original.reset();
                            }
                        };
                    
                    name_box.each(function() {
                        var settings = {
                                type        :  'text',
                                width       :  270,
                                name        :  $(this).attr('name'),
                                onsuccess   :  function(data) {
                                      var parsed = $.parseJSON(data);
                                      roles_breadcrumb.roles.name = parsed.name;
                                      $('#list #' + $('#role_id').val() + ' .column_1').html(parsed.name);
                                      $('.edit_name_text').html(parsed.name);
                                      $('#roles').html(parsed.name + " \u2002\u00BB\u2002");
                                }
                        };
                        $(this).editable( url, $.extend(settings, common));
                    });
            
                   description.each(function() {
                        var settings = {
                                type        :  'textarea',
                                name        :  $(this).attr('name'),
                                rows        :  5,
                                cols        :  30,
                                onsuccess   :  function(data) {
                                      var parsed = $.parseJSON(data);
                                      $('.edit_description').html(parsed.description);
                                }
                        };
                        $(this).editable( url, $.extend(settings, common));
                    });
                };
    
            if ( opening ) {
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
        setCurrentCrumb = function(hash_id){
            current_crumb = hash_id;
        },
        getCurrentOrganization = function(){
            return current_organization;  
        },
        setCurrentOrganization = function(hash_id){
            var split = hash_id.split('_');
            
            if( split[0] === 'organization' || split[0] === 'global' ){
                current_organization = hash_id;
                getPermissionDetails();
            } else if( split[1] === 'global' ) {
                current_organization = 'global';
                getPermissionDetails();
            } else if( split[0] === 'permission' ) {
                current_organization = 'organization_' + split[1];
                getPermissionDetails();
            } else {
                current_organization = hash_id;
            }
        },
        getPermissionDetails = function(){
            var id = current_organization.split('_')[1];

            if( !roles_breadcrumb[current_organization].permission_details && current_organization !== '' && current_organization !== undefined ){
                $('#add_permission').addClass('disabled');
                $.ajax({
                    type    : "GET",
                    url     : '/roles/' + id + '/resource_type/verbs_and_scopes',
                    cache   : false,
                    dataType: 'json',
                    success : function(data){
                        if( roles_breadcrumb[current_organization] ){
                            roles_breadcrumb[current_organization].permission_details = data;
                        }
                        $('#add_permission').removeClass('disabled');
                    }
                });
            }
        },
        savePermission = function(callback){
            var org_id = current_crumb.split('_')[1],
                form = $('#add_permission_form'),
                to_submit = form;
            
            if( current_organization !== "global" ){
                to_submit.find("#organization_id").val(org_id);
            }
            
            if( $('#all_verbs').hasClass('selected') ){
                to_submit = to_submit.serializeArray();
                to_submit.push({ name : 'permission[all_verbs]', value : true });
            }
            
            if( $('#all_tags').hasClass('selected') ){
                if( !(to_submit instanceof Array) ){
                    to_submit = to_submit.serializeArray();
                }
                to_submit.push({ name : 'permission[all_tags]', value : true });
            }
            
            if( to_submit instanceof Array ){
                to_submit = $.param(to_submit);
            } else {
                to_submit = to_submit.serialize();
            }
            
            $.ajax({
               type     : "PUT",
               url      : "/roles/" + $('#role_id').val() + "/create_permission/",
               cache    : false,
               data     : to_submit,
               dataType : 'json',
               success  : function(data){
                   $.extend(roles_breadcrumb, data);
                   ROLES.tree.rerender_content();
                   form[0].reset();
                   roles_breadcrumb[current_organization].count += 1

                   if( data.type === "all" ){
                       roles_breadcrumb[current_organization].full_access = true
                   }
                   
                   callback();
               }
            });
        },
        remove_permission = function(element){
            var id = element.attr('data-id');
            
            element.html(i18n.removing);
            
            $.ajax({
               type     : "DELETE",
               url      : "/roles/" + $('#role_id').val() + "/permission/" + id.split('_')[2] + "/destroy_permission/",
               cache    : false,
               dataType : 'json',
               success  : function(data){
                    /*if( roles_breadcrumb[id].type === "all" ){
                        roles_breadcrumb[current_organization].full_access = false
                    }*/
                    delete roles_breadcrumb[id];
                    roles_breadcrumb[current_organization].count -= 1;
                    ROLES.tree.rerender_content();
               }
            });
        },
        edit_user = function(element, adding){
            var submit_data = { update_users : { adding : adding, user_id : element.attr('data-id').split('_')[1] }};

            if( adding ){
                element.html(i18n.adding);
            } else {
                element.html(i18n.removing);
            }
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
                    ROLES.tree.rerender_content();
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
        },
        removeRole = function(button){
            button.addClass('disabled');
            $.ajax({
                type: "DELETE",
                url: button.attr('data-url'),
                cache: false,
                success: function(data){
                    // Generally a bad idea - trusting implicility the data being returned from the server
                    // This conforms with how other 'removes' on the site work - relying on a partial template
                    // to render and return the proper actions for a delete
                    eval(data);
                }
            });
        };

    return {
        getPermissionDetails    :  getPermissionDetails,
        setCurrentCrumb         :  setCurrentCrumb,
        savePermission          :  savePermission,
        handleContentAddRemove  :  handleContentAddRemove,
        setCurrentOrganization  :  setCurrentOrganization,
        getCurrentOrganization  :  getCurrentOrganization,
        removeRole              :  removeRole,
        role_edit               :  role_edit
    };
    
})(jQuery);

var templateLibrary = (function($){
    var listItem = function(id, name, count, notation, no_slide){
            var html ='<li>';
            
            if( no_slide ){
                html += '<div class="no_slide" id="' + id + '">'; 
            } else {
                html += '<div class="slide_link" id="' + id + '">';
            }
   
            html += '<span class="sort_attr">'+ name;
   
            if( notation !== undefined && notation !== null && notation !== false ){
                html += ' (' + notation + ') ';
            }
   
            if( count !== undefined && count !== null && count !== false ){
                html += ' (' + count + ')';
            }
            
            html += '</span></div></li>';
            
            return html;
        },
        list = function(items, type, options){
            var html = '<ul>',
                options = options ? options : {};
            for( item in items){
                if( items.hasOwnProperty(item) ){
                    if( item.split("_")[0] === type ){
                        html += listItem(item, items[item].name, false, false, options.no_slide);
                    }
                }
            }
            html += '</ul>';
            return html;
        },
        organizationsList = function(items, type, options){
            var html = '<ul>',
                options = options ? options : {},
                full_access = false;
            
            html += listItem('global', items['global'].name, items['global'].count, false);
            
            for( item in items){
                if( items.hasOwnProperty(item) ){
                    if( item.split("_")[0] === type ){
                        full_access = items[item].full_access ? i18n.full_access : false;
                        html += listItem(item, items[item].name, items[item].count, full_access, options.no_slide);
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
                html += permission.verbs[i].display_name;
                if( i !== length-1 ){
                    html += ', ';
                }
            }
            html += '</span></div><div class="permission_detail_container"><label class="grid_3 ra">On:</label><span>';
            
            length = permission.tags.length;
            for( i=0; i < length; i += 1){
                html += permission.tags[i].display_name;
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
                    if( item.split("_")[0] === "permission" && item.split("_")[1] === 'global' ){
                        html += permissionsListItem(item, globals[item].name, true);
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
            var height = $('.left').height(),
                panel_main = $('#panel_main');
                
            panel_main.find('.sliding_list').css({ 'height' : height - 60 });
            panel_main.find('.slider').css({ 'height' : height - 60 });
            panel_main.height(height);
            panel_main.find('.jspPage').height(height);
        },
        setSizing = function(){
            var panel = $('.panel-custom'),
                width = panel.width();
            
            width -= 2;
            panel.find('.sliding_container').width(width);
            panel.find('.breadcrumb_search').width(width);
            panel.find('.slider').width(width);
            panel.find('.sliding_list').width(width * 2);
            panel.find('.slide_up_container').width(width);
        },
        init = function(){
            var left_panel = $('.left');
            
            left_panel.resize(function(){
                setSizing();
            });
            left_panel.trigger('resize');
        },
        setSummary = function(hash_id){
            var summary = $('#roles_status');
             
            if( hash_id === 'roles' ){
                summary.html(i18n.roles_summary);
            } else if( hash_id === 'role_users' ){
                summary.html(i18n.users_summary);
            } else if ( hash_id === 'role_permissions' ){
                summary.html(i18n.role_permissions_summary);
            } else if ( hash_id === 'global' || hash_id.match(/organization?/g) ){
                summary.html(i18n.permissions_summary);
            }
        },
        handleButtons = function(hash_id){
            var type = hash_id.split('_')[0];

            if( type === 'organization' || type === 'permission' || type === 'global' ){
                $('#add_permission').removeClass('disabled');
                roleActions.setCurrentOrganization(hash_id);
            } else {
                $('#add_permission').addClass('disabled');
                roleActions.setCurrentOrganization('');
            }
        };
    
    return {
        init            :   init,
        render          :   render,
        sort            :   sort,
        setTreeHeight   :   setTreeHeight,
        setSummary      :   setSummary,
        handleButtons   :   handleButtons
    }
    
}(jQuery));

var pageActions = (function($){
    var toggle_list = {
            'role_edit'         :  roleActions.role_edit
        },
    
        registerEvents = function(){
            $('#edit_role').live('click', function() {
                if ($(this).hasClass('disabled')){
                    return false;
                }
                ROLES.actionBar.toggle('role_edit');
            });
            
            $('#add_permission').live('click', function() {
                if ($(this).hasClass('disabled')){
                    return false;
                }
                ROLES.actionBar.toggle('permission_add');
            });
            
            $('.content_add_remove').live('click', function(){
                roleActions.handleContentAddRemove($(this));
            });
            
            
            $('#remove_role').live('click', function(){
                var button = $(this);
                common.customConfirm(button.attr('data-confirm-text'), function(){
                    roleActions.removeRole(button);
                });         
            });
            
            panel.contract_cb = function(name){
                        $.bbq.removeState("role_edit");
                        $('#panel').removeClass('panel-custom');
                        ROLES.actionBar.reset();
                    };
                    
            panel.switch_content_cb = function(){
                $.bbq.removeState("role_edit");
                $('#panel').removeClass('panel-custom');
                ROLES.actionBar.reset();
            };
        };
    
    return {
        registerEvents  :  registerEvents,
        toggle_list     :  toggle_list
    };
    
})(jQuery);

$(document).ready(function() {
  
    ROLES.actionBar = sliding_tree.ActionBar(pageActions.toggle_list);
  
    pageActions.registerEvents();
});
