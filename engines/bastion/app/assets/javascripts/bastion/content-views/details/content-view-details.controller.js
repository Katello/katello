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
 * @name  Bastion.content-views.controller:ContentViewDetailsController
 *
 * @requires $scope
 * @requires ContentView
 * @requires gettext
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewDetailsController',
    ['$scope', 'ContentView', 'ContentViewVersion', 'AggregateTask', 'gettext',
    function ($scope, ContentView, ContentViewVersion, AggregateTask, gettext) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.contentView = ContentView.get({id: $scope.$stateParams.contentViewId});

        function processTasks(versions) {
            _.each(versions, function (version) {
                var taskIds = _.map(version['active_history'], function (history) {
                                    return history.task.id;
                                });

                if (taskIds.length > 0) {
                    version.task = AggregateTask.new(taskIds, function (task) {
                        taskUpdated(version, task);
                    });
                }
            });
        }

        function taskUpdated(version, task) {
            version.task = task;
            if (!task.pending && task.result === 'success') {
                if (task.label === 'Actions::Katello::ContentView::Promote') {
                    $scope.successMessages.push(promotionMessage(version, task));
                } else if (task.label === 'Actions::Katello::ContentView::Publish') {
                    $scope.successMessages.push(publishMessage(version));
                }
            }
        }

        function promotionMessage(version, task) {
            return gettext("Successfully promoted %cv version %ver to %env")
                .replace('%cv', version['content_view'].name)
                .replace('%ver', version.version)
                .replace('%env', task.input['environment_name']);
        }

        function publishMessage(version) {
            return gettext("Successfully published %cv version %ver and promoted to Library")
                .replace('%cv', version['content_view'].name)
                .replace('%ver', version.version);
        }

        $scope.reloadVersions = function () {
            var contentViewId = $scope.contentView.id || $scope.$stateParams.contentViewId;
            $scope.contentView.versions = [];

            ContentViewVersion.query({'content_view_id': contentViewId}, function (data) {
                $scope.versions = data.results;
                if ($scope.contentView) {
                    $scope.contentView.versions = data.results;
                }
                processTasks($scope.versions);
            });
        };

        $scope.save = function (contentView) {
            return contentView.$update(saveSuccess, saveError);
        };

        function saveSuccess() {
            $scope.successMessages = [gettext('Content View updated.')];
        }

        function saveError(response) {
            angular.forEach(response.data.errors, function (errorMessage) {
                $scope.errorMessages = [gettext("An error occurred updating the Content View: ") + errorMessage];
            });
        }

    }]
);
