/**
 * @ngdoc object
 * @name  Bastion.gpg-keys.controller:GPGKeyDetailsController
 *
 * @requires $scope
 * @requires GPGKey
 * @requires $q
 * @requires translate
 *
 * @description
 *   Provides the functionality for the gpgKey details action pane.
 */
angular.module('Bastion.gpg-keys').controller('GPGKeyDetailsController',
    ['$scope', 'GPGKey', '$q', 'translate', function ($scope, GPGKey, $q, translate) {
        $scope.errorMessages = [];
        $scope.successMessages = [];

        $scope.panel = $scope.panel || {loading: false};

        $scope.gpgKey = GPGKey.get({id: $scope.$stateParams.gpgKeyId}, function () {
            $scope.panel.loading = false;
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
