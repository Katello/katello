/**
 * @ngdoc service
 * @name  Bastion.components.service:BstBookmark
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for bst-bookmarks.
 */
angular.module('Bastion.components').factory('BstBookmark',
    ['BastionResource', function (BastionResource) {

        return BastionResource('api/v2/bookmarks', {id: '@id'},
            {
                create: { method: 'POST' }
            }
        );
    }]
);
