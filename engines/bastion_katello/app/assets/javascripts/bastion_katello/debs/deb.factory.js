(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.debs.factory:Deb
     *
     * @description
     *   Provides a BastionResource for interacting with deb Packages
     */
    function Deb(BastionResource, CurrentOrganization) {

        return BastionResource('katello/api/v2/debs/:id',
            {'id': '@id', 'organization_id': CurrentOrganization},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                'autocompleteName': {method: 'GET', isArray: false, params: {id: 'auto_complete_name'},
                    transformResponse: function (data) {
                        data = angular.fromJson(data);
                        return {results: data};
                    }
                },
                'autocompleteArch': {method: 'GET', isArray: false, params: {id: 'auto_complete_arch'},
                    transformResponse: function (data) {
                        data = angular.fromJson(data);
                        return {results: data};
                    }
                }
            }
        );

    }

    angular
        .module('Bastion.debs')
        .factory('Deb', Deb);

    Deb.$inject = ['BastionResource', 'CurrentOrganization'];

})();
