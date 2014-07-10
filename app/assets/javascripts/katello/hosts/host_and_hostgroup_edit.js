function update_environment_label(item) {
    var lifecycle_env = $(item).val().trim();
    if (lifecycle_env.length > 0) {
       $("#host_environment_id").parent().parent().find('label').text('Content View');
       $("#hostgroup_environment_id").parent().parent().find('label').text('Content View');
    } else {
       $("#host_environment_id").parent().parent().find('label').text('Puppet Environment');
       $("#hostgroup_environment_id").parent().parent().find('label').text('Puppet Environment');
    }
}

function toggle_installation_medium(item) {
    var content_source = $(item).val().trim();
    if (content_source.length > 0) {
      $("#host_medium_id").parent().parent().hide();
      $("#hostgroup_medium_id").parent().parent().hide();
    } else {
      $("#host_medium_id").parent().parent().show();
      $("#hostgroup_medium_id").parent().parent().show();
    }
}
