/**
 * Copyright 2013-2014 Red Hat, Inc.
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
 * @name  Bastion.activation-keys.controller:ActivationKeyDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires ActivationKey
 * @requires ContentView
 * @requires Organization
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the activation key info details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyDetailsInfoController',
    ['$scope', '$q', 'translate', 'ActivationKey', 'ContentView', 'Organization', 'CurrentOrganization',
        function ($scope, $q, translate, ActivationKey, ContentView, Organization, CurrentOrganization) {

        $scope.editContentView = false;
        $scope.editEnvironment = false;
        $scope.disableEnvironmentSelection = false;
        $scope.selectionRequired = true;
        $scope.environments = [];

        $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

        $scope.$on('activationKey.loaded', function () {
            $scope.originalEnvironment = $scope.activationKey.environment;
        });

        $scope.$watch('activationKey.environment', function (environment) {
            if (environment && $scope.originalEnvironment) {
                if (environment.id !== $scope.originalEnvironment.id) {
                    $scope.editContentView = true;
                    $scope.disableEnvironmentSelection = true;
                }
            } else if (environment) {
                $scope.editEnvironment = true;
                $scope.editContentView = true;
                $scope.disableEnvironmentSelection = true;
            }
        });

        $scope.cancelContentViewUpdate = function () {
            if ($scope.editContentView) {
                $scope.editContentView = false;
                $scope.editEnvironment = false;
                $scope.selectionRequired = false;
                $scope.activationKey.environment = $scope.originalEnvironment;
                $scope.disableEnvironmentSelection = false;
            }
        };

        $scope.saveContentView = function (activationKey) {
            $scope.editContentView = false;
            $scope.editEnvironment = false;
            $scope.save(activationKey).then(function (activationKey) {
                $scope.originalEnvironment = activationKey.environment;
            });
            $scope.disableEnvironmentSelection = false;
        };

        $scope.releaseVersions = function () {
            var deferred = $q.defer();

            ActivationKey.releaseVersions({ id: $scope.activationKey.id }, function (response) {
                deferred.resolve(response.results);
            });

            return deferred.promise;
        };

        $scope.clearReleaseVersion = function () {
            $scope.activationKey['release_version'] = '';
            $scope.save($scope.activationKey);
        };

        $scope.clearServiceLevel = function () {
            $scope.activationKey['service_level'] = '';
            $scope.save($scope.activationKey);
        };

        $scope.contentViews = function () {
            var deferred = $q.defer();

            ContentView.queryUnpaged({ 'environment_id': $scope.activationKey.environment.id }, function (response) {
                deferred.resolve(response.results);
            });

            return deferred.promise;
        };
    }]
);
