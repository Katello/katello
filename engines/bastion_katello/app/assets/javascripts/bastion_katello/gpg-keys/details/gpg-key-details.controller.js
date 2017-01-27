/**
 * @ngdoc object
 * @name  Bastion.gpg-keys.controller:GPGKeyDetailsController
 *
 * @requires $scope
 * @requires GPGKey
 * @requires $q
 * @requires translate
 * @requires ApiErrorHandler
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the gpgKey details action pane.
 */
angular.module('Bastion.gpg-keys').controller('GPGKeyDetailsController',
    ['$scope', 'GPGKey', '$q', 'translate', 'ApiErrorHandler', 'Notification', function ($scope, GPGKey, $q, translate, ApiErrorHandler, Notification) {
        $scope.panel = $scope.panel || {error: false, loading: false};

        $scope.gpgKey = GPGKey.get({id: $scope.$stateParams.gpgKeyId}, function () {
            $scope.panel.error = false;
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.save = function (gpgKey) {
            var deferred = $q.defer();

            gpgKey.$update(function (response) {
                deferred.resolve(response);
                Notification.setSuccessMessage(translate('GPG Key updated'));

            }, function (response) {
                deferred.reject(response);
                Notification.setErrorMessage(response.data.displayMessage);
            });

            return deferred.promise;
        };

        $scope.removeGPGKey = function (gpgKey) {
            gpgKey.$delete(function () {
                $scope.transitionTo('gpg-keys');
            });
        };
    }]
);
