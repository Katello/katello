/**
 * @ngdoc object
 * @name  Bastion.content-credentials.controller:ContentCredentialProductsController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires ContentCredential
 * @requires ApiErrorHandler
 *
 * @description
 *   Page for Content Credential products
 */
(function () {
    function ContentCredentialProductsController($scope, Nutupane, ContentCredential, ApiErrorHandler) {
        var nutupane = new Nutupane(ContentCredential, {
            id: $scope.$stateParams.contentCredentialId
        }, 'products');
        $scope.controllerName = 'katello_gpg_keys';
        nutupane.masterOnly = true;

        $scope.panel = $scope.panel || {error: false, loading: false};

        $scope.contentCredential = ContentCredential.get({id: $scope.$stateParams.contentCredentialId}, function () {
            $scope.panel.error = false;
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.table = nutupane.table;
    }

    angular.module('Bastion.content-credentials').controller('ContentCredentialProductsController', ContentCredentialProductsController);
    ContentCredentialProductsController.$inject = ['$scope', 'Nutupane', 'ContentCredential', 'ApiErrorHandler'];
})();
