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
 * @name  Katello.systems.factory:SystemTask
 *
 * @requires $resource
 * @requires $timeout
 * @requires Routes
 *
 * @description
 *   Provides a $resource for system tasks
 */
angular.module('Bastion.systems').factory('SystemTask',
    ['$resource', '$timeout','Routes',
    function($resource, $timeout, Routes) {
        var resource = $resource(Routes.apiSystemsPath() + '/tasks/:id', {id: '@uuid'}, {
            get: {method: 'GET', params: {paged: false}, isArray: false}
        });
        resource.poll = function(task, returnFunction) {
            resource.get({id: task.id}, function(data) {
                if (data.pending) {
                    $timeout(function(){resource.poll(data, returnFunction)}, 1000);
                }
                else{
                    returnFunction(data);
                }
            }, function() {
                returnFunction({'human_readable_result':"Failed to fetch task", failed: true});
            });
        };
        return resource;
    }]
);
