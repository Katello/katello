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
 * @name  Bastion.puppet-modules.factory:PuppetModule
 *
 * @requires $resource
 *
 * @description
 *   Provides a $resource for Puppet Module.
 */
angular.module('Bastion.puppet-modules').factory('PuppetModule',
    ['$resource', function ($resource) {

        var resource = $resource('/api/puppet_modules/:id/:action', {id: '@id'}, {
            query:  {method: 'GET'}
        });

        resource.query = function(){ return {
            total: 4,
            subtotal: 4,
            results: [
                {name: 'apple', version: 1.0, author: 'Joe'},
                {name: 'apple', version: 1.1, author: 'Joe'},
                {name: 'apple', version: 3.0, author: 'Bob'},
                {name: 'apple', version: 9.0, author: 'Alice'}
            ]
        }};
        return resource;
    }]
);
