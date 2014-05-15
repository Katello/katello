/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc service
 * @name  Bastion.organizations.factory:Organization
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for organization(s).
 */
angular.module('Bastion.organizations').factory('Organization',
    ['BastionResource', 'CurrentOrganization', function (BastionResource, CurrentOrganization) {
        return BastionResource('/api/v2/organizations/:id/:action',
            {id: '@id'},
            {
                update: { method: 'PUT'},
                repoDiscover: { method: 'POST', params: {action: 'repo_discover'}},
                cancelRepoDiscover: {method: 'POST', params: {action: 'cancel_repo_discover'}},
                autoAttachSubscriptions: {method: 'POST', params: {action: 'autoattach_subscriptions'}},
                paths: {
                    method: 'GET',
                    url: '/api/v2/organizations/:id/environments/paths',
                    isArray: true,
                    params: {'permission_type': '@permission_type'}
                },
                registerableEnvironments: {
                    method: 'GET',
                    url: '/organizations/:organizationId/environments/registerable_paths',
                    isArray: true
                },
                redhatProvider: {
                    method: 'GET',
                    url: '/api/v2/organizations/:organization_id/redhat_provider',
                    params: {'organization_id': CurrentOrganization}
                }
            }
        );

    }]
);
