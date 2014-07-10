$(document).on('ContentLoad', function(){onKatelloHostEditLoad()});

function onKatelloHostEditLoad(){
  $('#kt_environment_id').live('change', function() {
    toggle_installation_medium();
  });
  $('#host_environment_id').live('change', function() {
    toggle_installation_medium();
  });
  $('#host_content_source_id').live('change', function() {
    toggle_installation_medium();
  });
  $('#host_architecture_id').live('change', function() {
    toggle_installation_medium();
  });
  $('#host_operatingsystem_id').live('change', function() {
    toggle_installation_medium();
  });

  $('#hostgroup_environment_id').live('change', function() {
    toggle_installation_medium();
  });
  $('#hostgroup_content_source_id').live('change', function() {
    toggle_installation_medium();
  });
  $('#hostgroup_architecture_id').live('change', function() {
    toggle_installation_medium();
  });
  $('#hostgroup_operatingsystem_id').live('change', function() {
    toggle_installation_medium();
  });
}

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

function toggle_installation_medium() {

    kt_environment_id = $('#kt_environment_id').val();

    if ($('#hostgroup_parent_id').length > 0) {
      environment_id = $('#hostgroup_environment_id').val();
      content_source_id = $('#hostgroup_content_source_id').val();
      architecture_id = $('#hostgroup_architecture_id').val();
      operatingsystem_id = $('#hostgroup_operatingsystem_id').val();
    } else {
      environment_id = $('#host_environment_id').val();
      content_source_id = $('#host_content_source_id').val();
      architecture_id = $('#host_architecture_id').val();
      operatingsystem_id = $('#host_operatingsystem_id').val();
    }

    if (kt_environment_id.length > 0 &&
        environment_id.length > 0 &&
        content_source_id.length > 0 &&
        architecture_id.length > 0 &&
        operatingsystem_id.length > 0) {

      $.ajax({
        type:'get',
        url: '/operatingsystems/'+operatingsystem_id+'/available_kickstart_repo?environment_id='+environment_id+'&content_source_id='+content_source_id+'&architecture_id='+architecture_id,
        error: function(jqXHR, status, error){
            show_medium_selectbox();
        },
        success: function(result){
          if (result == null) {
            show_medium_selectbox();
          } else {
            // add kickstart_url div after checking that it doesn't exist
            // since this code is called 3 times
            if ($("#kt_kickstart_url").length == 0) {
              $('label[for="medium_id"]').after("<div id='kt_kickstart_url' class='col-md-8'></div>");
            }
            $("#host_medium_id").hide();
            $("#hostgroup_medium_id").hide();
            // populate kickstart_url inside div created above
            $("#kt_kickstart_url").html(result.name+"<br />"+result.path);
          }
        }
      })

    } else {
      show_medium_selectbox();
    }

}

function show_medium_selectbox() {
    $("#host_medium_id").show();
    $("#hostgroup_medium_id").show();
    $("#kt_kickstart_url").html('');
}
