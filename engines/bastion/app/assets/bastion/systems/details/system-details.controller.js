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
 * @requires $state
 * @requires $q
 * @requires System
 * @requires Organization
 *
 * @description
 *   Provides the functionality for the system details action pane.
 */
angular.module('Bastion.systems').controller('SystemDetailsController',
    ['$scope', '$state', '$q', 'System', 'Organization',
    function($scope, $state, $q, System, Organization) {

        if ($scope.system) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.system = System.get({id: $scope.$stateParams.systemId}, function(system) {
            $scope.$watch("table.rows.length > 0", function() {
                $scope.table.replaceRow(system);
            });

            $scope.$broadcast('system.loaded', system);
            $scope.panel.loading = false;
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

        $scope.transitionTo = function(state, params) {
            var systemId = $scope.$stateParams.systemId;

            if ($scope.system && $scope.system.uuid) {
                systemId = $scope.system.uuid;
            }

            if (systemId) {
                params = params ? params : {};
                params.systemId  = systemId;
                $state.transitionTo(state, params);
                return true;
            }
            return false;
        };

        $scope.serviceLevels = function() {
            var deferred = $q.defer();

            Organization.get(function(organization) {
                deferred.resolve(organization['service_levels']);
            });

            return deferred.promise;
        };
    }]
);
