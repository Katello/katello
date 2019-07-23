// add translate back

export default ['$filter',
  function ($filter) {
    return function (contentType) {
      var filtered = 'Unsupported Type!';

      if (contentType === 'cert') {
        filtered = 'Certificate';
      } else if (contentType === 'gpg_key') {
        filtered = 'GPG Key';
      }
      return filtered;
    };
  }
];
