(function () {
    function GPGKeyRepositoriesController($scope, Nutupane, GPGKey, ApiErrorHandler) {
        /**
         * @ngdoc object
         * @name  Bastion.gpg-keys.controller:GPGKeyRepositoriesController
         *
         * @requires $scope
         * @requires Nutupane
         * @requires GPGKey
         * @requires ApiErrorHandler
         *
         * @description
         *   Page for GPG Key repositories
         */
        var nutupane = new Nutupane(GPGKey, {
            id: $scope.$stateParams.gpgKeyId
        }, 'repositories');
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

    angular.module('Bastion.gpg-keys').controller('GPGKeyRepositoriesController', GPGKeyRepositoriesController);
    GPGKeyRepositoriesController.$inject = ['$scope', 'Nutupane', 'GPGKey', 'ApiErrorHandler'];
})();
