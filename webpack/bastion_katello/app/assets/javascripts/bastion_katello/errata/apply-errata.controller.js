/**
 * @ngdoc object
 * @name  Bastion.errata.controller:IncrementalUpdateController
 *
 * @requires $scope
 * @requires translate
 * @requires IncrementalUpdate
 * @requires ContentHostBulkAction
 * @requires ContentViewVersion
 * @requires CurrentOrganization
 * @requires Notification
 *
 * @description
 *   Display confirmation screen and apply Errata.
 */
angular.module('Bastion.errata').controller('ApplyErrataController',
    ['$scope', 'translate', 'IncrementalUpdate', 'HostBulkAction', 'ContentViewVersion', 'CurrentOrganization', 'Notification',
        function ($scope, translate, IncrementalUpdate, HostBulkAction, ContentViewVersion, CurrentOrganization, Notification) {
            var applyErrata, incrementalUpdate;

            function transitionToTask(task) {
                if ($scope.$stateParams.hasOwnProperty('errataId')) {
                    $scope.transitionTo('erratum.task', {errataId: $scope.$stateParams.errataId,
                        taskId: task.id});
                } else {
                    $scope.transitionTo('errata.tasks.task', {taskId: task.id});
                }
                $scope.applyingErrata = false;
            }

            $scope.applyingErrata = false;

            $scope.hasComposites = function (updates) {
                var composite;

                if (updates) {
                    composite = _.find(updates, function (update) {
                        return update.components;
                    });
                    return composite;
                }
                return false;
            };

            $scope.toggleComponents = function (update) {
                update.componentsVisible = !update.componentsVisible;
            };

            incrementalUpdate = function () {
                var error, params = {}, cvIdEnvIds = {};

                $scope.applyingErrata = true;

                params['add_content'] = {
                    'errata_ids': IncrementalUpdate.getErrataIds()
                };

                params['content_view_version_environments'] = [];
                params['resolve_dependencies'] = true;

                //get a list of unique content view version ids with their environments
                angular.forEach($scope.updates, function (update) {
                    var versionId = update['content_view_version'].id;

                    if (update.components) {
                        angular.forEach(_.map(update.components, 'id'), function (componentId) {
                            if (angular.isUndefined(cvIdEnvIds[componentId])) {
                                cvIdEnvIds[componentId] = [];
                            }
                        });
                    }
                    if (angular.isUndefined(cvIdEnvIds[versionId])) {
                        cvIdEnvIds[versionId] = [];
                    }
                    cvIdEnvIds[versionId] = _.uniq(cvIdEnvIds[versionId].concat(_.map(update.environments, 'id')));
                });

                angular.forEach(cvIdEnvIds, function (envIds, cvId) {
                    params['content_view_version_environments'].push({
                        'content_view_version_id': parseInt(cvId, 10),
                        'environment_ids': envIds
                    });
                });

                if ($scope.applyErrata) {
                    params['update_hosts'] = IncrementalUpdate.getBulkContentHosts();
                }

                error = function (response) {
                    angular.forEach(response.data.errors, function (responseError) {
                        Notification.setErrorMessage(responseError);
                    });
                    $scope.applyingErrata = false;
                };

                ContentViewVersion.incrementalUpdate(params, transitionToTask, error);
            };

            applyErrata = function () {
                var params = IncrementalUpdate.getBulkContentHosts(), error;

                $scope.applyingErrata = true;

                params['content_type'] = 'errata';
                params.content = IncrementalUpdate.getErrataIds();
                params['organization_id'] = CurrentOrganization;

                error = function (response) {
                    angular.forEach(response.data.errors, function (responseError) {
                        Notification.setErrorMessage(responseError);
                    });
                    $scope.applyingErrata = false;
                };

                HostBulkAction.installContent(params, transitionToTask, error);
            };

            $scope.selectedContentHosts = IncrementalUpdate.getBulkContentHosts();
            $scope.selectedContentHosts['errata_ids'] = IncrementalUpdate.getErrataIds();
            $scope.selectedContentHosts['organization_id'] = CurrentOrganization;
            HostBulkAction.availableIncrementalUpdates($scope.selectedContentHosts, function (updates) {
                $scope.updates = updates;
            });

            $scope.confirmApply = function() {
                $scope.applyingErrata = true;
                if ($scope.updates.length === 0) {
                    applyErrata();
                } else {
                    incrementalUpdate();
                }
            };

            $scope.incrementalUpdates = IncrementalUpdate.getIncrementalUpdates();
            $scope.selectedContentHosts = IncrementalUpdate.getBulkContentHosts();
            $scope.contentHostIds = IncrementalUpdate.getContentHostIds();
            $scope.errataIds = IncrementalUpdate.getErrataIds();
        }
    ]);
