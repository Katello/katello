/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/
angular.module('Bastion.widgets')
    .factory('taskListProvider', ['$timeout', '$resource', function($timeout, $resource) {
        var conditions = [], condToScopes = {}, scopeToCond = {},
            timoutId,
            taskListResource = $resource('/katello/api/dyntasks',
                                    {},
                                    {query: {method:'POST', isArray: true}});

        function updateProgress() {
            if(conditions.length == 0) {
                return;
            }
            taskListResource.query({conditions: conditions}, function(conditionsTasks) {
                angular.forEach(conditionsTasks, function(conditionTasks) {
                    var scopes = condToScopes[JSON.stringify(conditionTasks.condition)];
                    angular.forEach(scopes, function(scope) {
                        scope.updateTasks(conditionTasks.tasks);
                    });
                });
            });
        }
        function scheduleUpdate() {
            // save the timeoutId for canceling
            timeoutId = $timeout(function() {
                updateProgress();
                scheduleUpdate(); // schedule the next update
            }, 1500);
        }
        scheduleUpdate();

        function addScope(scope, searchOptions, condition) {
            if(searchOptions.activeOnly) {
                condition['active_only'] = true;
            }
            if(!condToScopes[JSON.stringify(condition)]) {
                conditions.push(condition);
                condToScopes[JSON.stringify(condition)] = [];
            }
            condToScopes[JSON.stringify(condition)].push(scope);
            scopeToCond[scope.$id] = condition;
        };

        function deleteScope(scope) {
            condition = scopeToCond[scope.$id];
            if(!condition) {
                return;
            }
            scopeIndex = condToScopes[JSON.stringify(condition)].indexOf(scope);
            condToScopes[JSON.stringify(condition)].splice(scopeIndex, 1);
            if(condToScopes[JSON.stringify(condition)].length == 0) {
                condIndex = conditions.indexOf(condition);
                conditions.splice(condIndex, 1);
                delete condToScopes[JSON.stringify(condition)];
            }
            delete scopeToCond[scope.$id];
        };

        return {
            registerUser: function(scope, searchOptions, userId) {
                addScope(scope, searchOptions, { type: 'user', user_id: userId });
            },
            registerResource: function(scope, searchOptions, resourceType, resourceId) {
                addScope(scope, searchOptions, { type: 'resource',
                                                 resource_type: resourceType,
                                                 resource_id: resourceId });
            },
            unregister: function(scope) { deleteScope(scope); }
        };
    }])
    .filter('progressClasses', function () {
        return function(task) {
            if(!task) {
                return ""
            }
            var classes = [];
            switch(task.result) {
            case "success": case "pending":
                classes.push("progress-success");
                break;
            case "error":
                classes.push("progress-danger");
                break;
            }

            switch(task.state) {
            case "running": case "pending":
                classes.push("active");
                break;
            case "stopped": case "paused": default:
                classes.push("");
                break;
            }

            return classes.join(' ');
        };
    })
    .directive('activetaskscount', ['taskListProvider', function(taskListProvider) {
        return {
            restrict: 'E',
            template: '<span>{{count}}</span>',
            link: function(scope) {
                taskListProvider.registerUser(scope, { activeOnly: true }, '1');
                scope.updateTasks = function(tasks) {
                    scope.count = tasks.length;
                }
            }
        };
     }])
    .directive('tasklistitem', function() {
        return {
            restrict: 'E',
            templateUrl: 'widgets/views/task-list-item.html',
            link: function(scope) {
            }
        };
    })
    .directive('tasklist',
               ['$templateCache', '$compile', 'taskListProvider', function($templateCache, $compile, taskListProvider) {
        return {
            restrict: 'E',
            template: '',
            scope: {
                taskActive: '@taskactive',
                taskUserId: '@taskuserid',
                taskResourceType: '@taskresourcetype',
                taskResourceId: '@taskresourceid',
            },
            link: function (scope, element, attrs) {
                scope.taskListItems = {}
                function taskScope(task) {
                    if(scope.taskListItems[task.uuid]) {
                        return scope.taskListItems[task.uuid].scope();
                    } else {
                        var taskScope = scope.$new();
                        var taskListItem = $compile('<tasklistitem></tasklistitem>')(taskScope);
                        element.after(taskListItem);
                        scope.taskListItems[task.uuid] = taskListItem;
                        return taskScope;
                    }
                }

                function deleteFinishedTasks(tasks) {
                    var existingUuids = [], uuidsToRemove = [];
                    angular.forEach(tasks, function(task) {
                        existingUuids.push(task.uuid.toString());
                    });

                    angular.forEach(scope.taskListItems, function(el, uuid) {
                        if(existingUuids.indexOf(uuid.toString()) == -1) {
                            uuidsToRemove.push(uuid);
                        }
                    });
                    angular.forEach(uuidsToRemove, function(uuid) {
                        scope.taskListItems[uuid].remove();
                        delete scope.taskListItems[uuid];
                    });
                }

                function searchOptions() {
                    return { activeOnly: scope.taskActive == 'true' }
                }

                scope.updateTasks = function(tasks) {
                    angular.forEach(tasks.reverse(), function(task) {
                        taskScope(task).task = task;
                    });
                    deleteFinishedTasks(tasks);
                }
                scope.$watch('taskUserId', function(userId) {
                    if(userId) {
                        taskListProvider.registerUser(scope, searchOptions(), userId)
                    }
                })
                scope.$watch('taskResourceId', function(resourceId) {
                    if(resourceId) {
                        taskListProvider.registerResource(scope, searchOptions(), scope.taskResourceType, resourceId);
                    }
                })

                element.bind('$destroy', function() {
                    taskListProvider.unregister(scope);
                });
            }
        }
    }]);
