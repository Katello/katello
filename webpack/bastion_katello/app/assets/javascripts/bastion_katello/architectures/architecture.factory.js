/**
 * @ngdoc service
 * @name  Bastion.architectures.factory:Architecture
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for architectures.
 */
angular.module('Bastion.architectures').factory('Architecture',
    ['BastionResource', function (BastionResource) {
        var resource = BastionResource('api/v2/architectures/');
        return resource;
    }]
);
