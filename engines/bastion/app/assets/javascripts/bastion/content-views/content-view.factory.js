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
 * @name  Bastion.content-views.factory:ContentView
 *
 * @requires $resource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a $resource for interacting with environments.
 */
angular.module('Bastion.content-views').factory('ContentView',
    ['$resource', 'CurrentOrganization',
    function ($resource, CurrentOrganization) {

        return $resource('/api/v2/content_views/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                query:  {method: 'GET', isArray: false},
                update: {method: 'PUT'},
                publish: {method: 'POST', params: {action: 'publish'}}
            }
        );

    }]
);
