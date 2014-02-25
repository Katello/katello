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
 * @requires $log
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a $resource for task(s).
 *
 *   Also provides a polling bulk search for tasks, define in
 *   foreman-tasks engine API. This allows polling for multiple task
 *   statuses with a single request (e.g. currently running tasks of a
 *   user, recent tasks of a user, tasks for given resource, detail of
 *   one task etc). See `resource.registerSearch` and
 *   `resource.unregisterSearch` for details.
 */

angular.module('Bastion.tasks').factory('Task',
    ['$resource', '$timeout', '$log', 'CurrentOrganization',
    function ($resource, $timeout, $log, CurrentOrganization) {
        var bulkSearchRunning = false, searchIdGenerator = 0,
            searchParamsById = {},  callbackById = {};

        var resource = $resource('/api/v2/tasks/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                query: {method: 'GET', isArray: false}
            }
        );

        var foremanTasksResource = $resource('/foreman_tasks/api/tasks/:id/:action',
            {},
            {
                bulkSearch: {method: 'POST', isArray: true, params: { action: 'bulk_search'}}
            }
        );

        function bulkSearchParams() {
            var searches = [];
            _.each(searchParamsById, function (searchParams, id) {
                searchParams['search_id'] = id;
                searches.push(searchParams);
            });
            return { searches: searches };
        }

        function taskProgressbar(task) {
            var type = task.result === 'error' ? 'danger' : 'success';
            return { value: task.progress * 100, type: type };
        }

        function schedulePoll() {
            $timeout(function () { updateProgress(true); }, 1500);
        }

        function updateProgress(periodic) {
            if (_.keys(searchParamsById).length === 0) {
                bulkSearchRunning = false;
                return;
            }
            foremanTasksResource.bulkSearch(bulkSearchParams(), function (response) {
                try {
                    _.each(response, function (tasksSearch) {
                        var searchId = tasksSearch['search_params']['search_id'];
                        var callback = callbackById[searchId];
                        try {
                            _.each(tasksSearch['results'], function (task) {
                                task.progressbar = taskProgressbar(task);
                            });
                            if (tasksSearch['search_params']['type'] === 'task') {
                                callback(tasksSearch['results'][0]);
                            } else {
                                callback(tasksSearch['results']);
                            }
                        }
                        catch (e) {
                            $log.error(e);
                        }
                    });
                }
                finally {
                    // schedule the next update
                    if (periodic) { schedulePoll(); }
                }
            }, function () {
                if (periodic) { schedulePoll(); }
            });
        }

        function ensureBulkSearchRunning() {
            if (!bulkSearchRunning) {
                bulkSearchRunning = true;
                updateProgress(true);
            }
        }

        function generateSearchId() {
            searchIdGenerator += 1;
            return searchIdGenerator;
        }

        function addSearch(searchParams, callback) {
            var searchId = generateSearchId();
            searchParamsById[searchId] = searchParams;
            callbackById[searchId] = callback;
            ensureBulkSearchRunning();
            return searchId;
        }

        function deleteSearch(searchId) {
            delete callbackById[searchId];
            delete searchParamsById[searchId];
        }

        resource.poll = function (task, returnFunction) {
            resource.get({id: task.id}, function (data) {
                if (data.pending) {
                    $timeout(function () {
                        resource.poll(data, returnFunction);
                    }, 8000);
                }
                else {
                    returnFunction(data);
                }
            }, function () {
                returnFunction({'human_readable_result': "Failed to fetch task", failed: true});
            });
        };

        /**
          * Registers a search for polling. The polling is
          * is performed using bulkSearch for all the registered searches at once
          * to avoid overloading the server with multiple requests
          * (since it is performed periodically)
          *
          * @param {Object} searchParams object specifying the params
          *        of the search.
          *
          * @param {Function} callback function to reflect the
          *        results. If searchParams.type === 'task', the
          *        function is called with a single task, otherwise
          *        it's passed with array of tasks sattisfying the
          *        conditions.
          *
          * @return {Number} the autogenerated id of the condition
          *        that can be used for unregistering the search later on
          */
        resource.registerSearch = function (searchParams, callback) {
            return addSearch(searchParams, callback);
        };

        /**
          * Unregisters the search from polling.
          *
          * @param {Number} id the value returned by the registerSearch
          */
        resource.unregisterSearch = function (id) { deleteSearch(id); };

        return resource;
    }]
);
