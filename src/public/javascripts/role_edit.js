$(function() {

    $('#panel').addClass('panel-custom');
  
    permissionWidget = KT.roles.permissionWidget();
    permissionWidget.init();
  
    KT.roles.actionBar.add_to_toggle_list({ 'permission_add' : permissionWidget.permission_add })
  
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
  
    rolesRenderer.init();

});