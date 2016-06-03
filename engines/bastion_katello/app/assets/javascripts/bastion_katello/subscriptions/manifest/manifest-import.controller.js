/**
 * @ngdoc object
 * @name  Bastion.subscriptions.controller:ManifestImportController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires CurrentOrganization
 * @requires Organization
 * @requires Subscription
 * @requires Task
 *
 * @description
 *   Controls the import of a manifest.
 */
angular.module('Bastion.subscriptions').controller('ManifestImportController',
    ['$scope', '$q', 'translate', 'CurrentOrganization', 'Organization', 'Task', 'Subscription', 'GlobalNotification',
    function ($scope, $q, translate, CurrentOrganization, Organization, Task, Subscription, GlobalNotification) {

        function buildManifestLink(upstream) {
            var url = upstream.webUrl,
                upstreamId = upstream.uuid;

            if (!url.match(/^http/)) {
                url = "https://" + url;
            }
            if (!url.match(/\/$/)) {
                url = url + "/";
            }

            url += upstreamId;

            return url;
        }

        function initializeManifestDetails(organization) {
            $scope.details = organization['owner_details'];
            $scope.upstream = $scope.details.upstreamConsumer;

            if (!_.isNull($scope.upstream)) {
                $scope.manifestLink = buildManifestLink($scope.upstream);
                $scope.manifestName = $scope.upstream.name || $scope.upstream.uuid;
            }
        }

        $scope.uploadErrorMessages = [];
        $scope.progress = {uploading: false};
        $scope.uploadURL = '/katello/api/v2/organizations/' + CurrentOrganization + '/subscriptions/upload';
        $scope.organization = Organization.get({id: CurrentOrganization});

        $q.all([$scope.organization.$promise]).then(function () {
            $scope.panel.loading = false;
            initializeManifestDetails($scope.organization);
        });

        $scope.$on('$destroy', function () {
            $scope.unregisterSearch();
        });

        $scope.unregisterSearch = function () {
            Task.unregisterSearch($scope.searchId);
            $scope.searchId = undefined;
        };

        $scope.handleTaskErrors = function (task, errorMessage) {
            var errorMessageWithDetails = errorMessage;
            if (task.result === 'error' || task.result === 'warning') {
                if (task.humanized.output && task.humanized.output.length > 0) {
                    errorMessageWithDetails += ' ' + task.humanized.output;
                }
                if (task.humanized.errors.length > 0) {
                    errorMessageWithDetails += ' ' + task.humanized.errors.join(' ');
                }
                GlobalNotification.setErrorMessage(errorMessageWithDetails);
                $scope.histories = Subscription.manifestHistory();
            }
        };

        $scope.updateTask = function (task) {
            $scope.task = task;

            if (!$scope.task.pending) {
                $scope.unregisterSearch();
                if ($scope.task.result === 'success') {
                    $scope.refreshOrganizationInfo();
                    GlobalNotification.setSuccessMessage(translate("Manifest successfully imported."));
                    $scope.refreshTable();
                } else {
                    $scope.handleTaskErrors(task, translate("Error importing manifest."));
                }
            }
        };

        $scope.deleteManifest = function () {
            Subscription.deleteManifest({}, function (returnData) {
                $scope.deleteTask = returnData;
                $scope.searchId = Task.registerSearch({'type': 'task', 'task_id': $scope.deleteTask.id}, $scope.deleteManifestTask);
            }, function (response) {
                $scope.saveError = true;
                $scope.errors = response.data.errors;
            });
        };

        $scope.deleteManifestTask = function (task) {
            $scope.deleteTask = task;
            if (!$scope.deleteTask.pending) {
                $scope.unregisterSearch();
                if ($scope.deleteTask.result === 'success') {
                    $scope.saveSuccess = true;
                    GlobalNotification.setSuccessMessage(translate("Manifest successfully deleted."));
                    $scope.refreshTable();
                    $scope.refreshOrganizationInfo();
                } else {
                    $scope.handleTaskErrors(task, translate("Error deleting manifest."));
                }
            }
        };

        $scope.refreshOrganizationInfo = function () {
            $scope.organization = Organization.get({id: CurrentOrganization});
            $q.all([$scope.organization.$promise]).then(function () {
                initializeManifestDetails($scope.organization);
            });
            $scope.histories = Subscription.manifestHistory();
        };

        $scope.refreshManifest = function () {
            Subscription.refreshManifest({}, function (returnData) {
                $scope.refreshTask = returnData;
                $scope.searchId = Task.registerSearch({'type': 'task', 'task_id': $scope.refreshTask.id}, $scope.refreshManifestTask);
            }, function (response) {
                $scope.saveError = true;
                $scope.errors = response.data.errors;
            });
        };

        $scope.refreshManifestTask = function (task) {
            $scope.refreshTask = task;
            if (!$scope.refreshTask.pending) {
                $scope.unregisterSearch();
                if ($scope.refreshTask.result === 'success') {
                    $scope.saveSuccess = true;
                    GlobalNotification.setSuccessMessage(translate("Manifest successfully refreshed."));
                    $scope.refreshTable();
                    $scope.refreshOrganizationInfo();
                } else {
                    $scope.handleTaskErrors(task, translate("Error refreshing manifest."));
                }
            }
        };

        $scope.saveCdnUrl = function (organization) {
            var deferred;

            // @TODO hack needed to prevent upload of fields users, parent_name, and parent_id
            // http://projects.theforeman.org/issues/12894
            var whitelistedOrganizationObject = {},
                whitelist = [
                    "id",
                    "redhat_repository_url"
                ];

            angular.forEach(whitelist, function (key) {
                whitelistedOrganizationObject[key] = organization[key];
            });

            deferred = Organization.update(whitelistedOrganizationObject, function () {
                GlobalNotification.setSuccessMessage(translate('Repository URL updated'));
                $scope.refreshTable();
                $scope.refreshOrganizationInfo();
            }, function (response) {
                GlobalNotification.setErrorMessage(translate("An error occurred saving the URL: ") + response.data.error.message);
            });

            return deferred.$promise;
        };

        $scope.uploadManifest = function (content) {
            var returnData;
            if (content) {
                try {
                    returnData = angular.fromJson(angular.element(content).html());
                } catch (err) {
                    returnData = content;
                }

                if (!returnData) {
                    returnData = content;
                }

                if (returnData !== null && angular.isUndefined(returnData.errors)) {
                    $scope.task = returnData;
                    $scope.searchId = Task.registerSearch({'type': 'task', 'task_id': $scope.task.id}, $scope.updateTask);
                } else {
                    $scope.uploadErrorMessages = [translate('Error during upload: ') + returnData.displayMessage];
                }

                $scope.progress.uploading = false;
            }
        };

        $scope.histories = Subscription.manifestHistory();

        $scope.showHistoryMoreLink = false;

        $scope.truncateHistories = function (histories) {
            var numToDisplay = 4;
            var result = [];
            angular.forEach(histories, function (history, index) {
                if (index < numToDisplay) {
                    result.push(history);
                }
            });
            return result;
        };

        $scope.isTruncated = function (subset, set) {
            return subset.length < set.length;
        };

        $scope.$watch('histories', function (changes) {
            changes.$promise.then(function (results) {
                $scope.statuses = $scope.truncateHistories(results);
                $scope.showHistoryMoreLink = $scope.isTruncated($scope.statuses, results);
            });
        });
    }]
);
