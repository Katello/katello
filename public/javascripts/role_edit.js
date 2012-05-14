$(document).ready(function() {

    $('#panel').addClass('panel-custom');
  
    permissionWidget = KT.roles.permissionWidget();
    permissionWidget.init();
  
  	KT.roles.tree = sliding_tree("roles_tree", {
                      breadcrumb      :  roles_breadcrumb,
                      default_tab     :  "roles",
                      bbq_tag         :  "role_edit",
                      render_cb       :  rolesRenderer.render,
                      enable_filter   :  true,
                      tab_change_cb   :  function(hash_id) {
                            if( hash_id.split('_')[0] !== 'permission' ){
                                rolesRenderer.sort(hash_id);
                            }
                            rolesRenderer.setTreeHeight();
                            rolesRenderer.setSummary(hash_id);
                            rolesRenderer.handleButtons(hash_id);
                            roleActions.setCurrentCrumb(hash_id);
                            KT.roles.actionBar.close();
                      }
                  });
  
    KT.roles.actionBar.add_to_toggle_list('add_permission', { container : 'permission_widget',
    															button	   : 'add_permission',
    															options	   : { add : true },
    															setup_fn   : permissionWidget.add_permission });
  	KT.roles.actionBar.add_to_toggle_list('edit_permission', { container : 'permission_widget',  	
  																button	   : 'edit_permission',
  																options	   : { edit : true },
    															setup_fn   : permissionWidget.edit_permission });
  
  	KT.roles.actionBar.add_to_toggle_list('role_edit', { container 	: 'role_edit',
            				 							button		: 'edit_role',
            				 							setup_fn 	: roleActions.role_edit });
    
    rolesRenderer.init();
    
    $('#panel').addClass('roles-selected-border');
    $('.arrow-right').remove();
    $('#list .active').width(284);

    $(window).trigger("hashchange");
});
