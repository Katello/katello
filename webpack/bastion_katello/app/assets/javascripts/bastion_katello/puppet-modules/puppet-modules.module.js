(function () {
    'use strict';

    /**
     * @ngdoc module
     * @name  Bastion.puppet-modules
     *
     * @description
     *   Module for Puppet Module related functionality.
     */
    angular
        .module('Bastion.puppet-modules', [
            'ngResource',
            'ui.router',
            'Bastion',
            'Bastion.common',
            'Bastion.i18n'
        ]);

})();
