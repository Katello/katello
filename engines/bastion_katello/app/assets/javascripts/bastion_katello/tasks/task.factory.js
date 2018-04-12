 /**
 * @ngdoc service
 * @name  Bastion.tasks.factory:Task
 *
 * @requires BastionResource
 * @requires $timeout
 * @requires $log
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for task(s).
 *
 *   Also provides a polling bulk search for tasks, define in
 *   foreman-tasks engine API. This allows polling for multiple task
 *   statuses with a single request (e.g. currently running tasks of a
 *   user, recent tasks of a user, tasks for given resource, detail of
 *   one task etc). See `resource.registerSearch` and
 *   `resource.unregisterSearch` for details.
 */

angular.module('Bastion.tasks').factory('Task',
    ['BastionResource', '$timeout', '$log', '$q',
    function (BastionResource, $timeout, $log, $q) {
        var bulkSearchRunning = false, searchIdGenerator = 0,
            searchParamsById = {}, callbackById = {}, pollCount = 0, maxPollInterval = 10000;

        var resource = BastionResource('foreman_tasks/api/tasks/:id/:action',
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
            var mapping = { 'error': 'danger', 'warning': 'warning', 'default': 'success' };
            var type = mapping[task.result] || mapping.default;
            return { value: task.progress * 100, type: type };
        }

        // add additional fields to the task model that help with
        // usage in the UI templates
        function normalizeTask(task) {
            task.progressbar = taskProgressbar(task);
            if (!task.humanized.errors) {
                task.humanized.errors = [];
            } else if (!_.isArray(task.humanized.errors)) {
                task.humanized.errors = [task.humanized.errors];
            }
        }

        function updateProgress(periodic) {
            if (_.keys(searchParamsById).length === 0) {
                bulkSearchRunning = false;
                return;
            }
            resource.bulkSearch(bulkSearchParams(), function (response) {
                try {
                    _.each(response, function (tasksSearch) {
                        var searchId = tasksSearch['search_params']['search_id'];
                        var callback = callbackById[searchId];
                        if (!callback) {
                            return;
                        }
                        try {
                            _.each(tasksSearch.results, function (task) {
                                normalizeTask(task);
                            });
                            if (tasksSearch['search_params'].type === 'task') {
                                callback(tasksSearch.results[0]);
                            } else {
                                callback(tasksSearch.results);
                            }
                        } catch (e) {
                            $log.error(e);
                        }
                    });
                } finally {
                    // schedule the next update
                    if (periodic) {
                        schedulePoll();
                    }
                }
            }, function () {
                if (periodic) {
                    schedulePoll();
                }
            });
        }

        /*eslint no-use-before-define:0*/
        function schedulePoll() {
            var pollTime;
            pollCount = pollCount + 1;
            pollTime = 1000 * pollCount;
            if (pollTime > maxPollInterval) {
                pollTime = maxPollInterval;
            }

            $timeout(function () {
                updateProgress(true);
            }, pollTime);
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
                } else {
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
        resource.unregisterSearch = function (id) {
            deleteSearch(id);
        };

        /**
          * monitors a single task, and runs corresponding callbacks
          * on given events.
          *
          * @param {Task} task - a task object to monitor. The task
          *    object can be either retrieved from polling or it might
          *    be a promised object from triggering a task.
          *
          * @returns {RunningTask} an object that represents the state
          *   of the running task with the following fields
          */
        resource.monitorTask = function (task) {
            var searchId, deferred = $q.defer();
            var runningTask = {
                // promise that the task finishes, rejected when some
                // error occurs
                promise: deferred.promise,
                // task object with details about the task
                task: task,
                // state of the running tasks, one of 'starting',
                // 'running', 'paused', 'stopped'
                state: null,
                // stops polling for the task updates
                stopMonitoring: function () {
                    if (searchId) {
                        resource.unregisterSearch(searchId);
                    }
                }
            };

            function updateTask(taskObject) {
                runningTask.task = taskObject;
                if (taskObject.state === 'paused' || taskObject.state === 'stopped') {
                    resource.unregisterSearch(searchId);
                    if (taskObject.result === 'success') {
                        runningTask.state = 'stopped';
                        deferred.resolve(taskObject);
                    }
                    if ((taskObject.result === 'error' || taskObject.result === 'warning')) {
                        runningTask.state = 'paused';
                        deferred.reject(taskObject.humanized.errors);
                    }
                } else {
                    runningTask.state = 'running';
                    deferred.notify(taskObject);
                }
            }

            function pollTask(taskObject) {
                searchId = resource.registerSearch({ 'type': 'task', 'task_id': taskObject.id }, updateTask);
            }

            if (task.$promise) {
                runningTask.state = 'starting';
                task.$promise.then(pollTask, function (error) {
                    var errors = [];
                    runningTask.state = 'stopped';
                    if (error.data.errors) {
                        errors = error.data.errors;
                    } else if (error.data.error) {
                        errors = error.data.error.message;
                    }
                    if (!_.isArray(errors)) {
                        errors = [errors];
                    }
                    deferred.reject(errors);
                });
            } else {
                updateTask(task);
                pollTask(task);
            }

            return runningTask;
        };

        return resource;
    }]
);
