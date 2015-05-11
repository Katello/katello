/**
 * @ngdoc service
 * @name  Bastion.content-hosts.factory:ContentHostErratum
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for the errata of a single content host
 */
angular.module('Bastion.content-hosts').factory('ContentHostErratum',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/v2/systems/:id/errata/:errata_id/:action', {id: '@uuid'}, {
            get: {method: 'GET', isArray: false, transformResponse: function (data) {
                data = angular.fromJson(data);
                angular.forEach(data.results, function (errata) {
                    errata.unselectable = !errata.installable;
                });
                return data;
            }},
            autocomplete: {method: 'GET', isArray: true, params: {action: 'auto_complete_search'}},
            apply: {method: 'PUT', params: {action: 'apply'}}
        });

    }]
);
