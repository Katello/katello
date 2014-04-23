/**
 * Copyright 2013-2014 Red Hat, Inc.
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
 * @name  Bastion.subscriptions.factory:Subscription
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for a subscription or list of subscriptions
 */
angular.module('Bastion.subscriptions').factory('Subscription', ['BastionResource', 'CurrentOrganization',
    function (BastionResource, CurrentOrganization) {
        return BastionResource('/api/v2/organizations/:org/subscriptions/:id/:action',
            {org: CurrentOrganization, id: '@id'},
            {
                deleteManifest: {
                    method: 'POST',
                    url: '/api/v2/organizations/:org/subscriptions/delete_manifest',
                    params: {'org': CurrentOrganization}
                },

                refreshManifest: {
                    method: 'PUT',
                    url: '/api/v2/organizations/:org/subscriptions/refresh_manifest',
                    params: {'org': CurrentOrganization}
                }
            });
    }]
);
