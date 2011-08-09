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
var roleActions = (function($){
    var opened = false;

    var toggle = function(delay){
        var edit_window = $('#role_edit'),
            name_box = $('.edit_name_text'),
            edit_button = $('#edit_role > span'),
            description = $('.edit_description'),
            animate_time = 500,
            after_function = undefined,
            nameBreadcrumb = $('.tree_breadcrumb');
            
        if (delay != undefined){
            animate_time = delay;
        }

        opened = !opened;

        if (opened) {
            edit_button.html(i18n.close_role_details);
            edit_button.parent().addClass("highlighted");
            after_function = setup_edit;
        }
        else {
            edit_button.html(i18n.edit_role_details);
            edit_button.parent().removeClass("highlighted");
        }

        edit_window.slideToggle(animate_time, after_function);
    },
    setup_edit = function() {
        var url = "/roles/" + $('#role_id').val();
        var name_box = $('.edit_name_text');
        var description = $('.edit_description');
        
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
           console.log(i18n.clickToEdit);
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
        if (opened) {
            toggle(0);
        }
    };

    return {
        toggle  :  function() {toggle();},
        close   :  close
    };
})(jQuery);

var templateLibrary = (function($){
    var listItem = function(id, name, no_slide){
            var html ='<li>';
            
            if( no_slide ){
                html += '<div class="no_slide" id="' + id + '">'; 
            } else {
                html += '<div class="slide_link" id="' + id + '">';
            }
    
            html += '<span class="sort_attr">'+ name + '</span></div></li>';
            return html;
        },
        list = function(items, type, options){
            var html = '<ul>',
                options = options ? options : {};
            for( item in items){
                if( items.hasOwnProperty(item) ){
                    if( item.split("_")[0] === type ){
                        html += listItem(item, items[item].name, options.no_slide);
                    }
                }
            }
            html += '</ul>';
            return html;
        },
        organizationsList = function(items, type, options){
            var html = '<ul>',
                options = options ? options : {};
            
            html += listItem(items['global'], items['global'].name, true);
            
            for( item in items){
                if( items.hasOwnProperty(item) ){
                    if( item.split("_")[0] === type ){
                        html += listItem(item, items[item].name, options.no_slide);
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
                        html += permissionsListItem(item.split('_')[2], permissions[item].name, true);
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
            return '<li>' + anchor + '<div class="no_slide"><span class="sort_attr">'  + name + '</span></div></li>';
        };
    
    return {
        list                :    list,
        organizationsList   :    organizationsList,
        permissionsList     :    permissionsList
    }
}(jQuery));

var rolesRenderer = (function($){
    var render = function(hash, render_cb){
            if( hash === 'role_permissions' ){
                render_cb(templateLibrary.organizationsList(roles_breadcrumb, 'organization'));
            } else if( hash === 'roles' ) {
                render_cb(templateLibrary.list(roles_breadcrumb, 'role'));
            } else if( hash === 'role_users' ){
                render_cb(templateLibrary.list(roles_breadcrumb, 'user', { no_slide : true }));
            } else {
                var split = hash.split("_"),
                    page = split[0],
                    organization_id = split[1],
                    permission_id = split[2];

                render_cb(getContent(page, organization_id, permission_id));
            }
        },
        getContent = function(key, organization_id, permission_id){
            if( key === 'organization' ){
                return templateLibrary.permissionsList(roles_breadcrumb, organization_id);
            }
        },
        sort = function() {
            $(".will_have_content").find("li").sortElements(function(a,b){
                    var a_html = $(a).find(".sort_attr").html();
                    var b_html = $(b).find(".sort_attr").html();
                    if (a_html && b_html ) {
                        return  a_html.toUpperCase() >
                                b_html.toUpperCase() ? 1 : -1;
                    }
            });
            console.log('sorted');
        },
        setTreeHeight = function(){
            var height = $('.left').height();
            $('.sliding_list').css({ 'height' : height - 91 });
            $('.slider').css({ 'height' : height - 91 });
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
            $('#role_edit').width(width);
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
            }
        };
    
    return {
        init            :   init,
        render          :   render,
        sort            :   sort,
        setTreeHeight    :   setTreeHeight,
        setStatus       :   setStatus
    }
}(jQuery));

$(function() {
  
    var roles_tree = sliding_tree("roles_tree", { 
                          breadcrumb      :  roles_breadcrumb,
                          default_tab     :  "roles",
                          bbq_tag         :  "role_edit",
                          render_cb       :  rolesRenderer.render,
                          enable_search   :  true,
                          tab_change_cb   :  function(hash_id) {
                              //rolesRenderer.sort();
                                rolesRenderer.setTreeHeight();
                                rolesRenderer.setStatus(hash_id);
                          }
                      });
                        
    rolesRenderer.init();
    $('#edit_role').live('click', function() {
        if ($(this).hasClass('disabled')){
            return false;
        }
        roleActions.toggle();
    });
});