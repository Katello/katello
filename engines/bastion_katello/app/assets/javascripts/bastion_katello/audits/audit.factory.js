(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.audits.factory:Audit
     *
     * @description
     *   Provides a BastionResource for interacting with Audits
     */
    function Audit(BastionResource) {

        return BastionResource('api/v2/audits/:id',
            {'id': '@id'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }
        );

    }

    angular
        .module('Bastion.audits')
        .factory('Audit', Audit);

    Audit.$inject = ['BastionResource'];

})();
