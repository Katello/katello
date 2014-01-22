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
 * @name  Bastion.users.factory:User
 *
 * @requires $resource
 * @requires $http
 * @requires Routes
 *
 * @description
 *   Provides a $resource for system subscriptions.
 */
angular.module('Bastion.users').factory('User',
    ['$resource', '$http', 'Routes', function ($resource, $http, Routes) {
        var resource = $resource(Routes.apiUsersPath() + '/:id', {id: '@id'});

        resource.selectOrg = function (organizationId, success, error) {
            return $http.post(Routes.setOrgUserSessionPath({'org_id': organizationId}))
                .success(success).error(error);
        };

        resource.setDefaultOrg = function (userId, organizationId, success, error) {
            var data = {'org': organizationId};
            if (!organizationId) {
                data = null;
            }
            return $http.put(Routes.setupDefaultOrgUserPath(userId), data)
                .success(success).error(error);
        };

        return resource;
    }]
);
