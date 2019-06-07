export default ['$filter', 'translate',
    function ($filter, translate) {
        return function (contentType) {
            var filtered = translate("Unsupported Type!");

            if (contentType === "cert") {
                filtered = translate("Certificate");
            } else if (contentType === "gpg_key") {
                filtered = translate("GPG Key");
            }
            return filtered;
        };
    }
  ];