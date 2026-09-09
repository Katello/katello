// Organization Label is required by Candlepin and cannot be changed after create.
// The create form showed it as required (*) but submitted blank; the server then
// filled it via setup_label_from_name, so users never saw the value they would be stuck with.
// Refs #39747 / SAT-38345: generate Label from Name in the UI, same idea as Products / Content Views.
var KT = KT || {};
KT.organizations = KT.organizations || {};

KT.organizations.initLabelFromName = function () {
  var $name = $('[name="organization[name]"]');
  var $form = $name.closest('form');
  var $label = $form.find('[name="organization[label]"]');

  // Edit form has the same field names but Label is disabled (immutable). Skip it.
  // orgLabelBound avoids double-init when loadJS / allJsLoaded both run.
  if (!$form.length || $form.data('orgLabelBound') || !$label.length || $label.prop('disabled')) {
    return;
  }
  $form.data('orgLabelBound', true);

  // Once the user types a custom Label, do not overwrite it from Name.
  var labelTouched = false;

  // Match Katello::Util::Model.labelize for the common ASCII path.
  // Non-ASCII or >128 chars: leave blank so the server can assign a UUID.
  var labelize = function (name) {
    if (!name || !/^[\x00-\x7F]*$/.test(name) || name.length > 128) {
      return '';
    }
    return name.replace(/[^A-Za-z0-9_-]+/g, '_');
  };

  var fillFromName = function () {
    if (!labelTouched) {
      $label.val(labelize($name.val()));
    }
  };

  $name.on('input', fillFromName);

  $label.on('input', function () {
    labelTouched = $label.val() !== '';
    if (!labelTouched) {
      fillFromName();
    }
  });

  // Foreman does not set HTML5 required, so blank Label can still be posted.
  // Fill it here (same as the server callback) instead of disabling Submit.
  $form.on('submit', function () {
    if ($.trim($label.val()) === '') {
      labelTouched = false;
      fillFromName();
    }
  });
};

// Inline Deface content can run before or after Foreman's loadJS.
// Handle both so auto-fill is not a no-op on a fully loaded page.
if (window.allJsLoaded) {
  KT.organizations.initLabelFromName();
} else {
  $(document).on('loadJS', KT.organizations.initLabelFromName);
}
