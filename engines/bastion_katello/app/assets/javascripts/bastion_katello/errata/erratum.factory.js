/**
 * @ngdoc service
 * @name  Bastion.errata.factory:Erratum
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for Errata
 */
angular.module('Bastion.errata').factory('Erratum',
    ['BastionResource', function (BastionResource) {

        return BastionResource('katello/api/v2/errata/:id/',
            {id: '@id', 'sort_by': 'issued', 'sort_order': 'DESC'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                applicableContentHosts: {method: 'GET', transformResponse: function (data) {
                    var erratum = angular.fromJson(data),
                        systems = erratum['hosts_applicable'];
                    return {results: systems, subtotal: systems.length, total: systems.length};
                }}
            }
        );

    }]
);
