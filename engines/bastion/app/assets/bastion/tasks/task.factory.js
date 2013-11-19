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
 * @name  Bastion.tasks.factory:Task
 *
 * @requires $resource
 * @requires $timeout
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a $resource for task(s).
 */
angular.module('Bastion.tasks').factory('Task',
    ['$resource', '$timeout', 'CurrentOrganization',
    function($resource, $timeout, CurrentOrganization) {

        var resource = $resource('/katello/api/tasks/:id/:action',
            {id: '@uuid', 'organization_id': CurrentOrganization},
            {
                query: {method: 'GET', isArray: false}
            }
        );

        resource.poll = function(task, returnFunction) {
            // TODO: remove task.id once we get rid of old TaskStatus code
            resource.get({id: (task.id || task.uuid)}, function(data) {
                if (data.pending) {
                    $timeout(function() {
                        resource.poll(data, returnFunction);
                    }, 8000);
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
