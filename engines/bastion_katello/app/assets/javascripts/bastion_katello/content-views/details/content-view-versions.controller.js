/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewVersionsController
 *
 * @requires $scope
 * @requires translate
 * @requires Nutupane
 * @requires ContentViewVersion
 * @requires AggregateTask
 * @requires ApiErrorHandler
 * @requires Notification
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the table view UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewVersionsController',
    ['$scope', 'translate', 'Nutupane', 'ContentViewVersion', 'AggregateTask', 'ApiErrorHandler', 'Notification',
    function ($scope, translate, Nutupane, ContentViewVersion, AggregateTask, ApiErrorHandler, Notification) {
        var nutupane, nutupaneParams = {
            'disableAutoLoad': true
        };

        function pluralSafe(count, strings) {
            if (count === 1) {
                return strings[0];
            }

            return strings[1];
        }

        function publishingMessage(count) {
            var messages = [translate("Publishing and promoting to 1 environment."),
                translate("Publishing and promoting to %count environments.").replace(
                    '%count', count)];
            return pluralSafe(count, messages);
        }

        function promotingMessage(count) {
            var messages = [translate('Promoting to 1 environment.'),
                translate("Promoting to %count environments.").replace('%count', count)];
            return pluralSafe(count, messages);
        }

        function deletingMessage(count) {
            var messages = [translate('Deleting from 1 environment.'),
                translate("Deleting from %count environments.").replace('%count', count)];
            return pluralSafe(count, messages);
        }

        function findTaskTypes(activeHistory, taskType) {
            return _.filter(activeHistory, function (history) {
                return history.task.label === taskType;
            });
        }

        function publishCompleteMessage(version) {
            return translate("Successfully published %cv version %ver and promoted to Library")
                .replace('%cv', version['content_view'].name)
                .replace('%ver', version.version);
        }

        function promotionCompleteMessage(version, task) {
            return translate("Successfully promoted %cv version %ver to %env")
                .replace('%cv', version['content_view'].name)
                .replace('%ver', version.version)
                .replace('%env', task.input.environments.join(", "));
        }

        function deletionCompleteMessage(version, task) {
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

        function updateVersion(version) {
            var versionIds = _.map($scope.table.rows, 'id'),
                versionIndex = versionIds.indexOf(version.id);

            ContentViewVersion.get({'id': version.id}).$promise.then(function (newVersion) {
                $scope.panel.loading = false;
                $scope.contentView.versions[versionIndex] = newVersion;
                $scope.table.rows[versionIndex] = newVersion;
            }, function (response) {
                $scope.panel.loading = false;
                ApiErrorHandler.handleGETRequestErrors(response, $scope);
            });
        }

        function taskUpdated(version, task) {
            var taskTypes = $scope.taskTypes;

            if (!task.pending) {
                $scope.pendingVersionTask = false;

                if (task.result === 'success') {
                    if (task.label === taskTypes.promotion) {
                        Notification.setSuccessMessage(promotionCompleteMessage(version, task));
                    } else if (task.label === taskTypes.publish) {
                        Notification.setSuccessMessage(publishCompleteMessage(version));
                    } else if (task.label === taskTypes.deletion) {
                        Notification.setSuccessMessage(deletionCompleteMessage(version, task));
                        $scope.reloadVersions();
                    }
                }
            } else {
                $scope.pendingVersionTask = true;
            }
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

        $scope.regenerateRepositories = function(version) {
            ContentViewVersion.republishRepositories({id: version.id}, function(task) {
                $scope.transitionTo('content-view.task', {taskId: task.id, contentViewId: version.content_view_id});
            });
        };

        $scope.hideProgress = function (version) {
            return version['active_history'].length === 0 || (version.task.state === 'stopped' &&
                version.task.progressbar.type === 'success');
        };

        $scope.historyText = function (version) {
            var taskTypes = $scope.taskTypes,
                taskType = version['last_event'].task ? version['last_event'].task.label : taskTypes[version['last_event'].action],
                message = "";

            if (taskType === taskTypes.deletion) {
                if (version['last_event'].environment) {
                    message = translate("Deletion from %s").replace('%s', version['last_event'].environment.name);
                } else {
                    message = translate("Version Deletion");
                }
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
                deletionEvents = _.filter(findTaskTypes(version['active_history'], taskTypes.deletion), function(history) {
                    return history.environment != null;
                }),
                promotionEvents = findTaskTypes(version['active_history'], taskTypes.promotion),
                publishEvents = findTaskTypes(version['active_history'], taskTypes.publish),
                messages = "";

            if (deletionEvents.length > 0) {
                messages = deletingMessage(deletionEvents.length);
            } else if (promotionEvents.length > 0) {
                messages = promotingMessage(promotionEvents.length);
            } else if (publishEvents.length > 0) {
                messages = publishingMessage(publishEvents.length);
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

        $scope.reloadVersions = function () {
            $scope.table.rows = [];
            nutupane.refresh();
        };

        $scope.$watch('table.rows', function () {
            if ($scope.table && $scope.table.rows.length > 0) {
                processTasks($scope.table.rows);
            }
        });

        $scope.$on('$destroy', function () {
            _.each($scope.versions, function (version) {
                if (version.task) {
                    version.task.unregisterAll();
                }
            });
        });

        $scope.panel = {
            error: false,
            loading: true
        };

        nutupane = new Nutupane(ContentViewVersion, {'content_view_id': $scope.$stateParams.contentViewId}, undefined, nutupaneParams);
        $scope.controllerName = 'katello_content_views';
        nutupane.setSearchKey('contentViewVersionSearch');
        nutupane.masterOnly = true;
        $scope.table = nutupane.table;

        $scope.pendingVersionTask = false;
        $scope.reloadVersions();
    }]
);
