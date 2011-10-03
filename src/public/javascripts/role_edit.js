$(document).ready(function() {

    $('#panel').addClass('panel-custom');
  
    permissionWidget = KT.roles.permissionWidget();
    permissionWidget.init();
  
  	KT.roles.tree = sliding_tree("roles_tree", {
                      breadcrumb      :  roles_breadcrumb,
                      default_tab     :  "roles",
                      bbq_tag         :  "role_edit",
                      render_cb       :  rolesRenderer.render,
                      enable_search   :  true,
                      tab_change_cb   :  function(hash_id) {
                            rolesRenderer.sort(hash_id);
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
  																options	   : { edit : true, id : KT.roles.tree.get_current_crumb() },
    															setup_fn   : permissionWidget.edit_permission });
  
    rolesRenderer.init();
    
    $('#panel').addClass('roles-selected-border');
    $('.arrow-right').remove();
    $('.active').width($('.active').width() + 1);

});