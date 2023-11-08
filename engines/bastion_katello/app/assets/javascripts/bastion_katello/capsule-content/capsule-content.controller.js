/**
 * @ngdoc object
 * @name  Bastion.capsule-content.controller:CapsuleContentController
 *
 * @requires $scope
 * @requires $urlMatcherFactory
 * @requires $location
 * @requires translate
 * @requires CapsuleContent
 * @requires AggregateTask
 * @requires CurrentOrganization
 * @requires syncState
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the capsule-content page.
 */
angular.module('Bastion.capsule-content').controller('CapsuleContentController',
    ['$scope', '$urlMatcherFactory', '$location', 'translate', 'CapsuleContent', 'AggregateTask', 'CurrentOrganization', 'syncState', 'Notification',
    function ($scope, $urlMatcherFactory, $location, translate, CapsuleContent, AggregateTask, CurrentOrganization, syncState, Notification) {

        var refreshSyncStatus;
        var urlMatcher = $urlMatcherFactory.compile("/smart_proxies/:capsuleId");
        var capsuleId = urlMatcher.exec($location.path()).capsuleId;

        function processError(response, prependMsg) {
            var msg = '';
            if (response.data && response.data.displayMessage) {
                if (angular.isDefined(prependMsg)) {
                    msg = msg + prependMsg;
                }
                msg = msg + response.data.displayMessage;
                Notification.setErrorMessage(msg);
            }
        }

        function pickLastTask(tasks) {
            var task = tasks.slice(-1)[0];
            task.progressbar = {
                value: task.progress * 100,
                type: $scope.progressbarType(task)
            };
            return task;
        }

        function isTaskInProgress(task) {
            return (task && (task.state === 'pending' || task.state === 'running'));
        }

        function stateFromTask(syncTask) {
            var state;

            if (isTaskInProgress(syncTask)) {
                state = syncState.SYNCING;
            } else if (syncTask && syncTask.result !== 'success') {
                state = syncState.FAILURE;
            } else {
                state = syncState.DEFAULT;
            }
            return state;
        }

        function taskUpdated() {
            if (!angular.isUndefined($scope.syncTask.result) && $scope.syncTask.result !== 'pending') {
                $scope.syncTask.unregisterAll();
                refreshSyncStatus();
            }
        }

        $scope.productsOrVersionUrl = function (cvIsDefault, cvId) {
            return cvIsDefault ? '/products' : '/content_views/' + cvId + '/versions';
        };

        function aggregateTasks(tasks) {
            var taskIds = _.map(tasks, function (task) {
                                return task.id;
                            });
            return AggregateTask.new(taskIds, taskUpdated);
        }

        refreshSyncStatus = function () {
            var params = {
                id: capsuleId
            };
            if ( CurrentOrganization !== '' ) {
                params['organization_id'] = CurrentOrganization;
            }

            CapsuleContent.syncStatus(params).$promise.then(function (syncStatus) {
                var errorCount, errorMessage, activeOrFailedTask;
                $scope.syncStatus = syncStatus;
                if (syncStatus['last_sync_time'] === null) {
                    $scope.syncStatus['last_sync_time'] = translate('Never');
                }

                if (syncStatus['active_sync_tasks'].length > 0) {
                    $scope.syncTask = aggregateTasks(syncStatus['active_sync_tasks']);
                    activeOrFailedTask = pickLastTask(syncStatus['active_sync_tasks']);

                } else if (syncStatus['last_failed_sync_tasks'].length > 0) {
                    activeOrFailedTask = pickLastTask(syncStatus['last_failed_sync_tasks']);
                    $scope.syncTask = activeOrFailedTask;
                    errorCount = $scope.syncTask.humanized.errors.length;

                    if (errorCount > 0) {
                        errorMessage = $scope.syncTask.humanized.errors[0];
                        if (errorCount > 2) {
                            errorMessage += " " + translate("Plus %y more errors").replace("%y", errorCount - 1);
                        } else if (errorCount > 1) {
                            errorMessage += " " + translate("Plus 1 more error");
                        }
                        Notification.setErrorMessage(translate('Last sync failed: ') + errorMessage);
                    }
                }
                $scope.syncState.set(stateFromTask(activeOrFailedTask));
            }, function (response) {
                $scope.syncStatus = {
                    'active_sync_tasks': [],
                    'last_failed_sync_tasks': []
                };
                processError(response, translate('Last sync failed: '));
            });
        };

        $scope.syncState = syncState;
        $scope.smartProxyId = capsuleId;
        $scope.expandEnvironments = {};

        refreshSyncStatus();

        $scope.$on('$destroy', function () {
            if ($scope.syncTask) {
                $scope.syncTask.unregisterAll();
            }
        });

        $scope.isTaskInProgress = isTaskInProgress;

        $scope.validateContent = function () {
            if (!$scope.syncState.is(syncState.SYNCING) && !$scope.syncState.is(syncState.VALIDATING_CONTENT) && !$scope.syncState.is(syncState.RECLAIMING_SPACE)) {

                $scope.syncState.set(syncState.VALIDATE_CONTENT_TRIGGERED);

                CapsuleContent.validateContent({id: capsuleId}).$promise.then(function (task) {
                    $scope.syncStatus['active_sync_tasks'].push(task);
                    $scope.syncTask = aggregateTasks($scope.syncStatus['active_sync_tasks']);
                    $scope.syncState.set(syncState.VALIDATING_CONTENT);
                }, function (response) {
                    processError(response, translate('Last validate content failed: '));
                    $scope.syncState.set(syncState.DEFAULT);
                });
            }
        };

        $scope.reclaimSpace = function () {
            if (!$scope.syncState.is(syncState.SYNCING) && !$scope.syncState.is(syncState.VALIDATING_CONTENT) && !$scope.syncState.is(syncState.RECLAIMING_SPACE)) {

                $scope.syncState.set(syncState.RECLAIM_SPACE_TRIGGERED);

                CapsuleContent.reclaimSpace({id: capsuleId}).$promise.then(function (task) {
                    $scope.syncStatus['active_sync_tasks'].push(task);
                    $scope.syncTask = aggregateTasks($scope.syncStatus['active_sync_tasks']);
                    $scope.syncState.set(syncState.RECLAIMING_SPACE);
                }, function (response) {
                    processError(response, translate('Last reclaim space failed: '));
                    $scope.syncState.set(syncState.DEFAULT);
                });
            }
        };

        $scope.syncCapsule = function (skipMetadataCheck) {
            if (!$scope.syncState.is(syncState.SYNCING) && !$scope.syncState.is(syncState.VALIDATING_CONTENT) && !$scope.syncState.is(syncState.RECLAIMING_SPACE)) {

                $scope.syncState.set(syncState.SYNC_TRIGGERED);

                CapsuleContent.sync({id: capsuleId, 'skip_metadata_check': skipMetadataCheck}).$promise.then(function (task) {
                    $scope.syncStatus['active_sync_tasks'].push(task);
                    $scope.syncTask = aggregateTasks($scope.syncStatus['active_sync_tasks']);
                    $scope.syncState.set(syncState.SYNCING);
                }, function (response) {
                    processError(response, translate('Last sync failed: '));
                    $scope.syncState.set(syncState.DEFAULT);
                });
            }
        };

        $scope.cancelSync = function () {
            if ($scope.syncState.is(syncState.SYNCING)) {

                $scope.syncState.set(syncState.CANCEL_TRIGGERED);
                CapsuleContent.cancelSync({id: capsuleId}).$promise.catch(processError);
            }
        };

        $scope.syncStatusText = function (currentSyncState, syncStatus) {
            var message, syncableEnvs, envNames;

            if (angular.isUndefined(syncStatus)) {
                return "";
            }

            if (currentSyncState.is(currentSyncState.SYNCING)) {
                message = translate("Smart proxy currently syncing to your locations...");
            } else if (currentSyncState.is(currentSyncState.VALIDATING_CONTENT)) {
                message = translate("Smart proxy currently validating content...");
            } else if (currentSyncState.is(currentSyncState.RECLAIMING_SPACE)) {
                message = translate("Smart proxy currently reclaiming space...");
            } else if (currentSyncState.is(currentSyncState.SYNC_TRIGGERED)) {
                message = translate("Synchronization is about to start...");
            } else if (currentSyncState.is(currentSyncState.CANCEL_TRIGGERED)) {
                message = translate("Synchronization is being cancelled...");
            } else if (currentSyncState.is(currentSyncState.VALIDATE_CONTENT_TRIGGERED)) {
                message = translate("Content validation is about to start...");
            } else if (currentSyncState.is(currentSyncState.RECLAIM_SPACE_TRIGGERED)) {
                message = translate("Space reclamation is about to start...");
            } else {
                syncableEnvs = _.filter(syncStatus['lifecycle_environments'], {syncable: true});

                if (syncableEnvs.length > 0) {
                    envNames = _.map(syncableEnvs, 'name').join(', ');
                    message = translate("%count environment(s) can be synchronized: %envs")
                                .replace('%count', syncableEnvs.length)
                                .replace('%envs', envNames);
                } else {
                    message = translate("Smart proxy is synchronized");
                }
            }
            return message;
        };

        $scope.toggleExpandEnvironment = function (environment) {
            $scope.expandEnvironments[environment.id] = !$scope.expandEnvironments[environment.id];
            return $scope.expandEnvironments[environment.id];
        };

        $scope.isEnvronmentExpanded = function (environment) {
            return $scope.expandEnvironments[environment.id];
        };

        $scope.progressbarType = function (syncTask) {
            var type;

            if (angular.isUndefined(syncTask) || syncTask.result === 'pending' || syncTask.result === 'success') {
                type = 'success';
            } else {
                type = 'danger';
            }
            return type;
        };

    }]
);
