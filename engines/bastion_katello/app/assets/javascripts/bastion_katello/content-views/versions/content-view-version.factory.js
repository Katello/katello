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
 * @name  Bastion.content-views.factory:ContentViewVersion
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for interacting with Content View Versions.
 */
angular.module('Bastion.content-views.versions').factory('ContentViewVersion',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/v2/content_view_versions/:id/:action',
            {id: '@id'},
            {
                update: {method: 'PUT'},
                incrementalUpdate: {method: 'POST', params: {action: 'incremental_update'}},
                promote: {method: 'POST', params: {action: 'promote'}}
            }
        );

    }]
);
