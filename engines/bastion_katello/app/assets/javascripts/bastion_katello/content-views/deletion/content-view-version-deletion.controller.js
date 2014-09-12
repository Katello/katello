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
 * @name  Bastion.content-views.controller:ContentViewVersionDeletion
 *
 * @requires $scope
 * @requires ContentViewVersion
 * @requires ContentView
 *
 * @description
 *   Provides the base controller functionality for content view deletion including
 *   keeping track of selections through the workflow.
 *   Also provides logic to control the content view & environment selector for the two
 *   child controllers that use it.
 */
angular.module('Bastion.content-views').controller('ContentViewVersionDeletionController',
    ['$scope', '$state', 'ContentViewVersion', 'ContentView',
    function ($scope, $state, ContentViewVersion, ContentView) {

        $scope.version = ContentViewVersion.get({id: $scope.$stateParams.versionId});

        $scope.stepStates = {
            environments: 'content-views.details.version-deletion.environments',
            activationKeys: 'content-views.details.version-deletion.activation-keys',
            contentHosts: 'content-views.details.version-deletion.content-hosts',
            confirm: 'content-views.details.version-deletion.confirm'
        };

        if ($scope.deleteOptions === undefined) {
            $scope.deleteOptions = {
                deleteArchive: false,
                environments: [],
                contentHosts: {},
                activationKeys: {}
            };
        }

        $scope.isStep = function (step) {
            return $state.is($scope.stepStates[step]);
        };

        $scope.transitionToNext = function (currentState) {
            var stepStates = $scope.stepStates;
            if (currentState === undefined) {
                currentState = $state.current.name;
            }

            if (currentState === stepStates.environments) {
                if ($scope.needHosts()) {
                    $scope.transitionTo(stepStates.contentHosts,
                                        {contentViewId: $scope.contentView.id, versionId: $scope.version.id});
                } else {
                    $scope.transitionToNext(stepStates.contentHosts);
                }
            } else if (currentState === stepStates.contentHosts) {
                if ($scope.needActivationKeys()) {
                    $scope.transitionTo(stepStates.activationKeys,
                                        {contentViewId: $scope.contentView.id, versionId: $scope.version.id});
                } else {
                    $scope.transitionToNext(stepStates.activationKeys);
                }
            } else {
                $scope.transitionTo(stepStates.confirm,
                                    {contentViewId: $scope.contentView.id, versionId: $scope.version.id});
            }
        };

        $scope.transitionBack = function (currentState) {
            var stepStates = $scope.stepStates;
            if (currentState === undefined) {
                currentState = $state.current.name;
            }

            if (currentState === stepStates.confirm) {
                if ($scope.needActivationKeys()) {
                    $scope.transitionTo(stepStates.activationKeys,
                                        {contentViewId: $scope.contentView.id, versionId: $scope.version.id});
                } else {
                    $scope.transitionBack(stepStates.activationKeys);
                }
            }
            else if (currentState === stepStates.activationKeys) {
                if ($scope.needHosts()) {
                    $scope.transitionTo(stepStates.contentHosts,
                                        {contentViewId: $scope.contentView.id, versionId: $scope.version.id});
                } else {
                    $scope.transitionBack(stepStates.contentHosts);
                }
            }
            else if (currentState === stepStates.contentHosts) {
                $scope.transitionTo(stepStates.environments,
                                    {contentViewId: $scope.contentView.id, versionId: $scope.version.id});
            }
        };

        $scope.validateEnvironmentSelection = function () {
            if (!$scope.deleteOptions.deleteArchive && $scope.deleteOptions.environments.length === 0) {
                $scope.transitionTo("content-views.details.version-deletion.environments",
                        {contentViewId: $scope.$stateParams.contentViewId, versionId: $scope.$stateParams.versionId});
            }
        };

        $scope.needHosts = function () {
            return $scope.totalHostCount() > 0;
        };

        $scope.needActivationKeys = function () {
            return $scope.totalActivationKeyCount() > 0;
        };

        $scope.selectedEnvironmentIds = function () {
            return _.pluck($scope.deleteOptions.environments, 'id');
        };

        $scope.totalHostCount = function () {
            return _.reduce($scope.deleteOptions.environments, function (sum, env) {
                return sum +  env['system_count'];
            }, 0);
        };

        $scope.totalActivationKeyCount = function () {
            return _.reduce($scope.deleteOptions.environments, function (sum, env) {
                return sum +  env['activation_key_count'];
            }, 0);
        };

        $scope.searchString = function (contentView, environments) {
            var envStrings = [],
                string = 'content_view:"%s"'.replace('%s', contentView.name);

            angular.forEach(environments, function (environment) {
                envStrings.push('environment:"%s"'.replace('%s', environment.name));
            });
            string = string + " AND (" + envStrings.join(" OR ") + ")";
            return string.replace(/"/g, "%22");
        };

        $scope.initEnvironmentWatch = function (childScope) {
            var removingEnvironment;
            childScope.$watch('selectedEnvironment', function () {
                if (childScope.selectedEnvironment === undefined) {
                    childScope.contentViewsForEnvironment = [];
                } else {
                    removingEnvironment = _.findWhere(childScope.deleteOptions.environments,
                                                 {id: childScope.selectedEnvironment.id}) !== undefined;
                    $scope.fetchingViews = true;
                    ContentView.queryUnpaged({ 'environment_id': childScope.selectedEnvironment.id },
                        function (response) {
                            $scope.fetchingViews = false;
                            childScope.contentViewsForEnvironment = _.reject(response.results, function (view) {
                                return (view.id === childScope.version['content_view_id']) && removingEnvironment;
                            });
                        }
                    );
                }
            });
        };

    }]
);
