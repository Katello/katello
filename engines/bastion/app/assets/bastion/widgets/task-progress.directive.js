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
    .factory('tasksStatusProvider', ['$timeout', '$resource', function($timeout, $resource) {
        var callbacks = {},
            timoutId,
            taskResource = $resource('/katello/api/dyntasks',
                                    {},
                                    {query: {method:'GET', isArray: true}});

        function updateProgress() {
            var uuids = []
            angular.forEach(callbacks, function(callback, uuid) { uuids.push(uuid); })
            if (uuids.length == 0) {
                return;
            }
            taskResource.query({'uuids[]': uuids}, function(tasks) {
                angular.forEach(tasks, function(task) {
                    var callback = callbacks[task.uuid]
                    if (callback) {
                        callback(task.progress*100);
                    }
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
        return {
            register: function(uuid, callback) { callbacks[uuid] = callback; },
            unregister: function(uuid) { delete callbacks[uuid]; }
        };
    }])
    .directive('taskprogress',
               ['tasksStatusProvider', function(tasksStatusProvider) {
        return {
            restrict: 'E',
            templateUrl: 'widgets/views/task-progress.html',
            scope: {
                uuid: '@',
            },
            link: function (scope, element, args) {
                tasksStatusProvider.register(args.uuid, function(progress) {
                    scope.progress = progress;
                });
                element.bind('$destroy', function() {
                    tasksStatusProvider.unregister(args.uuid);
                });
            }
        }
    }]);
