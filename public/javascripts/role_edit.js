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
    var organizationsListItem = function(id, name){
        var html ='<li>' + '<div class="slide_link" id="' + id + '">'

        html += '<span class="sort_attr">'+ name + '</span></div></li>';
        return html;
    },
    organizationsList = function(organizations){
        var html = '<ul>';
        for( item in organizations){
            if( organizations.hasOwnProperty(item) ){
                if( item.split("_")[0] === "organization" ){
                    html += organizationsListItem(item, organizations[item].name);
                }
            }
        }
        html += '</ul>';
        return html;
    };
    
    return {
        organizationsList   :    organizationsList
    }
}(jQuery));

var rolesRenderer = (function($){
    var render = function(hash, render_cb){
            if( hash === 'organizations'){
                render_cb(templateLibrary.organizationsList(roles_breadcrumb));
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
            var height = $('.panel').height();
            $('.sliding_list').css({ 'min-height' : height - 150 });
            $('.slider').css({ 'min-height' : height - 150 });
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
                        default_tab     :  "organizations",
                        bbq_tag         :  "role_edit",
                        base_icon       :  'home_img',
                        render_cb       :  rolesRenderer.render,
                        enable_search   :  true,
                        tab_change_cb   :  function(hash_id) {
                            console.log(hash_id);
                            console.log(rolesRenderer);
                            //rolesRenderer.sort();
                            rolesRenderer.setMinHeight();
                        }
                    });
});