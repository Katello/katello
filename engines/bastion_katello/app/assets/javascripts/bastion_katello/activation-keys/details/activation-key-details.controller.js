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
 * @requires GlobalNotification
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the activation key details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyDetailsController',
    ['$scope', '$state', '$q', 'translate', 'ActivationKey', 'Organization', 'CurrentOrganization', 'GlobalNotification', 'ApiErrorHandler',
    function ($scope, $state, $q, translate, ActivationKey, Organization, CurrentOrganization, GlobalNotification, ApiErrorHandler) {
        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.copyErrorMessages = [];
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.activationKey) {
            $scope.panel.loading = false;
        }

        $scope.activationKey = ActivationKey.get({id: $scope.$stateParams.activationKeyId}, function (activationKey) {
            $scope.$broadcast('activationKey.loaded', activationKey);
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
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
                $scope.transitionTo('activation-keys.details.info', {activationKeyId: response.id});
            }, function (response) {
                $scope.copyErrorMessages.push(response.data.displayMessage);
            });
        };

        $scope.removeActivationKey = function (activationKey) {
            var id = activationKey.id;

            activationKey.$delete(function () {
                $scope.removeRow(id);
                $scope.transitionTo('activation-keys.index');
                GlobalNotification.setSuccessMessage(translate('Activation Key removed.'));
            }, function (response) {
                GlobalNotification.setErrorMessage(translate("An error occurred removing the Activation Key: ") + response.data.displayMessage);
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
