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
angular.module('Bastion.content-views').factory('ContentViewPuppetModule',
    ['$resource', 'CurrentOrganization',
    function ($resource, CurrentOrganization) {
        var resource =
         $resource('/api/v2/content_views/:contentViewid/puppet_modules/:id/:action',
            {id: '@id', contentViewid: '@contentViewid', 'organization_id': CurrentOrganization},
            {
                query:  {method: 'GET', isArray: false},
                update: {method: 'PUT'}
            }
        );

        resource.query = function(){ return {
            total: 1,
            subtotal: 1,
            results: [
                {name: 'apple', author: 'joe', uuid: '1234', id: 1, version: 5.0},
                {name: 'pear', author: 'willbur', uuid: '1455dsf', id: 2, version: undefined, computedVersion: 2.1 }
            ]
        }};
        return resource;
    }]
);
