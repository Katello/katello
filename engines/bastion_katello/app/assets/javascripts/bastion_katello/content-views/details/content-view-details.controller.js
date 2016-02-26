/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewDetailsController
 *
 * @requires $scope
 * @requires ContentView
 * @requires Nutupane
 * @requires translate
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewDetailsController',
    ['$scope', 'ContentView', 'ContentViewVersion', 'Nutupane', 'AggregateTask', 'translate', 'ApiErrorHandler',
    function ($scope, ContentView, ContentViewVersion, Nutupane, AggregateTask, translate, ApiErrorHandler) {


        function saveSuccess() {
            $scope.successMessages = [translate('Content View updated.')];
        }

        function saveError(response) {
            angular.forEach(response.data.errors, function (errorMessage) {
                $scope.errorMessages = [translate("An error occurred updating the Content View: ") + errorMessage];
            });
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

        function updateVersion(version) {
            var versionIds = _.pluck($scope.detailsTable.rows, 'id'),
                versionIndex = versionIds.indexOf(version.id);

            ContentViewVersion.get({'id': version.id}).$promise.then(function (newVersion) {
                $scope.contentView.versions[versionIndex] = newVersion;
                $scope.versions[versionIndex] = newVersion;
            });
        }

        function processTasks(versions) {
            _.each(versions, function (version) {
                var taskIds = _.map(version['active_history'], function (history) {
                                    return history.task.id;
                                });

                if (taskIds.length > 0) {
                    version.task = AggregateTask.new(taskIds, function (task) {
                        taskUpdated(version, task);
                        if (task.label === $scope.taskTypes.publish && !task.pending && task.result === 'success') {
                            updateVersion(version);
                        }
                    });
                }
            });
        }

        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.panel = {
            error: false,
            loading: true
        };

        $scope.contentView = ContentView.get({id: $scope.$stateParams.contentViewId}, function () {
            $scope.loading = false;
        }, function (response) {
            $scope.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.taskTypes = {
            publish: "Actions::Katello::ContentView::Publish",
            promotion: "Actions::Katello::ContentView::Promote",
            deletion: "Actions::Katello::ContentView::Remove",
            incrementalUpdate: "Actions::Katello::ContentView::IncrementalUpdates",
            export: "Actions::Katello::ContentViewVersion::Export"
        };

        $scope.copy = function (newName) {
            ContentView.copy({id: $scope.contentView.id, 'content_view': {name: newName}}, function (response) {
                $scope.showCopy = false;
                $scope.table.addRow(response);
                $scope.transitionTo('content-views.details.info', {contentViewId: response.id});
            }, function (response) {
                $scope.copyErrorMessages.push(response.data.displayMessage);
            });
        };

        $scope.reloadVersions = function () {
            var contentViewId = $scope.contentView.id || $scope.$stateParams.contentViewId,
                nutupane = new Nutupane(ContentViewVersion, {
                    'content_view_id': contentViewId
                });

            nutupane.masterOnly = true;

            $scope.detailsTable = nutupane.table;
        };

        $scope.$watch('detailsTable.rows', function () {
            if ($scope.detailsTable && $scope.detailsTable.rows.length > 0) {
                processTasks($scope.detailsTable.rows);
            }
        });

        $scope.save = function (contentView) {
            return contentView.$update(saveSuccess, saveError);
        };

    }]
);
