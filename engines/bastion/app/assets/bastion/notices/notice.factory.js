/**
 * Copyright 2013 Red Hat, Inc.
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
 * @name  Katello.notices.factory:Notice
 *
 * @requires $resource
 * @requires Routes
 *
 * @description
 *   Provides a $resource for notice or list of notices.
 */
angular.module('Bastion.notices').factory('Notice',
    ['$resource', 'Routes',
    function($resource, Routes) {
        return $resource(Routes.apiNoticesPath() + '/:id/:action', {id: '@id'}, {
            update: {method: 'PUT'},
            query: {method: 'GET', isArray: false}
        });
    }]
);

/**
 * @ngdoc service
 * @name  Katello.notices.factory:BulkAction
 *
 * @requires $resource
 * @requires Routes
 *
 * @description
 *   Provides a $resource for bulk actions on notices.
 */
angular.module('Bastion.notices').factory('BulkAction',
    ['$resource', 'Routes',
    function($resource, Routes) {
        return $resource(Routes.apiNoticesPath() + '/:action', {}, {
            // TODO: what bulk on notices?
        });
    }]
);
