(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.ostree-branches.factory:OstreeBranch
     *
     * @description
     *   Provides a BastionResource for interacting with Ostree Branches
     */
    function OstreeBranch(BastionResource) {
        return BastionResource('katello/api/v2/ostree_branches/:id',
            {'id': '@id'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }

        );
    }

    angular
        .module('Bastion.ostree-branches')
        .factory('OstreeBranch', OstreeBranch);

    OstreeBranch.$inject = ['BastionResource'];

})();
