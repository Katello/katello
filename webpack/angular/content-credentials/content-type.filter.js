// TODO: add translate back

export default [
  function () {
    return function (contentType) {
      // var filtered = translate('Unsupported Type!');
      var filtered = 'Unsupported Type!';

      if (contentType === 'cert') {
        // filtered = translate('Certificate');
        filtered = 'Certificate';
      } else if (contentType === 'gpg_key') {
        // filtered = translate('GPG Key');
        filtered = 'GPG Key';
      }
      return filtered;
    };
  }
];
