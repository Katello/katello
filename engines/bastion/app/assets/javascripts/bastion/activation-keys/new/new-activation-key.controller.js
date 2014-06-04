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
 * @name  Bastion.activation-keys.controller:NewActivationKeyController
 *
 * @requires $scope
 * @requires $q
 * @requires FormUtils
 * @requires ActivationKey
 * @requires Organization
 * @requires CurrentOrganization
 * @requires ContentView
 *
 * @description
 *   Controls the creation of an empty ActivationKey object for use by sub-controllers.
 */
angular.module('Bastion.activation-keys').controller('NewActivationKeyController',
    ['$scope', '$q', 'FormUtils', 'ActivationKey', 'Organization', 'CurrentOrganization', 'ContentView',
    function ($scope, $q, FormUtils, ActivationKey, Organization, CurrentOrganization, ContentView) {

        $scope.activationKey = $scope.activationKey || new ActivationKey();
        $scope.panel = {loading: false};
        $scope.organization = CurrentOrganization;

        $scope.contentViews = [];
        $scope.editContentView = false;
        $scope.environments = [];

        $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

        $scope.$watch('activationKey.environment', function (environment) {
            if (environment) {
                $scope.editContentView = true;
                ContentView.queryUnpaged({ 'environment_id': environment.id }, function (response) {
                    $scope.contentViews = response.results;
                });
            }
        });

        $scope.save = function (activationKey) {
            activationKey['organization_id'] = CurrentOrganization;
            activationKey.$save(success, error);
        };

        $scope.unlimited = true;
        $scope.activationKey['usage_limit'] = -1;

        $scope.isUnlimited = function (activationKey) {
            return activationKey['usage_limit'] === -1;
        };

        $scope.inputChanged = function (activationKey) {
            if ($scope.isUnlimited(activationKey)) {
                $scope.unlimited = true;
            }
        };

        $scope.unlimitedChanged = function (activationKey) {
            if ($scope.isUnlimited(activationKey)) {
                $scope.unlimited = false;
                activationKey['usage_limit'] = 1;
            }
            else {
                $scope.unlimited = true;
                activationKey['usage_limit'] = -1;
            }
        };

        function success(response) {
            $scope.table.addRow(response);
            $scope.transitionTo('activation-keys.details.info', {activationKeyId: $scope.activationKey.id});
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.activationKeyForm[field].$setValidity('server', false);
                $scope.activationKeyForm[field].$error.messages = errors;
            });
        }

    }]
);
