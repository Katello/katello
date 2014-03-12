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
 * @requires gettext
 * @requires ContentViewVersion
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewVersionsController',
    ['$scope', 'gettext', 'ContentViewVersion', 'AggregateTask',
        function ($scope, gettext, ContentViewVersion, AggregateTask) {

        $scope.table = {};

        ContentViewVersion.query({'content_view_id': $scope.$stateParams.contentViewId}, function (data) {
            $scope.versions = data.results;
            processTasks($scope.versions);
        });

        function processTasks(versions) {
            _.each(versions, function (version) {
                var taskIds = _.map(version['active_history'], function (history) {
                                    return history.task.id;
                                });
                if (taskIds.length > 0) {
                    version.task = AggregateTask.new(taskIds);
                }
            });
        }

        $scope.$on('$destroy', function () {
            _.each($scope.versions, function (version) {
                if (version.task) {
                    version.task.unregisterAll();
                }
            });
        });

        $scope.status = function (version) {
            var promoteCount = version['active_history'].length,
                publish = _.findWhere(version['active_history'], {publish: true});

            if (publish) {
                promoteCount = promoteCount - 1;
            }
            return statusMessage(publish, promoteCount);
        };

        function statusMessage(isPublishing, promoteCount) {
            var status = '';
            if (promoteCount > 1) {
                if (isPublishing) {
                    status = gettext("Publishing and promoting to %count environments.").replace(
                        '%count', promoteCount);
                }
                else {
                    status = gettext("Promoting to %count environments.").replace('%count', promoteCount);
                }
            } else if (promoteCount === 1 || isPublishing) {
                if (isPublishing) {
                    status = gettext("Publishing and promoting to 1 environment.");
                }
                else {
                    status =  gettext("Promoting to 1 environment.");
                }
            }
            return status;
        }
    }]
);
