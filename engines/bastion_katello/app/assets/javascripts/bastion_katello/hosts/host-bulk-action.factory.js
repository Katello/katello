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

        return BastionResource('api/v2/hosts/bulk/:action', {}, {
            addHostCollections: {method: 'PUT', params: {action: 'add_host_collections'}},
            removeHostCollections: {method: 'PUT', params: {action: 'remove_host_collections'}},
            updateRepositorySets: {method: 'PUT', params: {action: 'content_overrides'}},
            addSubscriptions: {method: 'PUT', params: {action: 'add_subscriptions'}},
            removeSubscriptions: {method: 'PUT', params: {action: 'remove_subscriptions'}},
            installableErrata: {method: 'POST', params: {action: 'installable_errata'}},
            installContent: {method: 'PUT', params: {action: 'install_content'}},
            updateContent: {method: 'PUT', params: {action: 'update_content'}},
            removeContent: {method: 'PUT', params: {action: 'remove_content'}},
            autoAttach: {method: 'PUT', params: {action: 'auto_attach'}},
            destroyHosts: {method: 'PUT', params: {action: 'destroy'}},
            environmentContentView: {method: 'PUT', params: {action: 'environment_content_view'}},
            releaseVersion: {method: 'PUT', params: {action: 'release_version'}},
            availableIncrementalUpdates: {method: 'POST', isArray: true, params: {action: 'available_incremental_updates'}},
            moduleStreams: {method: 'POST', params: {action: 'module_streams'}}
        });

    }]
);
