/**
 * Copyright 2013 Red Hat, Inc.
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
 * @name  Bastion.environments.controller:PathController
 *
 * @requires $scope
 * @requires $q
 * @requires gettext
 * @requires $timeout
 * @requires $http
 * @requires Routes
 * @requires Environment
 * @requires FormUtils
 *
 * @description
 *   Provides the functionality for managing a single environment path..
 */
angular.module('Bastion.environments').controller('PathController',
    ['$scope', '$q', 'gettext', '$timeout', '$http', 'Routes', 'Environment', 'FormUtils',
        function($scope, $q, gettext, $timeout, $http, Routes, Environment, FormUtils) {

            $scope.environment = {};
            $scope.working = false;
            $scope.workingOn = {environment: undefined};

            $scope.workingOn = {
                environment: undefined
            };

            $scope.selectEnvironment = function(environment) {
                if (!environment.library) {
                    $scope.close();

                    $scope.workingOn.environment = environment;
                    $scope.environmentsTable.rows[$scope.row.pathId].showEdit = true;
                }
            };

            $scope.close = function() {
                $scope.workingOn.busy = false;
                $scope.workingOn.environment = undefined;
                $scope.row.showCreate = false;
                $scope.row.showEdit = false;
                $scope.environment = {};
            };

            $scope.update = function(environment) {
                var deferred = $q.defer();

                Environment.update(environment, function(response) {
                    deferred.resolve(response);
                    $scope.successMessages.push(gettext('Save Successful.'));
                }, function(response) {
                    deferred.reject(response);
                    _.each(response.data.errors, function(errorMessage) {
                        $scope.errorMessages.push(gettext("An error occurred saving the environment: ") + errorMessage);
                    });
                });

                return deferred.promise;
            };

            $scope.isLastEnvironment = function(environment) {
                if ($scope.row.path.length > 0 &&
                    $scope.row.path[$scope.row.path.length - 1].environment === environment) {
                    return true;
                } else {
                    return false;
                }
            };

            $scope.remove = function(environment) {
                var deferred = $q.defer();

                Environment.delete(environment, function(response) {
                    deferred.resolve(response);

                    $scope.close(environment);
                    removeEnvironment(environment);
                    $scope.successMessages.push(gettext('Remove Successful.'));

                }, function(response) {
                    deferred.reject(response);
                    _.each(response.data.errors, function(errorMessage) {
                        $scope.errorMessages.push(gettext("An error occurred removing the environment: ") + errorMessage);
                    });
                });

                return deferred.promise;
            };

            function removeEnvironment(environment) {
                // Remove the environment from the path.  If it is the only environment
                // in the path, remove the path.
                $scope.row.path = _.reject($scope.row.path, function(item) {
                    return item.environment === environment;
                }, this);

                if ($scope.row.path.length === 1 && $scope.row.path[0].environment.library) {
                    $scope.row.path.splice(0, 1);
                }
            }

            $scope.initiateCreateEnvironment = function() {
                $scope.close();
                $scope.row.showCreate = true;
            };

            $scope.$watch('environment.name', function() {
                if ($scope.environmentForm.name) {
                    $scope.environmentForm.name.$setValidity('server', true);
                    FormUtils.labelize($scope.environment, $scope.environmentForm);
                }
            });

            $scope.create = function(environment) {
                var deferred = $q.defer();

                $scope.workingOn.busy = true;
                environment.prior = $scope.row.path[$scope.row.path.length - 1].environment.id;

                Environment.save(environment, function (response) {
                    deferred.resolve(response);

                    // add the new environment to the path
                    $scope.row.path.push({environment: response});

                    $scope.close();
                    $scope.workingOn.busy = false;
                    $scope.successMessages.push(gettext('Create Successful.'));

                }, function(response) {
                    deferred.reject(response);
                    $scope.workingOn.busy = false;
                    _.each(response.data.errors, function(errorMessage) {
                        $scope.errorMessages.push(gettext("An error occurred creating the environment: ") + errorMessage);
                    });
                });

                return deferred.promise;
            };

        }]
);
