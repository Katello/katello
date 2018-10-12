(function () {
    /**
     * @ngdoc filter
     * @name  Bastion.repository-sets.filter:repositorySetsEnabled.filter.js
     *
     * @requires translate
     *
     * @description
     *  Makes the value of the repository set filter human readable.
     */

    function repositorySetsEnabled(translate) {
        return function (repositorySet) {
            var enabledText;

            if (repositorySet.enabled_content_override === true) {
                enabledText = translate('Enabled (overridden)');
            } else if (repositorySet.enabled_content_override === false) {
                enabledText = translate('Disabled (overridden)');
            } else {
                if (repositorySet.enabled) {
                    enabledText = translate('Enabled');
                } else {
                    enabledText = translate('Disabled');
                }
            }

            return enabledText;
        };
    }

    angular.module('Bastion.repository-sets').filter('repositorySetsEnabled', repositorySetsEnabled);
    repositorySetsEnabled.$inject = ['translate'];
})();
