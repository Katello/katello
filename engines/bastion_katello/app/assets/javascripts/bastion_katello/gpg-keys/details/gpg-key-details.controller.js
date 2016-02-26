/**
 * @ngdoc object
 * @name  Bastion.gpg-keys.controller:GPGKeyDetailsController
 *
 * @requires $scope
 * @requires GPGKey
 * @requires $q
 * @requires translate
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the gpgKey details action pane.
 */
angular.module('Bastion.gpg-keys').controller('GPGKeyDetailsController',
    ['$scope', 'GPGKey', '$q', 'translate', 'ApiErrorHandler', function ($scope, GPGKey, $q, translate, ApiErrorHandler) {
        $scope.errorMessages = [];
        $scope.successMessages = [];

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
                $scope.successMessages.push(translate('Gpg Key updated'));
                $scope.table.replaceRow(response);

            }, function (response) {
                deferred.reject(response);
                $scope.errorMessages = [response.data.displayMessage];
            });

            return deferred.promise;
        };

        $scope.removeGPGKey = function (gpgKey) {
            var id = gpgKey.id;

            gpgKey.$delete(function () {
                $scope.removeRow(id);
                $scope.transitionTo('gpgKeys.index');
            });
        };
    }]
);
