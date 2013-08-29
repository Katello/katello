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
 * @name  Bastion.systems.controller:SystemDetailsController
 *
 * @requires $scope
 * @requires $q
 * @requires $http
 * @requires Routes
 * @requires System
 * @requires SystemGroup
 * @requires ContentView
 *
 * @description
 *   Provides the functionality for the system details action pane.
 */
angular.module('Bastion.systems').controller('SystemDetailsInfoController',
    ['$scope', '$q', '$http', 'Routes', 'System', 'SystemGroup', 'ContentView',
    function($scope, $q, $http, Routes, System, SystemGroup, ContentView) {
        var customInfoErrorHandler = function(error) {
            $scope.saveError = true;
            $scope.errors = error["errors"];
        };

        $scope.editContentView = false;
        $scope.saveSuccess = false;
        $scope.saveError = false;
        $scope.previousEnvironment = null;

        $scope.$on('system.loaded', function() {
            $scope.setupSelector();
            $scope.systemFacts = dotNotationToObj($scope.system.facts);
            populateExcludedFacts();
        });

        $scope.save = function(system) {
            var deferred = $q.defer();

            system.$update(function(response) {
                deferred.resolve(response);
                $scope.saveSuccess = true;
            }, function(response) {
                deferred.reject(response);
                $scope.saveError = true;
                $scope.errors = response.data.errors;
            });

            return deferred.promise;
        };

        $scope.setEnvironment = function(environmentId) {
            if ($scope.previousEnvironment !== $scope.system.environment.id) {
                $scope.previousEnvironment = $scope.system.environment.id;
                $scope.system.environment.id = environmentId;
                $scope.editContentView = true;
                $scope.$apply();
            }
        };

        $scope.cancelContentViewUpdate = function() {
            if ($scope.editContentView) {
                $scope.editContentView = false;
                $scope.system.environment.id = $scope.previousEnvironment;
                $scope.pathSelector.select($scope.previousEnvironment);
            }
        };

        $scope.updateSystemGroups = function(systemGroups) {
            var data, success, error, deferred = $q.defer();

            data = {
                system: {
                    "system_group_ids": _.pluck(systemGroups, "id")
                }
            };

            success = function(data) {
                deferred.resolve(data);
            };
            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.saveError = true;
                $scope.errors = error.data["errors"];
            };

            System.saveSystemGroups({id: $scope.system.uuid}, data, success, error);
            return deferred.promise;
        };

        $scope.releaseVersions = function() {
            var deferred = $q.defer();

            System.releaseVersions({ id: $scope.system.uuid }, function(response) {
                deferred.resolve(response);
            });

            return deferred.promise;
        };

        $scope.contentViews = function() {
            var deferred = $q.defer();

            ContentView.query({ 'environment_id': $scope.system.environment.id }, function(response) {
                deferred.resolve(response.results);
            });

            return deferred.promise;
        };

        $scope.systemGroups = function() {
            var deferred = $q.defer();

            SystemGroup.query(function(systemGroups) {
                deferred.resolve(systemGroups);
            });

            return deferred.promise;
        };

        $scope.saveCustomInfo = function(info) {
            var url = [Routes.apiCustomInfoPath("system", $scope.system.id), info.keyname].join('/');
            return $http.put(url, {'custom_info': info}).error(customInfoErrorHandler);
        };

        $scope.addCustomInfo = function(info) {
            var url, success;
            url = Routes.apiCustomInfoPath("system", $scope.system.id);

            success = function() {
                $scope.system.customInfo.push(info);
            };

            return $http.post(url, {'custom_info': info}).success(success).error(customInfoErrorHandler);
        };

        $scope.deleteCustomInfo = function(info) {
            var url, success;
            url = [Routes.apiCustomInfoPath("system", $scope.system.id), info.keyname].join('/');

            success = function() {
                $scope.system.customInfo = _.filter($scope.system.customInfo, function(keyValue) {
                    return keyValue !== info;
                }, this);
            };

            return $http.delete(url).success(success).error(customInfoErrorHandler);
        };

        // TODO upgrade to Angular 1.1.4 so we can move this into a directive
        // and use dynamic templates (http://code.angularjs.org/1.1.4/docs/partials/guide/directive.html)
        $scope.getTemplateForType = function(value) {
            var template = 'systems/details/views/partials/system-detail-value.html';
            if (typeof(value) === 'object') {
                template = 'systems/details/views/partials/system-detail-object.html';
            }
            return template;
        };

        function dotNotationToObj(dotString) {
            var dotObject = {}, tempObject, parts, part, key;
            for (var property in dotString) {
                if (dotString.hasOwnProperty(property)) {
                    tempObject = dotObject;
                    parts = property.split('.');
                    key = parts.pop();
                    while (parts.length) {
                        part = parts.shift();
                        tempObject = tempObject[part] = tempObject[part] || {};
                    }
                    tempObject[key] = dotString[property];
                }
            }
            return dotObject;
        }

        function populateExcludedFacts() {
            $scope.advancedInfoLeft = {};
            $scope.advancedInfoRight = {};
            var index = 0;
            angular.forEach($scope.systemFacts, function(value, key) {
                if (index % 2 === 0) {
                    $scope.advancedInfoLeft[key] = value;
                } else {
                    $scope.advancedInfoRight[key] = value;
                }
                index = index + 1;
            });
            $scope.hasAdvancedInfo = Object.keys($scope.advancedInfoLeft).length > 0 ||
                Object.keys($scope.advancedInfoRight).length > 0;

        }
    }]
);
