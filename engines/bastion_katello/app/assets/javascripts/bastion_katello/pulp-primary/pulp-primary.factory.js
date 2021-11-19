/**
 * @ngdoc service
 * @name  Bastion.pulp-primary.factory:PulpPrimary
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for pulp primary.
 */
angular.module('Bastion.pulp-primary').factory('PulpPrimary',
    ['BastionResource', function (BastionResource) {

        return BastionResource('katello/api/capsules/:id/content/:action', {id: '@id'}, {
          reclaimSpace: {method: 'post', isArray: false, params: {action: 'reclaim_space'}}
        });

    }]
);
