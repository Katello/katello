/**
 * @ngdoc service
 * @name  Bastion.content-hosts.factory:Host
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for one or more hosts.
 */
angular.module('Bastion.hosts').factory('Host',
    ['BastionResource', function (BastionResource) {
        var resource = BastionResource('/api/v2/hosts/:id/:action', {id: '@id'}, {
            updateHostCollections: {method: 'PUT', params: {action: 'host_collections'}}
        });
        resource.prototype.hasContent = function () {
            return angular.isDefined(this.content) && angular.isDefined(this.content.uuid);
        };
        resource.prototype.hasSubscription = function () {
            return angular.isDefined(this.subscription) && angular.isDefined(this.subscription.uuid);
        };
        return resource;
    }]
);
