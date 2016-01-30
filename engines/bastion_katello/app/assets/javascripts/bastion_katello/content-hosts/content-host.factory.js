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
            products: {method: 'GET', params: {action: 'products'}},
            tasks: {method: 'GET', params: {action: 'tasks', paged: true}},
            contentOverride: {method: 'PUT', isArray: false, params: {action: 'content_override'}},
            autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
        });

    }]
);
