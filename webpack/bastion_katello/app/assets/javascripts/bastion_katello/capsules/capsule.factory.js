/**
 * @ngdoc service
 * @name  Bastion.capsules.factory:Capsule
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for capsules or list of capsules.
 */
angular.module('Bastion.capsules').factory('Capsule',
    ['BastionResource', function (BastionResource) {

        return BastionResource('katello/api/capsules/:id/:action', {id: '@id'}, {
        });

    }]
);
