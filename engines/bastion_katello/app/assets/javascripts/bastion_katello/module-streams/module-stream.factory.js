(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.module-streams.factory:ModuleStream
     *
     * @description
     *   Provides a BastionResource for interacting with Ostree Branches
     */
    function ModuleStream(BastionResource, CurrentOrganization) {
        return BastionResource('katello/api/v2/module_streams/:id',
            {'id': '@id', 'organization_id': CurrentOrganization},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }

        );
    }

    angular
        .module('Bastion.module-streams')
        .factory('ModuleStream', ModuleStream);

    ModuleStream.$inject = ['BastionResource', 'CurrentOrganization'];

})();
