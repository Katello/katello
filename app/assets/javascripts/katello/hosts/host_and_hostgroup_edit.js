$(document).on('change', '#host_kt_environment_id', function () {
  host_kt_environment_selected(this);
});

$(document).on('change', '#host_content_view_id', function () {
  host_content_view_selected(this);
});

function host_kt_environment_selected(element) {
  var kt_environment_id = element.value;
  var content_view_options = $('#host_content_view_id')
  content_view_options.empty();

  if (kt_environment_id == '') {
    content_view_options.attr('disabled', true);
    return false
  }

  $(element).indicator_show();


  var url = $(element).attr('data-url');

  $.ajax({
    data:{kt_environment_id: kt_environment_id},
    type:'post',
    url:url,
    dataType:'json',
    success:function (result) {
      if (result.length > 1)
        content_view_options.append($("<option />").val(null).text(__('Select content view')));

      $.each(result, function () {
        content_view_options.append($("<option />").val(this.id).text(this.name));
      });
      if (content_view_options.find('option').length > 0) {
        content_view_options.attr('disabled', false);
        content_view_options.change();
      }
      else {
        content_view_options.append($("<option />").text(__('No content views')));
        content_view_options.attr('disabled', true);
      }
      $(element).indicator_hide();
    }
  });
}

function host_content_view_selected(element) {
  var content_view_id = element.value;
  var kt_environment_id = $('#host_kt_environment_id').val();
  var puppet_environment_options = $('#host_environment_id');
  var puppet_env_id = $('#host_environment_id').val();
 // puppet_environment_options.empty();

  if (content_view_id == '') {
    return false
  }

  $(element).indicator_show();
  var url = $(element).attr('data-url');

  $.ajax({
    data:{content_view_id: content_view_id, kt_environment_id: kt_environment_id},
    type:'post',
    url:url,
    dataType:'json',
    success:function (result) {
      if ((result.length > 0) && ((puppet_env_id == undefined) || (puppet_env_id == "")))
        $.each(result, function () {
          // this defaults the puppet environment value after kt_environment and content_view are selected
          puppet_environment_options.val(this.environment.id);
        });

      $(element).indicator_hide();
    }
  });
}
