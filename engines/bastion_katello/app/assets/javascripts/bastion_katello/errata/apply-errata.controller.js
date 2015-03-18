/**
 * Copyright 2015 Red Hat, Inc.
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

            $scope.successMessages = [];
            $scope.errorMessages = [];
            $scope.applyingErrata = false;

            $scope.hasComposites = function (updates) {
                if (updates) {
                    var composite = _.find(updates, function (update) {
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
                var success, error, params = {}, cvIdEnvIds = {};

                $scope.applyingErrata = true;

                params['add_content'] = {
                    'errata_ids': $scope.errataIds
                };

                params['content_view_version_environments'] = [];
                params['resolve_dependencies'] = true;

                //get a list of unique content view verion ids with their environments
                angular.forEach($scope.updates, function (update) {
                    var versionId = update['content_view_version'].id;

                    if (update.components) {
                        angular.forEach(_.pluck(update.components, 'id'), function (componentId) {
                            if (cvIdEnvIds[componentId] === undefined) {
                                cvIdEnvIds[componentId] = [];
                            }
                        });
                    }
                    if (cvIdEnvIds[versionId] === undefined) {
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

                success = function (response) {
                    if ($scope.$stateParams.hasOwnProperty('errataId')) {
                        $scope.transitionTo('errata.details.task-details', {errataId: $scope.$stateParams.errataId,
                            taskId: response.id});
                    } else {
                        $scope.transitionTo('errata.tasks.details', {taskId: response.id});
                    }
                    $scope.applyingErrata = false;
                };

                error = function (response) {
                    $scope.errorMessages = response.data.errors;
                    $scope.applyingErrata = false;
                };

                ContentViewVersion.incrementalUpdate(params, success, error);
            };

            applyErrata = function () {
                var params = $scope.selectedContentHosts, success, error;

                $scope.applyingErrata = true;

                params['content_type'] = 'errata';
                params.content = $scope.errataIds;
                params['organization_id'] = CurrentOrganization;

                success = function () {
                    $scope.transitionTo('errata.index');
                    $scope.successMessages = [translate("Successfully scheduled installation of errata")];
                    $scope.applyingErrata = false;
                };

                error = function (response) {
                    $scope.errorMessages = response.data.errors;
                    $scope.applyingErrata = false;
                };

                ContentHostBulkAction.installContent(params, success, error);
            };

            if ($scope.$stateParams.hasOwnProperty('errataId')) {
                $scope.errataIds = [$scope.$stateParams.errataId];
            } else {
                if ($scope.selectedErrata) {
                    $scope.errataIds = $scope.selectedErrata.included.ids;
                }
            }

            if ($scope.selectedContentHosts) {
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
