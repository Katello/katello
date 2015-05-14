/**
 * @ngdoc service
 * @name  Bastion.custom-info.factory:CustomInfo
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for interacting with custom info.
 */
angular.module('Bastion.custom-info').factory('CustomInfo',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/v2/custom_info/:type/:id/:action',
            {},
            {
                update: { method: 'PUT' }
            }
        );

    }]
);
