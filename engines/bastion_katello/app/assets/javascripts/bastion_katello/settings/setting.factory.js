/**
 * @ngdoc service
 * @name  Bastion.settings.factory:Setting
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for a Setting.
 */
angular.module('Bastion.settings').factory('Setting',
    ['BastionResource', function (BastionResource) {
        var resource = BastionResource('api/v2/settings/');
        return resource;
    }]
);
