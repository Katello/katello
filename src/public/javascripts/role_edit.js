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
        permissionsList     :    permissionsList
    }
}(jQuery));

var rolesRenderer = (function($){
    var render = function(hash, render_cb){
            if( hash === 'role_organizations' ){
                render_cb(templateLibrary.list(roles_breadcrumb, 'organization'));
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
        setMinHeight = function(){
            var height = $('.left').height();
            $('.sliding_list').css({ 'min-height' : height - 102 });
            $('.slider').css({ 'min-height' : height - 102 });
            $('#panel_main').height(height);
            $('#panel_main .jspPage').height(height);
        };
    
    return {
        render          :   render,
        sort            :   sort,
        setMinHeight    :   setMinHeight
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
                            rolesRenderer.setMinHeight();
                        }
                    });
});