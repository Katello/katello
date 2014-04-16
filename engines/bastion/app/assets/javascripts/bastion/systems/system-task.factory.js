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
 * @name  Bastion.systems.factory:SystemTask
 *
 * @requires BastionResource
 * @requires $timeout
 *
 * @description
 *   Provides a BastionResource for system tasks
 */
angular.module('Bastion.systems').factory('SystemTask',
    ['BastionResource', '$timeout',
    function (BastionResource, $timeout) {
        var resource = BastionResource('/api/v2/systems/:systemId/tasks/:id', {id: '@uuid', systemId: '@systemId'}, {
            get: {method: 'GET', params: {paged: false}, isArray: false}
        });
        resource.poll = function (task, returnFunction) {
            resource.get({id: task.id, systemId: task.system.uuid}, function (data) {
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
