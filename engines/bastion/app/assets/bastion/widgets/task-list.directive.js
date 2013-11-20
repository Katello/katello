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
    .directive('tasklist',
               ['$compile', 'Task', function($compile, Task) {
        return {
            restrict: 'E',
            template: '',
            scope: {
                taskActive: '@taskactive',
                taskUserId: '@taskuserid',
                taskResourceType: '@taskresourcetype',
                taskResourceId: '@taskresourceid',
                taskTemplate: '@tasktemplate'
            },
            link: function (scope, element, attrs) {
                scope.taskListItems = {}
                function taskScope(task) {
                    if(scope.taskListItems[task.uuid]) {
                        return scope.taskListItems[task.uuid].scope();
                    } else {
                        var taskScope = scope.$new();
                        taskScope.taskTemplate = function() {
                            return scope.taskTemplate || 'widgets/views/task-list-item.html';
                        }
                        var taskListItem = $compile('<div ng-include="taskTemplate()"></div>')(taskScope);
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

                function searchOptions(type) {
                    return { 'active_only': scope.taskActive == 'true',
                             'type': type };
                }

                function userSearchOptions(userId) {
                    var ret = searchOptions('user');
                    ret['user_id'] = userId;
                    return ret;
                }

                function resourceSearchOptions(resourceType, resourceId) {
                    var ret = searchOptions('resource');
                    ret['resource_type'] = resourceType;
                    ret['resource_id'] = resourceId;
                    return ret;
                }

                scope.updateTasks = function(tasks) {
                    angular.forEach(tasks.reverse(), function(task) {
                        taskScope(task).task = task;
                    });
                    deleteFinishedTasks(tasks);
                }
                scope.$watch('taskUserId', function(userId) {
                    if(userId) {
                        scope.searchId = Task.registerSearch(userSearchOptions(userId), scope.updateTasks);
                    }
                })
                scope.$watch('taskResourceId', function(resourceId) {
                    if(resourceId) {
                        scope.searchId = Task.registerSearch(resourceSearchOptions(scope.taskResourceType, resourceId), scope.updateTasks);
                    }
                })

                element.bind('$destroy', function() {
                    Task.unregisterSearch(scope.searchId);
                });
            }
        }
    }]);
