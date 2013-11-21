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
 * @requires gettext
 * @requires Routes
 * @requires System
 * @requires SystemGroup
 * @requires ContentView
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the system details action pane.
 */
angular.module('Bastion.systems').controller('SystemDetailsInfoController',
    ['$scope', '$q', '$http', 'gettext', 'Routes', 'System', 'SystemGroup', 'ContentView', 'CurrentOrganization',
    function($scope, $q, $http, gettext, Routes, System, SystemGroup, ContentView, CurrentOrganization) {

        var templatePrefix = '../';

        var customInfoErrorHandler = function(error) {
            _.each(error.errors, function(errorMessage) {
                $scope.errorMessages.push(gettext("An error occurred updating Custom Information: ") + errorMessage);
            });
        };

        $scope.editContentView = false;

        $scope.$on('system.loaded', function() {
            $scope.setupSelector();
            $scope.systemFacts = dotNotationToObj($scope.system.facts);
            populateExcludedFacts();
        });

        $scope.setEnvironment = function(environmentId) {
            environmentId = parseInt(environmentId, 10);

            if ($scope.previousEnvironment !== environmentId) {
                $scope.previousEnvironment = $scope.system.environment.id;
                $scope.system.environment.id = environmentId;
                $scope.editContentView = true;

                /*jshint camelcase:false*/
                $scope.pathSelector.disable_all();
            }
        };

        $scope.cancelContentViewUpdate = function() {
            if ($scope.editContentView) {
                $scope.editContentView = false;
                $scope.system.environment.id = $scope.previousEnvironment;

                /*jshint camelcase:false*/
                $scope.pathSelector.enable_all();
                $scope.pathSelector.select($scope.previousEnvironment);
            }
        };

        $scope.saveContentView = function(system) {
            $scope.previousEnvironment = undefined;
            $scope.save(system);

            /*jshint camelcase:false*/
            $scope.pathSelector.enable_all();
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
                $scope.successMessages.push('System Saved.');
            };
            error = function(error) {
                deferred.reject(error.data.errors);
                _.each(error.data.errors, function(errorMessage) {
                    $scope.errorMessages.push(gettext("An error occurred updating System Groups: ") + errorMessage);
                });
            };

            System.saveSystemGroups({id: $scope.system.uuid}, data, success, error);
            return deferred.promise;
        };

        $scope.releaseVersions = function() {
            var deferred = $q.defer();

            System.releaseVersions({ id: $scope.system.uuid }, function(response) {
                deferred.resolve(response.results);
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

            SystemGroup.query({'organization_id': CurrentOrganization}, function(systemGroups) {
                deferred.resolve(systemGroups['results']);
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

        $scope.getActivationKeyLink = function(activationKey) {
            var panel = '/!=&panel=activation_key_%s&panelpage=edit'.replace('%s', activationKey.id);
            return Routes.activationKeysPath({anchor: panel});
        };

        $scope.getTemplateForType = function(value) {
            var template = templatePrefix + 'systems/details/views/partials/system-detail-value.html';
            if (typeof(value) === 'object') {
                template = templatePrefix + 'systems/details/views/partials/system-detail-object.html';
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

        $scope.memory = function(facts) {
            var mem;
            if (facts !== undefined) {
                if (facts.memory !== undefined) {
                    mem = facts.memory["memtotal"];
                }
                if (mem === undefined && facts.dmi !== undefined &&
                   facts.dmi.memory !== undefined) {
                    mem = facts.dmi.memory["size"];
                }
                return memoryInGigabytes(mem);
            } else {
                return "0";
            }
        };

        function memoryInGigabytes(memStr) {
            var mems,
                memory,
                unit;

            if (memStr === undefined || memStr === "") {
                return "0";
            }

            mems = memStr.split(/\s+/);
            memory = parseFloat(mems[0]);
            unit = mems[1];

            switch(unit) {
                case 'B':
                memory = 0;
                break;

                case 'kB':
                memory = 0;
                break;

                case 'MB':
                memory /= 1024;
                break;

                case 'GB':
                break;

                case 'TB':
                memory *= 1024;
                break;

                default:
                // by default memory is in kB
                memory /= (1024 * 1024);
                break;
            }

            memory = Math.round(memory * 100) / 100;
            return memory;
        }
    }]
);
