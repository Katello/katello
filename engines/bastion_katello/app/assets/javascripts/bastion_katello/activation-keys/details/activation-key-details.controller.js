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
 * @requires Notification
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the activation key details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyDetailsController',
    ['$scope', '$state', '$q', 'translate', 'ActivationKey', 'Organization', 'CurrentOrganization', 'Notification', 'ApiErrorHandler',
    function ($scope, $state, $q, translate, ActivationKey, Organization, CurrentOrganization, Notification, ApiErrorHandler) {
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
                Notification.setSuccessMessage(translate('Activation Key updated'));
            }, function (response) {
                deferred.reject(response);
                Notification.setErrorMessage(translate("An error occurred saving the Activation Key: ") + response.data.displayMessage);
            });
            return deferred.promise;
        };

        $scope.setActivationKey = function (activationKey) {
            $scope.activationKey = activationKey;
        };

        $scope.removeActivationKey = function (activationKey) {
            activationKey.$delete(function () {
                $scope.transitionTo('activation-keys');
                Notification.setSuccessMessage(translate('Activation Key removed.'));
            }, function (response) {
                Notification.setErrorMessage(translate("An error occurred removing the Activation Key: ") + response.data.displayMessage);
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
