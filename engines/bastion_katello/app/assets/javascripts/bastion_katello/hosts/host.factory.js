/**
 * @ngdoc service
 * @name  Bastion.hosts.factory:Host
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for one or more hosts.
 */
angular.module('Bastion.hosts').factory('Host',
    ['BastionResource', function (BastionResource) {
        var resource = BastionResource('/api/v2/hosts/:id/:action', {id: '@id'}, {
            update: {method: 'PUT'},
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

/**
 * @ngdoc service
 * @name  Bastion.hosts.factory:HostBulkAction
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for bulk actions on hosts.
 */
angular.module('Bastion.hosts').factory('HostBulkAction',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/api/v2/hosts/bulk/:action', {}, {
            addHostCollections: {method: 'PUT', params: {action: 'add_host_collections'}},
            installableErrata: {method: 'POST', params: {action: 'installable_errata'}},
            removeHostCollections: {method: 'PUT', params: {action: 'remove_host_collections'}},
            installContent: {method: 'PUT', params: {action: 'install_content'}},
            updateContent: {method: 'PUT', params: {action: 'update_content'}},
            removeContent: {method: 'PUT', params: {action: 'remove_content'}},
            destroyHosts: {method: 'PUT', params: {action: 'destroy'}},
            environmentContentView: {method: 'PUT', params: {action: 'environment_content_view'}},
            availableIncrementalUpdates: {method: 'POST', isArray: true, params: {action: 'available_incremental_updates'}}
        });

    }]
);
