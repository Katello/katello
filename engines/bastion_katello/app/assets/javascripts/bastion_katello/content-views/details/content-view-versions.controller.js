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
*/

/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewVersionsController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentViewVersion
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewVersionsController',
    ['$scope', 'translate', function ($scope, translate) {

        $scope.table = {};

        $scope.reloadVersions();

        $scope.$on('$destroy', function () {
            _.each($scope.versions, function (version) {
                if (version.task) {
                    version.task.unregisterAll();
                }
            });
        });

        $scope.hideProgress = function (version) {
            return version['active_history'].length === 0 || (version.task.state === 'stopped' &&
                version.task.progressbar.type === 'success');
        };

        $scope.historyText = function (version) {
            var taskTypes = $scope.taskTypes,
                taskType = version['last_event'].task.label,
                message = "";

            if (taskType === taskTypes.deletion) {
                message = translate("Deletion from %s").replace('%s', version['last_event'].environment.name);
            } else if (taskType === taskTypes.promotion) {
                message = translate("Promoted to %s").replace('%s', version['last_event'].environment.name);
            } else if (taskType === taskTypes.publish) {
                message = translate("Published");
            } else if (taskType === taskTypes.incrementalUpdate) {
                message = translate("Incremental Update");
            }
            return message;
        };

        $scope.status = function (version) {
            var taskTypes = $scope.taskTypes,
                deletionEvents = findTaskTypes(version['active_history'], taskTypes.deletion),
                promotionEvents = findTaskTypes(version['active_history'], taskTypes.promotion),
                publishEvents = findTaskTypes(version['active_history'], taskTypes.publish),
                messages = "";

            if (deletionEvents.length > 0) {
                messages = deleteMessage(deletionEvents.length);
            } else if (promotionEvents.length > 0) {
                messages = promoteMessage(promotionEvents.length);
            } else if (publishEvents.length > 0) {
                messages = publishMessage(publishEvents.length);
            }

            return messages;
        };

        $scope.taskInProgress = function (version) {
            var inProgress = false;
            if (version.task && (version.task.state === 'pending' || version.task.state === 'running')) {
                inProgress = true;
            }
            return inProgress;
        };

        $scope.taskFailed = function (version) {
            var failed = false;
            if (version.task && (version.task.result === 'error')) {
                failed = true;
            }
            return failed;
        };

        function findTaskTypes(activeHistory, taskType) {
            return _.filter(activeHistory, function (history) {
                return history.task.label === taskType;
            });
        }

        function deleteMessage(count) {
            var messages = [translate('Deleting from 1 environment.'),
                            translate("Deleting from %count environments.").replace('%count', count)];
            return pluralSafe(count, messages);
        }

        function publishMessage(count) {
            var messages = [translate("Publishing and promoting to 1 environment."),
                            translate("Publishing and promoting to %count environments.").replace(
                                        '%count', count)];
            return pluralSafe(count, messages);
        }

        function promoteMessage(count) {
            var messages = [translate('Promoting to 1 environment.'),
                            translate("Promoting to %count environments.").replace('%count', count)];
            return pluralSafe(count, messages);
        }

        function pluralSafe(count, strings) {
            if (count === 1) {
                return strings[0];
            } else {
                return strings[1];
            }
        }
    }]
);
