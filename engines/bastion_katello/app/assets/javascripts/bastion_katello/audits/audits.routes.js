(function () {
    'use strict';

    /**
     * @ngdoc object
     * @name Bastion.audits.config
     *
     * @requires $stateProvider
     *
     * @description
     *   State routes defined for the audits module
     */
    function AuditsConfig($stateProvider) {
        // empty
    }

    angular
        .module('Bastion.audits')
        .config(AuditsConfig);

    AuditsConfig.$inject = ['$stateProvider'];
})();
