/**
 * @ngdoc service
 * @name  Bastion.content-hosts.factory:HostErratum
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for the errata of a single content host
 */
angular.module('Bastion.hosts').factory('HostErratum',
    ['BastionResource', function (BastionResource) {

        return BastionResource('api/v2/hosts/:id/errata/:errata_id/:action', {id: '@id'}, {
            get: {method: 'GET', isArray: false, transformResponse: function (data) {
                data = angular.fromJson(data);
                angular.forEach(data.results, function (errata) {
                    errata.unselectable = !errata.installable;
                });
                return data;
            }},
            regenerateApplicability: {method: 'PUT', isArray: false, params: {action: 'applicability'}},
            autocomplete: {method: 'GET', isArray: true, params: {action: 'auto_complete_search'}},
            apply: {method: 'PUT', params: {action: 'apply'}}
        });

    }]
);
