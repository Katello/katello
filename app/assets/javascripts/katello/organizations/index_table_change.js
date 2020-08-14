function addSimpleContentAccessColumn() {
  if(organizationsCount()) {
    const table = $('.table-fixed');
    let row = 0;

    table.find('tr').each(function() {
      const trow = $(this);
      if(row === 0) {
        trow.append('<th>Simple Content Access</th>');
      } else {
        const orgName = trow.find('td:first').text();
        const hiddenFieldId = orgName.split(' ').join('_');
        const simpleContentAccess = $("input[type=hidden]#" + hiddenFieldId).val();
        const simpleContentAccessValue = simpleContentAccess === "true" ? "Enabled" : "Disabled";
        trow.append(`<td>${simpleContentAccessValue}</td>`);
      }
      row += 1;
    });
  }
}

function organizationsCount() {
  return $("input[type=hidden]#show_simple_content_access_column").val() === "true";
}

$(document).on('ContentLoad', function() {
  addSimpleContentAccessColumn();
});