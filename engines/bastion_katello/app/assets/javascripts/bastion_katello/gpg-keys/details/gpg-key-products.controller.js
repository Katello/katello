/**
 * @ngdoc object
 * @name  Bastion.gpg-keys.controller:GPGKeyProductsController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires GPGKey
 * @requires ApiErrorHandler
 *
 * @description
 *   Page for GPG Key products
 */
(function () {
    function GPGKeyProductsController($scope, Nutupane, GPGKey, ApiErrorHandler) {
        var nutupane = new Nutupane(GPGKey, {
            id: $scope.$stateParams.gpgKeyId
        }, 'products');
        $scope.controllerName = 'katello_gpg_keys';
        nutupane.masterOnly = true;

        $scope.panel = $scope.panel || {error: false, loading: false};

        $scope.gpgKey = GPGKey.get({id: $scope.$stateParams.gpgKeyId}, function () {
            $scope.panel.error = false;
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.table = nutupane.table;
    }

    angular.module('Bastion.gpg-keys').controller('GPGKeyProductsController', GPGKeyProductsController);
    GPGKeyProductsController.$inject = ['$scope', 'Nutupane', 'GPGKey', 'ApiErrorHandler'];
})();
