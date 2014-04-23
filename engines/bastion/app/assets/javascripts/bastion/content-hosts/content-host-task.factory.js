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
 * @name  Bastion.content-hosts.factory:ContentHostTask
 *
 * @requires BastionResource
 * @requires $timeout
 *
 * @description
 *   Provides a BastionResource for content host tasks
 */
angular.module('Bastion.content-hosts').factory('ContentHostTask',
    ['BastionResource', '$timeout',
    function (BastionResource, $timeout) {
        var resource = BastionResource('/api/v2/systems/:contentHostId/tasks/:id', {id: '@uuid', contentHostId: '@contentHostId'}, {
            get: {method: 'GET', params: {paged: false}, isArray: false}
        });
        resource.poll = function (task, returnFunction) {
            resource.get({id: task.id, contentHostId: task.system.uuid}, function (data) {
                if (data.pending) {
                    $timeout(function () {resource.poll(data, returnFunction)}, 1000);
                }
                else {
                    returnFunction(data);
                }
            }, function () {
                returnFunction({'human_readable_result': "Failed to fetch task", failed: true});
            });
        };
        return resource;
    }]
);
