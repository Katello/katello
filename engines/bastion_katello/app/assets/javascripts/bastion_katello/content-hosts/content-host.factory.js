/**
 * @ngdoc service
 * @name  Bastion.content-hosts.factory:ContentHost
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for one or more content hosts.
 */
angular.module('Bastion.content-hosts').factory('ContentHost',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/v2/systems/:id/:action/:action2', {id: '@uuid'}, {
            get: {method: 'GET', params: {fields: 'full'}},
            getPost: {method: 'POST', params: {fields: 'full', action: 'post_index'}},
            update: {method: 'PUT'},
            releaseVersions: {method: 'GET', params: {action: 'releases'}},
            subscriptions: {method: 'GET', params: {action: 'subscriptions'}},
            events: {method: 'GET', params: {action: 'events'}},
            products: {method: 'GET', params: {action: 'products'}},
            removeSubscriptions: {method: 'PUT', isArray: false, params: {action: 'subscriptions'}},
            addSubscriptions: {method: 'POST', isArray: false, params: {action: 'subscriptions'}},
            refreshSubscriptions: {method: 'PUT', params: {action: 'refresh_subscriptions'}},
            tasks: {method: 'GET', params: {action: 'tasks', paged: true}},
            availableHostCollections: {method: 'GET', params: {action: 'available_host_collections'}},
            hostCollections: {method: 'GET', transformResponse: function (data) {
                var contentHost = angular.fromJson(data);
                return {results: contentHost.hostCollections};
            }},
            contentOverride: {method: 'PUT', isArray: false, params: {action: 'content_override'}},
            autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
        });

    }]
);

/**
 * @ngdoc service
 * @name  Bastion.content-hosts.factory:ContentHostBulkAction
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for bulk actions on content hosts.
 */
angular.module('Bastion.content-hosts').factory('ContentHostBulkAction',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/v2/systems/bulk/:action', {}, {
            addHostCollections: {method: 'PUT', params: {action: 'add_host_collections'}},
            applicableErrata: {method: 'POST', params: {action: 'applicable_errata'}},
            removeHostCollections: {method: 'PUT', params: {action: 'remove_host_collections'}},
            installContent: {method: 'PUT', params: {action: 'install_content'}},
            updateContent: {method: 'PUT', params: {action: 'update_content'}},
            removeContent: {method: 'PUT', params: {action: 'remove_content'}},
            unregisterContentHosts: {method: 'PUT', params: {action: 'destroy'}},
            environmentContentView: {method: 'PUT', params: {action: 'environment_content_view'}},
            availableIncrementalUpdates: {method: 'POST', isArray: true, params: {action: 'available_incremental_updates'}}
        });

    }]
);
