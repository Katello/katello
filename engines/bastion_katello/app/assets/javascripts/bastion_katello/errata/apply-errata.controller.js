/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ApplyErrataController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentHostBulkAction
 * @requires ContentViewVersion
 * @requires CurrentOrganization
 *
 * @description
 *   Display confirmation screen and apply Errata.
 */
angular.module('Bastion.errata').controller('ApplyErrataController',
    ['$scope', 'translate', 'ContentHostBulkAction', 'ContentViewVersion', 'CurrentOrganization',
        function ($scope, translate, ContentHostBulkAction, ContentViewVersion, CurrentOrganization) {
            var applyErrata, incrementalUpdate;

            function transitionToTask(task) {
                if ($scope.$stateParams.hasOwnProperty('errataId')) {
                    $scope.transitionTo('errata.details.task-details', {errataId: $scope.$stateParams.errataId,
                        taskId: task.id});
                } else {
                    $scope.transitionTo('errata.tasks.details', {taskId: task.id});
                }
                $scope.applyingErrata = false;
            }

            $scope.successMessages = [];
            $scope.errorMessages = [];
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
                    'errata_ids': $scope.errataIds
                };

                params['content_view_version_environments'] = [];
                params['resolve_dependencies'] = true;

                //get a list of unique content view version ids with their environments
                angular.forEach($scope.updates, function (update) {
                    var versionId = update['content_view_version'].id;

                    if (update.components) {
                        angular.forEach(_.pluck(update.components, 'id'), function (componentId) {
                            if (angular.isUndefined(cvIdEnvIds[componentId])) {
                                cvIdEnvIds[componentId] = [];
                            }
                        });
                    }
                    if (angular.isUndefined(cvIdEnvIds[versionId])) {
                        cvIdEnvIds[versionId] = [];
                    }
                    cvIdEnvIds[versionId] = _.uniq(cvIdEnvIds[versionId].concat(_.pluck(update.environments, 'id')));
                });

                angular.forEach(cvIdEnvIds, function (envIds, cvId) {
                    params['content_view_version_environments'].push({
                        'content_view_version_id': parseInt(cvId, 10),
                        'environment_ids': envIds
                    });
                });

                if ($scope.applyErrata) {
                    params['update_systems'] = $scope.selectedContentHosts;
                }

                error = function (response) {
                    $scope.errorMessages = response.data.errors;
                    $scope.applyingErrata = false;
                };

                ContentViewVersion.incrementalUpdate(params, transitionToTask, error);
            };

            applyErrata = function () {
                var params = $scope.selectedContentHosts, error;

                $scope.applyingErrata = true;

                params['content_type'] = 'errata';
                params.content = $scope.errataIds;
                params['organization_id'] = CurrentOrganization;

                error = function (response) {
                    $scope.errorMessages = response.data.errors;
                    $scope.applyingErrata = false;
                };

                ContentHostBulkAction.installContent(params, transitionToTask, error);
            };

            if ($scope.$stateParams.hasOwnProperty('errataId')) {
                $scope.errataIds = [$scope.$stateParams.errataId];
            } else {
                if ($scope.selectedErrata) {
                    $scope.errataIds = $scope.selectedErrata.included.ids;
                }
            }

            if ($scope.selectedContentHosts && $scope.errataIds) {
                $scope.selectedContentHosts['errata_ids'] = $scope.errataIds;
                $scope.selectedContentHosts['organization_id'] = CurrentOrganization;
                ContentHostBulkAction.availableIncrementalUpdates($scope.selectedContentHosts, function (updates) {
                    $scope.updates = updates;
                });
            }

            $scope.confirmApply = function () {
                if ($scope.updates.length === 0) {
                    applyErrata();
                } else {
                    incrementalUpdate();
                }
            };

            $scope.checkIfIncrementalUpdateRunning();

        }
    ]);
