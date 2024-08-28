$(document).on('loadJS', function(){
  var form_id = $('#new_subpanel'),
      form_submit_id = form_id.find('.subpanel_create'),
      url_after_submit = form_submit_id.data('url_after_submit');

  KT.panel.registerSubPanelSubmit(form_id, form_submit_id, url_after_submit);
});