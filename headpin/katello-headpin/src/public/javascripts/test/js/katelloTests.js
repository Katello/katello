test('localize_i18n', function() {

  var transme = {
    "cancel": 'Cancel',
    "error": 'Error',
    "complete": 'Process complete'
  };

  localize(transme);
  equal(i18n['error'], 'Error', 'contains Error key');

})

test('escapeSelector', function() {
  var val = KT.common.escapeId("#my.val");
  ok(val.indexOf("\\") != -1, "properly escape Jquery selectors");
})
