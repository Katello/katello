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
 * @name  Bastion.activation-keys.controller:ActivationKeyDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires ActivationKey
 * @requires CurrentOrganization
 * @requires Organization
 *
 * @description
 *   Provides the functionality for the activation key details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyDetailsController',
    ['$scope', '$state', '$q', 'translate', 'ActivationKey', 'Organization', 'CurrentOrganization',
    function ($scope, $state, $q, translate, ActivationKey, Organization, CurrentOrganization) {
        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.copyErrorMessages = [];

        if ($scope.activationKey) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.activationKey = ActivationKey.get({id: $scope.$stateParams.activationKeyId}, function (activationKey) {
            $scope.$broadcast('activationKey.loaded', activationKey);
            $scope.panel.loading = false;
        });

        $scope.save = function (activationKey) {
            var deferred = $q.defer();

            activationKey.$update(function (response) {
                deferred.resolve(response);
                $scope.successMessages.push(translate('Activation Key updated'));
                $scope.table.replaceRow(response);
            }, function (response) {
                deferred.reject(response);
                $scope.errorMessages.push(translate("An error occurred saving the Activation Key: ") + response.data.displayMessage);
            });
            return deferred.promise;
        };

        $scope.setActivationKey = function (activationKey) {
            $scope.activationKey = activationKey;
        };

        $scope.copy = function (newName) {
            ActivationKey.copy({id: $scope.activationKey.id, 'new_name': newName}, function (response) {
                $scope.showCopy = false;
                $scope.table.addRow(response);
                $scope.transitionTo('activation-keys.details.info', {activationKeyId: response['id']});
            }, function (response) {
                $scope.copyErrorMessages.push(response.data.displayMessage);
            });
        };

        $scope.removeActivationKey = function (activationKey) {
            var id = activationKey.id;

            activationKey.$delete(function () {
                $scope.removeRow(id);
                $scope.transitionTo('activation-keys.index');
                $scope.successMessages.push(translate('Activation Key removed.'));
            }, function (response) {
                $scope.errorMessages.push(translate("An error occurred removing the Activation Key: ") + response.data.displayMessage);
            });
        };

        $scope.serviceLevels = function () {
            var deferred = $q.defer();

            Organization.get({id: CurrentOrganization}, function (organization) {
                deferred.resolve(organization['service_levels']);
            });

            return deferred.promise;
        };
    }]
);
