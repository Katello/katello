/**
 * @ngdoc service
 * @name  Bastion.capsule-content.factory:CapsuleContent
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for capsule content.
 */
angular.module('Bastion.capsule-content').factory('CapsuleContent',
    ['BastionResource', function (BastionResource) {

        return BastionResource('katello/api/capsules/:id/content/:action', {id: '@id'}, {
          syncStatus: {method: 'GET', isArray: false, params: {action: 'sync'}},
          sync: {method: 'post', isArray: false, params: {action: 'sync'}},
          cancelSync: {method: 'delete', isArray: false, params: {action: 'sync'}}
        });

    }]
);
