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
 * @requires translate
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewDetailsController',
    ['$scope', 'ContentView', 'ContentViewVersion', 'AggregateTask', 'translate',
    function ($scope, ContentView, ContentViewVersion, AggregateTask, translate) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.contentView = ContentView.get({id: $scope.$stateParams.contentViewId});

        $scope.taskTypes = {
            publish: "Actions::Katello::ContentView::Publish",
            promotion: "Actions::Katello::ContentView::Promote",
            deletion:  "Actions::Katello::ContentView::Remove",
            incrementalUpdate:  "Actions::Katello::ContentView::IncrementalUpdates"
        };

        $scope.copy = function (newName) {
            ContentView.copy({id: $scope.contentView.id, 'content_view': {name: newName}}, function (response) {
                $scope.showCopy = false;
                $scope.table.addRow(response);
                $scope.transitionTo('content-views.details.info', {contentViewId: response['id']});
            }, function (response) {
                $scope.copyErrorMessages.push(response.data.displayMessage);
            });
        };

        function processTasks(versions) {
            _.each(versions, function (version) {
                var taskIds = _.map(version['active_history'], function (history) {
                                    return history.task.id;
                                });

                if (taskIds.length > 0) {
                    version.task = AggregateTask.new(taskIds, function (task) {
                        taskUpdated(version,  task);
                        if (task.label === $scope.taskTypes.publish && !task.pending && task.result === 'success') {
                            updateVersion(version);
                        }
                    });
                }
            });
        }

        function taskUpdated(version, task) {
            var taskTypes = $scope.taskTypes;

            if (!task.pending && task.result === 'success') {
                if (task.label === taskTypes.promotion) {
                    $scope.successMessages.push(promotionMessage(version, task));
                } else if (task.label === taskTypes.publish) {
                    $scope.successMessages.push(publishMessage(version));
                } else if (task.label === taskTypes.deletion) {
                    $scope.successMessages.push(deletionMessage(version, task));
                    $scope.reloadVersions();
                }
            }
        }

        function promotionMessage(version, task) {
            return translate("Successfully promoted %cv version %ver to %env")
                .replace('%cv', version['content_view'].name)
                .replace('%ver', version.version)
                .replace('%env', task.input['environment_name']);
        }

        function deletionMessage(version, task) {
            var message;

            if (task.input['content_view_ids'] && task.input['content_view_ids'].length > 0) {
                message = translate("Successfully deleted %cv version %ver.")
                                .replace('%cv', version['content_view'].name)
                                .replace('%ver', version.version);
            } else {
                message = translate("Successfully removed %cv version %ver from environments: %env")
                                .replace('%cv', version['content_view'].name)
                                .replace('%ver', version.version)
                                .replace('%env', task.input['environment_names'].join(', '));
            }
            return message;
        }

        function publishMessage(version) {
            return translate("Successfully published %cv version %ver and promoted to Library")
                .replace('%cv', version['content_view'].name)
                .replace('%ver', version.version);
        }

        function updateVersion(version) {
            var versionIds = _.map($scope.contentView.versions, function (ver) {
                    return ver.id;
                }),
                versionIndex = versionIds.indexOf(version.id);

            ContentViewVersion.get({'id': version.id}).$promise.then(function (newVersion) {
                $scope.contentView.versions[versionIndex] = newVersion;
                $scope.versions[versionIndex] = newVersion;
            });
        }

        $scope.reloadVersions = function () {
            var contentViewId = $scope.contentView.id || $scope.$stateParams.contentViewId;
            $scope.contentView.versions = [];
            $scope.loadingVersions = true;

            ContentViewVersion.queryUnpaged({'content_view_id': contentViewId}, function (data) {
                $scope.versions = data.results;
                if ($scope.contentView) {
                    $scope.contentView.versions = data.results;
                }
                $scope.loadingVersions = false;
                processTasks($scope.versions);
            });
        };

        $scope.save = function (contentView) {
            return contentView.$update(saveSuccess, saveError);
        };

        function saveSuccess() {
            $scope.successMessages = [translate('Content View updated.')];
        }

        function saveError(response) {
            angular.forEach(response.data.errors, function (errorMessage) {
                $scope.errorMessages = [translate("An error occurred updating the Content View: ") + errorMessage];
            });
        }

    }]
);
